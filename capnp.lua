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
      local root, extra = dissect.message(buf, pkt, tree)
      if root then
         tree:append_text(": " .. root .. tostring(extra))
      end
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
   end

   return dissect.ptr(0, 0, segs, pkt, tree:add(segs[0](0,8), "Root"), messageNode)
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
         tree:append_text(": " .. node.name .. " = null")
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

   return dis(seg, pos, segs, pkt, tree, node)
end

function dissect.struct(seg, pos, segs, pkt, tree, node, override_offset)
   local buf = segs[seg]
   local offset = override_offset or buf(pos, 4):le_int() / 4
   local dsize = buf(pos + 4, 2):le_uint()
   local psize = buf(pos + 6, 2):le_uint()
   local b_data = buf(pos + (offset + 1) * 8, dsize * 8):tvb()
   local ptr_offset = pos + (dsize + offset + 1) * 8
   local b_ptr = buf(ptr_offset, psize * 8):tvb()
   local discriminantValue, discriminantField
      = dissect.struct_discriminant(b_data, node.struct)


   tree:append_text(": " .. node.name .. (discriminantField and ", union: " .. discriminantField.name or ""))

   local struct_tree = tree:add("(raw struct)")
   struct_tree:add(buf(pos, 4), "Data offset:", offset)
   local data_tree = struct_tree:add(buf(pos + 4, 2), "Data (", dsize, "words )")
   if dsize > 0 then
      data_tree:add(b_data(0), "Data (", b_data:len(), "bytes )")
   end
   local ptr_tree = struct_tree:add(buf(pos + 6, 2), "Pointers:", psize)
   if psize > 0 then
         ptr_tree:add(b_ptr(0), "Data (", b_ptr:len(), "bytes )")
   end

   if node.struct then
      local fields_tree = tree:add(
         buf(pos + (offset + 1) * 8, (dsize + psize) * 8),
         "Fields")
      dissect.struct_fields(
         b_data, b_ptr, ptr_offset, psize, discriminantValue,
         seg, segs, pkt, fields_tree, node.struct.fields)
   else
      for i = 0, psize - 1 do
         dissect.ptr(
            seg, ptr_offset + (i * 8), segs, pkt,
            ptr_tree:add(b_ptr(i * 8, 8), "Pointer", i),
            { name = "<opaque pointer>" })
      end
   end

   return node.name, discriminantField and ", " .. discriminantField.name
end

function dissect.struct_discriminant(buf, struct)
   local discriminant = struct and struct.discriminantCount > 0
      and buf(struct.discriminantOffset * 2, 2):le_uint()
   if discriminant then
      for _, f in ipairs(struct.fields) do
         if f.discriminantValue == discriminant then
            return discriminant, f
         end
      end
   end
end

-- Notice: only default values for bool fields are currently implemented!
function dissect.struct_fields(b_data, b_ptr, ptrs, psize, discriminant,
                               seg, segs, pkt, tree, fields)
   for _, f in ipairs(fields) do
      repeat
         if f.discriminantValue < 0xffff and
            f.discriminantValue ~= discriminant
         then break end
         if f.group then
            local group = schema.find(rpc_capnp.nodes, "id", f.group.typeId)
            local group_discriminantValue, group_discriminantField
               = dissect.struct_discriminant(b_data, group.struct)
            dissect.struct_fields(
               b_data, b_ptr, ptrs, psize, group_discriminantValue,
               seg, segs, pkt,
               tree:add(f.name .. (group_discriminantField and ", union: "
                                      .. group_discriminantField.name or "")),
               group.struct.fields)
         else
            dissect.data(
               f.slot.type, f.slot.offset, seg, segs, b_data, b_ptr,
               psize, ptrs, pkt, tree, f.name, f.slot.defaultValue)
         end
      until true
   end
end

local list_element_size = {0, 1, 8, 16, 32, 64, "ptr", "composite"}

function dissect.list(seg, pos, segs, pkt, tree, node)
   local buf = segs[seg]
   local offset = math.floor(buf(pos, 4):le_int() / 4)
   local data_pos = pos + (offset + 1) * 8
   local count = math.floor(buf(pos + 4, 4):le_uint() / 8)
   local esize = list_element_size[buf(pos + 4, 1):bitfield(5, 3) + 1]
   local node_text = ": " .. tostring(count) .. " item" .. count == 1 and "" or "s"

   tree:add(buf(pos, 4), "Offset:", offset)
   tree:add(buf(pos + 4, 4), "Count/Words:", count)
   tree:add(buf(pos + 4, 1), "Element size:", esize)

   if type(esize) == "number" then
      local data = buf(data_pos, (count * esize) / 8)
      if esize == 8 then
         local text = string.format("%q", data:string())
         tree:add(proto.fields.text, data, text)
         node_text = ": " .. node.name .. " = " .. text
      elseif count > 0 and esize > 0 then
         local item_tree = tree:add(proto.fields.data, data)
         for i = 0, count - 1 do
            dissect.data(
               node, i, seg, segs, data, nil, 0, 0,
               pkt, item_tree, tostring(i))
         end
      end
   elseif esize == "ptr" then
      local data = buf(data_pos, count * 8)
      local item_tree = tree:add(data, "Items (", data:len(), "bytes )")
      for i = 0, count - 1 do
         dissect.data(
            node, i, seg, segs, nil, data, count,
            data_pos, pkt, tree, tostring(i)
         )
      end
   elseif esize == "composite" then
      local data = buf(data_pos, (count + 1) * 8)
      local item_tree = tree:add(data, "Items (", data:len(), "bytes )")
      local struct = schema.find(rpc_capnp.nodes, "id", node.struct.typeId)
      count = data(0, 4):le_int() / 4
      for i = 0, count - 1 do
         dissect.struct(
            seg, data_pos, segs, pkt,
            item_tree:add(tostring(i)), struct, i)
      end
   end

   tree:append_text(node_text)
end

function dissect.cap(seg, pos, segs, pkt, tree, node)
   local buf = segs[seg]
   local idx = buf(pos + 4, 4):le_uint()
   tree:append_text(": " .. node.name .. " = " .. tostring(idx))
   tree:add(buf(pos + 4, 4), "Capability (index):", idx)
end

function dissect.data(data_type, offset, seg, segs, b_data, b_ptr, psize, ptrs,
                      pkt, tree, name, default_value)
   local typ, val = next(data_type)

   if typ == "struct" then
      if offset < psize then
         dissect.ptr(
            seg, ptrs + (offset * 8), segs, pkt,
            tree:add(b_ptr(offset * 8, 8), name),
            schema.find(rpc_capnp.nodes, "id", val.typeId))
      else
         tree:add(name .. ":", "(no data)")
      end
   elseif typ == "list" then
      if offset < psize then
         dissect.ptr(
            seg, ptrs + (offset * 8), segs, pkt,
            tree:add(b_ptr(offset * 8, 8), name),
            val.elementType)
      else
         tree:add(name .. ":", "(no data)")
      end
   elseif typ == "anyPointer" then
      if offset < psize then
         dissect.ptr(
            seg, ptrs + (offset * 8), segs, pkt,
            tree:add(b_ptr(offset * 8, 8), name),
            { name = "AnyPointer" })
      else
         tree:add(name .. ":", "(no data)")
      end
   elseif typ == "interface" then
      tree:add(name, "<todo>", typ)
   elseif typ == "void" then
      tree:add(name .. ":", "(void)")
   elseif typ == "bool" then
      local off, bit = math.modf(offset / 8)
      if off < b_data:len() then
         local b = b_data(off, 1)
         local v = b:bitfield(7 - (bit * 8), 1)
         local value = v == 1
         if default_value and default_value.bool then
            value = not value
         end
         tree:add(b, name .. ":", tostring(value))
      else
         tree:add(name .. ":", "(no data)")
      end
   elseif string.sub(typ, 1, 3) == "int" then
      local size = tonumber(string.sub(typ, 4)) / 8
      if (offset + 1) * size <= b_data:len() then
         local b = b_data(offset * size, size)
         local v = size < 8 and b:le_int() or tostring(b:le_int64())
         tree:add(b, name .. ":", v)
      else
         tree:add(name .. ":", "(no data)")
      end
   elseif string.sub(typ, 1, 4) == "uint" then
      local size = tonumber(string.sub(typ, 5)) / 8
      if (offset + 1) * size <= b_data:len() then
         local b = b_data(offset * size, size)
         local v = size < 8 and b:le_uint() or tostring(b:le_uint64())
         tree:add(b, name .. ":", v)
      else
         tree:add(name .. ":", "(no data)")
      end
   else
      tree:add(name .. ":", "<field type not dissected>", typ)
   end
end
