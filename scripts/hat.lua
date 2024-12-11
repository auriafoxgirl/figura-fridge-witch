-- physics for the witch hat, same idea as christmas hat in advent of figura 2023

local modelParts = {
   {fridgeModel.hat.hat2, 0.5},
   {fridgeModel.hat.hat2.hat3, 1},
   {fridgeModel.hat.hat2.hat3.hat4, 1.25},
   {fridgeModel.hat.hat2.hat3.hat4.hat5, 1.5},
}

local newDir = vec(1, 0.5):normalize()
local oldDir = newDir:copy()
local vel = vec(0, 0)

function events.tick()
   oldDir = newDir
   
   local bodyYaw = (player:getBodyYaw() - player:getBodyYaw(0) + 180) % 360 - 180
   local playerVel = vectors.rotateAroundAxis(player:getBodyYaw(), player:getVelocity(), vec(0, 1, 0))
   playerVel = vec(
      math.clamp(playerVel.x * 0.5, -0.1, 0.1),
      math.min(playerVel.y, 0.1),
      math.clamp(playerVel.z * 0.5, -0.1, 0.1)
   )

   vel = vel + playerVel.xz * 0.4
   if playerVel.y > 0 then
      newDir = newDir * (1 + playerVel.y)
   else
      newDir = newDir / (1 - playerVel.y)
   end
   newDir = newDir * matrices.rotation2(-bodyYaw * 0.5)
   
   vel = vel:clamped(0, 1) * 0.8
   vel = vel + ((newDir - vec(-0.001, 0.001)):normalize() - newDir) * 0.1

   newDir = newDir + vel
end

function events.render(delta)
   local dir = math.lerp(oldDir, newDir, delta)

   local yaw = math.deg(math.atan2(dir.x, dir.y))
   local pitch = dir:length() * 25
   for _, modelData in pairs(modelParts) do
      local model = modelData[1]
      local pivot = model:getPivot()
      local mat = matrices.mat4()
      mat:translate(-pivot)
      mat:rotateY(-yaw)
      mat:rotateX(pitch * modelData[2])
      mat:rotateY(yaw)
      mat:translate(pivot)
      model:setMatrix(mat)
   end
end
