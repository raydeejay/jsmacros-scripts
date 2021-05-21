-- autofarmer.lua
-- raydeejay 2021

local finder = require('config/jsMacros/Macros/finder')

function onMain(fn)
   client:getMinecraft():execute(consumer:autoWrap(fn))
end

local baritone = reflection:getClass('baritone.api.BaritoneAPI'):getProvider():getPrimaryBaritone()
local GoalBlock = reflection:getClass('baritone.api.pathing.goals.GoalBlock')
local p = player:getPlayer()

function tap(key)
   keybind:keyBind(key, true)
   keybind:keyBind(key, false)
end

local crops = {
   ['minecraft:wheat'] = 'minecraft:wheat_seeds',
   ['minecraft:beetroots'] = 'minecraft:beetroot_seeds',
   ['minecraft:carrots'] = 'minecraft:carrot',
   ['minecraft:potatoes'] = 'minecraft:potato'
}

function maturity(crop)
   if crop == 'minecraft:beetroots' then return '3' end
   return '7'
end

function selectSeed(crop)
   local slot = finder.findInHotbar(crops[crop])
   local inv = player:openInventory()

   if slot then
      local slot = slot-36
      inv:setSelectedHotbarSlotIndex(slot)
   else
      local slot = finder.findInInventory(crops[crop])
      if slot then
         inv:swap(inv:getSelectedHotbarSlotIndex()+36, slot)
      else
         chat:log('Missing seeds for ' .. crop)
      end
   end
end

function farm(targets)
   for i,v in ipairs(targets) do
      local x,y,z,age = v:getX(), v:getY(), v:getZ(), v:getBlockState().age

      if age == maturity(v:getId()) then
         local goalProcess = baritone:getCustomGoalProcess()
         local pos = p:getPos()
         goalProcess:setGoalAndPath(reflection:newInstance(GoalBlock, {x, y, z}))

         while goalProcess:isActive() do client:waitTick() end
         p:lookAt(x+0.5, y-2, z+0.5)

         selectSeed(v:getId())

         tap('key.attack')
         tap('key.use')

         client:waitTick(6)
      end
   end
end


local targets = finder.findBlocks(crops, 32)
chat:toast('Farmer', 'Found ' .. #targets .. ' crops')

farm(targets)

chat:toast('Farmer', 'Finished')
