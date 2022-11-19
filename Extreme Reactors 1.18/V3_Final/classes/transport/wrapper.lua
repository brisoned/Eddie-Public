local Wrapper = {
    type = "",
    location = "",
    data = {}
}


function _G.newMessage(type, data, location)
    local message = {}
    setmetatable(message,{__index = Wrapper})

    message.data = data
    message.type = type
    message.location = location

    return textutils.serialise(message)
end