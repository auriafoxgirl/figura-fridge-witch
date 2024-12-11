nameplate.ALL:setText(toJson{
   "${badges}:witch_hat: ",
   {
      text = '${name}',
      color = '#84ebff'
   }
})
nameplate.ENTITY:setOutline(true)
nameplate.ENTITY:setOutlineColor(vectors.hexToRGB('#061231'))
nameplate.ENTITY:setBackgroundColor(0, 0, 0, 0)

function events.tick()
   local y = player:getEyeHeight() * 16 + 16
   nameplate.ENTITY:setPivot(0, y / 16, 0)
end