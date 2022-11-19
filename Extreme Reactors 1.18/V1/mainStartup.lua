local event  = require("event")
local computer = require("computer")
local component = require("component")
local side = require("sides")
local colors = require("colors")
local core = component.draconic_rf_storage
local rs = component.redstone
 
function getEnergy()
    local amount = core.getEnergyStored()
    local capacity = core.getMaxEnergyStored()
    return math.floor((amount/capacity)*100)
end
 
function sleep(n)
    os.execute("sleep " .. tonumber(n))
end
 
while true do
    local energy = getEnergy()
    if energy < 50 then
        rs.setOutput(side.right,15)
    elseif energy > 50
        then rs.setOutput(side.right,0)
    end
    sleep(3)
    os.execute("startup")
end