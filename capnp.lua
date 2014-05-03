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
proto.fields.struct = ProtoField.bytes("capnp.struct", "Struct")
proto.fields.offset = ProtoField.int32("capnp.offset", "Offset")
proto.fields.dsize = ProtoField.uint16("capnp.dsize", "Data size")
proto.fields.psize = ProtoField.uint16("capnp.psize", "Pointers")
proto.fields.data = ProtoField.bytes("capnp.data", "Data")
proto.fields.list = ProtoField.bytes("capnp.list", "List")
proto.fields.text = ProtoField.string("capnp.text", "Text")

local data_dis = Dissector.get("data")
local dissect = {}

function proto.dissector(buf, pkt, root)
   if buf(0,1):bitfield(6, 2) == 0 then
      pkt.cols.protocol:set("CAPNP")
      dissect.message(buf, pkt, root:add(proto, buf(0)))
   end
   data_dis:call(buf, pkt, root)
end

DissectorTable.get("tcp.port"):add(55000, proto)

function dissect.message(buf, pkt, root)
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

   dissect.ptr(0, 0, segs, pkt, tree)
end

function dissect.ptr(seg, pos, segs, pkt, root)
   local kind = segs[seg](pos, 1):bitfield(6, 2)
   local dis = function ()
      local ref = segs[seg](pos, 8):tvb()
      print(table.concat(
               {"packet", pkt.number, seg, pos,
                "unknown pointer", tostring(ref)}, " "))
      data_dis:call(ref, pkt, root)
   end

   if kind == 0 then
      dis = dissect.struct
   elseif kind == 1 then
      dis = dissect.list
   end

   dis(seg, pos, segs, pkt, root)
end

function dissect.struct(seg, pos, segs, pkt, root)
   local buf = segs[seg]
   local offset = buf(pos, 4):le_int() / 4
   local dsize = buf(pos + 4, 2):le_uint()
   local psize = buf(pos + 6, 2):le_uint()
   local tree = root:add(proto.fields.struct, buf(pos, 8))

   tree:add_le(proto.fields.offset, buf(pos, 4), offset)
   data_tree = tree:add_le(proto.fields.dsize, buf(pos + 4, 2))
   if dsize > 0 then
      dissect.struct_data(
         buf(pos + (offset + 1) * 8, dsize * 8),
         pkt, data_tree)
   end
   dissect.struct_ptrs(
      seg, pos + (offset + dsize + 1) * 8,
      psize, segs, pkt,
      tree:add_le(proto.fields.psize, buf(pos + 6, 2)))
end

function dissect.struct_data(buf, pkt, tree)
   -- need schema in order to make any sense of this data..
   tree:add(proto.fields.data, buf)
end

function dissect.struct_ptrs(seg, pos, count, segs, pkt, tree)
   for i = 0, count - 1 do
      dissect.ptr(seg, pos + (i * 8), segs, pkt, tree)
   end
end

local list_element_size = { 0, 1, 8, 16, 32, 64, "ptr", "composite"}

function dissect.list(seg, pos, segs, pkt, root)
   local buf = segs[seg]
   local offset = math.floor(buf(pos, 4):le_int() / 4)
   local count = buf(pos + 4, 4):le_uint() / 8
   local esize = list_element_size[buf(pos + 4, 1):bitfield(5, 3) + 1]

   local tree = root:add(proto.fields.list, buf(pos, 8))
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
