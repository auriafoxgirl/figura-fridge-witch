-- super simple sync script, made while coding the fridge avatar contest, i didnt wanted to use libraries
local mod = {}
local registered = {}
local names = {}

---register value to sync
---@generic value
---@param name string
---@param get fun(): value
---@param set fun(value: value)
function mod.register(name, get, set)
   registered[name] = {
      get = get,
      set = set
   }
   table.insert(names, name)
   table.sort(names)
end

function pings.sync(...)
   if not player:isLoaded() then -- i dont want do all of this not player loaded is thing
      return
   end
   local tbl = {...}
   local i = 0
   for _, name in pairs(names) do
      i = i + 1
      registered[name].set(tbl[i])
   end
end

if not host:isHost() then
   return mod
end

function events.tick()
   if time % 100 == 1 then
      local tbl = {}
      local i = 0
      for _, name in pairs(names) do
         i = i + 1
         tbl[i] = registered[name].get()
      end
      pings.sync(table.unpack(tbl))
   end
end

return mod