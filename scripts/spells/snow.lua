local spell = {
   icon = 'minecraft:snow',
   name = 'Snow',
}

local particleEffects = require('scripts.particleEffects')
local snowLayers = require('scripts.snow_layers')

local dist = 3
local snowTimeMin = 200
local snowTimeMax = 220

function spell.run()
   local block = player:getTargetedBlock(true, 20)
   local pos = block:getPos()

   particleEffects.box(pos - dist * vec(1, 0.1, 1), pos + dist)

   for _, block in pairs(world.getBlocks(pos - dist, pos + dist)) do
      snowLayers.newLayer(block:getPos(), math.random(snowTimeMin, snowTimeMax))
   end
end

return spell