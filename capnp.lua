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
      local defs = sn[sn.union.typ]
      if not defs then
         defs = {}
         sn[sn.union.typ] = defs
      end
      defs[sn.union.idx or (#defs + 1)] = value.typ
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
         schema(sn.ptr and sn.ptr[i] or ("ptr " .. tostring(i))))
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

function schema.new(name, tab)
   schema[name] = tab
   tab.name = name
end

schema.new(
   "Message",
   {
      union = {
         offset = 0, typ = "ptr", idx = 0,

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

schema.new(
   "Resolve",
   {
      union = {
         offset = 4,
         [0] = { name = "cap", typ = "CapDescriptor" },
         [1] = { name = "exception", typ = "Exception" }
      },
      data = {
         { offset = 0, size = 4, typ = "uint", name = "promiseId" }
      }
   }
)

schema.new(
   "Restore",
   {
      data = {
         { offset = 0, size = 4, typ = "uint", name = "questionId"}
      },
      ptr = {
         [0] = "SturdyRefObjectId"
      }
   }
)
