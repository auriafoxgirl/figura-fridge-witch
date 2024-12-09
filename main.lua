vanilla_model.ALL:visible(false)

-- global variables
fridgeModel = models.fridge.fridge
time = 0

-- configure stuff
fridgeModel:setPrimaryRenderType('CUTOUT_CULL')
fridgeModel.inside:light(15, 15)
fridgeModel.inside.insideWall:setPrimaryRenderType('CUTOUT')
fridgeModel.door.doorInside:setPrimaryRenderType('CUTOUT')
fridgeModel.inside.fridgeLight:setPrimaryRenderType('EMISSIVE_SOLID')
renderer:setShadowRadius(0.6)

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