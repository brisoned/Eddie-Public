local ReactorOnlyMessage = {
    energyStored = 0,
    energyMax = 0,
    reactorCount = 0,
    fuelConsumed = 0,
    steamProduced = 0,
    efficiency = 0
}

function _G.newReactorOnlyMessage()
    local reactorOnly = {}
    setmetatable(reactorOnly,{__index = ReactorTurbineMessage})
    
    return reactorOnly
end