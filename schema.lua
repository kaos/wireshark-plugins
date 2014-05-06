schema = {}

function schema.find(s, key, val, default)
   for _, n in ipairs(s) do
      if n[key] == val then
            return n
      end
   end
   return default
end
