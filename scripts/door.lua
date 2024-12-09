local model = fridgeModel.door
local rot = 0
local oldRot = 0
local vel = 10 * 0
local closed = true

function events.tick()
   oldRot = rot
   vel = vel * 0.9

   local bodyYaw = (player:getBodyYaw() - player:getBodyYaw(0) + 180) % 360 - 180
   local playerVel = vectors.rotateAroundAxis(player:getBodyYaw(), player:getVelocity(), vec(0, 1, 0))
   vel = vel + bodyYaw * 0.2
   vel = vel - playerVel.z * 10 + playerVel.x * 10

   rot = rot + vel
   if rot > 100 then
      rot = 100
      vel = math.abs(vel) * -0.2
   elseif rot < 0 then
      if not closed and not renderer:isFirstPerson() then
         local volume = math.min(math.abs(vel) * 0.05, 1)
         sounds['block.iron_door.close']
            :pos(player:getPos())
            :volume(volume)
            :pitch(1.1)
            :play()
      end
      closed = true
      rot = 0
      vel = vel * 0.2
   end
   if rot > 5 then
      closed = false
   end
end

function events.render(delta)
   model:setRot(0, math.lerp(oldRot, rot, delta), 0)
end