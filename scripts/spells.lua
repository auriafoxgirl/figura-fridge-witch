local keyUse = keybinds:fromVanilla('key.use')
local isWandEnabled = require('scripts.wand')

keyUse.press = function()
   if not player:isLoaded() then
      return
   end
   if not isWandEnabled() then
      return
   end
   if player:getPermissionLevel() < 2 then
      return
   end
   -- print('blep')
   local dir = player:getLookDir()
   local pos = player:getPos():add(0, player:getEyeHeight(), 0) + dir
   local motion = dir + (vec(math.random(), math.random(), math.random()) * 2 - 1) * 0.2
   local command = '/summon falling_block '
   command = command..pos.x..' '
   command = command..pos.y..' '
   command = command..pos.z..' '
   command = command..'{BlockState:{Name:"minecraft:snow"},Time:1,Motion:['
   command = command..motion.x..','
   command = command..motion.y..','
   command = command..motion.z
   command = command..']}'
   host:sendChatCommand(command)

   return true
end