local spell = {
   icon = 'minecraft:ice',
   name = 'Ice Spike',
   actionWheelOrder = 'Sz'
}

local particleEffects = require('scripts.particleEffects')
local iceSpikes = require('scripts.ice_spikes')

function spell.run()
   local pos = player:getPos():add(0, player:getEyeHeight(), 0)
   local dir = player:getLookDir()
   particleEffects.line(2, 8)
   iceSpikes.newSpike(pos, dir * 2, 2)
end

return spell