-- autofarmer.lua
-- raydeejay 2021

local finder = require('config/jsMacros/Macros/finder')

local baritone = reflection:getClass('baritone.api.BaritoneAPI'):getProvider():getPrimaryBaritone()
local GoalBlock = reflection:getClass('baritone.api.pathing.goals.GoalBlock')
local p = player:getPlayer()

function tap(key)
   keybind:keyBind(key, true)
   keybind:keyBind(key, false)
end

local crops = {
   -- ['minecraft:nether_wart'] = {seed='minecraft:nether_wart', maturity='3'},
   -- baritone is awful at soulsand, unfortunately
   ['minecraft:wheat'] = {seed='minecraft:wheat_seeds', maturity='7'},
   ['minecraft:beetroots'] = {seed='minecraft:beetroot_seeds', maturity='3'},
   ['minecraft:carrots'] = {seed='minecraft:carrot', maturity='7'},
   ['minecraft:potatoes'] = {seed='minecraft:potato', maturity='7'}
}

local reeds = {
   ['minecraft:sugar_cane'] = true,
   ['minecraft:bamboo'] = true
}

function selectSeed(seed)
   local slot = finder.findInHotbar(seed)
   local inv = player:openInventory()

   if slot then
      local slot = slot-36
      inv:setSelectedHotbarSlotIndex(slot)
   else
      local slot = finder.findInInventory(seed)
      if slot then
         inv:swap(inv:getSelectedHotbarSlotIndex()+36, slot)
      else
         chat:log('Missing seeds ' .. seed)
      end
   end
end

function farm(targets)
   for i,v in ipairs(targets) do
      local x,y,z,age = v:getX(), v:getY(), v:getZ(), v:getBlockState().age
      local crop = crops[v:getId()]

      if age == crop.maturity then
         local goalProcess = baritone:getCustomGoalProcess()
         local pos = p:getPos()
         goalProcess:setGoalAndPath(reflection:newInstance(GoalBlock, {x, y, z}))

         while goalProcess:isActive() do client:waitTick() end
         p:lookAt(x+0.5, y-2, z+0.5)

         selectSeed(crop.seed)

         tap('key.attack')
         tap('key.use')

         client:waitTick(6)
      end
   end
end

function farmReeds(targets)
   -- TODO: should select sword
   for i,v in ipairs(targets) do
      local x,y,z = v:getX(), v:getY(), v:getZ()
      local id, below, above = v:getId(), world:getBlock(x,y-1,z):getId(), world:getBlock(x,y+1,z):getId()

      if id ~= below and id == above then
         local goalProcess = baritone:getCustomGoalProcess()
         local pos = p:getPos()
         goalProcess:setGoalAndPath(reflection:newInstance(GoalBlock, {x, y, z}))

         while goalProcess:isActive() do client:waitTick() end
         p:lookAt(x+0.5, 255, z+0.5)
         p:lookAt(p:getYaw(), 0)

         tap('key.attack')

         client:waitTick(6)
      end
   end
end


chat:toast('Farmer', 'Scanning')

-- farm reeds first so there's no need to find the sword
local target_reeds = finder.findBlocks(reeds, 32)
chat:toast('Farmer', 'Found ' .. #target_reeds .. ' reeds')
farmReeds(target_reeds)

local target_crops = finder.findBlocks(crops, 32)
chat:toast('Farmer', 'Found ' .. #target_crops .. ' crops')
farm(target_crops)

chat:toast('Farmer', 'Finished')
