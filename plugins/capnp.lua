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
local tcp_port, udp_port
local dir_marker = {}
local dir
local reqs = {}

proto.fields.text = ProtoField.string("capnp.text", "Text")
proto.prefs["tcp.port"] = Pref.uint(
   "TCP Port", 9090,
   "Set the tcp port for Cap'n Proto RPC messages.")
proto.prefs["udp.port"] = Pref.uint(
   "UDP Port", 9090,
   "Set the udp port for Cap'n Proto RPC messages.")
proto.prefs.to_port = Pref.string("Direction marker, to port", "->", "")
proto.prefs.from_port = Pref.string("Direction marker, from port", "<-", "")

local dissect = {}
local fileNode, messageNode

function proto.dissector(buf, pkt, root)
   pkt.cols.protocol:set("CAPNP")

   -- didn't find any reliable way to see if it is a TCP or UDP packet!
   dir = pkt.dst_port == tcp_port or pkt.dst_port == udp_port

   local desc
   while buf:len() > 0 do
      local d
      buf, d = dissect.message(buf, pkt, root)
      if desc then
         desc = desc .. ", ..."
      else
         desc = d
      end
   end

   local marker = dir_marker[dir] or ""
   pkt.cols.info:set(marker .. desc)
end

local function unregister(name, port)
   if port then
      DissectorTable.get(name):remove(port, proto)
   end
end

local function register(name, port)
   if port then
      DissectorTable.get(name):add(port, proto)
   end
end

local function update_dissector_port(name, port)
   if proto.prefs[name] ~= port then
      unregister(name, port)
      port = proto.prefs[name]
      register(name, port)
   end
   return port
end

function proto.init()
   dir_marker[true] = proto.prefs.to_port .. " "
   dir_marker[false] = proto.prefs.from_port .. " "
   reqs[true] = {}
   reqs[false] = {}

   tcp_port = update_dissector_port("tcp.port", tcp_port)
   udp_port = update_dissector_port("udp.port", udp_port)
end


--------------------------------------------------------------------------------
-- Dissect routines
--------------------------------------------------------------------------------

function dissect.message(buf, pkt, root)
   local count = buf(0,4):le_uint() + 1
   local seg_table_size = 4 * (count + count % 2)
   local data = buf(seg_table_size):tvb()
   local segs = {}
   local tree = root:add(proto, buf(0, seg_table_size))
   local seg_tree = tree:add(buf(0,4), "Segments:", count)

   reqs.dir = dir
   reqs.id = nil

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
      fileNode = capnp_schema("id", capnp_schema.rpc.requestedFiles[1].id)
      local messageId = capnp_schema("name", "Message", fileNode.nestedNodes).id
      messageNode = capnp_schema("id", messageId)
   end

   local msg = dissect.ptr(
      0, 0, segs, pkt, tree:add(segs[0](0,8), "Root"), messageNode)
   local desc = dissect.describe_message(msg)
   if desc then
      tree:append_text(": " .. desc)
   end

   return data, desc
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

   local discriminantValue, discriminantField
      = dissect.struct_discriminant(b_data, node.struct, data_tree)


   tree:append_text(": " .. node.name .. (discriminantField and ", union: " .. discriminantField.name or ""))
   local fields = {}
   if node.struct then
      local fields_tree = tree:add(
         buf(pos + (offset + 1) * 8, (dsize + psize) * 8),
         "Fields")

      fields = dissect.struct_fields(
         b_data, b_ptr, ptr_offset, psize, discriminantValue,
         seg, segs, pkt, fields_tree, node)
   else
      for i = 0, psize - 1 do
         dissect.ptr(
            seg, ptr_offset + (i * 8), segs, pkt,
            ptr_tree:add(b_ptr(i * 8, 8), "Pointer", i),
            { name = "<opaque pointer>" })
      end
   end

   return { struct = {
               schema = node,
               discriminant = discriminantField,
               fields = fields
   }}
end

function dissect.struct_discriminant(buf, struct, tree, label)
   local discriminant = struct and struct.discriminantCount > 0
   if not discriminant then
      return false, nil, tree
   end

   local data = buf(struct.discriminantOffset * 2, 2)
   discriminant = data:le_uint()

   for _, f in ipairs(struct.fields) do
      if f.discriminantValue == discriminant then
         return discriminant, f, tree:add(
            data, (label or "Union") .. ", tag:",  discriminant, "(", f.name, ")")
      end
   end
end

-- Notice: only default values for bool fields are currently implemented!
function dissect.struct_fields(b_data, b_ptr, ptrs, psize, discriminant,
                               seg, segs, pkt, tree, node)
   local res = {}
   local fields = node.struct.fields

   if not fields then return res end

   for _, f in ipairs(fields) do
      repeat
         if f.discriminantValue < 0xffff and
            f.discriminantValue ~= discriminant
         then break end
         if f.group then
            local group = capnp_schema("id", f.group.typeId)
            local group_discriminantValue, group_discriminantField, group_tree
               = dissect.struct_discriminant(b_data, group.struct, tree, f.name)
            res[f.name] = dissect.struct_fields(
               b_data, b_ptr, ptrs, psize, group_discriminantValue,
               seg, segs, pkt, group_tree, group)
         else
            -- make sure to register this call's meta data before
            -- processing the call params
            if node.name == "Call" then
               if f.name == "params" then
                  reqs.call(res, pkt)
               end
            elseif node.name == "Return" then
               if f.name == "results" then
                  reqs.result(res, pkt)
               end
            end

            res[f.name] = dissect.data(
               f.slot.type, f.slot.offset, seg, segs, b_data, b_ptr,
               psize, ptrs, pkt, tree, f.name, f.slot.defaultValue)
         end
      until true
   end

   -- Clear out call meta data when done with it. Maybe not the best
   -- thing to do, but it's no good to hold on to them forever either.
   if node.name == "Finish" then
      reqs.finish(res, pkt)
   end

   return res
end

local list_element_size = {0, 1, 8, 16, 32, 64, "ptr", "composite"}

function dissect.list(seg, pos, segs, pkt, tree, node)
   local buf = segs[seg]
   local offset = math.floor(buf(pos, 4):le_int() / 4)
   local data_pos = pos + (offset + 1) * 8
   local count = math.floor(buf(pos + 4, 4):le_uint() / 8)
   local esize = list_element_size[buf(pos + 4, 1):bitfield(5, 3) + 1]
   local node_text
   local res = {}

   tree:add(buf(pos, 4), "Offset:", offset)
   tree:add(buf(pos + 4, 1), "Element size:", esize)

   if type(esize) == "number" then
      tree:add(buf(pos + 4, 4), "Count:", count)
      local data = buf(data_pos, (count * esize) / 8)
      if esize == 8 and not node.struct then
         res = string.format("%q", data:string())
         tree:add(proto.fields.text, data, res)
         node_text = ": " .. node.name .. " = " .. res
      elseif count > 0 and esize > 0 then
         local item_tree = tree:add(data, "Data (", data:len(), "bytes )")
         if node.struct then
            local struct = capnp_schema("id", node.struct.typeId)
            node = { ["headless-struct"] = struct }
         end
         for i = 0, count - 1 do
            res[i + 1] = dissect.data(
               node, i, seg, segs, data, nil, 0, 0,
               pkt, item_tree, tostring(i))
         end
      end
   elseif esize == "ptr" then
      tree:add(buf(pos + 4, 4), "Count:", count)
      local data = buf(data_pos, count * 8)
      local item_tree = tree:add(data, "Items (", data:len(), "bytes )")
      for i = 0, count - 1 do
         res[i + 1] = dissect.data(
            node, i, seg, segs, nil, data, count,
            data_pos, pkt, tree, tostring(i))
      end
   elseif esize == "composite" then
      local data = buf(data_pos, (count + 1) * 8):tvb()
      local words = count

      count = data(0, 4):le_int() / 4
      tree:add(buf(pos + 4, 4), "Words:", words)
         :add(data(0, 4), "Count:", count)

      local struct = node.struct and capnp_schema("id", node.struct.typeId) or node
      tree:add(data(0, 8), "Tag:", struct.name)

      if count > 0 then
         local size = words / count
         local item_tree = tree:add(data(8), "Items (", words * 8, "bytes )")
         for i = 0, count - 1 do
            res[i + 1] = dissect.struct(
               seg, data_pos, segs, pkt,
               item_tree:add(tostring(i)), struct, i * size)
         end
      end
   end

   if not node_text then
      node_text = ": " .. tostring(count) .. " item" .. (count == 1 and "" or "s")
   end

   return { list=res }, tree:append_text(node_text)
end

function dissect.cap(seg, pos, segs, pkt, tree, node)
   local buf = segs[seg]
   local idx = buf(pos + 4, 4):le_uint()
   tree:append_text(": " .. node.name .. ", index: " .. tostring(idx))
   tree:add(buf(pos + 4, 4), "capTable index:", idx)
   return { cap=idx }
end

function dissect.data(data_type, offset, seg, segs, b_data, b_ptr, psize, ptrs,
                      pkt, tree, name, default_value)
   local typ, val = next(data_type)

   if typ == "struct" then
      if offset < psize then
         return dissect.ptr(
            seg, ptrs + (offset * 8), segs, pkt,
            tree:add(b_ptr(offset * 8, 8), name),
            capnp_schema("id", val.typeId))
      end
   elseif typ == "list" then
      if offset < psize then
         return dissect.ptr(
            seg, ptrs + (offset * 8), segs, pkt,
            tree:add(b_ptr(offset * 8, 8), name),
            val.elementType)
      end
   elseif typ == "anyPointer" then
      if offset < psize then
         local req = reqs.get(pkt)
         return dissect.ptr(
            seg, ptrs + (offset * 8), segs, pkt,
            tree:add(b_ptr(offset * 8, 8), name),
            name == "content" and req and req.content
               or { name = "AnyPointer" })
      end
   elseif typ == "interface" then
      return dissect.cap(
         seg, ptrs + (offset * 8), segs, pkt,
         tree:add(b_ptr(offset * 8, 8), name),
         capnp_schema("id", val.typeId)
            or { name = "(Interface)" })
   elseif typ == "void" then
      return typ, tree:add(name .. ":", "(void)")
   elseif typ == "bool" then
      local off, bit = math.modf(offset / 8)
      if off < b_data:len() then
         local b = b_data(off, 1)
         local v = b:bitfield(7 - (bit * 8), 1)
         local value = v == 1
         if default_value and default_value.bool then
            value = not value
         end
         return value, tree:add(b, name .. ":", tostring(value))
      end
   elseif typ == "enum" then
      if (offset + 1) * 2 <= b_data:len() then
         local b = b_data(offset * 2, 2)
         local n = capnp_schema("id", val.typeId)
         local t = b:le_uint()
         local v = n and n.enum.enumerants[t + 1].name or t
         return v, tree:add(b, name .. ":", v)
      end
   elseif string.sub(typ, 1, 3) == "int" then
      local size = tonumber(string.sub(typ, 4)) / 8
      if (offset + 1) * size <= b_data:len() then
         local b = b_data(offset * size, size)
         local v = size < 8 and b:le_int() or tostring(b:le_int64())
         return v, tree:add(b, name .. ":", v)
      end
   elseif string.sub(typ, 1, 4) == "uint" then
      local size = tonumber(string.sub(typ, 5)) / 8
      if (offset + 1) * size <= b_data:len() then
         local b = b_data(offset * size, size)
         local v = size < 8 and b:le_uint() or tostring(b:le_uint64())
         return v, tree:add(b, name .. ":", v)
      end
   elseif string.sub(typ, 1, 5) == "float" then
      local size = tonumber(string.sub(typ, 6)) / 8
      if (offset + 1) * size <= b_data:len() then
         local b = b_data(offset * size, size)
         local v = b:le_float()
         return v, tree:add(b, name .. ":", v)
      end
   elseif typ == "headless-struct" then
      local size = val.struct.preferredListEncoding
      if (offset + 1) * size <= b_data:len() then
         local data = b_data(offset * size, size)
         local struct_tree = tree:add(data, name .. ":", val.name)
         local discriminantValue = dissect.struct_discriminant(data, val.struct, struct_tree)
         return dissect.struct_fields(
            data:tvb(), nil, 0, 0, discriminantValue, seg, segs, pkt,
            struct_tree, val)
      end
   else
      return "<not dissected>", tree:add(name .. ":", "<field type not dissected>", typ)
   end

   return "(no data)", tree:add(name .. ":", "(no data)", typ)
end

--------------------------------------------------------------------------------
-- request tracking
--------------------------------------------------------------------------------

function reqs.get(pkt, id)
   if id then
      reqs.id = id
   else
      id = reqs.id
   end

   if not id then return nil end

   local req = reqs[reqs.dir][id]
   if not req then
      req = {}
      reqs[reqs.dir][id] = req
   end

   local r = req[id]
   if not r then
      r = {}
      req[id] = r
   end

   for _, v in ipairs(r) do
      if v.from <= pkt.number and not v.to or v.to >= pkt.number then
         return v
      end
   end

   local v = { from = pkt.number }
   r[#r + 1] = v
   return v
end

function reqs.call(fields, pkt)
   local r = reqs.get(pkt, fields.questionId)
   local node = capnp_schema("id", fields.interfaceId)
   if node then
      r.method = node.interface.methods[fields.methodId + 1]
      r.content = capnp_schema("id", r.method.paramStructType)
   end
end

function reqs.result(fields, pkt)
   -- results travel in opposite direction of that of calls/finish requests.
   reqs.dir = not dir
   local r = reqs.get(pkt, fields.answerId)
   if r.method then
      r.content = capnp_schema("id", r.method.resultStructType)
   end
end

function reqs.finish(fields, pkt)
   local r = reqs.get(pkt, fields.questionId)
   r.to = pkt.number
end

--------------------------------------------------------------------------------
-- functions for describing a dissected message
--------------------------------------------------------------------------------

local describe = { struct = {} }

function dissect.describe_message(msg)
   return describe.value(msg)
end

-- utility functions

function describe.value(obj)
   if type(obj) ~= "table" then
      return tostring(obj)
   end

   local typ, val = next(obj)
   if typ == "struct" then
      local fun = describe.struct[val.schema.name] or describe.any_struct
      return fun and fun(val) or ""
   elseif typ == "list" then
      if type(val) == "table" then
         return "[" .. describe.list(val) .. "]"
      else
         return tostring(val)
      end
   elseif typ == "cap" then
      return "cap(" .. tostring(val) .. ")"
   end

   return typ .. "=" .. describe.value(val)
end

function describe.list(t)
   local res = {}
   for k, v in pairs(t) do
      res[k] = describe.value(v)
   end
   return describe.lua_value(res)
end

function describe.discriminant(obj)
   if not obj.discriminant then return "" end
   local tag = obj.discriminant.name
   local val = obj.fields[tag]
   return tag .. describe.value(val)
end

function describe.any_struct(obj)
   return "(" .. describe.list(obj.fields) .. ")"
end

function describe.lua_value(o)
   if type(o) == 'table' then
      local s
      for k,v in pairs(o) do
         s = s and s .. ', ' or ''
         if type(k) ~= 'number' then
            s = s .. k .. '='
         end
         s = s .. describe.lua_value(v)
      end
      return s or ''
   else
      return tostring(o)
   end
end

----------------------------------------
-- rpc types, roughly in the same order
-- as defined in rpc.capnp

function describe.struct.Message(obj)
   return describe.discriminant(obj)
end

function describe.struct.Call(obj)
   local f = obj.fields
   local id = f.interfaceId
   local mid = f.methodId
   local cap = capnp_schema("id", id)
   local o = cap and cap.name or tostring(id)
   local m = cap and cap.interface.methods[mid + 1].name
      or "method(" .. tostring(mid) .. ") "
   local t = {}
   for _, k in ipairs({ "target", "params" }) do
      t[k] = describe.value(f[k])
   end
   return "(" .. tostring(f.questionId) .. ") " .. t.target
      .. "::" .. o .. "->" .. m .. t.params
      .. " return to: " .. next(f.sendResultsTo)
      .. ", tail call: " .. tostring(f.allowThirdPartyTailCall)
end

function describe.struct.Return(obj)
   local f = obj.fields
   local result = describe.discriminant(obj)
   return "(" .. tostring(f.answerId) .. ") " .. result
end

function describe.struct.Finish(obj)
   local f = obj.fields
   return "(" .. tostring(f.questionId) .. ")"
end

function describe.struct.Resolve(obj)
   local f = obj.fields
   local promise = describe.discriminant(obj)
   return "(" .. tostring(f.promiseId) .. ") " .. promise
end

function describe.struct.Release(obj)
   local f = obj.fields
   return "(" .. tostring(f.id) .. ")"
end

-- function describe.struct.Disembargo()
-- end

-- function describe.struct.Save()
-- end

function describe.struct.Restore(obj)
   local f = obj.fields
   local object = describe.value(f.objectId)
   return "(" .. tostring(f.questionId) .. ") " .. object
end

-- function describe.struct.Delete()
-- end

-- function describe.struct.Provide()
-- end

-- function describe.struct.Accept()
-- end

-- function describe.struct.Join()
-- end

----------------------------------------
-- Common structures used in messages

-- function describe.struct.MessageTarget(obj)
-- end

-- function describe.struct.Payload(obj)
--    return "(...)"
-- end

-- function describe.struct.CapDescriptor()
-- end

function describe.struct.PromisedAnswer(obj)
   local f = obj.fields
   return "(" .. tostring(f.questionId) .. ", " .. describe.value(f.transform) .. ")"
end

-- function describe.struct.SturdyRef()
-- end

-- function describe.struct.ThirdPartyCapDescriptor()
-- end

-- function describe.struct.Exception()
-- end
