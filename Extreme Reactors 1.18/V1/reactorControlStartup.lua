sleep(0.1)
if fs.exists("reactor_control") then
    local id = multishell.launch({ shell = shell, require = require }, "reactor_control")
    multishell.setTitle(id, "reactor_control")
end