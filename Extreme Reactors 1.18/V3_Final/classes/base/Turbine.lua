-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local Turbine = {
    name = "",
    id = {},
    side = "",
    type = "",

    active = function(self)
        return self.id.getActive()
    end,
    coilsEngaged = function(self)
        return self.id.getInductorEngaged()
    end,
    rotorSpeed = function(self)
        return self.id.getRotorSpeed()
    end,
    energy = function(self)
        return self.id.getEnergyStored()
    end,
    energyProduction = function(self)
        return self.id.getEnergyProducedLastTick()
    end,
    steamIn = function(self)
        return self.id.getFluidFlowRate()
    end,

    setOn = function(self, status)
        self.id.setActive(status)
    end,
    setCoils = function(self, status)
        self.id.setInductorEngaged(status)
    end,
    setSteamIn = function(self, amount)
        self.id.setFluidFlowRateMax(amount)
    end,
    maxInputSteam = 2000,
    decrementAmount = function(self)
        return 50
    end
}

function _G.newTurbine(name,id, side, type)
    debugOutput("Creating new Base Turbine")
    local turbine = {}
    setmetatable(turbine,{__index = Turbine})
    
    if id == nil then
        debugOutput("MISSING wrapped peripheral object. This is going to break!")
    end

    debugOutput("Settings Name -> ".. name)
    turbine.name = name
    turbine.id = id
    debugOutput("Settings Side -> ".. side)
    turbine.side = side
    debugOutput("Settings Type -> ".. type)
    turbine.type = type

    return turbine
end

function _G.printTurbineData(turbine)
    debugOutput("Name: "..turbine.name)
    debugOutput("ID: "..tostring(turbine.id))
    debugOutput("Type: "..turbine.type)
end






