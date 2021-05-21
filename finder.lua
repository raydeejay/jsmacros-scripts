local finder = {}

local function nearby(pos1, pos2)
   local dist = 2
   return math.abs(pos1.x - pos2.x) < dist and math.abs(pos1.z - pos2.z) < dist
end

-- deprecated
-- function finder.findChests()
--    local pos = player:getPlayer():getPos()

--    local result = {}
--    for x = math.floor(pos.x) - 8, pos.x + 8 do
--       for z = math.floor(pos.z) - 8, pos.z + 8 do
--          if world:getBlock(x, math.floor(pos.y), z):getId() == 'minecraft:barrel' then
--             table.insert(result, {x= x, y=math.floor(pos.y), z= z})
--          end
--       end
--    end
   
--    return result
-- end

function finder.findBlocks(targets, radius)
   local radius = radius or 8
   local pos = player:getPlayer():getPos()

   local result = {}
   for x = math.floor(pos.x) - radius, pos.x + radius do
      for z = math.floor(pos.z) - radius, pos.z + radius do
         local block = world:getBlock(x, math.floor(pos.y), z)
         if targets[block:getId()] then
            table.insert(result, block)
         end
      end
   end

   return result
end

function finder.findInInventory(item)
   local inv = player:openInventory()
   local map = inv:getMap()

   for i,slot in ipairs(map.main) do
      local itemstack = inv:getSlot(slot)
      if item == itemstack:getItemID() then
         return slot
      end
   end
   
   inv:close()
   return nil
end

function finder.findInHotbar(item)
   local inv = player:openInventory()
   local map = inv:getMap()

   for i,slot in ipairs(map.hotbar) do
      local itemstack = inv:getSlot(slot)
      if item == itemstack:getItemID() then
         return slot
      end
   end

   inv:close()
   return nil
end


-- function finder.findBlocks(targets, radius)
--     local radius = radius or 8
--     local pos = player:getPlayer():getPos()

--     local result = {}
--     for x = math.floor(pos.x) - radius, pos.x + radius do
--         for z = math.floor(pos.z) - radius, pos.z + radius do
--             if targets[world:getBlock(x, math.ceil(pos.y), z):getId()] then
--                table.insert(result, {x= x, y= math.floor(pos.y), z= z})
--             end
--         end
--     end

--     return result
-- end

return finder
