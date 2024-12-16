if not host:isHost() then
   return
end

local wand = require('scripts.wand')
local spells = require('scripts.spells_system')

local page = action_wheel:newPage('main')
action_wheel:setPage(page)

local wandAction = page:newAction()
wandAction:title('Toggle Wand')
wandAction:item('minecraft:debug_stick')
wandAction:onToggle(function()
   local enabled = wand.toggle()
   wandAction:setToggled(enabled)
end)
wandAction:setColor(vectors.hexToRGB('#182937'))
wandAction:setToggleColor(vectors.hexToRGB('#84ebff'))

local spellActions = {}
local function updateSpellActions()
   local attackSpell, attackKeyName = spells.getSpellAttack()
   local useSpell, useKeyName = spells.getSpellUse()

   for i, action in pairs(spellActions) do
      local spell = spells.spells[i]
      local isAttackSpell = attackSpell == i
      local isUseSpell = useSpell == i
      local title = {
         spell.name,
         '\n',
         {
            color = isAttackSpell and '#84ebff' or '#516b8a',
            text = '',
            extra = {
               isAttackSpell and '> ' or {
                  ' ',
                  {
                     text = ' ',
                     bold = true,
                  }
               },
               attackKeyName
            }
         },
         '\n',
         {
            color = isUseSpell and '#84ebff' or '#516b8a',
            text = '',
            extra = {
               isUseSpell and '> ' or {
                  ' ',
                  {
                     text = ' ',
                     bold = true,
                  }
               },
               useKeyName
            }
         },
      }
      action:setTitle(toJson(title))
      if isAttackSpell then
         if isUseSpell then
            action:setColor(1, 1, 1)
         else
            action:setColor(vectors.hexToRGB('#71c6ff'))
         end
      else
         if isUseSpell then
            action:setColor(vectors.hexToRGB('#6987ff'))
         else
            action:setColor(0, 0, 0)
         end
      end
   end
end

for i, spell in pairs(spells.spells) do
   local action = page:newAction()
   action:item(spell.icon)
   spellActions[i] = action
   action.leftClick = function()
      spells.setSpellAttack(i)
      updateSpellActions()
   end
   action.rightClick = function()
      spells.setSpellUse(i)
      updateSpellActions()
   end
end

updateSpellActions()