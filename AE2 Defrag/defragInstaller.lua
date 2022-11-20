--Progams to list on the install menu. You will need to include any dependencies.
programs = {
  [1] = {
    ["Git"] = "https://raw.githubusercontent.com/brisoned/Eddie-Public/main/AE2%20Defrag/defrag.lua",
    ["dirName"] = "AE2_Defrag",
    ["fileName"] = "defrag.lua",
    ["displayName"] = "AE2 Defrag",
    ["dependencies"] = {
      [1] = {
        ["Git"] = "https://raw.githubusercontent.com/brisoned/Eddie-Public/main/AE2%20Defrag/touchpoint.lua",
        ["fileName"] = "touchpoint.lua",
        ["displayName"] = "Touchpoint API"
      }
    }
  },
  [2] = {
    ["Git"] = "https://raw.githubusercontent.com/krumpaul/public/main/wpp.lua",
    ["dirName"] = "WPP",
    ["fileName"] = "wpp.lua",
    ["displayName"] = "WPP Master Computer"
  },
  [3] = {
    ["Git"] = "https://raw.githubusercontent.com/krumpaul/public/main/wpp_remote",
    ["dirName"] = "WPP_REMOTE",
    ["fileName"] = "wpp_remote.lua",
    ["displayName"] = "WPP Remote Computer"
  }
}

--------------------------------------------------------
term.clear()
-------------------FORMATTING-------------------------------

function draw_text_term(x, y, text, text_color, bg_color)
  term.setTextColor(text_color)
  term.setBackgroundColor(bg_color)
  term.setCursorPos(x, y)
  write(text)
end

function draw_line_term(x, y, length, color)
  term.setBackgroundColor(color)
  term.setCursorPos(x, y)
  term.write(string.rep(" ", length))
end

function progress_bar_term(x, y, length, minVal, maxVal, bar_color, bg_color)
  draw_line_term(x, y, length, bg_color) --backgoround bar
  local barSize = math.floor((minVal / maxVal) * length)
  draw_line_term(x, y, barSize, bar_color) --progress so far
end

function menu_bars()

  draw_line_term(1, 1, 55, colors.blue)
  draw_text_term(10, 1, "AE2 Defrag Installer", colors.white, colors.blue)

  draw_line_term(1, 18, 55, colors.blue)
  draw_line_term(1, 19, 55, colors.blue)
  draw_text_term(10, 18, "by brisoned", colors.white, colors.blue)
end

--Restores file from backups
function restoreFile(file)
  fs.copy("/backups/" .. file .. "_old", file)
  fs.delete("/backups/" .. file .. "_old")
end

--Test for successful install
function installFailed(file, x, y)
  if fs.exists(file) then
    draw_text_term(x, y, file .. ":" .. " Success!", colors.lime, colors.black)
    return false
  else
    draw_text_term(x, y, file .. ":" .. " Failed!", colors.red, colors.black)
    if fs.exists("/backups/" .. file .. "_old") then
      restoreFile(file)
    end
    return true
  end
end

--Delete backups
function deleteBackup(backupDir, file)
  if fs.exists(backupDir .. file .. "_old") then
    fs.delete(backupDir .. file .. "_old")
  end
end

--Create Backups
function createBackup(backupDir, litPath, file)
  if fs.exists(litPath) then
    fs.copy(litPath, backupDir .. file .. "_old")
    fs.delete(litPath)
  end
end

--Get table length
function tablelength(table)
  local count = 0
  for _ in pairs(table) do
    count = count + 1
  end
  return count
end

--Installs a program and its dependencies
function install(program, programGit)
  term.clear()
  menu_bars()

  draw_text_term(1, 3, "Installing " .. program .. "...", colors.yellow, colors.black)
  term.setCursorPos(1, 5)
  term.setTextColor(colors.white)
  sleep(0.5)

  -----------------Install control program---------------

  --Get variables for current program install
  for i, p in ipairs(programs) do
    if p.fileName == program then
      currRootDir = p.dirName
      currBackupDir = p.dirName .. "/backups/"
      currDepDir = p.dirName .. "/dependencies/"
      currLitPath = p.dirName .. "/" .. p.fileName
      if p.dependencies ~= nil then
        currDeps = p.dependencies
      end
    end
  end

  --delete any old backups
  deleteBackup(currBackupDir, program)

  --backup current program
  createBackup(currBackupDir, currLitPath, program)

  if currDeps ~= nil then
    --delete old dependency backups
    for i, d in ipairs(currDeps) do
      deleteBackup(currBackupDir, d.fileName)
    end

    --create new dependency backups
    for i, d in ipairs(currDeps) do
      currDepLitPath = currDepDir .. "/" .. d.fileName
      createBackup(currBackupDir, currDepLitPath, d.fileName)
    end
  end

  --install prgram
  progInstallSuccess = shell.run("wget", programGit, currLitPath)
  if progInstallSuccess == true then
    draw_text_term(1, 1, program .. ":" .. " Success!", colors.lime, colors.black)
  else
    draw_text_term(1, 1, program .. ":" .. " Failed!", colors.red, colors.black)
    draw_text_term(1, 2, "Rolling back install...", colors.yellow, colors.black)
    os.sleep(1)
    fs.delete(currRootDir)
    draw_text_term(1, 3, "Press enter to return to main menu.", colors.red, colors.black)
    wait = read()
    start()
  end

  --install dependencies
  if currDeps ~= nil then
    depPrintStartY = 4
    for i, d in ipairs(currDeps) do
      currDepLitPath = currDepDir .. "/" .. d.fileName
      depInstallSuccess = shell.run("wget", d.Git, currDepLitPath)
      if depInstallSuccess == true then
        draw_text_term(1, depPrintStartY, d.fileName .. ":" .. " Success!", colors.lime, colors.black)
      else
        draw_text_term(1, (depPrintStartY + 1), d.fileName .. ":" .. " Failed!", colors.red, colors.black)
        draw_text_term(1, (depPrintStartY + 2), "Rolling back install...", colors.yellow, colors.black)
        os.sleep(1)
        fs.delete(currRootDir)
        draw_text_term(1, (depPrintStartY + 3), "Press enter to return to main menu.", colors.yellow, colors.black)
        wait = read()
        start()
      end
    end
  end

  --reboot after install
  if progInstallSuccess == true and depInstallSuccess == true then
    draw_text_term(1, 16, "Press enter to reboot", colors.gray, colors.black)
    wait = read()
    os.reboot()
  elseif progInstallSuccess == true then
    draw_text_term(1, 16, "Press enter to reboot", colors.gray, colors.black)
    wait = read()
    os.reboot()
  else
    draw_text_term(1, 15, "Something went wrong...", colors.red, colors.black)
    draw_text_term(1, (depPrintStartY + 3), "Press enter to return to main menu.", colors.yellow, colors.black)
    wait = read()
    start()
  end
  currDeps = nil
end

function selectProgram()
  term.clear()
  menu_bars()
  maxNum = tablelength(programs)
  optionStartY = 5
  draw_text_term(1, 4, "What would you like to install?", colors.yellow, colors.black)
  for i, p in ipairs(programs) do
    draw_text_term(3, optionStartY, i .. " - " .. p.displayName, colors.white, colors.black)
    optionStartY = optionStartY + 1
    i = i + 1
  end
  draw_text_term(1, optionStartY, "Enter a number:", colors.yellow, colors.black)
  optionStartY = optionStartY + 1
  term.setCursorPos(1, optionStartY)
  term.setTextColor(colors.white)
  input = read()
  if tonumber(input) <= (maxNum) then
    for i, p in ipairs(programs) do
      if tonumber(input) == i then
        install(p.fileName, p.Git)
      end
    end
  else
    draw_text_term(1, 12, "please enter a valid number between 1 and 4.", colors.red, colors.black)
    sleep(1)
    start()
  end
  start()
end

--start the main loop
function start()
  selectProgram()
end

start()
