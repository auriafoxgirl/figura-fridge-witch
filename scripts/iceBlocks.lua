local mod = {}
local iceBlocks = {}
local iceWorld = models:newPart('iceWorld', 'World')
local iceModelTemplate = models.iceBlock:remove()
local vector3Index = figuraMetatables.Vector3.__index
for _, v in pairs(iceModelTemplate:getChildren()) do
   v:setPrimaryTexture('RESOURCE', 'minecraft:textures/block/ice.png')
   v:setSecondaryRenderType('NONE')
end

local particleEffects = require('scripts.particleEffects')

local function makeIceModel(size)
   local model = iceWorld:newPart('')
   model:addChild(iceModelTemplate.x:copy(''):setUVMatrix(matrices.scale3(size.x, size.y, 1)))
   model:addChild(iceModelTemplate.y:copy(''):setUVMatrix(matrices.scale3(size.x, size.z, 1)))
   model:addChild(iceModelTemplate.z:copy(''):setUVMatrix(matrices.scale3(size.x, size.y, 1)))
   model:scale(size)
   model:setPrimaryRenderType('TRANSLUCENT_CULL')

   return model
end

---@overload fun(entity: Entity): Vector3
local function getBoundingBox(entity)
   local savedBox = entity:getVariable("patpat.boundingBox")
   local box = entity:getBoundingBox()
   if savedBox then
      local success, v = pcall(vector3Index, savedBox, 'xyz')
      if success then
         box = v
      end
   end

   return box
end

---creates ice block in specified region
---@param pos1 Vector3
---@param pos2 Vector3
---@param time number
function mod.iceRegion(pos1, pos2, time)
   error('unfinished, borken')
   table.insert(iceBlocks, {
      time = time
   })
end

---creates ice block parented to entity
---@param entity Entity
---@param time number
function mod.iceEntity(entity, time)
   local size = getBoundingBox(entity)
   size = size + vec(6, 3, 6) / 16
   local id = entity:getUUID()
   local entityPos = entity:getPos()
   particleEffects.box(entityPos - size.x_z * 0.5, entityPos + size * vec(0.5, 1, 0.5))
   if iceBlocks[id] then
      iceBlocks[id].time = time
      return
   end
   iceBlocks[id] = {
      time = time,
      entity = entity,
      model = makeIceModel(size),
      size = size
   }
end

function events.tick()
   for i, v in pairs(iceBlocks) do
      v.time = v.time - 1
      if v.time < 0 or (v.entity and not v.entity:isLoaded()) then
         v.model:remove()
         local pos = v.entity and v.entity:getPos() or nil
         if pos then
            sounds['minecraft:block.glass.break']:pos(pos):play()
            particleEffects.boxIce(pos - v.size.x_z * 0.5, pos + v.size * vec(0.5, 1, 0.5))
         end
         iceBlocks[i] = nil
      end
   end
end

iceWorld.preRender = function(delta)
   local camPos = client.getCameraPos()
   for _, v in pairs(iceBlocks) do
      if v.entity then
         local pos = v.entity:getPos(delta) - v.size.x_z * 0.5
         v.model:setPos(pos * 16 + vec(0, 0.001, 0))
         if camPos > pos and camPos < pos + v.size then
            v.model:setPrimaryRenderType('TRANSLUCENT')
         else
            v.model:setPrimaryRenderType('TRANSLUCENT_CULL')
         end 
      end
   end
end

return mod