local mod = {}
local iceSpikes = {}
local spikeWorld = models:newPart('iceWorld', 'World')
local iceModelTemplate = models.iceSpike:remove()
iceModelTemplate:setPrimaryTexture('RESOURCE', 'minecraft:textures/block/ice.png')
iceModelTemplate:setPrimaryRenderType('TRANSLUCENT_CULL')
iceModelTemplate:setSecondaryRenderType('NONE')

local commands = require('scripts.commands')
local particleEffects = require('scripts.particleEffects')

local gravity = vec(0, -0.02, 0)
local airDrag = 0.96
local ignoredEntity = avatar:getUUID()

local atan2 = math.atan2
local lerp = math.lerp
local deg = math.deg

---creates ice spike in specified region
---@param pos Vector3
---@param vel Vector3
---@param damage? number
function mod.newSpike(pos, vel, damage)
   local model = iceModelTemplate:copy('')
   spikeWorld:addChild(model)
   pos = pos:copy()
   vel = vel:copy()
   table.insert(iceSpikes, {
      time = 100,
      pos = pos,
      oldPos = pos,
      oldVel = vel,
      vel = vel,
      damage = damage or 0,
      model = model,
      size = 0,
      oldSize = 0,
      targetSize = 0.8 + math.random() * 0.4
   })
end

function events.tick()
   for i, v in pairs(iceSpikes) do
      v.time = v.time - 1
      if v.time < 0 then
         v.model:remove()
         iceSpikes[i] = nil
         sounds['minecraft:block.glass.break']:pos(v.pos):play()
         particleEffects.boxIce(v.pos - 0.5, v.pos + 0.5)
      else
         v.oldPos = v.pos
         v.oldVel = v.vel
         v.vel = v.vel * airDrag + gravity
         local newPos = v.pos + v.vel
         local entity = raycast:entity(v.pos, newPos)
         if entity and entity:getUUID() ~= ignoredEntity then
            v.time = 0
            if v.damage >= 1 then
               commands.spikeDamage(entity, v.damage)
            end
         end
         local _, hitPos = raycast:block(v.pos, newPos)
         if (hitPos - newPos):lengthSquared() > 0.001 then
            v.time = 0
         end
         v.pos = newPos
         v.oldSize = v.size
         v.size = lerp(v.size, v.targetSize, 0.6)
      end
   end
end

spikeWorld.preRender = function(delta)
   for _, v in pairs(iceSpikes) do
      local mat = matrices.mat4()
      local vel = math.lerp(v.oldVel, v.vel, delta)
      mat:scale(math.lerp(v.oldSize, v.size, delta))
      mat:rotateX(deg(atan2(vel.xz:length(), vel.y)))
      mat:rotateY(deg(atan2(vel.x, vel.z)))
      mat:translate(lerp(v.oldPos, v.pos, delta) * 16)
      v.model:setMatrix(mat)
   end
end

return mod