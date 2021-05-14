-- autominer.lua
-- raydeejay 2021

-- wagyourtail -- 10/05/2021
-- baritone doesn't like it when it's told to start
-- pathing and it's not from the main game thread
function onMain(fn)
   client:getMinecraft():execute(consumer:autoWrap(fn))
end

local baritone = reflection:getClass('baritone.api.BaritoneAPI'):getProvider():getPrimaryBaritone()
local GoalBlock = reflection:getClass('baritone.api.pathing.goals.GoalBlock')
local BetterBlockPos = reflection:getClass('baritone.api.utils.BetterBlockPos')
local p = player:getPlayer()

-- specify storage(s) coords
local chest = {x = 38620, y = 58, z = -48618}
local mine_base = {x = 38612, y = 13, z = -48620}

-- store the last mined point here?
local last_mined = nil



function clearSides()
   local pos = p:getPos()
   -- north in SMP, west in SSP (the position is offset? hm?)
   local feet = reflection:newInstance(BetterBlockPos, {pos.x, pos.y, pos.z}):north()  -- also why
   local selectionManager = baritone:getSelectionManager()

   selectionManager:removeAllSelections()
   selectionManager:addSelection(feet:south():up(), feet:south(5):up())
   selectionManager:addSelection(feet:north():up(), feet:north(5):up())
   chat:say('#sel cleararea')
   chat:say('#sel clear')
end

function getNextPos(pos, distance)
   return { math.floor(pos.x - distance), math.floor(pos.y), math.floor(pos.z) }
end

function moveForward()
   local goalProcess = baritone:getCustomGoalProcess()
   local pos = p:getPos()
   goalProcess:setGoalAndPath(reflection:newInstance(GoalBlock, getNextPos(pos, 3)))
end

function isWielding(item)
   return (p:getMainHand():getItemID() == item or p:getOffHand():getItemID() == item)
end

function placeTorch()
   local fpos = p:getPos()
   local x,y,z = math.floor(fpos.x), math.floor(fpos.y)-1, math.floor(fpos.z)

   if isWielding('minecraft:torch') then
      p:lookAt(x, y, z)
      keybind:keyBind('key.use', true)
      keybind:keyBind('key.use', false)
      client:waitTick()
   end
end

function stripmine(steps)
   chat:say('#allowPlace true')
   chat:say('#allowBreak true')
   for i = 1,steps do
      chat:title("Step #" .. i .. " of " .. steps)
      local yaw, pitch = p:getYaw(), p:getPitch()

      onMain(moveForward)
      client:waitTick(60)  -- fix...?

      local pos = p:getPos()
      local light = world:getBlockLight(math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))

      if light < 8 then placeTorch() end

      onMain(clearSides)
      client:waitTick(100)  -- fix as well...?

      -- show toast if low on torches
      -- mine uncovered ores nearby
      -- then come back to the end position

      p:lookAt(yaw, pitch)
   end

   chat:say('#wp delete last_mined')
   chat:say('#wp save user last_mined')
end


function isNear(pos1, dist)
   local dist = dist or 3
   local pos2 = p:getPos()
   return math.abs(pos1.x - pos2.x) < dist and
      math.abs(pos1.y - pos2.y) < dist and
      math.abs(pos1.z - pos2.z) < dist
end


local cargo = {
   ['minecraft:iron_ore'] = true,     ['minecraft:gold_ore'] = true,
   ['minecraft:coal_ore'] = true,     -- ['minecraft:coal'] = true,
   ['minecraft:lapis_ore'] = true,    -- ['minecraft:lapis'] = true,
   ['minecraft:redstone_ore'] = true, -- ['minecraft:redstone'] = true,
   ['minecraft:diamond_ore'] = true,  -- ['minecraft:diamond'] = true,
   ['minecraft:emerald_ore'] = true,  -- ['minecraft:emerald'] = true
}

function deposit(inv, slot)
   local itemstack = inv:getSlot(slot)
   if (cargo[itemstack:getItemID()]) then
      inv:quick(slot)
      --client:waitTick()
   end
end


function goHomeAndBack()
   chat:title('Going back to base')

   chat:say('#allowPlace true')
   chat:say('#allowBreak false')
   chat:say('#home') -- or base coords
   --chat:say(string.format('#goto %d %d %d', chest[1], chest[2], chest[3])) -- or base coords

   while not isNear(chest, 1) do client:waitTick() end
   chat:say('#stop')
   -- need to update the information about the surroundings somehow...
   --chat:say('#goto chest')
   p:lookAt(chest.x+0.5, chest.y+0.5, chest.z+0.5)
   keybind:keyBind('key.use', true)
   keybind:keyBind('key.use', false)
   
   -- wait for the interface to open
   while not hud:isContainer() do client:waitTick() end

   -- iterate through all inventory slots (and hotbar?)
   local inv = player:openInventory()
   local map = inv:getMap()

   for i,slot in ipairs(map.hotbar) do  deposit(inv, slot)  end
   for i,slot in ipairs(map.main)   do  deposit(inv, slot)  end

   inv:close()

   client:waitTick(20)

   chat:title('Going back to the mine')
   chat:say(string.format('#goto %d %d %d', mine_base.x, mine_base.y, mine_base.z))
   while not isNear(mine_base, 3) do client:waitTick() end
   chat:say('#wp goto last_mined')
end

function kconcat(tab, sep)
   local ctab, n = {}, 1
   for k, v in pairs(tab) do
      ctab[n] = k
      n = n + 1
   end
   return table.concat(ctab, sep)
end


function collectOres(distance)
   chat:title('Collecting ores')
   chat:say('#allowPlace false')
   chat:say('#allowBreak true')

   local pos = p:getPos()
   chat:say('#mine ' .. kconcat(cargo, ' '))
   while isNear(pos, distance) do
      local pos = p:getPos()
      local light = world:getBlockLight(math.floor(pos.x), math.floor(pos.y), math.floor(pos.z))
      if light < 8 then placeTorch() end
      client:waitTick()
   end
   
   chat:say('#stop')
end

-- should force legitmine and stuff

local times = 6

stripmine(times)
collectOres(times * 3 + 8)
--close passages?
goHomeAndBack()
