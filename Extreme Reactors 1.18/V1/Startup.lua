sleep(0.1)
if fs.exists("ReactorStartup") then
    shell.run("ReactorStartup")
end
if fs.exists("TurbineStartup") then
    shell.run("TurbineStartup")
end
if fs.exists("wpp_remote_startup") then
    shell.run("wpp_remote_startup")
end