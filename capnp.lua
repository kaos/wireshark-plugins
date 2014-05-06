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

proto.fields.data = ProtoField.bytes("capnp.data", "Data")
proto.fields.text = ProtoField.string("capnp.text", "Text")

local dissect = {}
local fileNode, messageNode

function proto.dissector(buf, pkt, root)
   if buf(0,1):bitfield(6, 2) == 0 then
      pkt.cols.protocol:set("CAPNP")
      local tree = root:add(proto, buf(0))
      dissect.message(buf, pkt, tree)
      --this works nicely
      --tree:append_text(": Message...")
   end
end

DissectorTable.get("tcp.port"):add(55000, proto)

function dissect.message(buf, pkt, tree)
   local count = buf(0,4):le_uint() + 1
   local data = buf(4 * (count + count % 2)):tvb()
   local segs = {}
   local seg_tree = tree:add(buf(0,4), "Segments:", count)

   -- decode segments header
   for i = 1, count do
      local b_size = buf(4 * i, 4)
      local size = b_size:le_uint() * 8
      segs[i - 1] = data(0, size):tvb()
      seg_tree
         :add(b_size, "Segment:", i - 1, "(", size / 8, "words )")
         :add(data(0, size), "Data (", size, "bytes )")
      data = data(size):tvb()
   end

   if not fileNode then
      fileNode = schema.find(rpc_capnp.nodes, "id", rpc_capnp.requestedFiles[1].id)
      local messageId = schema.find(fileNode.nestedNodes, "name", "Message").id
      messageNode = schema.find(rpc_capnp.nodes, "id", messageId)
      messageNode.name = "Message"
   end

   dissect.ptr(0, 0, segs, pkt, tree, messageNode)
end

function dissect.ptr(seg, pos, segs, pkt, tree, node)
   local kind = segs[seg](pos, 1):bitfield(6, 2)
   local dis = function ()
      local ref = segs[seg](pos, 8):tvb()
      print(table.concat(
               {"packet", pkt.number, seg, pos,
                "unknown (or NYI) pointer", tostring(ref)}, " "))
   end

   if kind == 0 then
      local null = tostring(segs[seg](pos,8):le_uint64()) == "0"
      if null then
         tree:add(segs[seg](pos, 8), node.name, "= null")
         return
      else
         dis = dissect.struct
      end
   elseif kind == 1 then
      dis = dissect.list
   elseif kind == 2 then
      -- far ptr, NYI
   elseif kind == 3 then
      if segs[seg](pos, 4):le_uint() == 3 then
         dis = dissect.cap
      end
   end

   dis(seg, pos, segs, pkt, tree, node)
end

function dissect.struct(seg, pos, segs, pkt, root, node)
   local buf = segs[seg]
   local offset = buf(pos, 4):le_int() / 4
   local dsize = buf(pos + 4, 2):le_uint()
   local psize = buf(pos + 6, 2):le_uint()
   local tree = root:add(buf(pos, 8), node.name, "(struct)")

   tree:add(buf(pos, 4), "Data offset:", offset)
   data_tree = tree:add(buf(pos + 4, 2), "Data (", dsize, "words )")
   if dsize > 0 then
      dissect.struct_data(
         buf(pos + (offset + 1) * 8, dsize * 8),
         pkt, data_tree)
   end
   dissect.struct_ptrs(
      seg, pos + (offset + dsize + 1) * 8,
      psize, segs, pkt,
      tree:add(buf(pos + 6, 2), "Pointers:", psize))
end

function dissect.struct_data(buf, pkt, tree)
   tree:add(buf, "Data (", buf:len(), "bytes )")
end

function dissect.struct_ptrs(seg, pos, count, segs, pkt, tree)
   for i = 0, count - 1 do
      dissect.ptr(seg, pos + (i * 8), segs, pkt, tree, { name = "Pointer " .. tostring(i) })
   end
end

local list_element_size = {0, 1, 8, 16, 32, 64, "ptr", "composite"}

function dissect.list(seg, pos, segs, pkt, root, node)
   local buf = segs[seg]
   local offset = math.floor(buf(pos, 4):le_int() / 4)
   local count = math.floor(buf(pos + 4, 4):le_uint() / 8)
   local esize = list_element_size[buf(pos + 4, 1):bitfield(5, 3) + 1]

   local tree = root:add(buf(pos, 8), node.name, "(list)")
   tree:add(buf(pos, 4), "Offset:", offset)
   tree:add(buf(pos + 4, 4), "Count:", count)
   tree:add(buf(pos + 4, 1), "Element size:", esize)

   if type(esize) == "number" then
      local data = buf(pos + (offset + 1) * 8, (count * esize) / 8)
      if esize == 8 then
         local text = data:string()
         tree:add(proto.fields.text, data, text)
         tree:set_text(node.name .. " = " .. text)
      else
         tree:add(proto.fields.data, data)
      end
   end
end

function dissect.cap(seg, pos, segs, pkt, root, node)
   local buf = segs[seg]
   local idx = buf(pos + 4, 4):le_uint()
   root:add(buf(pos, 8), node.name .. ":", "Capability (index) =", idx)
end
