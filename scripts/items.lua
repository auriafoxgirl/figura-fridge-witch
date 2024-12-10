local itemsContainer = fridgeModel.itemsContainer
local itemPositions = {
   vec(-3, 25, -2),
   vec(2.5, 25, 2),
   vec(2.5, 19, -2),
   vec(-3, 19, 2),
   vec(-3, 13, -2),
   vec(2.5, 13, 2),
}

-- local i = 0
for _, v in pairs(itemModels) do
   -- i = i + 1
   local i = math.random(#itemPositions)
   v:pos(itemPositions[i])
   table.remove(itemPositions, i)
   itemsContainer:addChild(v)
end

-- host only
if not host:isHost() then
   return
end

---returns how food is item
---@param item ItemStack
local function getFoodScore(item)
   if itemModels[item] then
      return 4
   end
   local useAction = item:getUseAction()
   if useAction == 'EAT' then
      return 3
   elseif useAction == 'DRINK' then
      return 2
   end
   if item.id == 'minecraft:air' or item:getCount() == 0 then
      return 0
   end
   return 1
end

local function getFood()
   local limit = #itemPositions
   -- host:getSlot()
end