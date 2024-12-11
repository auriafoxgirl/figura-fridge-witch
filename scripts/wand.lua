local wandModelOrginal = fridgeModel.wand
local wandModel = wandModelOrginal:getParent():newPart('wand')
wandModelOrginal:setPos(32, 0, 0)
   :setScale(0.75)
   :setSecondaryRenderType('GLINT')
wandModelOrginal:moveTo(wandModel)

local pos = vec(0, 0, 0)
local oldPos = vec(0, 0, 0)
local targetPos = vec(0, 0, 0)
local rot = vec(0, 0, 0)
local oldRot = vec(0, 0, 0)
local wandEnabled = false

local wandToggleKey = keybinds:fromVanilla('figura.config.action_wheel_button')
wandToggleKey.press = function()
   if wandEnabled then
      wandEnabled = false
      fancyPrint('Wand disabled')
      return true
   end
   if not player:isLoaded() then
      return true
   end
   if player:getItem(1).id ~= 'minecraft:air' then
      fancyPrint("Couldn't enable wand, make sure you are not holding any item")
      return true
   end
   wandEnabled = true
   fancyPrint('Wand enable')
   return true
end

local function isWandEnabled()
   if player:getItem(1).id ~= 'minecraft:air' then
      return false
   end
   return wandEnabled
end

local function randomVector()
   return vec(
      math.random(),
      math.random(),
      math.random()
   ) * 2 - 1
end

function events.tick()
   if not isWandEnabled() then
      return
   end
   oldPos = pos
   pos = math.lerp(pos, targetPos, 0.4)
   oldRot = rot
   rot = math.lerp(rot, vec(pos.y, -pos.x, 0) * 2, 0.4)

   local wandTipPos = wandModelOrginal.wandTip:partToWorldMatrix():apply()
   for _ = 1, 2 do
      particles['totem_of_undying']
         :pos(wandTipPos + randomVector() * 0.2)
         :velocity(randomVector() * 0.01)
         :gravity(-0.05)
         :size(0.25)
         :lifetime(math.random(5, 15))
         :color(math.lerp(vec(1, 1, 1), vec(0.6, 0.8, 1), math.random()))
         :spawn()
   end
end

local function updateModel(delta)
   if not isWandEnabled() then
      wandModel:visible(false)
      return
   end
   local wandPos = math.lerp(oldPos, pos, delta) + vec(0, 24, -16)
   local wandRot = math.lerp(oldRot, rot, delta)
   if renderer:isFirstPerson() then
      wandModel:setParentType('World')
      local rot = player:getRot(delta)
      local eyeHeight = player:getEyeHeight() * 16
      wandPos.z = wandPos.z + 6
      wandPos.x = wandPos.x + (player:isLeftHanded() and -1 or 1) * 16
      wandPos.y = wandPos.y - eyeHeight
      wandPos = wandPos * matrices.xRotation3(-rot.x) * matrices.yRotation3(180 - rot.y)
      wandPos.y = wandPos.y + eyeHeight - 4
      wandPos = wandPos + player:getPos(delta) * 16
      wandRot.y = wandRot.y - rot.y + 180
      wandRot.x = wandRot.x - rot.x + 30
   else
      wandPos.x = wandPos.x + 6
      wandPos.y = wandPos.y - 2
      wandModel:setParentType('None')
   end
   wandModel:pos(wandPos)
   wandModel:rot(wandRot)
   wandModel:visible(true)
end

function events.render(delta)
   updateModel(delta)
end

wandModel.preRender = function(delta)
   if not player:isLoaded() then
      return
   end
   updateModel(delta)
end