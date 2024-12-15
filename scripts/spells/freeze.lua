local spell = {
   icon = 'minecraft:ice',
   name = 'Freeze',
}

local commands = require('scripts.commands')

function spell.run(entity)
   if entity then
      commands.freeze(entity, 60)
   end
end

return spell