local spell = {
   icon = 'minecraft:ice',
   name = 'Freeze',
}

local commands = require('scripts.commands')
local particleEffects = require('scripts.particleEffects')

function spell.run(entity)
   particleEffects.line(8, 32)
   if entity then
      commands.freeze(entity, 60)
   end
end

return spell