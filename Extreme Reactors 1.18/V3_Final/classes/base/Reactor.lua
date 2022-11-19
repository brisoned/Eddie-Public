-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local Reactor = {
    name = "",
    id = {},
    side = "",
    type = "",

    active = function(self)
        return self.id.getActive()
    end,
    controlRodLevel = function(self)
        return self.id.getControlRodLevel(0)
    end,
    controlRodCount = function(self)
        return self.id.getNumberOfControlRods()
    end,
    energy = function(self)
        return self.id.getEnergyStored()
    end,
    fuelTemp = function(self)
        return self.id.getFuelTemperature()
    end,
    casingTemp = function(self)
        return self.id.getCasingTemperature()
    end,
    fuel = function(self)
        return self.id.getFuelAmount()
    end,
    maxFuel = function(self)
        return self.id.getFuelAmountMax()
    end,
    fuelPer = function(self)
        return math.floor(self:fuel()/self:maxFuel()*100)
    end,
    waste = function(self)
        return self.id.getWasteAmount()
    end,
    energyProduction = function(self)
        return self.id.getEnergyProducedLastTick()
    end,
    steamOutput = function(self)
        return self.id.getHotFluidProducedLastTick()
    end,
    fuelConsumption = function(self)
        return self.id.getFuelConsumedLastTick()
    end,
    activeCooling = function(self)
        return self.id.isActivelyCooled()
    end,

    setOn = function(self,status)
        self.id.setActive(status)
    end,
    setRodLevel = function(self,level)
        self.id.setAllControlRodLevels(level)
    end,
    maxOutputSteam = 50000
}


function _G.newReactor(name,id, side, type)
    print("Creating new Base Reactor")
    local reactor = {}
    setmetatable(reactor,{__index=Reactor})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    print("Settings Name -> ".. name)
    reactor.name = name
    reactor.id = id
    print("Settings Side -> ".. side)
    reactor.side = side
    print("Settings Type -> ".. type)
    reactor.type = type

    return reactor
end






