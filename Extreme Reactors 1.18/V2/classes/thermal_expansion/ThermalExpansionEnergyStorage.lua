-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local ThermalExpansionEnergyStorage = {
    name = "",
    id = {},
    side = "",
    type = "",
    
    energy = function(self)
        return self.id.getEnergyStored()
    end,
    capacity = function(self)
        return self.id.getEnergyCapacity()
    end,
    percentage = function(self)
        return math.floor(self:energy()/self:capacity()*100)
    end,
    percentagePrecise = function(self)
        return self:energy()/self:capacity()*100
    end
}

function _G.newThermalExpansionEnergyStorage(name,id, side, type)
    print("Creating new Thermal Expansion Energy Storage")
    local storage = {}
    setmetatable(storage,{__index=ThermalExpansionEnergyStorage})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    storage.name = name
    storage.id = id
    storage.side = side
    storage.type = type

    return storage
end








