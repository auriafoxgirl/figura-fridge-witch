vanilla_model.ALL:visible(false)
vanilla_model.HELD_ITEMS:visible(true)

-- global variables
fridgeModel = models.fridge.fridge
time = 0
itemModels = {} ---@type {[string]: ModelPart}

function fancyPrint(text)
   printJson(toJson{
      text = '❄ '..text..'\n',
      color = '#84ebff'
   })
end

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

-- load everything
for _, v in pairs(listFiles('', true)) do
   if v ~= 'main' then
      require(v)
   end
end