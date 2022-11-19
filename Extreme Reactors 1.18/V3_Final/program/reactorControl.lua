-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Reactor control --

--Loads the touchpoint and input APIs
shell.run("cp /extreme-reactors-control/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")

shell.run("cp /extreme-reactors-control/config/input.lua /input")
os.loadAPI("input")
shell.run("rm input")

--Some variables
local page = touchpoint.new(touchpointLocation)
local rodLevel
local enPer
local fuel
local fuelPer
local rfGen
local fuelCons
local isOn
local enPerR
local rOn
local rOff
local internalBuffer

--Create the buttons
function createButtons()
    page:add("Main Menu", function() run("/extreme-reactors-control/start/menu.lua") end, 2, 22, 17, 22)

    --Control Rods Buttons
    page:add("-1", function() setControlRods("-", 1) end, 45, 5, 48, 5)
    page:add("-10", function() setControlRods("-", 10) end, 39, 5, 43, 5)
    page:add("-100", function() setControlRods("-", 100) end, 32, 5, 37, 5)
    page:add("+1", function() setControlRods("+", 1) end, 45, 7, 48, 7)
    page:add("+10", function() setControlRods("+", 10) end, 39, 7, 43, 7)
    page:add("+100", function() setControlRods("+", 100) end, 32, 7, 37, 7)

    page:draw()
end

--Create additional manual buttons
function createButtonsMan()
    createButtons()

    --Reactor Toggle Button
    rOn = { " On ", label = "reactorOn" }
    rOff = { " Off ", label = "reactorOn" }

    page:add("reactorOn", toggleReactor, 11, 10, 15, 10)

    if getReactorsActive() then
        page:rename("reactorOn", rOn, true)
        page:toggleButton("reactorOn")
    else
        page:rename("reactorOn", rOff, true)
    end

    --Print buttons
    page:draw()
end

--Checks, if all peripherals were setup correctly
function checkPeripherals()
    controlMonitor.setBackgroundColor(colors.black)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1, 1)
    controlMonitor.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    if r == "" then
        controlMonitor.write(_G.language:getText("reactorsNotFound"))
        error(_G.language:getText("reactorsNotFound"))
    end
    if v == "" then
        v = r
        internalBuffer = true
    else
        internalBuffer = false
    end
end

--Toggles the reactor status and the button
function toggleReactor()
    if getReactorsActive() then
        allReactorsOff()
    else
        allReactorsOn()
    end

    page:toggleButton("reactorOn")
    if getReactorsActive() then
        page:rename("reactorOn", rOn, true)
    else
        page:rename("reactorOn", rOff, true)
    end
end

function getReactorsActive()
    local reactorStatus = false

    for i = 0, amountReactors, 1 do
        if reactors[i]:active() then
            reactorStatus = true
        else
            reactorStatus = false
        end
    end

    return reactorStatus
end

--Enable all reactors
function allReactorsOn()
    for i = 0, amountReactors, 1 do
        reactors[i]:setOn(true)
    end
end

--Disable all reactor
function allReactorsOff()
    for i = 0, amountReactors, 1 do
        reactors[i]:setOn(false)
    end
end

--Adjusts the control rods
function setControlRods(operation, value)
    local targetValue = reactors[0]:controlRodLevel(0)
    if operation == "-" then
        targetValue = targetValue - value
        if targetValue < 1 then targetValue = 0 end
    elseif operation == "+" then
        targetValue = targetValue + value
        if targetValue > 98 then targetValue = 99 end
    end

    -- loop reactors and set control rod levels
    for i = 0, amountReactors, 1 do
        reactors[i]:setRodLevel(targetValue)
    end
end

function getEnergy()
    local energyStore = 0

    for i = 0, amountCapacitors, 1 do
        local stored = math.floor(capacitors[i]:energy())
        energyStore = energyStore + stored
    end

    return energyStore
end

function getEnergyMax()
    local energyStore = 0

    for i = 0, amountCapacitors, 1 do
        if (capacitors[i] == nil) then            
        else
            local maxStorage = math.floor(capacitors[i]:capacity())
            energyStore = energyStore + maxStorage
        end
    end

    return energyStore
end

function getEnergyPer()
    local en = getEnergy()
    local enMax = getEnergyMax()
    print(en .. " of " .. enMax)
    local enPer = math.floor(en / enMax * 100)
    return enPer
end

--Returns the current energy level (reactor)
function getEnergyR()
    local en = 0

    for i = 0, amountReactors, 1 do
        en = en + reactors[i]:energy()
    end

    local enMax = 10000000 * (amountReactors + 1)
    return math.floor(en / enMax * 100)
end


function getFuelAmount()
    local en = 0

    for i = 0, amountReactors, 1 do
        en = en + reactors[i]:fuel()
    end

    return en
end

function getFuelAmountMax()
    local en = 0

    for i = 0, amountReactors, 1 do
        en = en + reactors[i]:maxFuel()
    end

    return en
end

function getEnergyProducedLastTick()
    local en = 0

    for i = 0, amountReactors, 1 do
        en = en + reactors[i]:energyProduction()
    end

    return en
end
function getFuelConsumedLastTick()
    local en = 0

    for i = 0, amountReactors, 1 do
        en = en + reactors[i]:fuelConsumption()
    end

    return en
end
--Reads all the reactors data
function getReactorData()
    rodLevel = reactors[0]:controlRodLevel(0)
    enPer = getEnergyPer()
    enPerR = getEnergyR()
    fuel = getFuelAmount()
    local fuelMax = getFuelAmountMax()
    fuelPer = math.floor(fuel / fuelMax * 100)
    rfGen = getEnergyProducedLastTick()
    fuelCons = getFuelConsumedLastTick()
    isOn = reactors[0]:active()
end

--Checks for button clicks
function getClick()

    while true do

        --Refresh Data
        getReactorData()

        --refresh screen
        if overallMode == "auto" then
            displayDataAuto()
        elseif overallMode == "manual" then
            displayDataMan()
        end

        --timer
        local timer1 = os.startTimer(1)

        while true do
            --gets the event
            local event, p1 = page:handleEvents(os.pullEvent())
            print(event .. ", " .. p1)

            --execute a buttons function if clicked
            if event == "button_click" then
                page:flash(p1)
                page.buttonList[p1].func()
                break
            elseif event == "timer" and p1 == timer1 then
                break
            end
        end
    end
end

--Displays the data on the screen (auto mode)
function displayDataAuto()
    if enPer <= reactorOnAt then
        allReactorsOn()
    elseif enPer > reactorOffAt then
        allReactorsOff()
    end

    --Print all buttons
    page:draw()

    controlMonitor.setBackgroundColor(tonumber(backgroundColor))
    controlMonitor.setTextColor(tonumber(textColor))

    --Print the energy bar
    controlMonitor.setCursorPos(2, 2)

    controlMonitor.write(_G.language:getText("wordEnergy")..": " .. enPer .. "%  ")

    controlMonitor.setCursorPos(2, 3)
    local part1 = enPer / 5
    controlMonitor.setCursorPos(2, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 3)
    for i = 1, part1 do
        controlMonitor.write(" ")
    end

    controlMonitor.setTextColor(textColor)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    --Print the reactor energy bar
    controlMonitor.setCursorPos(2, 5)
    controlMonitor.write(_G.language:getText("wordEnergy").." (".._G.language:getText("wordReactor").."): " .. enPerR .. "%  ")

    controlMonitor.setCursorPos(2, 6)
    local part2 = enPerR / 5
    controlMonitor.setCursorPos(2, 6)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 6)
    for i = 1, part2 do
        controlMonitor.write(" ")
    end

    controlMonitor.setTextColor(textColor)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    --Print the RodLevel bar
    controlMonitor.setCursorPos(30, 2)
    controlMonitor.write(_G.language:getText("fuelRodLevel").. rodLevel .. "  ")
    controlMonitor.setCursorPos(30, 3)

    local part3 = rodLevel / 5
    controlMonitor.setCursorPos(30, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(30, 3)
    for i = 1, part3 do
        controlMonitor.write(" ")
    end

    controlMonitor.setTextColor(textColor)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    controlMonitor.setCursorPos(2, 8)
    
    controlMonitor.write(_G.language:getText("rfProduction") .. input.formatNumberComma(math.floor(rfGen)) .. " RF/t      ")

    controlMonitor.setCursorPos(2, 10)
    if (amountReactors > 0) then        
        controlMonitor.write((amountReactors + 1) .. " ".._G.language:getText("wordReactors")..": ")
    else
        controlMonitor.write("1 ".._G.language:getText("wordReactor")..": ")
    end  

    if getReactorsActive() then
        controlMonitor.setTextColor(colors.green)
        controlMonitor.write("on ")
    end
    if not getReactorsActive() then
        controlMonitor.setTextColor(colors.red)
        controlMonitor.write("off")
    end

    controlMonitor.setTextColor(tonumber(textColor))

    --Display Fuel Consumption
    controlMonitor.setCursorPos(2, 12)
    local fuelCons2 = string.sub(fuelCons, 0, 4)

    controlMonitor.write(_G.language:getText("fuelConsumption") ..  fuelCons2 .. "mb/t     ")

    --Display Reactor Efficiency (RF/mb)
    controlMonitor.setCursorPos(2, 14)

    --Calculation and formatting of the efficiency
    local fuelEfficiency = rfGen / fuelCons
    if tonumber(fuelCons) == 0 then fuelEfficiency = 0 end
    local fuelEfficiency2 = math.floor(fuelEfficiency)

    controlMonitor.write(_G.language:getText("wordEfficiency")..": " .. input.formatNumberComma(fuelEfficiency2) .. " RF/mb    ")

    --Display the current Casing/Core Temperature
    local caT = tostring(reactors[0]:casingTemp())
    local caseTemp = string.sub(caT, 0, 6)
    local coT = tostring(reactors[0]:fuelTemp())
    local coreTemp = string.sub(coT, 0, 6)

    controlMonitor.setCursorPos(2, 16)

    controlMonitor.write(_G.language:getText("casingTemp") .. caseTemp .. "C    ")
    controlMonitor.setCursorPos(2, 17)
    controlMonitor.write(_G.language:getText("coreTemp") .. coreTemp .. "C    ")

    controlMonitor.setCursorPos(2, 25)
    controlMonitor.write(_G.language:getText("wordVersion").." " .. version)
end

--Displays the data on the screen (manual mode)
function displayDataMan()

    if getReactorsActive() then
        if not page.buttonList["reactorOn"].active then
            page:toggleButton("reactorOn")
            page:rename("reactorOn", rOn, true)
        end
    else
        if page.buttonList["reactorOn"].active then
            page:toggleButton("reactorOn")
            page:rename("reactorOn", rOff, true)
        end
    end

    page:draw()

    controlMonitor.setBackgroundColor(tonumber(backgroundColor))
    controlMonitor.setTextColor(tonumber(textColor))

    --Print the energy bar
    controlMonitor.setCursorPos(2, 2)

    controlMonitor.write(_G.language:getText("wordEnergy")..": " .. enPer .. "%  ")

    controlMonitor.setCursorPos(2, 3)
    local part1 = enPer / 5
    controlMonitor.setCursorPos(2, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 3)
    for i = 1, part1 do
        controlMonitor.write(" ")
    end

    controlMonitor.setTextColor(textColor)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    --Print the reactor energy bar
    controlMonitor.setCursorPos(2, 5)
    
    controlMonitor.write(_G.language:getText("wordEnergy").." (".._G.language:getText("wordReactor").."): " .. enPerR .. "%  ")

    controlMonitor.setCursorPos(2, 6)
    local part2 = enPerR / 5
    controlMonitor.setCursorPos(2, 6)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 6)
    for i = 1, part2 do
        controlMonitor.write(" ")
    end

    controlMonitor.setTextColor(textColor)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    --Print the RodLevel bar
    controlMonitor.setCursorPos(30, 2)
    controlMonitor.write(_G.language:getText("fuelRodLevel") .. rodLevel .. "  ")
    controlMonitor.setCursorPos(30, 3)

    local part3 = rodLevel / 5
    controlMonitor.setCursorPos(30, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(30, 3)
    for i = 1, part3 do
        controlMonitor.write(" ")
    end

    controlMonitor.setTextColor(textColor)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    --Print the current RF Production of the reactor
    controlMonitor.setCursorPos(2, 8)
    
    controlMonitor.write(_G.language:getText("rfProduction").. input.formatNumberComma(math.floor(rfGen)) .. " RF/t      ")

    --Print the current status of the reactor
    controlMonitor.setCursorPos(2, 10)

    controlMonitor.write(_G.language:getText("wordReactor")..": ")        

    controlMonitor.setTextColor(tonumber(textColor))

    --Display Fuel Consumption
    controlMonitor.setCursorPos(2, 12)
    local fuelCons2 = string.sub(tostring(fuelCons), 0, 4)

    controlMonitor.write(_G.language:getText("fuelConsumption") .. fuelCons2 .. "mb/t     ")

    --Display Reactor Efficiency (RF/mb)
    controlMonitor.setCursorPos(2, 14)

    --Calculation and formatting of the efficiency
    local fuelEfficiency = rfGen / fuelCons
    if tonumber(fuelCons) == 0 then fuelEfficiency = 0 end
    local fuelEfficiency2 = math.floor(fuelEfficiency)

    controlMonitor.write(_G.language:getText("wordEfficiency") .. ": " .. input.formatNumberComma(fuelEfficiency2) .. " RF/mb    ")

    --Display the current Casing/Core temperature of the reactor
    local caT = tostring(reactors[0]:casingTemp())
    local caseTemp = string.sub(caT, 0, 6)
    local coT = tostring(reactors[0]:fuelTemp())
    local coreTemp = string.sub(coT, 0, 6)

    controlMonitor.setCursorPos(2, 16)

    controlMonitor.write(_G.language:getText("casingTemp") .. caseTemp .. "C    ")
    controlMonitor.setCursorPos(2, 17)
    controlMonitor.write(_G.language:getText("coreTemp") .. coreTemp .. "C    ")

    --Print the current version
    controlMonitor.setCursorPos(2, 25)
    controlMonitor.write(_G.language:getText("wordVersion").." " .. version)
end

function emitStartUpMessage(message) 
    _G.newMessage("startUp", _G.newStartUpMessage(message), _G.location)
end

function emitMessage(data)
    _G.newMessage("reactorMessage", data, _G.location)
end

--Runs another program
function run(program)
    shell.run(program)
    error("terminated.")
end

--Run
checkPeripherals()
if overallMode == "auto" then
    createButtons()
elseif overallMode == "manual" then
    createButtonsMan()
end
controlMonitor.setBackgroundColor(tonumber(backgroundColor))
controlMonitor.setTextColor(tonumber(textColor))
controlMonitor.clear()
getClick()
