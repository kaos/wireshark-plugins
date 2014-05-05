--
--  Copyright 2014, Andreas Stenius <kaos@astekk.se>
--
--   Licensed under the Apache License, Version 2.0 (the "License");
--   you may not use this file except in compliance with the License.
--   You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
--   Unless required by applicable law or agreed to in writing, software
--   distributed under the License is distributed on an "AS IS" BASIS,
--   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--   See the License for the specific language governing permissions and
--   limitations under the License.
--
local proto = Proto("capnp", "Cap'n Proto RPC Protocol")
proto.fields.count = ProtoField.uint32("capnp.count", "Count")
proto.fields.size = ProtoField.uint32("capnp.size", "Size")
proto.fields.offset = ProtoField.int32("capnp.offset", "Offset")
proto.fields.dsize = ProtoField.uint16("capnp.dsize", "Data size")
proto.fields.psize = ProtoField.uint16("capnp.psize", "Pointers")
proto.fields.data = ProtoField.bytes("capnp.data", "Data")
proto.fields.text = ProtoField.string("capnp.text", "Text")

local data_dis = Dissector.get("data")
local dissect = {}
local schema = {}

function proto.dissector(buf, pkt, root)
   if buf(0,1):bitfield(6, 2) == 0 then
      pkt.cols.protocol:set("CAPNP")
      dissect.message(buf, pkt, root:add(proto, buf(0)), schema("Message"))
   end
   data_dis:call(buf, pkt, root)
end

DissectorTable.get("tcp.port"):add(55000, proto)

function dissect.message(buf, pkt, root, sn)
   local tree = root
   local count = buf(0,4):le_uint() + 1
   local data = buf(4 * (count + count % 2)):tvb()
   local segs = {}
   local seg_tree = tree:add_le(proto.fields.count, buf(0,4), count)

   for i = 1, count do
      local b_size = buf(4 * i, 4)
      local size = b_size:le_uint() * 8
      segs[i-1] = data(0, size):tvb()
      data_dis:call(
         segs[i-1], pkt,
         seg_tree:add_le(proto.fields.size, b_size))
      data = data(size):tvb()
   end

   dissect.ptr(0, 0, segs, pkt, tree, sn)
end

function dissect.ptr(seg, pos, segs, pkt, root, sn)
   local kind = segs[seg](pos, 1):bitfield(6, 2)
   local dis = function ()
      local ref = segs[seg](pos, 8):tvb()
      print(table.concat(
               {"packet", pkt.number, seg, pos,
                "unknown (or NYI) pointer", tostring(ref)}, " "))
      data_dis:call(ref, pkt, root)
   end

   if kind == 0 then
      dis = dissect.struct
   elseif kind == 1 then
      dis = dissect.list
   elseif kind == 2 then
      -- far ptr, NYI
   elseif kind == 3 then
      if segs[seg](pos, 4):le_uint() == 3 then
         dis = dissect.cap
      end
   end

   dis(seg, pos, segs, pkt, root, sn)
end

function dissect.struct(seg, pos, segs, pkt, root, sn)
   local buf = segs[seg]
   local offset = buf(pos, 4):le_int() / 4
   local dsize = buf(pos + 4, 2):le_uint()
   local psize = buf(pos + 6, 2):le_uint()
   local tree = root:add(buf(pos, 8), "struct", sn.name)

   tree:add_le(proto.fields.offset, buf(pos, 4), offset)
   data_tree = tree:add_le(proto.fields.dsize, buf(pos + 4, 2))
   if dsize > 0 then
      dissect.struct_data(
         buf(pos + (offset + 1) * 8, dsize * 8),
         pkt, data_tree, sn)
   end
   dissect.struct_ptrs(
      seg, pos + (offset + dsize + 1) * 8,
      psize, segs, pkt,
      tree:add_le(proto.fields.psize, buf(pos + 6, 2)),
      sn)
end

function dissect.struct_data(buf, pkt, tree, sn)
   tree:add(proto.fields.data, buf)

   if sn.union then
      local tag = buf(sn.union.offset, 2)
      local value = sn.union[tag:le_uint()] or {}
      tree:add(tag, "union", value.name or "(unknown tag)")
      local def = value.def or sn.union.def
      if def and def ~= "void" then
         local defs = sn[def]
         if not defs then
            defs = {}
            sn[def] = defs
         end
         defs[value.idx or sn.union.idx or (#defs + 1)] = value
      end
   end

   for k,v in ipairs(sn.data or {}) do
      local b = buf(v.offset, v.size)
      if v.typ == "uint" then
         tree:add(b, v.name, ":", b:le_uint())
      else
         tree:add(b, v.name, v.typ)
      end
   end
end

function dissect.struct_ptrs(seg, pos, count, segs, pkt, tree, sn)
   for i = 0, count - 1 do
      dissect.ptr(
         seg, pos + (i * 8), segs, pkt, tree,
         schema(sn.ptr and sn.ptr[i].typ or ("ptr " .. tostring(i))))
   end
end

local list_element_size = {0, 1, 8, 16, 32, 64, "ptr", "composite"}

function dissect.list(seg, pos, segs, pkt, root, sn)
   local buf = segs[seg]
   local offset = math.floor(buf(pos, 4):le_int() / 4)
   local count = buf(pos + 4, 4):le_uint() / 8
   local esize = list_element_size[buf(pos + 4, 1):bitfield(5, 3) + 1]

   local tree = root:add(buf(pos, 8), "list", sn.name)
   tree:add(proto.fields.offset, buf(pos, 4), offset)
   tree:add(proto.fields.count, buf(pos + 4, 4), count)

   if type(esize) == "number" then
      tree:add(proto.fields.size, buf(pos + 4, 1), esize)
      local data = buf(pos + (offset + 1) * 8, (count * esize) / 8)
      if esize == 8 then
         tree:add(proto.fields.text, data, data:string())
      else
         tree:add(proto.fields.data, data)
      end
   end
end

function dissect.cap(seg, pos, segs, pkt, root)
   local buf = segs[seg]
   local idx = buf(pos + 4, 4):le_uint()
   root:add(buf(pos, 8), "capability", idx)
end

local meta_schema = {
   __index = function (tab, key)
      return { name = "(" .. tostring(key) .. ")" }
   end,
   __call = function (tab, typ)
      return setmetatable({}, { __index = tab[typ] })
   end
}

setmetatable(schema, meta_schema)

function schema.add(name, tab)
   schema[name] = tab
   tab.name = name
end

schema.add(
   "Message",
   {
      union = {
         offset = 0, def = "ptr", idx = 0,

         [0] = { name = "unimplemented", typ = "Message" },
         [1] = { name = "abort", typ = "Exception" },
         [2] = { name = "call", typ = "Call" },
         [3] = { name = "return", typ = "Return" },
         [4] = { name = "finish", typ = "Finish" },
         [5] = { name = "resolve", typ = "Resolve" },
         [6] = { name = "release", typ = "Release"},
         [7] = { name = "save", typ = "Save"},
         [8] = { name = "restore", typ = "Restore"},
         [9] = { name = "delete", typ = "Delete"},
         [10] = { name = "provide", typ = "Provide"},
         [11] = { name = "accept", typ = "Accept"},
         [12] = { name = "join", typ = "Join"},
         [13] = { name = "disembargo", typ = "Disembargo"}
      }
   }
)

schema.add(
   "Exception",
   {
      data = {
         { offset = 0, size = 1, typ = "bool", name = "isCallersFault" },
         { offset = 2, size = 2, typ = "Durability", name = "durability" }
      },
      ptr = {
         [0] = { name = "reason", typ = "text" }
      }
   }
)

schema.add(
   "Call",
   {
      data = {
         { offset = 0, size = 4, typ = "uint", name = "questionId" },
         { offset = 8, size = 8, typ = "uint64", name = "interfaceId" },
         { offset = 4, size = 2, typ = "uint", name = "methodId" },
         { offset = 16, size = 1, typ = "bool", name = "allowThirdPartyTailCall" }
      },
      ptr = {
         [0] = { name = "target", typ = "MessageTarget" },
         [1] = { name = "params", typ = "Payload" }
      },
      union = {
         offset = 6,
         [0] = { name = "caller" },
         [1] = { name = "yourself" },
         [2] = { name = "thirdParty", def = "ptr", idx = 2, typ = "AnyPointer" }
      }
   }
)

schema.add(
   "Return",
   {
      data = {
         { offset = 0, size = 4, typ = "uint", name = "answerId" },
         { offset = 4, size = 1, typ = "bool", name = "releaseParamCaps", default = 1 }
      },
      union = {
         offset = 6, def = "ptr", idx = 0,
         [0] = { name = "results", typ = "Payload" },
         [1] = { name = "exception", typ = "Exception" },
         [2] = { name = "canceled", def = "void" },
         [3] = { name = "resultsSentElsewhere", def = "void" },
         [4] = { name = "takeFromOtherQuestion", def = "data", offset = 8, size = 4, typ = "uint" },
         [5] = { name = "acceptFromThirdParty", typ = "AnyPointer" }
      }
   }
)

schema.add(
   "Finish",
   {
      data = {
         { offset = 0, size = 4, typ = "uint", name = "questionId" },
         { offset = 4, size = 1, typ = "bool", name = "releaseResultCaps", default = 1 }
      }
   }
)

schema.add(
   "Resolve",
   {
      data = {
         { offset = 0, size = 4, typ = "uint", name = "promiseId" }
      },
      union = {
         offset = 4,
         [0] = { name = "cap", typ = "CapDescriptor" },
         [1] = { name = "exception", typ = "Exception" }
      }
   }
)

-- struct Release @0xad1a6c0d7dd07497 {  # 8 bytes, 0 ptrs, packed as 64-bit
--   id @0 :UInt32;  # bits[0, 32)
--   referenceCount @1 :UInt32;  # bits[32, 64)
-- }
-- struct Disembargo @0xf964368b0fbd3711 {  # 8 bytes, 1 ptrs
--   target @0 :MessageTarget;  # ptr[0]
--   context :group {
--     union {  # tag bits [32, 48)
--       senderLoopback @1 :UInt32;  # bits[0, 32), union tag = 0
--       receiverLoopback @2 :UInt32;  # bits[0, 32), union tag = 1
--       accept @3 :Void;  # bits[0, 0), union tag = 2
--       provide @4 :UInt32;  # bits[0, 32), union tag = 3
--     }
--   }
-- }
-- struct Save @0xe40ef0b4b02e882c {  # 8 bytes, 1 ptrs
--   questionId @0 :UInt32;  # bits[0, 32)
--   target @1 :MessageTarget;  # ptr[0]
-- }

schema.add(
   "Restore",
   {
      data = {
         { offset = 0, size = 4, typ = "uint", name = "questionId"}
      },
      ptr = {
         [0] = { name = "objectId", typ = "SturdyRefObjectId" }
      }
   }
)

-- struct Delete @0x86267432565dee97 {  # 8 bytes, 1 ptrs
--   questionId @0 :UInt32;  # bits[0, 32)
--   objectId @1 :AnyPointer;  # ptr[0]
-- }
-- struct Provide @0x9c6a046bfbc1ac5a {  # 8 bytes, 2 ptrs
--   questionId @0 :UInt32;  # bits[0, 32)
--   target @1 :MessageTarget;  # ptr[0]
--   recipient @2 :AnyPointer;  # ptr[1]
-- }
-- struct Accept @0xd4c9b56290554016 {  # 8 bytes, 1 ptrs
--   questionId @0 :UInt32;  # bits[0, 32)
--   provision @1 :AnyPointer;  # ptr[0]
--   embargo @2 :Bool;  # bits[32, 33)
-- }
-- struct Join @0xfbe1980490e001af {  # 8 bytes, 2 ptrs
--   questionId @0 :UInt32;  # bits[0, 32)
--   target @1 :MessageTarget;  # ptr[0]
--   keyPart @2 :AnyPointer;  # ptr[1]
-- }
-- struct MessageTarget @0x95bc14545813fbc1 {  # 8 bytes, 1 ptrs
--   union {  # tag bits [32, 48)
--     importedCap @0 :UInt32;  # bits[0, 32), union tag = 0
--     promisedAnswer @1 :PromisedAnswer;  # ptr[0], union tag = 1
--   }
-- }
-- struct Payload @0x9a0e61223d96743b {  # 0 bytes, 2 ptrs
--   content @0 :AnyPointer;  # ptr[0]
--   capTable @1 :List(CapDescriptor);  # ptr[1]
-- }
-- struct CapDescriptor @0x8523ddc40b86b8b0 {  # 8 bytes, 1 ptrs
--   union {  # tag bits [0, 16)
--     none @0 :Void;  # bits[0, 0), union tag = 0
--     senderHosted @1 :UInt32;  # bits[32, 64), union tag = 1
--     senderPromise @2 :UInt32;  # bits[32, 64), union tag = 2
--     receiverHosted @3 :UInt32;  # bits[32, 64), union tag = 3
--     receiverAnswer @4 :PromisedAnswer;  # ptr[0], union tag = 4
--     thirdPartyHosted @5 :ThirdPartyCapDescriptor;  # ptr[0], union tag = 5
--   }
-- }
-- struct PromisedAnswer @0xd800b1d6cd6f1ca0 {  # 8 bytes, 1 ptrs
--   questionId @0 :UInt32;  # bits[0, 32)
--   transform @1 :List(Op);  # ptr[0]
--   struct Op @0xf316944415569081 {  # 8 bytes, 0 ptrs, packed as 32-bit
--     union {  # tag bits [0, 16)
--       noop @0 :Void;  # bits[0, 0), union tag = 0
--       getPointerField @1 :UInt16;  # bits[16, 32), union tag = 1
--     }
--   }
-- }
-- struct SturdyRef @0xce8c7a90684b48ff {  # 0 bytes, 2 ptrs
--   hostId @0 :AnyPointer;  # ptr[0]
--   objectId @1 :AnyPointer;  # ptr[1]
-- }
-- struct ThirdPartyCapDescriptor @0xd37007fde1f0027d {  # 8 bytes, 1 ptrs
--   id @0 :AnyPointer;  # ptr[0]
--   vineId @1 :UInt32;  # bits[0, 32)
-- }

-- struct Exception @0xd625b7063acf691a {  # 8 bytes, 1 ptrs
--   reason @0 :Text;  # ptr[0]
--   isCallersFault @1 :Bool;  # bits[0, 1)
--   durability @2 :Durability;  # bits[16, 32)
--   enum Durability @0xbbaeda2607b6f958 {
--     permanent @0;
--     temporary @1;
--     overloaded @2;
--   }
-- }
