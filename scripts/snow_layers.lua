local mod = {}
local snowModel = models:newPart('snow_layers_world', 'World')
local snowLayers = {}
local vectorUp = vec(0, 1, 0)
local posOffset = vec(0.0005, 0.0005, 0.0005)
local scaleOffset = vec(-0.001, 1, -0.001)

local snowLayersToRender = {}

function mod.newLayer(pos, time)
   pos = pos:copy():floor()
   local id = tostring(pos)
   if snowLayers[id] then
      snowLayers[id].time = time
      return
   end
   if #world.getBlockState(pos + vectorUp):getCollisionShape() >= 1 then
      return
   end
   local model = snowModel:newPart('')
   local modelPivot = model:newPart('')
   local light = world.getLightLevel(pos + vectorUp)
   local skyLight = world.getSkyLightLevel(pos + vectorUp)
   local height = 0
   for i, aabb in pairs(world.getBlockState(pos):getCollisionShape()) do
      height = math.max(height, aabb[2].y)
      modelPivot:newBlock('a'..i)
         :block('snow')
         :pos((aabb[1].x_z + aabb[2]._y_ + posOffset) * 16)
         :scale(aabb[2].x_z - aabb[1].x_z + scaleOffset)
         :light(light, skyLight)
   end
   model:pos(pos * 16)
   model:pivot(0, height * 16, 0)
   snowLayers[id] = {
      model = model,
      time = time,
      scale = 0,
      oldScale = 0,
      targetScale = 1
   }
   snowLayersToRender[id] = snowLayers[id]
end

function events.tick()
   for i, v in pairs(snowLayers) do
      v.time = v.time - 1
      v.oldScale = v.scale
      v.targetScale = math.lerp(v.targetScale, v.time > 20 and 1 or 0, 0.1)
      v.scale = math.lerp(v.scale, v.targetScale, 0.2)
      if v.time < 0 then
         v.model:remove()
         snowLayers[i] = nil
      elseif v.scale < 0.99 or v.targetScale < 0.99 then
         snowLayersToRender[i] = v
      end
   end
end

snowModel.preRender = function(delta)
   for _, v in pairs(snowLayersToRender) do
      v.model:scale(1, math.lerp(v.oldScale, v.scale, delta), 1)
   end
   snowLayersToRender = {}
end

return mod