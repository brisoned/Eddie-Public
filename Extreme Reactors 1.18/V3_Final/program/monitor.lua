-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program --
-- Version 1.0 --
-- Remote Monitor --

shell.run("cp /extreme-reactors-control/config/input.lua /input")
os.loadAPI("input")
shell.run("rm input")

--Checks if all required peripherals are attached
function checkPeripherals()
    controlMonitor.setBackgroundColor(colors.black)
    controlMonitor.clear()
    controlMonitor.setCursorPos(1, 1)
    controlMonitor.setTextColor(colors.red)
    term.clear()
    term.setCursorPos(1, 1)
    term.setTextColor(colors.red)
end

function getEnergyPer(data)
    local en = data.energyStored
    local enMax = data.energyMax
    print(en .. " of " .. enMax)
    local enPer = math.floor(en / enMax * 100)
    return enPer
end

function printStatsReactorTurbine(data)
    --prints the energy level (in %)
    controlMonitor.setBackgroundColor(tonumber(backgroundColor))
    controlMonitor.setTextColor(tonumber(textColor))

    controlMonitor.setCursorPos(2, 2)

    controlMonitor.write(_G.language:getText("wordEnergy")..": " .. getEnergyPer(data) .. "%  ")

    --prints the energy bar
    local part1 = getEnergyPer(data) / 5
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

    if data.reactorCount > 0 then        
        controlMonitor.write(data.reactorCount .. " ".._G.language:getText("wordReactors")..": ")
    else
        controlMonitor.write("1 ".._G.language:getText("wordReactor")..": ")
    end    
    
    if data.active then
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
    controlMonitor.setCursorPos(24, 2)
    controlMonitor.write(_G.language:getText("wordTurbines")..": " .. #turbines .. "  ")
end

function start()
    
    if _G.wirelessModem == nil then              
        controlMonitor.write(_G.language:getText("noModemFound"))
        -- exit we don't have a modem
        return
    end   

    --Reset terminal
    term.clear()
    term.setCursorPos(1, 1)

    --Reset Monitor
    controlMonitor.setBackgroundColor(backgroundColor)
    controlMonitor.clear()
    controlMonitor.setTextColor(textColor)
    controlMonitor.setCursorPos(1, 1)


    --Check for click events
    while true do
        --gets the event     
        if not _G.wirelessModem.isOpen(_G.modemChannel) then
            _G.wirelessModem.open(_G.modemChannel)
        end 

        local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
        local responseObject = textutils.unserialise(message)

        if responseObject.location == _G.location then            
            if responseObject.type == "rtMessage" then
                printStatsReactorTurbine(responseObject.data)
            end
        end
    end
end

start()
