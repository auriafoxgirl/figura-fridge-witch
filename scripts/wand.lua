local wandModelOrginal = fridgeModel.wand
local wandModel = wandModelOrginal:getParent():newPart('wand')
wandModelOrginal:setPos(32, 0, 0)
   :setScale(0.75)
   :setSecondaryRenderType('GLINT')
wandModelOrginal:moveTo(wandModel)

local sync = require('scripts.sync')
require('scripts.sendChatMessages')

local pos = vec(0, 0, 0)
local oldPos = vec(0, 0, 0)
local targetPos = vec(0, 0, 0)
local rot = vec(0, 0, 0)
local oldRot = vec(0, 0, 0)
local wandEnabled = false
local oldPlayerRot
local playerRot

function pings.toggleWand(state)
   wandEnabled = state
end

sync.register('wand', function()
   return wandEnabled
end, function(state)
   wandEnabled = state
end)

local f3Key = keybinds:newKeybind('f3 no override', 'key.keyboard.f3')
local wandToggleKey = keybinds:fromVanilla('figura.config.action_wheel_button')
wandToggleKey.press = function()
   if f3Key:isPressed() then
      return
   end
   if wandEnabled then
      pings.toggleWand(false)
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
   fancyPrint('Wand enabled')
   pings.toggleWand(true)
   if player:getPermissionLevel() >= 2 then
      sendChatMessages(function(state)
         if not state then
            fancyPrint{
               'Figura Setting "',
               {translate = "figura.config.chat_messages"},
               '" is disabled'
            }
            fancyPrint("some wand features will be limited")
         end
      end)
   else
      fancyPrint("You don't have command permissions on this server")
      fancyPrint("some wand features will be limited")
   end
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

function events.entity_init()
   playerRot = player:getRot()
   oldPlayerRot = playerRot
end

function events.tick()
   if not isWandEnabled() then
      return
   end
   oldPlayerRot = playerRot
   playerRot = math.lerpAngle(oldPlayerRot, player:getRot(), 0.5)

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
   local wandPos = math.lerp(oldPos, pos, delta)
   local wandRot = math.lerp(oldRot, rot, delta)
   local mat = matrices.mat4()
   if renderer:isFirstPerson() then
      wandModel:setParentType('World')
   
      local rot = math.lerpAngle(math.lerpAngle(oldPlayerRot, playerRot, delta), player:getRot(), 0.8)

      wandPos.x = wandPos.x + (player:isLeftHanded() and -1 or 1) * 10
      mat:translate(wandPos + vec(0, -12, -2))
      
      mat:rotateX(30 - rot.x)
      mat:rotateY(180 - rot.y)
      
      mat:translate(client.getCameraPos() * 16)
   else
      wandPos = wandPos + vec(6, 22, -16)
      mat:rotate(wandRot)
      mat:translate(wandPos)
      wandModel:setParentType('None')
   end
   wandModel:setMatrix(mat)
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

return isWandEnabled