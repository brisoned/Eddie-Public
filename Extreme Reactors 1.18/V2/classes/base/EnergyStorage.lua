-- Reactor / Turbine Control
-- (c) 2021 SeekerOfHonjo
-- Version 2.0

local EnergyStorage = {
    name = "",
    id = {},
    side = "",
    type = "",
    
    energy = function(self)
        return self.id.getEnergyStored()
    end,
    capacity = function(self)
        return self.id.getMaxEnergyStored()
    end,
    percentage = function(self)
        return math.floor(self:energy()/self:capacity()*100)
    end,
    percentagePrecise = function(self)
        return self:energy()/self:capacity()*100
    end
}

function _G.newEnergyStorage(name,id, side, type)
    print("Creating new Base Energy Storage")
    local storage = {}
    setmetatable(storage,{__index=EnergyStorage})
    
    if id == nil then
        print("MISSING wrapped peripheral object. This is going to break!")
    end

    storage.name = name
    storage.id = id
    storage.side = side
    storage.type = type

    return storage
end

function _G.printEnergyStorageData(storage)
    print("Name: "..storage.name)
    print("ID: "..tostring(storage.id))
    print("Energy: "..storage:energy())
    print("Capacity: "..storage:capacity())
    print("Fill: "..storage:percentage().."%")
end







