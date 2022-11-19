-- Extreme Reactors Control by SeekerOfHonjo --
-- Original work by Thor_s_Crafter on https://github.com/ThorsCrafter/Reactor-and-Turbine-control-program -- 
-- Version 1.0 --
-- Options menu --

--Loads the touchpoint and input APIs
shell.run("cp /extreme-reactors-control/config/touchpoint.lua /touchpoint")
os.loadAPI("touchpoint")
shell.run("rm touchpoint")

shell.run("cp /extreme-reactors-control/config/input.lua /input")
os.loadAPI("input")
shell.run("rm input")

menuOn = true

--Some variables
local mode
local mode2
local continue = true
local touch1 = touchpoint.new(touchpointLocation)
local touch2 = touchpoint.new(touchpointLocation)
local touch3 = touchpoint.new(touchpointLocation)
local touch4 = touchpoint.new(touchpointLocation)
local currPage =  touchpoint.new(touchpointLocation)
local currFunct = backToMainMenu

--Save the changes and reopen the options menu
function saveConfigFile()
  _G.saveOptionFile()
  shell.run("/extreme-reactors-control/program/editOptions.lua")
  shell.completeProgram("/extreme-reactors-control/program/editOptions.lua")
end

--Go back to the main menu
function displayMenu()
  loadOptionFile()
  controlMonitor.clear()
  shell.run("reboot")
  shell.completeProgram("/extreme-reactors-control/program/editOptions.lua")
end

--Creates all buttons
function createAllButtons()
  --Overview buttons
  touch1:add(_G.language:getText("wordBackground"),setBackground,3,4,19,4)
  touch1:add(_G.language:getText("wordText"),setText,3,6,19,6)
  touch1:add(_G.language:getText("reactorOff"),setOffAt,3,8,19,8)
  touch1:add(_G.language:getText("reactorOn"),setOnAt,3,10,19,10)
  touch1:add(_G.language:getText("turbineSpeed"),setTurbineSpeed,3,12,19,12)
  touch1:add(_G.language:getText("steamInput"),setTurbineSteamRate,3,14,19,14)
  touch1:add(_G.language:getText("turbineOnOff"),changeTurbineBehaviour,3,16,19,16)
  touch1:add(_G.language:getText("deleteConfig"),resetConfig,3,18,19,18)
  touch1:add(_G.language:getText("wordSave"),saveConfigFile,3,21,19,21)
  touch1:add(_G.language:getText("wordMainMenu"),displayMenu,3,23,19,23)

  --Color buttons
  touch2:add(_G.language:getText("wordWhite"),function() setColor(1) end,35,5,48,5)
  touch2:add(_G.language:getText("wordOrange"),function() setColor(2) end,50,5,63,5)
  touch2:add(_G.language:getText("wordMagenta"),function() setColor(4) end,35,7,48,7)
  touch2:add(_G.language:getText("wordLightBlue"),function() setColor(8) end,50,7,63,7)
  touch2:add(_G.language:getText("wordYellow"),function() setColor(16) end,35,9,48,9)
  touch2:add(_G.language:getText("wordLime"),function() setColor(32) end,50,9,63,9)
  touch2:add(_G.language:getText("wordPink"),function() setColor(64) end,35,11,48,11)
  touch2:add(_G.language:getText("wordGray"),function() setColor(128) end,50,11,63,11)
  touch2:add(_G.language:getText("wordLightGray"),function() setColor(256) end,35,13,48,13)
  touch2:add(_G.language:getText("wordCyan"),function() setColor(512) end,50,13,63,13)
  touch2:add(_G.language:getText("wordPurple"),function() setColor(1024) end,35,15,48,15)
  touch2:add(_G.language:getText("wordBlue"),function() setColor(2048) end,50,15,63,15)
  touch2:add(_G.language:getText("wordBrown"),function() setColor(4096) end,35,17,48,17)
  touch2:add(_G.language:getText("wordGreen"),function() setColor(8192) end,50,17,63,17)
  touch2:add(_G.language:getText("wordRed"),function() setColor(16384) end,35,19,48,19)
  touch2:add(_G.language:getText("wordBlack"),function() setColor(32768) end,50,19,63,19)
  touch2:add(_G.language:getText("wordBack"),backToMainMenu,3,8,19,8)

  --+/- buttons (1-100)
  touch3:add("-1",function() setOnOffAt("-",1) end,3,8,6,8)
  touch3:add("-10",function() setOnOffAt("-",10) end,8,8,12,8)
  touch3:add("-100",function() setOnOffAt("-",100) end,14,8,19,8)
  touch3:add("+1", function() setOnOffAt("+",1) end,3,10,6,10)
  touch3:add("+10",function() setOnOffAt("+",10) end,8,10,12,10)
  touch3:add("+100",function() setOnOffAt("+",100) end,14,10,19,10)
  touch3:add(_G.language:getText("wordBack"),backToMainMenu,3,13,19,13)

  --+/- buttons (1-1000)
  touch4:add("-1",function() setOnOffAt("-",1) end,3,8,6,8)
  touch4:add("-10",function() setOnOffAt("-",10) end,8,8,12,8)
  touch4:add("-100",function() setOnOffAt("-",100) end,14,8,19,8)
  touch4:add("-1000",function() setOnOffAt("-",1000) end,21,8,28,8)
  touch4:add("+1", function() setOnOffAt("+",1) end,3,10,6,10)
  touch4:add("+10",function() setOnOffAt("+",10) end,8,10,12,10)
  touch4:add("+100",function() setOnOffAt("+",100) end,14,10,19,10)
  touch4:add("+1000",function() setOnOffAt("+",1000) end,21,10,28,10)
  touch4:add(_G.language:getText("wordBack"),backToMainMenu,3,13,19,13)
end

--Display the overwiew
function backToMainMenu()
  controlMonitor.clear()
  currPage=touch1
  currPage:draw()
  controlMonitor.setCursorPos(2,2)
  controlMonitor.setTextColor(textColor)
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setCursorPos(4,2)

  controlMonitor.write("-- ".._G.language:getText("wordOptions").." --")

  --Set text of all the options
  controlMonitor.setCursorPos(24,4)
  local col = printColor(tonumber(_G.optionList["backgroundColor"]))
  local col2 = printColor(backgroundColor)
  if tonumber(_G.optionList["backgroundColor"]) ~= backgroundColor then

      controlMonitor.write(_G.language:getText("wordBackgroundColor")..": "..col.." -> "..col2.."   ")

  else
      controlMonitor.write(_G.language:getText("wordBackgroundColor")..": "..col2.."    ")
  end

  controlMonitor.setCursorPos(24,6)
  local col3 = printColor(tonumber(_G.optionList["textColor"]))
  local col4 = printColor(textColor)
  if tonumber(_G.optionList["textColor"]) ~= textColor then
      controlMonitor.write(_G.language:getText("wordTextColor")..": "..col3.." -> "..col4.."   ")
  else
      controlMonitor.write(_G.language:getText("wordTextColor")..": "..col4.."   ")
  end

  controlMonitor.setCursorPos(24,8)
  if math.floor(tonumber(_G.optionList["reactorOffAt"])) ~= math.floor(reactorOffAt) then
      controlMonitor.write(_G.language:getText("reactorOffAbove")..math.floor(tonumber(_G.optionList["reactorOffAt"])).."% -> "..math.floor(reactorOffAt).."%   ")
  else
      controlMonitor.write(_G.language:getText("reactorOffAbove")..math.floor(reactorOffAt).."%   ")
  end

  controlMonitor.setCursorPos(24,10)
  if math.floor(tonumber(_G.optionList["reactorOnAt"])) ~= math.floor(reactorOnAt) then
      controlMonitor.write(_G.language:getText("reactorOnBelow")..math.floor(tonumber(_G.optionList["reactorOnAt"])).."% -> "..math.floor(reactorOnAt).."%   ")

  else
      controlMonitor.write(_G.language:getText("reactorOnBelow")..math.floor(reactorOnAt).."%   ")
  end
  
  controlMonitor.setCursorPos(24,12)
  if tonumber(_G.optionList["turbineTargetSpeed"]) ~= turbineTargetSpeed then
      controlMonitor.write(_G.language:getText("turbineMaxSpeed")..(input.formatNumberComma(math.floor(tonumber(_G.optionList["turbineTargetSpeed"])))).." -> "..(input.formatNumberComma(turbineTargetSpeed)).."RPM      ")

  else
      controlMonitor.write(_G.language:getText("turbineMaxSpeed")..(input.formatNumberComma(turbineTargetSpeed)).."RPM     ")

  end

  controlMonitor.setCursorPos(24,14)
  if tonumber(_G.optionList["targetSteam"]) ~= targetSteam then
      controlMonitor.write(_G.language:getText("turbineSteamInput")..(input.formatNumberComma(math.floor(tonumber(_G.optionList["targetSteam"])))).." -> "..(input.formatNumberComma(targetSteam)).."mb/t      ")


  else
      controlMonitor.write(_G.language:getText("turbineSteamInput")..(input.formatNumberComma(targetSteam)).."mb/t     ")

  end

  controlMonitor.setCursorPos(24,16)
  local turbineOnOffString1 = ""
  local turbineOnOffString2 = ""
  local outputPreString = string.gsub(_G.language:getText("turbineDisableAt"),"{reactorOffAt}",reactorOffAt)
  if _G.optionList["turbineOnOff"] ~= turbineOnOff then
      if _G.optionList["turbineOnOff"] == "off" then
        turbineOnOffString1 = _G.language:getText("wordNo")
        turbineOnOffString2 = _G.language:getText("wordYes")
      elseif _G.optionList["turbineOnOff"] == "on" then
        turbineOnOffString1 = _G.language:getText("wordYes")
        turbineOnOffString2 = _G.language:getText("wordNo")
      end
      controlMonitor.write(outputPreString..turbineOnOffString2.." -> "..turbineOnOffString1)

  else
      if _G.optionList["turbineOnOff"] == "off" then _G.turbineOnOffString2 = _G.language:getText("wordYes")
      elseif _G.optionList["turbineOnOff"] == "on" then _G.turbineOnOffString2 = _G.language:getText("wordNo") end
      controlMonitor.write(outputPreString..turbineOnOffString2.."   ")

  end

  controlMonitor.setCursorPos(24,18)
  controlMonitor.write("Config available: ")
  if _G.optionList["version"] == "" then
    controlMonitor.write(_G.language:getText("wordNo"))
  else
    controlMonitor.write(_G.language:getText("wordYes"))
  end
  getClick(backToMainMenu)
end

--Function for setting the background color
function setBackground()
  mode = "background"
  controlMonitor.clear()
  currPage = touch2
  currPage:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)
  controlMonitor.setCursorPos(3,2)
    controlMonitor.write("-- Change BackgroundColor --")
    controlMonitor.setCursorPos(3,5)
    controlMonitor.write("BackgroundColor: ")
  local col = printColor(backgroundColor)
  controlMonitor.write(col)
  --refresh_G.optionList()
  getClick(setBackground)
end

--Function for setting the text color
function setText()
  mode = "text"
  controlMonitor.clear()
  currPage = touch2
  currPage:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)
  controlMonitor.setCursorPos(3,2)
    controlMonitor.write("-- Change TextColor --")
    controlMonitor.setCursorPos(3,5)
    controlMonitor.write("TextColor: ")
  local col = printColor(textColor)
  controlMonitor.write(col)
  --refresh_G.optionList()
  getClick(setText)
end

--Function for setting the shutdown level (high)
function setOffAt()
  mode2 = "off"
  controlMonitor.clear()
  currPage = touch3
  currPage:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)
  controlMonitor.setCursorPos(3,2)
    controlMonitor.write("-- Reactor off --")
    controlMonitor.setCursorPos(3,5)
    controlMonitor.write("Reactor off above "..math.floor(reactorOffAt).."%  ")
  --refresh_G.optionList()
  getClick(setOffAt)
end

--Function for setting the shutdown level (low)
function setOnAt()
  mode2 = "on"
  controlMonitor.clear()
  currPage = touch3
  currPage:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)
  controlMonitor.setCursorPos(3,2)
    controlMonitor.write("-- Reactor on --")
    controlMonitor.setCursorPos(3,5)
    controlMonitor.write("Reactor on below "..math.floor(reactorOnAt).."%  ")
  --refresh_G.optionList()
  getClick(setOnAt)
end

function setColor(id)
  if mode == "background" then
    _G.backgroundColor = id
    setBackground()
  elseif mode == "text" then
    _G.textColor = id
    setText()
  end
end

--Resolve color codes to text
function printColor(which)
  --	local which
  --	if mode == "background" then which = backgroundColor
  --	elseif mode == "text" then which = textColor end
  if which == 1 then return _G.language:getText("wordWhite")
  elseif which == 2 then return _G.language:getText("wordOrange")
  elseif which == 4 then return _G.language:getText("wordMagenta")
  elseif which == 8 then return _G.language:getText("wordLightBlue")
  elseif which == 16 then return _G.language:getText("wordYellow")
  elseif which == 32 then return _G.language:getText("wordLime")
  elseif which == 64 then return _G.language:getText("wordPink")
  elseif which == 128 then return _G.language:getText("wordGray")
  elseif which == 256 then return _G.language:getText("wordLightGray")
  elseif which == 512 then return _G.language:getText("wordCyan")
  elseif which == 1024 then return _G.language:getText("wordPurple")
  elseif which == 2048 then return _G.language:getText("wordBlue")
  elseif which == 4096 then return _G.language:getText("wordBrown")
  elseif which == 8192 then return _G.language:getText("wordGreen")
  elseif which == 16384 then return _G.language:getText("wordRed")
  elseif which == 32768 then return _G.language:getText("wordBlack")
  end
end

--Increase/decrease reactorOff/reactorOn setting
function setOnOffAt(vorz,anz)
  if vorz == "-" then
    if mode2 == "off" then
      _G.reactorOffAt = reactorOffAt - anz
      if reactorOffAt < 0 then 
        _G.reactorOffAt = 0
      end
    elseif mode2 == "on" then
      _G.reactorOnAt = reactorOnAt - anz
      if reactorOnAt < 0 then 
        _G.reactorOnAt = 0 
      end
    elseif mode2 == "speed" then
      _G.turbineTargetSpeed = turbineTargetSpeed - anz
      if turbineTargetSpeed < 0 then 
        _G.turbineTargetSpeed = 0 
      end
    elseif mode2 == "steam" then
      _G.targetSteam = targetSteam - anz
      if targetSteam < 0 then 
        _G.targetSteam = 0 
      end
    end
  elseif vorz == "+" then
    if mode2 == "off" then
      _G.reactorOffAt = reactorOffAt + anz
      if reactorOffAt >100 then _G.reactorOffAt = 100 end
    elseif mode2 == "on" then
      _G.reactorOnAt = reactorOnAt + anz
      if reactorOnAt >100 then _G.reactorOnAt = 100 end
    elseif mode2 == "speed" then
      turbineTargetSpeed = turbineTargetSpeed + anz
    elseif mode2 == "steam" then
      _G.targetSteam = targetSteam + anz
      if targetSteam > turbines[0].maxInputSteam then 
        _G.targetSteam = turbines[0].maxInputSteam 
      end
    end
  end
  if mode2 == "off" then setOffAt()
  elseif mode2 == "on" then setOnAt() end
end

--Sets the max. turbine speed
function setTurbineSpeed()
mode2 = "speed"
  controlMonitor.clear()
  currPage = touch4
  currPage:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)
  controlMonitor.setCursorPos(3,2)

    controlMonitor.write("-- Turbine Speed --")
    controlMonitor.setCursorPos(3,5)
    controlMonitor.write("Maximum Turbine speed: "..(input.formatNumberComma(turbineTargetSpeed)).."RPM      ")

  --refresh_G.optionList()
  getClick(setTurbineSpeed)
  setTurbineSpeed()
end

--Sets the max. turbine steam input
function setTurbineSteamRate()
  mode2 = "steam"
  controlMonitor.clear()
  currPage = touch4
  currPage:draw()
  controlMonitor.setBackgroundColor(backgroundColor)
  controlMonitor.setTextColor(textColor)
  controlMonitor.setCursorPos(3,2)

    controlMonitor.write("-- Turbine Steam Input --")
    controlMonitor.setCursorPos(3,5)
    controlMonitor.write("Turbine Steam Input-Rate: "..(input.formatNumberComma(targetSteam)).."mb/t      ")

  --refresh_G.optionList()
  getClick(setTurbineSteamRate)
  setTurbineSteamRate()
end

--Enable/Disable turbine at targetSpeed?
function changeTurbineBehaviour()
  if turbineOnOff == "off" then _G.turbineOnOff = "on"
  elseif turbineOnOff == "on" then _G.turbineOnOff = "off" end
  backToMainMenu()
end

--Reset the config file
function resetConfig()
  rodLevel = 0
  _G.targetSteam = turbines[0].maxInputSteam
  backToMainMenu()
end

--Check for click events
function getClick(funct)
  local event,but = currPage:handleEvents(os.pullEvent())
  if event == "button_click" then
    currPage:flash(but)
    currPage.buttonList[but].func()
  else
    sleep(1)
    funct()
  end
end

--Run
controlMonitor.clear()

createAllButtons()
backToMainMenu()
