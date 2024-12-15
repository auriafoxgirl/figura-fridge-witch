local mod = {}

local iceBlocks = require('scripts.iceBlocks')

local function canRunCommands()
   return player:getPermissionLevel() >= 2
end

local function sendCommand(command)
   if #command >= 256 then
      return
   end
   host:sendChatCommand(command)
end

---@overload fun(entity: Entity, time: number)
function mod.freeze(entity, time)
   iceBlocks.iceEntity(entity, time)
   if not canRunCommands() then
      return
   end
   sendCommand('/effect give '..entity:getUUID()..' ')
end

return mod