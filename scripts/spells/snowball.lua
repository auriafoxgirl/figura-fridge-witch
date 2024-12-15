local spell = {
   icon = 'minecraft:snowball',
   name = 'Snowball',
}

local commands = require('scripts.commands')
local particleEffects = require('scripts.particleEffects')

function spell.run()
   local pos = player:getPos():add(0, player:getEyeHeight(), 0)
   local dir = player:getLookDir()
   particleEffects.line(2, 8)
   commands.snowball(pos, dir * 2)
end

return spell