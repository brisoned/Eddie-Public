sleep(0.1)
if fs.exists("reactor_control") then
    local id = multishell.launch({ shell = shell, require = require }, "turbine_control")
    multishell.setTitle(id, "turbine_control")
end