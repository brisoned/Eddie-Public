-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 2.6 --

-- Loads the Touchpoint API (by Lyqyd)
shell.run("cp /extreme-reactors-control/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")


-- Touchpoint Page
local page = touchpoint.new(touchpointLocation)
-- Button Labels
local startOn = {}
local startOff = {}

function _G.createButtons()

  page:add(_G.language:getText("startProgram"),startTC,3,5,20,5)
  page:add(_G.language:getText("reactorOnly"),function() switchProgram("Reactor") end,3,9,20,9)
  page:add(_G.language:getText("wordTurbines"),function() switchProgram("Turbine") end,3,11,20,11)
  page:add(_G.language:getText("wordAutomatic"),nil,23,9,35,9)
  page:add(_G.language:getText("wordManual"),nil,23,11,35,11)
  page:add(_G.language:getText("wordOptions"),displayOptions,3,16,20,16)
  page:add(_G.language:getText("quitProgram"),exit,3,17,20,17)
  page:add(_G.language:getText("wordReboot"),reboot,3,18,20,18)
  page:add("menuOn",nil,39,7,49,7)
  startOn = {"   ".._G.language:getText("wordOn").."    ",label = "menuOn"}
  startOff = {"   ".._G.language:getText("wordOff").."   ",label = "menuOn"}

  if program == "turbine" then
    page:toggleButton(_G.language:getText("wordTurbines"))
  elseif program == "reactor" then
    page:toggleButton(_G.language:getText("reactorOnly"))
  end
  
  if overallMode == "auto" then
    page:toggleButton(_G.language:getText("wordAutomatic"))
  elseif overallMode == "manual" then
    page:toggleButton(_G.language:getText("wordManual"))
  end

  if mainMenu then
    page:rename("menuOn",startOn,true)
    page:toggleButton("menuOn")
  else
    page:rename("menuOn",startOff,true)
  end
end

function _G.exit()
  controlMonitor.clear()
  controlMonitor.setCursorPos(27,8)
  controlMonitor.write(_G.language:getText("terminatedProgram"))    
  term.clear()
  term.setCursorPos(1,1)
  shell.completeProgram("/extreme-reactors-control/start/menu.lua")
end

function _G.switchProgram(currBut)
  if program == "turbine" and currBut == "Reactor" then
    program = "reactor"

    if not page.buttonList[_G.language:getText("reactorOnly")].active then
      page:toggleButton(_G.language:getText("reactorOnly"))
    end
    if page.buttonList[_G.language:getText("wordTurbines")].active then
      page:toggleButton(_G.language:getText("wordTurbines"))
    end

  elseif program == "reactor" and currBut == "Turbine" then
    program = "turbine"
        
    if page.buttonList["Reactor only"].active then
      page:toggleButton(_G.language:getText("reactorOnly"))
    end
    if not page.buttonList["Turbines"].active then
      page:toggleButton(_G.language:getText("wordTurbines"))
    end
  end   


  saveOptionFile()
  page:draw()
  displayMenu()
end

function _G.startTC()
  if program == "turbine" then
    shell.run("/extreme-reactors-control/program/turbineControl.lua")
  elseif program == "reactor" then
    shell.run("/extreme-reactors-control/program/reactorControl.lua")
  end
end

function displayOptions()
  shell.run("/extreme-reactors-control/program/editOptions.lua")
end

function reboot()
  os.reboot()
end

local function getClick(funct)
  local event,but = page:handleEvents(os.pullEvent())
  
  if event == "button_click" then
    if but == "menuOn" then
      if not mainMenu then
        _G.mainMenu = true
        page:rename("menuOn",startOn,true)
      elseif mainMenu then
        _G.mainMenu = false
        page:rename("menuOn",startOff,true)
      end
      saveOptionFile()
      funct()
    elseif but == "Automatic" then
      if page.buttonList[but].active == false then
        page:toggleButton(_G.language:getText("wordAutomatic"))
      end
      if overallMode == "manual" then
        page:toggleButton(_G.language:getText("wordManual"))
      end
      _G.overallMode = "auto"
      saveOptionFile()
      funct()

    elseif but == "Manual" then
      if page.buttonList[but].active == false then
        page:toggleButton(but)
      end

      if overallMode == "auto" then
        page:toggleButton(_G.language:getText("wordAutomatic"))
      end

      _G.overallMode = "manual"
      saveOptionFile()
      funct()
    else
      page:flash(but)
      page.buttonList[but].func()
    end

  else
    sleep(1)
    funct()
  end
end

function _G.displayMenu()
  controlMonitor.clear()
  page:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)

  controlMonitor.setCursorPos(3,2)
  controlMonitor.write("-- ".._G.language:getText("wordMainMenu").." --")
  controlMonitor.setCursorPos(39,5)
  controlMonitor.write(_G.language:getText("showOnStartup")..": ")
  controlMonitor.setCursorPos(39,9)
  controlMonitor.write(_G.language:getText("wordLanguage")..": ")
  controlMonitor.setCursorPos(3,7)
  controlMonitor.write(_G.language:getText("wordProgram")..": ")
  controlMonitor.setCursorPos(23,7)
  controlMonitor.write(_G.language:getText("wordMode")..": ")

  getClick(displayMenu)
end

createButtons()
displayMenu()