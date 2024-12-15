-- particle effects for wand spells
local mod = {}

local coldParticles = {
   'totem_of_undying',
   'cloud'
}

local function randomVector()
   return vec(
      math.random(),
      math.random(),
      math.random()
   ) * 2 - 1
end

local function indexParticle(k)
   return particles[k]
end

---@param k string
---@return boolean
local function particleExists(k)
   return (pcall(indexParticle, k))
end

---@overload fun(dist: number, amount: number)
function mod.line(dist, amount)
   local pos = player:getPos():add(0, player:getEyeHeight(), 0)
   local dir = player:getLookDir()
   for _ = 1, amount do
      particles[coldParticles[math.random(2)]]
         :pos(pos + dir * math.random() * dist)
         :velocity(randomVector() * 0.1 + dir * 0.2)
         :gravity(-0.05)
         :size(0.25)
         :lifetime(math.random(10, 30))
         :color(math.lerp(vec(1, 1, 1), vec(0.6, 0.8, 1), math.random()))
         :spawn()
   end
end

---@overload fun(pos1: Vector3, pos2: Vector3)
function mod.box(pos1, pos2)
   local center = (pos1 + pos2) * 0.5
   for _ = 1, 32 do
      local pos = vec(
         math.lerp(pos1.x, pos2.x, math.random()),
         math.lerp(pos1.y, pos2.y, math.random()),
         math.lerp(pos1.z, pos2.z, math.random())
      )
      particles['cloud']
         :pos(pos)
         :velocity(randomVector() * 0.05 + (pos - center):normalize() * 0.1)
         :gravity(-0.05)
         :size(1)
         :lifetime(math.random(10, 30))
         :color(math.lerp(vec(1, 1, 1), vec(0.6, 0.8, 1), math.random()))
         :spawn()
   end
end

---@overload fun(pos1: Vector3, pos2: Vector3)
function mod.boxIce(pos1, pos2)
   if not particleExists('block ice') then
      return
   end
   local center = (pos1 + pos2) * 0.5
   for _ = 1, 32 do
      local pos = vec(
         math.lerp(pos1.x, pos2.x, math.random()),
         math.lerp(pos1.y, pos2.y, math.random()),
         math.lerp(pos1.z, pos2.z, math.random())
      )
      particles['block ice']
         :pos(pos)
         :velocity(randomVector() * 0.05 + (pos - center):normalize() * 0.1)
         :lifetime(math.random(10, 30))
         :color(math.lerp(vec(1, 1, 1), vec(0.6, 0.8, 1), math.random()))
         :spawn()
   end
end

return mod