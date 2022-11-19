-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local MekanismEnergyStorage = {
    name = "",
    id = {},
    side = "",
    type = "",
    useGetEnergy = false,    
    useGetTotalEnergy = false,    
    useGetEnergyCapacity = false,    
    useGetMaxEnergy = false,    
    useGetTotalMaxEnergy = false,

    energy = function(self)
        if self.useGetEnergy then
            return self.id.getEnergy()
        end
        if self.useGetTotalEnergy then
            return self.id.getTotalEnergy()
        end
    end,
    capacity = function(self)
        if self.useGetEnergyCapacity then
            return self.id.getEnergyCapacity()
        end
        if self.useGetMaxEnergy then
            return self.id.getMaxEnergy()
        end
        if self.useGetTotalMaxEnergy then
            return self.id.getTotalMaxEnergy()
        end
    end,
    percentage = function(self)
        return math.floor(self:energy()/self:capacity()*100)
    end,
    percentagePrecise = function(self)
        return self:energy()/self:capacity()*100
    end
}

function _G.newMekanismEnergyStorage(name,id, side, type)
    print("Creating new Mekanism EnergyCube Storage")
    local storage = {}
    setmetatable(storage,{__index=MekanismEnergyStorage})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    local successGetEnergy, errGetEnergy= pcall(function() id.getEnergy() end)
    local successGetTotalEnergy, errGetTotalEnergy= pcall(function() id.getTotalEnergy() end)
    local successGetEnergyCapacity, errGetEnergyCapacity= pcall(function() id.getEnergyCapacity() end)
    local successGetMaxEnergy, errGetMaxEnergy= pcall(function() id.getMaxEnergy() end)
    local successGetTotalMaxEnergy, errGetTotalMaxEnergy= pcall(function() id.getTotalMaxEnergy() end)

    storage.useGetEnergy = successGetEnergy
    storage.useGetTotalEnergy = successGetTotalEnergy   
    storage.useGetEnergyCapacity = successGetEnergyCapacity    
    storage.useGetMaxEnergy = successGetMaxEnergy    
    storage.useGetTotalMaxEnergy = successGetTotalMaxEnergy

    storage.name = name
    storage.id = id
    storage.side = side
    storage.type = type

    return storage
end








