local type = event.screenName

local origins = {
   ['3 Row Chest'] = 90,
   ['6 Row Chest'] = 64,
   ['Shulker Box'] = 90,
   ['Horse'] = 90
}

local function stack_cb(button, screen)
   screen:addText('Stacked!', 50, 50, 0x999999, true)
   local inv = Player:openInventory()
   local map = inv:getMap()

   -- iterate through chest contents, collect unique ids
   local candidates = {}
   for i,slot in ipairs(map.container) do
      local id = inv:getSlot(slot):getItemID()
      candidates[id] = true
   end

   -- iterate through inventory, if id is in chest, shiftclick it
   -- don't stack from the hotbar, presumably we want to keep those items
   for i,slot in ipairs(map.main) do
      local id = inv:getSlot(slot):getItemID()
      if candidates[id] then
         inv:quick(slot)
      end
   end
end

local function restock_cb(button, screen)
   screen:addText('Restocked!', 50, 50, 0x999999, true)
   local inv = Player:openInventory()
   local map = inv:getMap()

   -- iterate through chest contents, collect unique ids
   local candidates = {}
   for i,slot in ipairs(map.container) do
      local id = inv:getSlot(slot):getItemID()
      candidates[id] = true
   end

   -- iterate through inventory, if id is in chest, shiftclick it
   for i,slot in ipairs(map.hotbar) do
      local id = inv:getSlot(slot):getItemID()
      if candidates[id] then
         inv:grabAll(slot)
         inv:click(slot, 0)
      end
   end

   for i,slot in ipairs(map.main) do
      local id = inv:getSlot(slot):getItemID()
      if candidates[id] then
         inv:grabAll(slot)
         inv:click(slot, 0)
      end
   end
end

local function sort_cb(button, screen)
   screen:addText('Sorted!', 50, 50, 0x999999, true)
   local inv = Player:openInventory()
   local map = inv:getMap()

   -- collect item and air slots
   local items = false

   for i,slot in ipairs(map.container) do
      if inv:getSlot(slot):getItemID() ~= 'minecraft:air' then
         items = true
         break
      end
   end

   -- nothing to do if the container is empty
   if not items then return end

   -- sort the items
   local again = true
   while again do
      again = false
      for i,slot in ipairs(map.container) do
         if i == #map.container then break end
         local a = inv:getSlot(slot):getItemID()
         if a == 'minecraft:air' then a = 'z' end

         local b = inv:getSlot(slot+1):getItemID()
         if b == 'minecraft:air' then b = 'z' end

         if a > b then
            again = true
            inv:swap(slot, slot+1)
         end
      end
   end
end

if origins[type] then
   local scr = Hud:getOpenScreen()
   scr:addButton(410, origins[type], 60, 20, 'Stack',
                 JavaWrapper:methodToJava(stack_cb))
   scr:addButton(410, origins[type]+24, 60, 20, 'Restock',
                 JavaWrapper:methodToJava(restock_cb))
   scr:addButton(410, origins[type]+48, 60, 20, 'Sort',
                 JavaWrapper:methodToJava(sort_cb))
end
