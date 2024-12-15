local keyUse = keybinds:fromVanilla('key.use')
local keyAttack = keybinds:fromVanilla('key.attack')
local wand = require('scripts.wand')

local mod = {}

local spellAttack = 1
local spellUse = 1
local spells = {}
mod.spells = spells
do
   local spellsByName = {}
   local spellNames = {}
   for _, script in pairs(listFiles('scripts.spells')) do
      local spell = require(script)
      spellsByName[spell.name] = spell
      table.insert(spellNames, spell.name)
   end 
   table.sort(spellNames)
   for _, name in pairs(spellNames) do
      table.insert(spells, spellsByName[name])
   end
end

function mod.getSpellAttack()
   return spellAttack, keyAttack:getKeyName()
end

function mod.getSpellUse()
   return spellUse, keyUse:getKeyName()
end

function mod.setSpellAttack(i)
   spellAttack = i
end

function mod.setSpellUse(i)
   spellUse = i
end

---@overload fun(uuid: string): string
local function packUuid(uuid)
   uuid = uuid:gsub('%X+', '')
   local small = ''
   for i = 1, #uuid, 2 do
      small = small..string.char(tonumber(uuid:sub(i, i + 1), 16))
   end
   return small
end

local uuidDashes = {[4] = true, [6] = true, [8] = true, [10] = true}
---@overload fun(uuidSmall: string): string
local function unpackUuid(uuidSmall)
   local uuid = ''
   for i = 1, #uuidSmall do
      uuid = uuid..string.format('%02x', string.byte(uuidSmall:sub(i, i)))
      if uuidDashes[i] then
         uuid = uuid..'-'
      end
   end
   return uuid
end

function pings.castSpell(spellId, entityUuid)
   if not player:isLoaded() then
      return
   end
   local entity = entityUuid and world.getEntity(unpackUuid(entityUuid))
   spells[spellId].run(entity)

   local pos = player:getPos()
   local subtitle = toJson{text = 'wand sounds', color = '#84ebff'}
   sounds["minecraft:block.amethyst_block.chime"]:setPitch(0.5):pos(pos):subtitle(subtitle):play()
   sounds["minecraft:block.amethyst_block.resonate"]:setPitch(0.4):pos(pos):subtitle(subtitle):play()
   sounds["minecraft:block.amethyst_block.resonate"]:setPitch(0.8):pos(pos):subtitle(subtitle):play()
   sounds["minecraft:block.large_amethyst_bud.break"]:setPitch(0.8):pos(pos):subtitle(subtitle):play()
end

local function castSpell(spellId)
   if not player:isLoaded() then
      return
   end
   if action_wheel:isEnabled() then
      return
   end
   if not wand.getEnabled() then
      return
   end

   local playerEyePos = player:getPos():add(0, player:getEyeHeight(), 0)
   local playerDir = player:getLookDir()

   local entity = player:getTargetedEntity(20)
   if not entity then
      local ignoredEntities = {[avatar:getUUID()] = true}
      for i = 3, 20 do
         local pos = playerEyePos + i * playerDir
         local dist = math.min(i * 0.2, 3)
         local entities = getEntities(pos - dist, pos + dist, ignoredEntities)
         if #entities >= 1 then
            entity = entities[1]
            break
         end
      end
   end
   if entity then
      local dist = (playerEyePos - entity:getPos()):length()
      local _, blockPos = player:getTargetedBlock(true, 20)
      local blockDist = (playerEyePos - blockPos):length()
      if dist > blockDist + 1 then
         entity = nil
      end
   end

   local entityUuid = entity and packUuid(entity:getUUID())

   pings.castSpell(spellId, entityUuid)

   return true
end

keyAttack.press = function()
   return castSpell(spellAttack)
end

keyUse.press = function()
   return castSpell(spellUse)
end

return mod