-- Config
maxUsedSlotsPerCell = 55
paddingPercent = 100
rootDir = "AE2_Defrag"

--Set directory
shell.setDir(rootDir)

--wpp support
wpp = require("dependencies/wpp")
wpp.wireless.connect("defrag")

--monitor
monName = "wpp@defrag://19/monitor_19"
monitor = wpp.peripheral.wrap(monName)

function main()
    monitor.clear()
    monitor.setTextScale(0.5)
    monitor.setCursorPos(1, 1)
    monitor.setCursorBlink(false)
    redstone.setOutput("bottom", true)
    term.redirect(monitor)

    --Live system peripheral names
    systemDriveNames = {
        "ae2:drive_17",
        "ae2:drive_18",
        "ae2:drive_19",
        "ae2:drive_20",
        "ae2:drive_23",
        "ae2:drive_21",
        "ae2:drive_22"
    }

    --Workspace peripheral names
    ioPort = "ae2:io_port_4"
    interface = "meBridge_5"
    chest = "ae2:chest_6"
    drives = {
        "ae2:drive_24",
        "ae2:drive_25",
        "ae2:drive_26",
        "ae2:drive_27",
        "ae2:drive_28",
        "ae2:drive_29",
        "ae2:drive_30",
        "ae2:drive_31",
    }

    --Cell names and capacity
    capacityByName = {
        ["ae2:item_storage_cell_1k"] = 1024,
        ["ae2:item_storage_cell_4k"] = 4096,
        ["ae2:item_storage_cell_16k"] = 16384,
        ["ae2:item_storage_cell_64k"] = 65536,
        ["ae2:item_storage_cell_256k"] = 262144,
        ["ae2additions:item_storage_cell_1024"] = 1048576,
        ["ae2additions:item_storage_cell_4096"] = 8388608,
        ["ae2additions:item_storage_cell_16384"] = 16777216,
        ["ae2additions:item_storage_cell_65536"] = 67108864
    }

    -- /Config

    -- Util Functions

    local clock = os.clock
    local function sleep(n) -- seconds
        local t0 = clock()
        while clock() - t0 <= n do end
    end

    local function map(array, func)
        local new_array = {}
        for i, v in pairs(array) do
            new_array[i] = func(v, i)
        end
        return new_array
    end

    local function values(obj)
        local result = {}
        for _, v in pairs(obj) do
            table.insert(result, v)
        end
        return result
    end

    local function groupBy(array, prop)
        local result = {}
        for _, element in pairs(array) do
            if element[prop] ~= nil then
                if result[element[prop]] == nil then
                    result[element[prop]] = {}
                end
                table.insert(result[element[prop]], element)
            end
        end
        return result
    end

    -- /Util Functions

    -- Peripherals

    local systemDrives = map(systemDriveNames, function(driveName)
        returnperipheral.wrap(driveName)
    end)
    local workspace = {
        ioPort = peripheral.wrap(ioPort),
        interface = peripheral.wrap(interface),
        chest = peripheral.wrap(chest),
        drives = map(drives, function(driveName)
            return peripheral.wrap(driveName)
        end)
    }

    -- /Peripherals

    -- Classes

    -- Cell

    local cells = {}
    local additionallyRequiredCells = {}
    local Cell = {}
    Cell.__index = Cell

    Cell.capacities = (function()
        local capacities = values(capacityByName)
        table.sort(capacities, function(a, b) return a < b end)
        return capacities
    end)()

    function Cell.sortByUnusedBytesDesc(a, b)
        return b:getNumUnusedBytes() < a:getNumUnusedBytes()
    end

    function Cell.sortByCapacity(a, b)
        return a.capacity < b.capacity
    end

    function Cell.sortByCapacityDesc(a, b)
        return b.capacity < a.capacity
    end

    function Cell.loadAll()
        for driveNum, systemDrive in ipairs(systemDrives) do
            local systemCells = systemDrive.list()
            local toSlotNum = 1
            for _, cell in pairs(systemCells) do
                table.insert(cells, Cell.new(capacityByName[cell.name], driveNum, toSlotNum))
                toSlotNum = toSlotNum + 1
            end
        end
        table.remove(cells, #cells)
    end

    function Cell.new(capacity, driveNum, slotNum)
        local self = setmetatable({}, Cell)
        self.capacity = capacity
        self.driveNum = driveNum
        self.slotNum = slotNum
        self.inventory = {}
        return self
    end

    function Cell.getSmallestCellNeededForStack(stack)
        for _, capacity in ipairs(Cell.capacities) do
            local cell = Cell.new(capacity)
            if cell:hasSpaceFor(stack) then
                return cell
            end
        end
    end

    function Cell:getNumUsedBytes()
        local bytesUsed = 0
        for _, stackData in pairs(self.inventory) do
            bytesUsed = bytesUsed + self:getBytesForStack(stackData)
        end
        return bytesUsed
    end

    function Cell:add(stack)
        table.insert(self.inventory, stack)
        if self:getNumUsedBytes() > self.capacity then
            error("Unexpected error: inventory has exceeded capacity")
        end
    end

    function Cell:getBytesForStack(stack)
        return (self.capacity / 128) + math.ceil(stack.count / 8)
    end

    function Cell:hasSpaceFor(stack)
        local bytesUsed = self:getNumUsedBytes()
        local hasEnoughBytes = bytesUsed + self:getBytesForStack(stack) < self.capacity
        local hasEnoughSlots = self:getNumUnusedSlots() > 0
        return hasEnoughBytes and hasEnoughSlots
    end

    function Cell:getNumUnusedBytes()
        return self.capacity - self:getNumUsedBytes()
    end

    function Cell:getNumUnusedSlots()
        return maxUsedSlotsPerCell - #self.inventory
    end

    function Cell:clearAndPutInWorkspaceChest()
        local drive = workspace.drives[self.driveNum]
        drive.pushItems(ioPort, self.slotNum)
        while workspace.ioPort.list()[7] == nil do
            sleep(0.1)
        end
        workspace.ioPort.pushItems(chest, 7)
    end

    function Cell:exportInventoryToWorkspaceChest()
        for _, stack in ipairs(self.inventory) do
            stack:exportToWorkspaceChest()
        end
    end

    local outputDrives = {}
    for _, drive in pairs(systemDrives) do
        table.insert(outputDrives, drive)
    end
    local currentOutputDrive = table.remove(outputDrives, 1)
    function Cell:moveBackToSystem()
        currentOutputDrive.pullItems(chest, 2)
        if #currentOutputDrive.list() == 10 then
            currentOutputDrive = table.remove(outputDrives, 1)
        end
    end

    -- Stack

    local stacks = {}
    local Stack = {}
    Stack.__index = Stack

    function Stack.sortByCountDesc(a, b)
        return b.count < a.count
    end

    function Stack.loadAll()
        local handledItemTypes = {}
        local allItemTypes = workspace.interface.listItems()
        for _, itemType in pairs(allItemTypes) do
            if handledItemTypes[itemType.name] == nil then
                handledItemTypes[itemType.name] = 1
                local ccStack = workspace.interface.getItem(itemType)
                table.insert(stacks, Stack.new(ccStack))
            end
        end
    end

    function Stack.new(ccStack)
        local self = setmetatable({}, Stack)
        self.ccStack = ccStack
        self.displayName = self.ccStack.displayName
        self.count = (1 + paddingPercent / 100) * self.ccStack.amount
        return self
    end

    function Stack:addToCellWithLargestUnusuedSpace()
        table.sort(cells, Cell.sortByUnusedBytesDesc)
        for _, cell in ipairs(cells) do
            if cell:hasSpaceFor(self) then
                cell:add(self)
                return
            end
        end
        for key, value in pairs(self) do
            print(key, value)
        end
        local newCell = Cell.getSmallestCellNeededForStack(self)
        newCell:add(self)
        table.insert(cells, newCell)
        table.insert(additionallyRequiredCells, newCell)
        error("No cell found to add stack to")
    end

    function Stack:exportAllToWorkspaceChest()
        local amountToExport = self.count
        print("  Exporting " .. amountToExport .. " " .. self.displayName .. "...")
        local amountExported = 0
        while amountExported < amountToExport do
            amountExported = amountExported + workspace.interface.exportItemToPeripheral(self.ccStack, chest)
            if unexpected_condition then
                error()
            end
        end
    end

    -- /Classes

    -- Main

    print("Scanning for cells...")
    --monitor.write("Scanning for cells...")
    Cell.loadAll()

    print("Moving cells to workspace...")
    --monitor.write("Moving cells to workspace...")
    local function moveDrivesFromSystemToWorkspace()
        for driveNum, systemDrive in ipairs(systemDrives) do
            local systemCells = systemDrive.list()
            for fromSlotNum, _ in pairs(systemCells) do
                systemDrive.pushItems(drives[driveNum], fromSlotNum)
            end
        end
    end

    moveDrivesFromSystemToWorkspace()

    print("Scanning for stacks...")
    --monitor.write("Scanning for stacks...")
    Stack.loadAll()

    print("Planning...")
    --monitor.write("Planning...")
    table.sort(stacks, Stack.sortByCountDesc)
    for _, stack in ipairs(stacks) do
        stack:addToCellWithLargestUnusuedSpace()
    end

    if #additionallyRequiredCells > 0 then
        print("Needed cells:")
        --monitor.write("Needed cells:")
        local requiredCellsByCapacity = groupBy(additionallyRequiredCells, 'capacity')
        for _, capacity in ipairs(Cell.capacities) do
            if requiredCellsByCapacity[capacity] ~= nil and #requiredCellsByCapacity[capacity] > 0 then
                print("  " .. #requiredCellsByCapacity[capacity] .. " " .. (capacity / 1024) .. "k cells")
                --monitor.write("  "..#requiredCellsByCapacity[capacity].." "..(capacity/1024).."k cells")
            end
        end
        error("Add the above cells to continue")
    end

    print("Executing plan...")
    --monitor.write("Executing plan...")
    table.sort(cells, Cell.sortByCapacity)

    for _, cell in ipairs(cells) do
        print("clearing and putting in workspace...")
        --monitor.write("clearing and putting in workspace...")
        cell:clearAndPutInWorkspaceChest()
        print("moving stacks to chest...")
        --monitor.write("moving stacks to chest...")
        for _, stack in ipairs(cell.inventory) do
            if pcall(stack.exportAllToWorkspaceChest, stack) then
                print(" ")
            else
                print("failed on stack:" .. stack.displayName .. "skipping")
            end
        end
        print("moving cell back to system...")
        --monitor.write("moving cell back to system...")
        cell:moveBackToSystem()
    end
    redstone.setOutput("bottom", false)
end

while true do
    local event, side, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    for _, m in pairs(message) do
        print(m)
        if m == "Defrag Now!" then
            print(m)
            main()
        end
    end
end
