local ReactorTurbineMessage = {
    energyStored = 0,
    energyMax = 0,
    reactorCount = 0,
    steam = 0,
    fuelConsumed = 0,
    efficiency = 0,
    casing = 0,
    core = 0,
    rodLevel = 0,
    rfProduced = 0,
    active = false,
    turbines = {}
}

local Turbine = {
    engaged = "",
    turbineSpeed = 0,
    rfProduction = 0,
    turbineEnergy = 0
}

function _G.newReactorTurbineMessage(turbineCount)
    debugOutput("Creating new ReactorOnlyMessage Class")

    local reactorTurbine = {}
    setmetatable(reactorTurbine,{__index = ReactorTurbineMessage})
    
    for i = 0, turbineCount do
        reactorTurbine.turbines[i] = {}
        setmetatable(reactorTurbine.turbines[i],{__index = Turbine})
    end

    return reactorTurbine
end
