vanilla_model.ALL:visible(false)
vanilla_model.HELD_ITEMS:visible(true)

-- read only metatables
for _, v in pairs(figuraMetatables) do
   v.__metatable = false
end

-- global variables
fridgeModel = models.fridge.fridge
time = 0
itemModels = {} ---@type {[string]: ModelPart}

---prints pretty, cold text
---@param text string|table
function fancyPrint(text)
   printJson(toJson{
      {
         text = '❄ ',
         color = '#84ebff',
         extra = {text},
      },
      '\n'
   })
end

-- avatar vars
avatar:store("patpat.boundingBox", vec(1, 2, 1))

-- configure stuff
fridgeModel:setPrimaryRenderType('CUTOUT_CULL')
fridgeModel.inside:light(15, 15)
fridgeModel.inside.insideWall:setPrimaryRenderType('CUTOUT')
fridgeModel.door.doorInside:setPrimaryRenderType('CUTOUT')
fridgeModel.inside.fridgeLight:setPrimaryRenderType('EMISSIVE_SOLID')
renderer:setShadowRadius(0.6)

models.fridge.items.itemAppleGoldEnchanted:setPrimaryRenderType('EMISSIVE_SOLID')
models.fridge.items.itemAppleGoldEnchanted.top:setPrimaryRenderType('CUTOUT_EMISSIVE_SOLID')
models.fridge.items.itemAppleGoldEnchanted.cube:setSecondaryRenderType('GLINT2')

-- update item models
local itemNamesMap = {
   itemApple = 'minecraft:apple',
   itemAppleGold = 'minecraft:golden_apple',
   itemAppleGoldEnchanted = 'minecraft:enchanted_golden_apple',
   itemBread = 'minecraft:bread',
   itemCake = 'minecraft:cake',
   itemMilk = 'minecraft:milk_bucket',
   itemIcecream = 'minecraft:snowball'
}
for _, v in pairs(models.fridge.items:getChildren()) do
   v:remove()
   local name = v:getName()
   local item = itemNamesMap[name]
   local model = models:newPart(name):remove()
   v:setPos(-v:getPivot())
   model:addChild(v):setPrimaryRenderType('CUTOUT')
   itemModels[item] = model
end

-- timer
function events.tick()
   time = time + 1
end

-- useful functions
---gets entities
---@param pos1 Vector3
---@param pos2 Vector3
---@param ignoredUuids? {[string]: any}
---@return Entity[]
function getEntities(pos1, pos2, ignoredUuids)
   local entities = {}
   raycast:entity(pos1, pos2, function(entity)
      if not ignoredUuids or not ignoredUuids[entity:getUUID()] then
         table.insert(entities, entity)
      end
      return false
   end)
   return entities
end

-- load everything
for _, v in pairs(listFiles('', true)) do
   if v ~= 'main' then
      require(v)
   end
end