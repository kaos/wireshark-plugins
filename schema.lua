schema = {}

function schema.find(s, key, val, default)
   for _, n in ipairs(s) do
      if n[key] == val then
         if n.displayName and not n.name then
            n.name = string.sub(n.displayName, n.displayNamePrefixLength + 1)
         end
         return n
      end
   end
   return default
end
