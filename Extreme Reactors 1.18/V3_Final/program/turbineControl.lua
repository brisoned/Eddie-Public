    -- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program --
-- Version 1.0 --
-- Turbine control --

--Loads the touchpoint API
shell.run("cp /extreme-reactors-control/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")

--Loads the input API
shell.run("cp /extreme-reactors-control/config/input.lua /input")
os.loadAPI("input")
shell.run("rm input")

--Some variables
--Touchpoint init
local page = touchpoint.new(touchpointLocation)
--Buttons
local rOn
local rOff
local tOn
local tOff
local aTOn
local aTOff
local aTN = {"  -  ", label = "aTurbinesOn"}
local cOn
local cOff
--Last/Current turbine (for switching)
local lastStat = 0
local currStat = 0
--Last/Current TurbineSpeed (for checking)
local lastSpeed = {}
local currSpeed = {}
local speedFailCounter = {}

--Button renaming

rOn = {" ".._G.language:getText("wordOn").."  ", label = "reactorOn"}
rOff = {" ".._G.language:getText("wordOff").." ", label = "reactorOn"}
tOn = {" ".._G.language:getText("wordOn").."  ", label = "turbineOn"}
tOff = {" ".._G.language:getText("wordOff").." ", label = "turbineOn"}
aTOn = {" ".._G.language:getText("wordOn").." ", label = "aTurbinesOn"}
aTOff = {" ".._G.language:getText("wordOff").." ", label = "aTurbinesOn"}
cOn = {" ".._G.language:getText("wordOn").."  ", label = "coilsOn"}
cOff = {" ".._G.language:getText("wordOff").." ", label = "coilsOn"}

--Init auto mode
function startAutoMode()
    --Everything setup correctly?
    debugOutput("Check Peripherals")
    checkPeripherals()

    --Loads/Calculates the reactor's rod level

    if not skipControlRodCheck then
        debugOutput("Find Optimal Fuel Rod Level")
        findOptimalFuelRodLevel()
    end

    --Clear display
    term.clear()
    term.setCursorPos(1, 1)

    --Display prints
    debugOutput("Getting all Turbines to " .. turbineTargetSpeed .. " RPM...")

    --Gets turbine to target speed
    debugOutput("Init SpeedTables")
    initSpeedTable()
    while not allAtTargetSpeed() do
        debugOutput("GetToTargetSpeed")
        getToTargetSpeed()
        sleep(1)
        term.setCursorPos(1, 2)
        local badReactor = 0
        debugOutput("Looping Turbines")
        for i = 0, amountTurbines, 1 do
            if i == 0 then
                --restarted loop
                badReactor = 0
                controlMonitor.setBackgroundColor(backgroundColor)
                controlMonitor.setTextColor(textColor)
                controlMonitor.clear()
                controlMonitor.setCursorPos(1, 1)

                controlMonitor.write(
                    _G.language:getText("gettingTurbinesTo") .. (input.formatNumberComma(turbineTargetSpeed)) .. " RPM. ".._G.language:getText("pleaseWait")
                )
            end

            if turbines[i] == nil then
                debugOutput("Turbine " ..i.. " -> is NIL stuff is broken")
                debugOutput("Total Turbines = " ..amountTurbines)
            else
                printTurbineData(turbines[i])
            end

            local tSpeed = turbines[i]:rotorSpeed()

            print("Speed: " .. tSpeed .. "     ")

            if tSpeed > turbineTargetSpeed then
                --dont diplay
            else
                badReactor = badReactor + 1
                local columnMax = 24
                if _G.smallMonitor == 0 then
                    columnMax = 36
                end
                --formatting and printing status
                controlMonitor.setTextColor(textColor)
                controlMonitor.setCursorPos(1, (badReactor + 3))
                if badReactor < (columnMax*4) then
                    if badReactor >= (columnMax*3) then
                        controlMonitor.setCursorPos(54, (badReactor - (columnMax*3) + 3))
                    elseif badReactor >= (columnMax*2) then
                        controlMonitor.setCursorPos(36, (badReactor - (columnMax*2) + 3))
                    elseif badReactor >= columnMax then
                        controlMonitor.setCursorPos(18, (badReactor - columnMax + 3))
                    end

                    if (i + 1) < 10 then
                        controlMonitor.write(
                            "00" .. (i + 1) .. ": " .. (input.formatNumberComma(math.floor(tSpeed))) .. "RPM"
                        )
                    elseif (i + 1) < 100 then
                            controlMonitor.write(
                                "0" .. (i + 1) .. ": " .. (input.formatNumberComma(math.floor(tSpeed))) .. "RPM"
                            )
                    else
                        controlMonitor.write((i + 1) .. ": " .. (input.formatNumberComma(math.floor(tSpeed))) .. "RPM")
                    end
                end
            end
        end
    end

    --Enable reactor and turbines
    allReactorsOn()
    allTurbinesOn()
  --  print("before SpeedMaxin LINE 142")
    maintainSpeedMaxInAuto()

    --Reset terminal
    term.clear()
    term.setCursorPos(1, 1)

    --Reset Monitor
    controlMonitor.setBackgroundColor(backgroundColor)
    controlMonitor.clear()
    controlMonitor.setTextColor(textColor)
    controlMonitor.setCursorPos(1, 1)

    --Creates all buttons
    createAllButtons()

    --Displays first turbine (default)
    printStatsAuto(0)

    --run
    clickEvent()
end

--Init manual mode
function startManualMode()
    --Everything setup correctly?
    checkPeripherals()
    --Creates all buttons
    createAllButtons()
    --Creates additional manual buttons
    createManualButtons()

    --Sets all turbine flow rates to maximum (if set different in auto mode)
    for i = 0, #t do
        turbines[i]:setSteamIn(targetSteam)
    end

    --Displays the first turbine (default)
    printStatsMan(0)

    --run
    clickEvent()
end

--Checks if all required peripherals are attached
function checkPeripherals()
    controlMonitor.setBackgroundColor(colors.black)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1, 1)
    controlMonitor.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
    --No turbine found
    if turbines[0] == nil then
        controlMonitor.write(_G.language:getText("turbinesNotFound"))
        error(_G.language:getText("turbinesNotFound"))
    end
    --No reactor found
    if reactors[0] == "" then
        controlMonitor.write(_G.language:getText("reactorsNotFound"))
        error(_G.language:getText("reactorsNotFound"))
    end
    --No energy storage found
    if capacitors[0] == nil then   
        controlMonitor.write(_G.language:getText("capicitorsNotFound"))
        error(_G.language:getText("capicitorsNotFound"))
    end
end

function getEnergy()
    local energyStore = 0

    for i = 0, amountCapacitors, 1 do
        local stored = capacitors[i]:energy()
        if stored then 
        local stored = math.floor(capacitors[i]:energy())
        else
        local stored = 0
        end
        if energyStore then
        energyStore = energyStore + stored
         else
          energyStore = 0 + stored
      end  
     end

    return energyStore
end

function getEnergyMax()
    local energyStore = 0

    for i = 0, amountCapacitors, 1 do
        local maxStorage = math.floor(capacitors[i]:capacity())
        energyStore = energyStore + maxStorage
    end

    return energyStore
end

function getEnergyPer()
    local en = getEnergy()
    local enMax = getEnergyMax()
    -- print(en .. " of " .. enMax)
    local enPer = math.floor(en / enMax * 100)
    return enPer
end

--Returns the current energy fill status of a turbine
function getTurbineEnergy(turbine)
    return turbines[turbine]:energy()
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

--Set Reactor FuelRod Level
function setReactorFuelRodLevel(controlRodLevel)
    for i = 0, amountReactors, 1 do
        reactors[i]:setRodLevel(controlRodLevel)
    end
end

function avgCasingTemp()
    local tempData = 0

    for i = 0, amountReactors, 1 do
        tempData = tempData + reactors[i]:casingTemp()
    end

    tempData = tempData / (amountReactors + 1)

    return tempData
end

function avgCoreTemp()
    local tempData = 0

    for i = 0, amountReactors, 1 do
        tempData = tempData + reactors[i]:fuelTemp()
    end

    tempData = tempData / (amountReactors + 1)

    return tempData
end

function getSteamProduced()
    local tempData = 0

    for i = 0, amountReactors, 1 do
        tempData = tempData + reactors[i]:steamOutput()
    end

    return tempData
end

function getFuelUsed()
    local tempData = 0

    for i = 0, amountReactors, 1 do
        tempData = tempData + reactors[i]:fuelConsumption()
    end

    return tempData
end

--Toggles one turbine status and button
function toggleTurbine(i)
    print("func toggleTurbine called")
    turbines[i]:setOn(not turbines[i]:active())
    page:toggleButton("turbineOn")
    if turbines[i]:active() then
        page:rename("turbineOn", tOn, true)
    else
        page:rename("turbineOn", tOff, true)
    end
end

--Toggles one turbine coils and button
function toggleCoils(i)
    print("func ToggleCoils called")
    turbines[i]:setCoils(not turbines[i]:coilsEngaged())
    page:toggleButton("coilsOn")
    if turbines[i]:coilsEngaged() then
        page:rename("coilsOn", cOn, true)
    else
        page:rename("coilsOn", cOff, true)
    end
end

--Enable all turbines (Coils engaged, FluidRate 2000mb/t)
function allTurbinesOn()
    print("func allTurbinesOn called")
    for i = 0, amountTurbines, 1 do
        turbines[i]:setOn(true)
        turbines[i]:setCoils(true)
        turbines[i]:setSteamIn(targetSteam)
    end
end

--Disable all turbiens (Coils disengaged, FluidRate 0mb/t)
function allTurbinesOff()
    print("func allTurbinesoff")
    for i = 0, amountTurbines, 1 do
        turbines[i]:setCoils(false)
        turbines[i]:setSteamIn(0)
    end
end

--Enable one turbine
function turbineOn(i)
    print("func turbineOn called")
    turbines[i]:setCoils(true)
    turbines[i]:setSteamIn(targetSteam)
end

--Disable one turbine
function turbineOff(i)
    print("func turbineOff called")
    turbines[i]:setCoils(false)
    turbines[i]:setSteamIn(0)
end

--Toggles all turbines (and buttons)
function toggleAllTurbines()
    print("func toggleAllTurbines called")
    page:rename("aTurbinesOn", aTOff, true)
    local onOff
    if turbines[0].active() then
        onOff = "off"
    else
        onOff = "on"
    end
    for i = 0, amountTurbines do
        if onOff == "off" then
            turbines[i]:setOn(false)
            if page.buttonList["aTurbinesOn"].active then
                page:toggleButton("aTurbinesOn")
                page:rename("aTurbinesOn", aTOff, true)
            end
        else
            turbines[i]:setOn(true)
            if not page.buttonList["aTurbinesOn"].active then
                page:toggleButton("aTurbinesOn")
                page:rename("aTurbinesOn", aTOn, true)
            end --if
        end --else
    end --for
end

--function

--Toggles all turbine coils (and buttons)
function toggleAllCoils()
    print("toggleAllCoils called")
    local coilsOnOff
    if turbines[0].coilsEngaged() then
        coilsOnOff = "off"
    else
        coilsOnOff = "on"
    end
    for i = 0, amountTurbines do
        if coilsOnOff == "off" then
            turbines[i]:setCoils(false)
            if page.buttonList["Coils"].active then
                page:toggleButton("Coils")
            end
        else
            turbines[i]:setCoils(true)
            if not page.buttonList["Coils"].active then
                page:toggleButton("Coils")
            end
        end
    end
end

--Calculates/Reads the optiomal reactor rod level
function findOptimalFuelRodLevel()
    --Load config?
    if not (math.floor(rodLevel) == 0) then
        setReactorFuelRodLevel(rodLevel)
    else
        --Get reactor below 99c
        getTo99c()

        --Enable reactor + turbines
        allReactorsOn()
        allTurbinesOn()

        --Calculation variables
        local controlRodLevel = 99
        local diff = 0
        local targetSteamOutput = targetSteam * (amountTurbines + 1)
        local targetLevel = 99

        --Display
        controlMonitor.setBackgroundColor(backgroundColor)
        controlMonitor.setTextColor(textColor)
        controlMonitor.clear()

        print("TargetSteam: " .. targetSteamOutput)

        controlMonitor.setCursorPos(1, 1)
        controlMonitor.write(_G.language:getText("findingOptimalFuelRodLevel"))
        controlMonitor.setCursorPos(1, 3)
        controlMonitor.write(_G.language:getText("calculatingLevel"))
        controlMonitor.setCursorPos(1, 5)
        controlMonitor.write(
            _G.language:getText("targetSteamOutput") .. (input.formatNumberComma(math.floor(targetSteamOutput))) .. "mb/t"
        )

        --Calculate Level based on 2 values
        local failCounter = 0
        while true do
            setReactorFuelRodLevel(controlRodLevel)
            sleep(2)
            local steamOutput1 = getSteamProduced()
            print("SO1: " .. steamOutput1)
            setReactorFuelRodLevel(controlRodLevel - 1)
            sleep(5)
            local steamOutput2 = getSteamProduced()
            print("SO2: " .. steamOutput2)
            diff = steamOutput2 - steamOutput1
            print("Diff: " .. diff)

            targetLevel = 100 - math.floor(targetSteamOutput / diff)
            print("Target: " .. targetLevel)

            --Check target level
            if targetLevel < 0 or targetLevel == "-inf" then
                --Calculation failed 3 times?
                if failCounter > 2 then
                    controlMonitor.setBackgroundColor(colors.black)
                    controlMonitor.clear()
                    controlMonitor.setTextColor(colors.red)
                    controlMonitor.setCursorPos(1, 1)

                    controlMonitor.write(_G.language:getText("rodLevelFailed"))
                    controlMonitor.setCursorPos(1, 2)
                    controlMonitor.write(_G.language:getText("calculationLessThenZero"))
                    controlMonitor.setCursorPos(1, 3)
                    controlMonitor.write(_G.language:getText("pleaseCheckSteamWaterIO"))

                    --Disable reactor and turbines
                    allReactorsOff()
                print("line 530 all turbines off")
                    allTurbinesOff()
                    for i = 1, amountTurbines do
                        turbines[i]:setOn(false)
                    end

                    term.clear()
                    term.setCursorPos(1, 1)
                    print(_G.language:getText("targetRodLevel").. targetLevel)
                    error(_G.language:getText("rodLevelFailed"))
                else
                    failCounter = failCounter + 1
                    sleep(2)
                end

                print("FailCounter: " .. failCounter)
            else
                break
            end
        end

        --RodLevel calculation successful
        print("RodLevel calculation successful!")
        setReactorFuelRodLevel(targetLevel)
        controlRodLevel = targetLevel

        --Find precise level
        while true do
            if (controlRodLevel <= 0) then
                -- prevent controlRodLevel from going negative in case the reactor cannot produce enough steam to reach targetSteamOutput
                controlRodLevel = 0
                for i = 0, amountReactors, 1 do
                    reactors[i]:setControlRods(controlRodLevel)
                end
                rodLevel = controlRodLevel
                saveOptionFile()
                print(_G.language:getText("targetRodLevel").. controlRodLevel)
                sleep(2)
                break
            end
            sleep(5)
            local steamOutput = getSteamProduced()

            controlMonitor.setCursorPos(1, 3)
            controlMonitor.write(_G.language:getText("fuelRodLevel") .. controlRodLevel .. "  ")

            controlMonitor.setCursorPos(1, 6)
            controlMonitor.write(_G.language:getText("currentSteamOutput") .. (input.formatNumberComma(steamOutput)) .. "mb/t    ")

            --Level too big
            if steamOutput < targetSteamOutput then
                controlRodLevel = controlRodLevel - 1
                setReactorFuelRodLevel(controlRodLevel)
            else
                setReactorFuelRodLevel(controlRodLevel)
                rodLevel = controlRodLevel
                saveOptionFile()
                print("Target RodLevel: " .. controlRodLevel)
                sleep(2)
                break
            end --else
        end --while
    end --else
end

--function

--Gets the reactor below 99c
function getTo99c()
    controlMonitor.setBackgroundColor(backgroundColor)
    controlMonitor.setTextColor(textColor)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1, 1)

    controlMonitor.write(_G.language:getText("coolingReactor"))

    --Disables reactor and enables all turbines
    allReactorsOff()
    allTurbinesOn()

    --Temperature variables
    local fTemp = avgCoreTemp()
    local cTemp = avgCasingTemp()
    local isNotBelow = true

    --Wait until both values are below 99
    while isNotBelow do
        term.setCursorPos(1, 2)
        print(_G.language:getText("coreTemp") .. fTemp .. "      ")
        print(_G.language:getText("casingTemp") .. cTemp .. "      ")

        fTemp = avgCoreTemp()
        cTemp = avgCasingTemp()

        if fTemp < 99 then
            if cTemp < 99 then
                isNotBelow = false
            end
        end

        sleep(1)
    end --while
end

--function

--Checks the current energy level and controlls turbines/reactor
--based on user settings (reactorOn, reactorOff)
function checkEnergyLevel()
   -- print("in checkEnergylevel 620")
   printStatsAuto(currStat)
  --  print("after printStats Auto 623")
    --Level > user setting (default: 90%)
    if getEnergyPer() >= reactorOffAt then
        --Level < user setting (default: 50%)
     --   print("Energy >= reactorOffAt")
        if turbineOnOff == "on" then
            allTurbinesOn()
        elseif turbineOnOff == "off" then
            print("649 all turbine off")
            allTurbinesOff()
        end
        allReactorsOff()
    elseif getEnergyPer() <= reactorOnAt then
        allReactorsOn()
        for i = 0, amountTurbines do
            --turbines[i]:setSteamIn(targetSteam)
            --maintainSpeedMaxInAuto()
            if turbines[i]:rotorSpeed() < turbineTargetSpeed * 0.98 then
                turbines[i]:setCoils(false)
            end
            if turbines[i]:rotorSpeed() > turbineTargetSpeed * 1.02 then
                turbines[i]:setCoils(true)
            end
        end
    else
        if getReactorsActive() then
            for i = 0, amountTurbines do
                if turbines[i]:rotorSpeed() < turbineTargetSpeed * 0.98 then
                    turbines[i]:setCoils(false)
                end
                if turbines[i]:rotorSpeed() > turbineTargetSpeed * 1.02 then
                    turbines[i]:setCoils(true)
                end
            end --for
        end --if
    end --else
end

--Sets the tables for checking the current turbineSpeeds
function initSpeedTable()
    for i = 0, amountTurbines do
        lastSpeed[i] = 0
        currSpeed[i] = 0
        speedFailCounter[i] = 0
    end
end

--Gets turbines to targetSpeed
function getToTargetSpeed()
    for i = 0, amountTurbines, 1 do

        if turbines[i] == nil then
            debugOutput("Turbine " ..i.. " -> is NIL stuff is broken")
            debugOutput("Total Turbines = " ..amountTurbines)
        else
            printTurbineData(turbines[i])

            --Get the current speed of the turbine
            local tspeed = turbines[i]:rotorSpeed()

            --Control turbines
            if tspeed <= turbineTargetSpeed then
                allReactorsOn()
                turbines[i]:setOn(true)
                turbines[i]:setCoils(false)
                turbines[i]:setSteamIn(targetSteam)
            end
            if turbines[i]:rotorSpeed() > turbineTargetSpeed then
                turbineOff(i)
            end

            --Not working yet - Needs reworking
            --        --Write speed to the currSpeed table
            --        currSpeed[i] = tspeed
            --
            --        --Check turbine speed progression
            --        if currSpeed[i] < lastSpeed[i]-50 then
            --
            --            print(speedFailCounter)
            --
            --            --Return error message
            --            if speedFailCounter[i] >= 3 then
            --                controlMonitor.setBackgroundColor(colors.black)
            --                controlMonitor.clear()
            --                controlMonitor.setTextColor(colors.red)
            --                controlMonitor.setCursorPos(1, 1)
            --                    controlMonitor.write("Turbines can't get to speed!")
            --                    controlMonitor.setCursorPos(1,2)
            --                    controlMonitor.write("Please check your Steam-Input!")
            --                    error("Turbines can't get to speed!")
            --            --increase speedFailCounter
            --            else
            --                speedFailCounter[i] = speedFailCounter[i] + 1
            --            end
            --        end
            --
            --        --Write speed to the lastSpeed table
            --        lastSpeed[i] = tspeed
        end
    end
end

--Returns true if all turbines are at targetSpeed
function allAtTargetSpeed()
    for i = 0, amountTurbines do
        
        if turbines[i] == nil then
            debugOutput("Turbine " ..i.. " -> is NIL stuff is broken")
            debugOutput("Total Turbines = " ..amountTurbines)
        end

        if (turbines[i] ~= nil and turbines[i]:rotorSpeed() < turbineTargetSpeed) then
            return false
        end
    end
    return true
end

--Runs another program
function run(program)
    shell.run(program)
    shell.completeProgram("/extreme-reactors-control/program/turbineControl.lua")
    error("terminated.")
end

--Creates all required buttons
function createAllButtons()
    if _G.smallMonitor == 0 then
        local x1 = 30
        local x2 = 37
        local x3 = 44
        local x4 = 51
        local x5 = 58
        local x6 = 65
        local x7 = 72
        local y = 4

        --Turbine buttons
        for i = 0, amountTurbines, 1 do
            if i <= 18 then
                page:add(
                    "#" .. (i + 1),
                    function()
                        if overallMode == "manual" then
                            printStatsMan(i)
                        else
                            printStatsAuto(i)
                        end
                    end,
                    x1,
                    y,
                    x1 + 5,
                    y
                )
            elseif (i > 18 and i <= 37) then
                page:add(
                    "#" .. (i + 1),
                    function()
                        if overallMode == "manual" then
                            printStatsMan(i)
                        else
                            printStatsAuto(i)
                        end
                    end,
                    x2,
                    y,
                    x2 + 5,
                    y
                )
            elseif (i > 37 and i <= 56) then
                page:add(
                    "#" .. (i + 1),
                    function()
                        if overallMode == "manual" then
                            printStatsMan(i)
                        else
                            printStatsAuto(i)
                        end
                    end,
                    x3,
                    y,
                    x3 + 5,
                    y
                )
            elseif (i > 56 and i <= 75) then
                page:add(
                    "#" .. (i + 1),
                    function()
                        if overallMode == "manual" then
                            printStatsMan(i)
                        else
                            printStatsAuto(i)
                        end
                    end,
                    x4,
                    y,
                    x4 + 5,
                    y
                )
            elseif (i > 75 and i <= 94) then
                page:add(
                    "#" .. (i + 1),
                    function()
                        if overallMode == "manual" then
                            printStatsMan(i)
                        else
                            printStatsAuto(i)
                        end
                    end,
                    x5,
                    y,
                    x5 + 5,
                    y
                )
            elseif (i > 94 and i <= 113) then
                page:add(
                    "#" .. (i + 1),
                    function()
                        if overallMode == "manual" then
                            printStatsMan(i)
                        else
                            printStatsAuto(i)
                        end
                    end,
                    x6,
                    y,
                    x6 + 5,
                    y
                )
            elseif (i > 113 and i <= 132) then
                page:add(
                    "#" .. (i + 1),
                    function()
                        if overallMode == "manual" then
                            printStatsMan(i)
                        else
                            printStatsAuto(i)
                        end
                    end,
                    x7,
                    y,
                    x7 + 5,
                    y
                )
            end
            if (i == 18 or i == 37 or i == 56 or i == 75 or i == 94 or i == 113) then
                y = 4
            else
                y = y + 2
            end
        end --for

        --Other buttons
        page:add(
            _G.language:getText("wordMainMenu"),
            function()
                run("/extreme-reactors-control/start/menu.lua")
            end,
            2,
            37,
            17,
            37
        )
    else
        local x1 = 40
        local x2 = 47
        local x3 = 54
        local x4 = 61
        local y = 4
    
        --Turbine buttons
        for i = 0, amountTurbines, 1 do
            if overallMode == "auto" then
                if i <= 7 then
                    page:add("#" .. (i + 1), function() printStatsAuto(i) end, x1, y, x1 + 5, y)
                elseif (i > 7 and i <= 15) then
                    page:add("#" .. (i + 1), function() printStatsAuto(i) end, x2, y, x2 + 5, y)
                elseif (i > 15 and i <= 23) then
                    page:add("#" .. (i + 1), function() printStatsAuto(i) end, x3, y, x3 + 5, y)
                elseif i > 23 then
                    page:add("#" .. (i + 1), function() printStatsAuto(i) end, x4, y, x4 + 5, y)
                end
                if (i == 7 or i == 15 or i == 23) then y = 4
                else y = y + 2
                end
    
            elseif overallMode == "manual" then
                if i <= 7 then
                    page:add("#" .. (i + 1), function() printStatsMan(i) end, x1, y, x1 + 5, y)
                elseif (i > 7 and i <= 15) then
                    page:add("#" .. (i + 1), function() printStatsMan(i) end, x2, y, x2 + 5, y)
                elseif (i > 15 and i <= 23) then
                    page:add("#" .. (i + 1), function() printStatsMan(i) end, x3, y, x3 + 5, y)
                elseif i > 23 then
                    page:add("#" .. (i + 1), function() printStatsMan(i) end, x4, y, x4 + 5, y)
                end
                if (i == 7 or i == 15 or i == 23) then y = 4
                else y = y + 2
                end
            end --mode
        end --for
    
        --Other buttons
        page:add(_G.language:getText("wordMainMenu"), function() run("/extreme-reactors-control/start/menu.lua") end, 2, 23, 17, 23)
    end

    page:draw()
end

--Creates (additional) manual buttons
function createManualButtons()
    page:add("reactorOn", toggleReactor, 11, 11, 15, 11)
    page:add("Coils", toggleAllCoils, 25, 17, 31, 17)
    page:add("aTurbinesOn", toggleAllTurbines, 18, 17, 23, 17)
    page:rename("aTurbinesOn", aTN, true)

    --Switch reactor button?
    if getReactorsActive() then
        page:rename("reactorOn", rOn, true)
        page:toggleButton("reactorOn")
    else
        page:rename("reactorOn", rOff, true)
    end

    --Turbine buttons on/off
    page:add(
        "turbineOn",
        function()
            toggleTurbine(currStat)
        end,
        20,
        13,
        24,
        13
    )
    if turbines[currStat].active() then
        page:rename("turbineOn", tOn, true)
        page:toggleButton("turbineOn")
    else
        page:rename("turbineOn", tOff, true)
    end

    -- Turbinen buttons (Coils)
    page:add(
        "coilsOn",
        function()
            toggleCoils(currStat)
        end,
        9,
        15,
        13,
        15
    )
    if turbines[currStat].coilsEngaged() then
        page:rename("coilsOn", cOn, true)
    else
        page:rename("coilsOn", cOff, true)
    end
    page:draw()
end

--Checks for events (timer/clicks)
function clickEvent()
    while true do
        --refresh screen
        if overallMode == "auto" then
           -- print("in clickEvent")
            checkEnergyLevel()
           -- print("going into maintain speed func")
            maintainSpeedMaxInAuto()
        elseif overallMode == "manual" then
            printStatsMan(currStat)
        end

        --timer
        local timer1 = os.startTimer(1)

        while true do
            --gets the event
            local event, p1 = page:handleEvents(os.pullEvent())
            --print(event .. ", " .. p1)

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

function maintainSpeedMaxInAuto()
    for i = 0, amountTurbines, 1 do
        local lTurbine = turbines[i]
                if not currentRPMold then
                currentRPMold = 0
                else
                currentRPMold = math.floor(currentRPM)
                end 
                --currentRPMold = currentRPM
                currRPM = lTurbine:rotorSpeed()
                if not currRPM then
                currentRPM = 0
                else
                currentRPM = math.floor(currRPM)
                end
                --currentRPMold = currentRPM
                staticRPMsteam = 0
                staticcount = 0
       -- print("Get Turbine Speed" .. "old value:" .. currentRPMold .. "new value:" .. currentRPM)
        if currentRPMold == currentRPM and staticcount <2 and staticRPMsteam == 0 then 
       -- print("Potential Static Value Found")
        staticcount = staticcount + 1
        elseif currentRPMold == currentRPM and staticcount >=2 and staticRPMSteam == 0 then
       -- print("Setting Static Steam Value!")
        staticRPMsteam = lTurbine:steamIn()
        end
        if currentRPM < _G.turbineTargetSpeed+20 and currentRPM > _G.turbineTargetSpeed-20 then
           -- do nothing
            -- speed iso good
            if staticRPMsteam ~= 0 then
                print("Turbine within bounds setting static value")
                lTurbine:setSteamIn(staticRPMsteam)
            end
        elseif currentRPM < _G.turbineTargetSpeed+20 then
            local newSteamAmount = lTurbine:steamIn() + lTurbine:decrementAmount()
            lTurbine:setSteamIn(newSteamAmount)
         else
             --while currentRPM > _G.turbineTargetSpeed do
                local newSteamAmount = lTurbine:steamIn() - lTurbine:decrementAmount()
             --   print("Steam Amount" .. newSteamAmount)
                if(newSteamAmount >= 0) then
    
                    lTurbine:setSteamIn(newSteamAmount)
                else
                    --cant go any lower will be lower then 0 and cant have that
                    break
                end
            --end
        end
    end
end

--displays all info on the screen (auto mode)
function printStatsAuto(turbine)
    --refresh current turbine
   -- print("in printStatsAuto 1038")
    currStat = turbine

    --toggles turbine buttons if pressed (old button off, new button on)
    if not page.buttonList["#" .. currStat + 1].active then
        page:toggleButton("#" .. currStat + 1)
    end
    if currStat ~= lastStat then
        if page.buttonList["#" .. lastStat + 1].active then
            page:toggleButton("#" .. lastStat + 1)
        end
    end

    local data = getReactorInfo();
    emitMessage(data)

    --prints the energy level (in %)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))
    controlMonitor.setTextColor(tonumber(textColor))

    controlMonitor.setCursorPos(2, 2)

    controlMonitor.write(_G.language:getText("wordEnergy")..": " .. getEnergyPer() .. "%  ")

    --prints the energy bar
    local part1 = getEnergyPer() / 5
    controlMonitor.setCursorPos(2, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 3)
    for i = 1, part1 do
        controlMonitor.write(" ")
    end
    controlMonitor.setTextColor(textColor)

    --prints the overall energy production
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    controlMonitor.setCursorPos(2, 5)

    controlMonitor.write(_G.language:getText("rfProduction") .. (input.formatNumberComma(data.rfProduced)) .. " KRF/t      ")

    --Reactor status (on/off)
    controlMonitor.setCursorPos(2, 7)

    if (amountReactors > 0) then        
        controlMonitor.write((amountReactors + 1) .. " ".._G.language:getText("wordReactors")..": ")
    else
        controlMonitor.write("1 ".._G.language:getText("wordReactor")..": ")
    end    
    
    if getReactorsActive() then
        controlMonitor.setTextColor(colors.green)
        controlMonitor.write("on ")
    else
        controlMonitor.setTextColor(colors.red)
        controlMonitor.write("off")
    end

    --Prints all other informations (fuel consumption,steam,turbine amount,mode)
    controlMonitor.setTextColor(tonumber(textColor))
    controlMonitor.setCursorPos(2, 9)

    controlMonitor.write(_G.language:getText("fuelConsumption") .. data.fuelConsumed .. "mb/t     ")
    controlMonitor.setCursorPos(2, 10)
    controlMonitor.write(_G.language:getText("wordSteam")..": " .. (input.formatNumberComma(data.steam)) .. "B/t    ")
    controlMonitor.setCursorPos(2, 11)
    controlMonitor.write(_G.language:getText("wordEfficiency")..": " .. (input.formatNumberComma(data.efficiency)) .. " KRF/mb       ")
    controlMonitor.setCursorPos(30, 2)
    controlMonitor.write(_G.language:getText("wordTurbines")..": " .. (amountTurbines + 1) .. "  ")
    controlMonitor.setCursorPos(2, 13)
    controlMonitor.write("-- ".._G.language:getText("wordTurbine").." " .. (turbine + 1) .. " --")

    --Currently selected turbine details

    --coils
    controlMonitor.setCursorPos(2, 14)
    controlMonitor.write(_G.language:getText("wordCoils")..": ")

    if turbines[turbine]:coilsEngaged() then
        controlMonitor.setTextColor(colors.green)
        controlMonitor.write(_G.language:getText("wordEngaged").."     ")
    end
    if turbines[turbine]:coilsEngaged() == false then
        controlMonitor.setTextColor(colors.red)
        controlMonitor.write(_G.language:getText("wordDisengaged"))
    end
    controlMonitor.setTextColor(tonumber(textColor))

    --rotor speed/RF-production
    controlMonitor.setCursorPos(2, 15)

    controlMonitor.write(_G.language:getText("turbineSpeed")..": ")
    controlMonitor.write((input.formatNumberComma(math.floor(turbines[turbine]:rotorSpeed()))) .. " RPM    ")
    controlMonitor.setCursorPos(2, 16)
    tmpeng = turbines[turbine]:energyProduction()
    if tmpeng == nil then
        tmpeng = 0
    end
    controlMonitor.write(
        _G.language:getText("rfProduction")..
        
            (input.formatNumberComma(math.floor(tmpeng/1000))) .. " KRF/t           "
    )

    --Internal buffer of the turbine
    controlMonitor.setCursorPos(2, 17)

    controlMonitor.write(_G.language:getText("internalEnergy"))
    controlMonitor.write(input.formatNumberComma(math.floor(getTurbineEnergy(turbine))) .. " RF          ")

    --prints the current program version
    controlMonitor.setCursorPos(2, 39)
    controlMonitor.write(_G.language:getText("wordVersion").." " .. version)

    --refreshes the last turbine id
    lastStat = turbine
end

function emitStartUpMessage(message) 
    _G.newMessage("startUp", _G.newStartUpMessage(message), _G.location)
end

function emitMessage(data)
    if _G.enableWireless then
        local transmitMessage = _G.newMessage("rtMessage", data, _G.location)
        _G.wirelessModem.transmit(_G.modemChannel,_G.modemChannel+1,transmitMessage)
    end    
end

function getReactorInfo() 
    local reactorInfo = _G.newReactorTurbineMessage(amountTurbines)

    local rfGen = 0

    for i = 0, amountTurbines, 1 do
        rfGen = rfGen + turbines[i]:energyProduction()
        
        if turbines[i]:coilsEngaged() then
            reactorInfo.turbines[i].engaged = _G.language:getText("wordEngaged")
        end
        if turbines[i]:coilsEngaged() == false then            
            reactorInfo.turbines[i].engaged = _G.language:getText("wordDisengaged")
        end

        reactorInfo.turbines[i].turbineSpeed = math.floor(turbines[i]:rotorSpeed())
        reactorInfo.turbines[i].rfProduction = math.floor(turbines[i]:energyProduction()/1000)
        reactorInfo.turbines[i].turbineEnergy = math.floor(getTurbineEnergy(i))
    end
    
    reactorInfo.turbineData = textutils.serialise(reactorInfo.turbines)
    reactorInfo.energyStored = math.floor(getEnergy())
    reactorInfo.energyMax = math.floor(getEnergyMax())
    reactorInfo.reactorCount = (amountReactors + 1)
    reactorInfo.active = getReactorsActive()
    reactorInfo.steam = math.floor(getSteamProduced()/1000)

    local fuelCons = tostring(getFuelUsed())
    local fuelCons2 = string.sub(fuelCons, 0, 4)
    reactorInfo.fuelConsumed = fuelCons2;
    if not rfGen or not getFuelUsed then eff = 0 else eff = math.floor(rfGen / getFuelUsed()) end
        
    --local eff = math.floor(rfGen / getFuelUsed())
    reactorInfo.efficiency = math.floor(eff/1000)
    reactorInfo.rfProduced = rfGen;

    reactorInfo.casing = 0
    reactorInfo.core = 0
    reactorInfo.rodLevel = 0

    return reactorInfo
end

--printStats (manual)
function printStatsMan(turbine)
    --refresh current turbine
    currStat = turbine

    --toggles turbine buttons if pressed (old button off, new button on)
    if not page.buttonList["#" .. currStat + 1].active then
        page:toggleButton("#" .. currStat + 1)
    end
    if currStat ~= lastStat then
        if page.buttonList["#" .. lastStat + 1].active then
            page:toggleButton("#" .. lastStat + 1)
        end
    end

    --On/Off buttons
    if turbines[currStat].active() and not page.buttonList["turbineOn"].active then
        page:rename("turbineOn", tOn, true)
        page:toggleButton("turbineOn")
    end
    if not turbines[currStat].active() and page.buttonList["turbineOn"].active then
        page:rename("turbineOn", tOff, true)
        page:toggleButton("turbineOn")
    end
    if turbines[currStat].coilsEngaged() and not page.buttonList["coilsOn"].active then
        page:rename("coilsOn", cOn, true)
        page:toggleButton("coilsOn")
    end
    if not turbines[currStat].coilsEngaged() and page.buttonList["coilsOn"].active then
        page:rename("coilsOn", cOff, true)
        page:toggleButton("coilsOn")
    end

    --prints the energy level (in %)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))
    controlMonitor.setTextColor(tonumber(textColor))

    controlMonitor.setCursorPos(2, 2)

    controlMonitor.write(_G.language:getText("wordEnergy")..": " .. getEnergyPer() .. "%  ")

    --prints the energy bar
    local part1 = getEnergyPer() / 5
    controlMonitor.setCursorPos(2, 3)
    controlMonitor.setBackgroundColor(colors.lightGray)
    controlMonitor.write("                    ")
    controlMonitor.setBackgroundColor(colors.green)
    controlMonitor.setCursorPos(2, 3)
    for i = 1, part1 do
        controlMonitor.write(" ")
    end
    controlMonitor.setTextColor(textColor)

    --prints the overall energy production
    local rfGen = 0
    for i = 0, amountTurbines, 1 do
        rfGen = rfGen + turbines[i]:energyProduction()
    end

    controlMonitor.setBackgroundColor(tonumber(backgroundColor))

    --Other status informations
    controlMonitor.setCursorPos(2, 5)
    controlMonitor.write(_G.language:getText("rfProduction") .. (input.formatNumberComma(math.floor(rfGen/1000))) .. " KRF/t      ")
    controlMonitor.setCursorPos(2, 7)
    local fuelCons = tostring(getFuelUsed())
    local fuelCons2 = string.sub(fuelCons, 0, 4)
    controlMonitor.write(_G.language:getText("fuelConsumption") .. fuelCons2 .. "mb/t     ")
    controlMonitor.setCursorPos(2, 9)
    controlMonitor.write(_G.language:getText("turbineSpeed")..": ")
    controlMonitor.write((input.formatNumberComma(math.floor(turbines[turbine]:rotorSpeed()))) .. " RPM     ")
    controlMonitor.setCursorPos(2, 11)
    controlMonitor.write(_G.language:getText("wordReactor")..": ")
    controlMonitor.setCursorPos(2, 13)
    controlMonitor.write(_G.language:getText("currentTurbine"))
    controlMonitor.setCursorPos(2, 17)
    controlMonitor.write(_G.language:getText("allTurbines"))

    controlMonitor.setCursorPos(2, 15)
    controlMonitor.write(_G.language:getText("wordCoils")..": ")

    controlMonitor.setCursorPos(30, 2)
    controlMonitor.write(_G.language:getText("wordTurbines")..": " .. (amountTurbines + 1) .. "  ")

    --prints the current program version
    controlMonitor.setCursorPos(2, 39)
    controlMonitor.write(_G.language:getText("wordVersion").." " .. version)

    --refreshes the last turbine id
    lastStat = turbine
end

--program start
if overallMode == "auto" then
    startAutoMode()
elseif overallMode == "manual" then
    startManualMode()
end