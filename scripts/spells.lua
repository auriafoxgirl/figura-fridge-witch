local keyUse = keybinds:fromVanilla('key.use')
local isWandEnabled = require('scripts.wand')

keyUse.press = function()
   if not player:isLoaded() then
      return
   end
   if not isWandEnabled() then
      return
   end
   print('blep')
end