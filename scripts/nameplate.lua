---formats text
---@param str string
---@param startColor string?
---@return table
local function formatText(str, startColor)
   local json = toJson({{text = str, color = startColor}})
   json = json:gsub('${(.-)}', '"},{"color":"%1","text":"')
   return parseJson(json)
end

nameplate.ALL:setText(toJson{
   {
      text = "${badges}:witch_hat: ",
      hoverEvent = {action = "show_text", value = {
         avatar:getEntityName(),
         {text = ' ❄', color = '#84ebff'},
         '\n',
         formatText(avatar:getUUID():gsub('%-', '${#84ebff}-${#ffffff}'), '#ffffff'),
         formatText([[

┌──┐
││    │     ${#84ebff}Made by${#4769d7}:${#ffffff}
││    │     ${#84ebff}AuriaFoxGirl${#ffffff}
├──┤
││    │
└──┘]])
      }},
   },
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