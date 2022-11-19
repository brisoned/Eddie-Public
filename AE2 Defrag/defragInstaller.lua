--Main program git. Both variables are required for this script to function.
mainGit = "https://raw.githubusercontent.com/brisoned/Eddie-Public/main/AE2%20Defrag/defrag.lua"
mainName = "defrag.lua"

--Startup git. it is assumed this will be called startup or startup.lua.
startupGit = ""

--Dependency gits. Each dependency requires a Git variable and a fileName variable.
dependencies = {
  touchpoint = {
    Git = "https://raw.githubusercontent.com/brisoned/Eddie-Public/main/AE2%20Defrag/touchpoint.lua",
    fileName = "touchpoint.lua"
  }
}

--Optional gits. Each optional install requires a Git variable and a fileName variables.
extras = {
  wpp = {
    Git = "https://raw.githubusercontent.com/krumpaul/public/main/wpp.lua",
    fileName = "wpp.lua",
    displayName = "WPP Master Computer",
    id = 1
  },
  wpp_remote = {
    Git = "https://raw.githubusercontent.com/krumpaul/public/main/wpp_remote",
    fileName = "wpp_remote.lua",
    displayName = "WPP Remote Computer",
    id = 2
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
function deleteBackup(file)
  if fs.exists("/backups/" .. file .. "_old") then
    fs.delete("/backups/" .. file .. "_old")
  end
end

--Create Backups
function createBackup(file)
  if fs.exists(file) then
    fs.copy(file, "/backups/" .. file .. "_old")
    fs.delete(file)
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
function install(program, rawGit)
  term.clear()
  menu_bars()

  draw_text_term(1, 3, "Installing " .. program .. "...", colors.yellow, colors.black)
  term.setCursorPos(1, 5)
  term.setTextColor(colors.white)
  sleep(0.5)

  -----------------Install control program---------------

  --Make backups folder if it doesn't exist
  if fs.exists("backups") == false then
    fs.makeDir("backups")
  end

  --delete any old backups
  deleteBackup(program)

  --backup current program
  createBackup(program)

  --install prgram
  if program ~= mainName then
    for _, extra in pairs(extras) do
      if program == extra.fileName then
        shell.run("wget", extra.Git, extra.fileName)
      end
    end
  else
    shell.run("wget", rawGit, mainName)
  end
  term.clear()

  sleep(0.5)

  term.setCursorPos(1, 8)

  --delete any old startup backups
  deleteBackup("startup")

  --backup/delete startup script
  createBackup("startup")

  --Install startup script
  --shell.run("wget",startupGit)
  --term.clear()

  --delete an old dependency backups
  for _, dependency in pairs(dependencies) do
    deleteBackup(dependency.fileName)
  end

  --backup/delete dependencies
  for _, dependency in pairs(dependencies) do
    createBackup(dependency.fileName)
  end

  --testing for successful installs
  failed = false
  if program == mainName then
    --Install dependency files
    for _, dependency in pairs(dependencies) do
      shell.run("wget", dependency.Git, dependency.fileName)
      term.clear()
    end
    --test for successful install of main program
    failed = installFailed(program, 1, 4)
    --test for successful install of dependencies
    startY = 5
    for _, dependency in pairs(dependencies) do
      failed = installFailed(dependency.fileName, 1, startY)
      startY = startY + 1
    end
  else
    --test for successful install of optional programs
    startY = 4
    for _, extra in pairs(extras) do
      if program == extra.fileName then
        failed = installFailed(extra.fileName, 1, startY)
      end
      startY = startY + 1
    end
  end

  --if failed go back to start, if not reboot.
  if failed == true then
    draw_text_term(1, 16, "Press Enter to return to menu...", colors.gray, colors.black)
    wait = read()
    start()
  else
    draw_text_term(1, 16, "Press Enter to reboot...", colors.gray, colors.black)
    wait = read()
    shell.run("reboot")
  end
end

function selectProgram()
  term.clear()
  menu_bars()
  maxNum = tablelength(extras)
  optionalStartL = 2
  optionalStartY = 6
  draw_text_term(1, 4, "What would you like to install?", colors.yellow, colors.black)
  draw_text_term(3, 5, "1 - AE2 Defrag", colors.white, colors.black)
  for _, extra in pairs(extras) do
    draw_text_term(3, optionalStartY, optionalStartL .. " - " .. extra.displayName, colors.white, colors.black)
    optionalStartY = optionalStartY + 1
    optionalStartL = optionalStartL + 1
  end
  draw_text_term(1, optionalStartY, "Enter a number:", colors.yellow, colors.black)
  term.setCursorPos(1, 12)
  term.setTextColor(colors.white)
  input = read()
  if input == "1" then
    install(mainName, mainGit)
  elseif input <= maxNum then
    for _, extra in pairs(extras) do
      if input == extra.id then
        install(extra.fileName, extra.Git)
      end
    end
  else
    draw_text_term(1, 12, "please enter a valid number between 1 and 4.", colors.red, colors.black)
    sleep(1)
    start()
  end
end

--start the main loop
function start()
  selectProgram()
end

start()
