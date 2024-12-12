local checkFunctions = {}
local checkEvents = {}

---checks
---@param func fun(state: boolean)
---@param successInternal? boolean -- interal, dont use it when using this function
function sendChatMessages(func, successInternal)
   if successInternal then
      for _, v in pairs(checkFunctions) do
         v(true)
      end
      for _, v in pairs(checkEvents) do
         events.TICK:remove(v)
      end
      checkFunctions = {}
      checkEvents = {}
      return
   end

   local eventName = client.intUUIDToString(client.generateUUID())
   local time = 0
   events.TICK:register(function()
      time = time + 1
      if time >= 2 then
         func(false)
         events.TICK:remove(eventName)
      end
   end, eventName)

   table.insert(checkFunctions, func)
   table.insert(checkEvents, eventName)

   host:sendChatCommand('/figura run sendChatMessages(nil, true)')
end