local sync = require('scripts.sync')
local itemsContainerBase = fridgeModel.itemsContainer
local itemsContainer = itemsContainerBase:newPart('')
local getFridgeItems
local previousFridgeItems = ''
local itemPositions = {
   vec(-3, 25, -2),
   vec(2.5, 25, 2),
   vec(2.5, 19, -2),
   vec(-3, 19, 2),
   vec(-3, 13, -2),
   vec(2.5, 13, 2),
}

local characterMap = {
   A = '_',
   B = '-',
   C = '.',
   D = '/',
   E = ':',
   Z = ';', -- next item
   Y = '',  -- empty, to make sure the data wont get weird at end
   X = '@', -- player head
}
local characterMapReversed = {}
for i, v in pairs(characterMap) do
   characterMapReversed[v] = i
end

local function setFridgeItems(compressed)
   if previousFridgeItems == compressed then
      return
   end
   previousFridgeItems = compressed
   -- decode base64
   local buffer = data:createBuffer()
   buffer:writeByteArray(compressed)
   buffer:setPosition(0)
   local text = buffer:readBase64()
   buffer:close()
   -- replace some characters with other
   text = text:gsub('.', characterMap)
   -- items
   local i = 0
   itemsContainerBase:removeChild(itemsContainer)
   itemsContainer = itemsContainerBase:newPart('')
   for itemStr in text:gmatch('[^;]+') do
      if itemStr:sub(1, 1) == '@' then
         itemStr = 'minecraft:player_head{SkullOwner:' .. itemStr:sub(2, -1) .. '}'
      end
      local success, item = pcall(world.newItem, itemStr)
      if success then
         i = i + 1
         local model = itemsContainer:newPart('')
         model:setPos(itemPositions[i])
         model:setLight(15, 15)
         if itemModels[item.id] then
            model:addChild(itemModels[item.id])
         else
            model:newItem('')
               :setItem(item)
               :setDisplayMode('FIXED')
               :rot(0, 180 + math.cos(i * 4) * 20, 0)
               :light(15, 15)
               :setScale(0.35)
               :setPos(0, 2.5, 0)
         end
      end
   end
end

function pings.syncItems(data)
   setFridgeItems(data)
end

sync.register('items', function()
   return getFridgeItems()
end, setFridgeItems)

-- host only
if not host:isHost() then
   return
end

---returns how food is item
---@param item ItemStack
local function getFoodScore(item)
   if itemModels[item.id] then
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

local function simplifyItem(itemStr)
   local itemId = world.newItem(itemStr).id
   if itemId == 'minecraft:player_head' then
      -- for some reason item.tag doesnt include the profile data?
      local success, tag = pcall(parseJson, itemStr:match('%b{}$'))
      if success then
         local owner
         if type(tag) == 'table' then
            if type(tag.SkullOwner) == 'table' and type(tag.SkullOwner.Name) == 'string' then
               owner = tag.SkullOwner.Name
            elseif type(tag['minecraft:profile']) == 'table' and type(tag['minecraft:profile'].name) == 'string' then
               owner = tag['minecraft:profile'].name
            end
         end
         if owner then
            owner = owner:lower()
            
            local item = '@'..owner
            item = item:gsub('.', characterMapReversed)

            return item
         end
      end
   end

   itemId = itemId:gsub('^minecraft:', '')
   itemId = itemId:gsub('.', characterMapReversed)

   return itemId
end

function getFridgeItems()
   local limit = #itemPositions
   -- get inventory
   local inventory = {}
   for i = 0, 35 do
      local item = host:getSlot(i)
      local score = getFoodScore(item)
      if score >= 1 then
         inventory[item:toStackString()] = getFoodScore(item)
      end
   end
   -- sort items
   local scores = {}
   for i = 1, 4 do
      scores[i] = {}
   end
   for id, score in pairs(inventory) do
      table.insert(scores[score], id)
   end
   -- get best items
   local items = {}
   for i = #scores, 1, -1 do
      local v = scores[i]
      table.sort(v)
      for _, item in pairs(v) do
         table.insert(items, item)
         if #items >= limit then
            break
         end
      end
      if #items >= limit then
         break
      end
   end
   table.sort(items)
   -- compress
   local tbl = {}
   for _, item in pairs(items) do
      local itemStr = simplifyItem(item)
      itemStr = itemStr:gsub('[^%w+/]', '')
      table.insert(tbl, itemStr)
   end
   local str = table.concat(tbl, 'Z')
   -- while a bit weird, making it act like it was base64 makes it 25% smaller
   str = str .. ('Y'):rep(4 - #str % 4)
   local buffer = data:createBuffer()
   buffer:writeBase64(str)
   buffer:setPosition(0)
   local output = buffer:readByteArray()
   buffer:close()
   -- return
   return output
end

local oldItems = ''
function events.tick()
   if time % 20 ~= 0 then
      return
   end
   local newItems = getFridgeItems()
   if newItems ~= oldItems then
      oldItems = newItems
      pings.syncItems(newItems)
   end
end