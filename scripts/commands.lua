local mod = {}

local iceBlocks = require('scripts.ice_blocks')

local function canRunCommands()
   return host:isHost() and player:getPermissionLevel() >= 2
end

local function sendCommand(command)
   if #command >= 256 then
      return
   end
   host:sendChatCommand(command)
end

local function formatNumber(x)
   local sign = x < 0 and '-' or ''
   x = math.abs(x)
   local decimals = tostring(math.floor((x % 1) * 10000) / 10000)
   if decimals == '0' then
      return sign..tostring(math.floor(x))
   end
   return sign..tostring(math.floor(x))..'.'..decimals:gsub('^0%.', '')
end

local function formatPos(pos)
   return formatNumber(pos.x)..' '..formatNumber(pos.y)..' '..formatNumber(pos.z)
end

local function formatMotion(vel)
   return formatNumber(vel.x)..'d,'..formatNumber(vel.y)..'d,'..formatNumber(vel.z)..'d'
end

---@overload fun(entity: Entity, time: number)
function mod.freeze(entity, time)
   iceBlocks.iceEntity(entity, time)
   if not canRunCommands() then
      return
   end
   if entity:isLiving() then
      sendCommand('effect give '..entity:getUUID()..' slowness '..math.floor(time / 20)..' 6 true')
   end
end

---@overload fun(pos: Vector3, vel: Vector3)
function mod.snowball(pos, vel)
   if not canRunCommands() then
      return
   end
   sendCommand('summon snowball '..formatPos(pos)..' {Motion:['..formatMotion(vel)..']}')
end

---@overload fun(entity: Entity, damage: number)
function mod.spikeDamage(entity, damage)
   if not canRunCommands() then
      return
   end
   local id = entity:getType()
   if not entity:isLiving() and id ~= 'minecraft:boat' and not id:match('minecart') then
      return
   end
   sendCommand('damage '..entity:getUUID()..' '..formatNumber(damage)..' minecraft:player_attack by @s')
end

return mod