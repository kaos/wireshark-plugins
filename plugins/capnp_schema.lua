local capnp_schema = {}

local function find(s, key, val)
   for _, n in ipairs(s) do
      if n[key] == val then
         if n.displayName and not n.name then
            n.name = string.sub(
               n.displayName,
               n.displayNamePrefixLength + 1)
         end
         return n
      end
   end
end

setmetatable(
   capnp_schema,
   { __call = function(s, key, val, tab)
        local node = tab and find(tab, key, val)
        if not node then
           for _, ns in pairs(s) do
              node = find(ns.nodes, key, val)
              if node then break end
           end
        end
        return node
   end
})

return capnp_schema
