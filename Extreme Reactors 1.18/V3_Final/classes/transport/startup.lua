local StartUpMessage = {
    message = ""
}

function _G.newStartUpMessage(messageData)
    local message = {}
    setmetatable(message,{__index = StartUpMessage})
    
    message.message = messageData

    return message
end  