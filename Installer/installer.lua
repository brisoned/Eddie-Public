--Progams to list on the install menu.
--url, dirName, fileName, displayName, and makeStartup are required.
--dependencies is for additional files you would like to install with the program.
--makeStartup will make a startup file if true that opens the main program in a shell tab at startup.
--Make sure to follow the formatting.
programs = {
	[1] = {
		["url"] = "https://raw.githubusercontent.com/brisoned/Eddie-Public/main/AE2%20Defrag/defrag.lua",
		["dirName"] = "AE2_Defrag",
		["fileName"] = "defrag.lua",
		["displayName"] = "AE2 Defrag",
		["makeStartup"] = false,
		["dependencies"] = {
			[1] = {
				["url"] = "https://raw.githubusercontent.com/brisoned/Eddie-Public/main/AE2%20Defrag/touchpoint.lua",
				["fileName"] = "touchpoint.lua",
				["displayName"] = "Touchpoint API"
			}
		}
	},
	[2] = {
		["url"] = "https://raw.githubusercontent.com/krumpaul/public/main/wpp.lua",
		["dirName"] = "WPP",
		["fileName"] = "wpp.lua",
		["displayName"] = "WPP API",
		["makeStartup"] = false
	},
	[3] = {
		["url"] = "https://raw.githubusercontent.com/brisoned/Eddie-Public/main/WPP/wpp_remote",
		["dirName"] = "WPP_REMOTE",
		["fileName"] = "wpp_remote.lua",
		["displayName"] = "WPP Remote Computer",
		["makeStartup"] = true,
		["dependencies"] = {
			[1] = {
				["url"] = "https://raw.githubusercontent.com/krumpaul/public/main/wpp.lua",
				["fileName"] = "wpp.lua",
				["displayName"] = "WPP API",
			}
		}
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
	draw_text_term(10, 1, "The One Install To Rule Them All", colors.white, colors.blue)

	draw_line_term(1, 18, 55, colors.blue)
	draw_line_term(1, 19, 55, colors.blue)
	draw_text_term(10, 18, "by brisoned", colors.white, colors.blue)
end

--Restores file from backups
function restoreFiles(backupDir, filePath, fileName)
	if fs.exists(filePath) then
		fs.delete(filePath)
	end
	fs.copy(backupDir .. fileName .. "_old", filePath)
	fs.delete(backupDir .. fileName .. "_old")
end

--Deletes old backups
function deleteBackup(backupDir, fileName)
	if fs.exists(backupDir .. fileName .. "_old") then
		fs.delete(backupDir .. fileName .. "_old")
	end
end

--Creates new Backups
function createBackup(backupDir, filePath, fileName)
	if fs.exists(filePath) then
		fs.copy(filePath, backupDir .. fileName .. "_old")
		fs.delete(filePath)
	end
end

--Returns table length as an integer.
function tablelength(table)
	local count = 0
	for _ in pairs(table) do
		count = count + 1
	end
	return count
end

--Splits a string into a table.
function splitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

--Formats the computer
function formatComputer()
	term.clear()
	draw_text_term(1, 1, "Getting list of files...", colors.yellow, colors.black)
	local currFiles = fs.list("/")
	sleep(1)
	for i, currfile in pairs(currFiles) do
		i = i + 1
		isInstaller = string.find(currfile, "nstaller")
		if (currfile ~= "rom") and (isInstaller == nil) then
			fs.delete(currfile)
			draw_text_term(1, i, "Deleted: " .. currfile, colors.red, colors.black)
			sleep(0.5)
		end
	end
	draw_text_term(1, 16, "Press enter to reboot", colors.gray, colors.black)
	wait = read()
	os.reboot()
end

--Installs a program, its dependencies, and manages backups.
function install(program, link, startup)
	currDeps = nil
	term.clear()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	sleep(0.5)

	--Get variables for current program install
	for i, p in ipairs(programs) do
		if p.fileName == program then
			currRootDir = p.dirName
			currBackupDir = currRootDir .. "/backups/"
			if p.dependencies ~= nil then
				currDeps = p.dependencies
				currDepDir = currRootDir .. "/dependencies/"
			end
			currLitPath = currRootDir .. "/" .. p.fileName
			if p.dependencies ~= nil then
				currDeps = p.dependencies
			end
		end
	end

	--delete any old program backups
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
			currDepLitPath = currDepDir .. d.fileName
			createBackup(currBackupDir, currDepLitPath, d.fileName)
		end
	end

	--install prgram
	progInstallSuccess = shell.run("wget", link, currLitPath)
	if fs.exists(currLitPath) and (startup == true) then
		local f = fs.open("startup", fs.exists("startup") and "a" or "w")
		local l2 = "local id = multishell.launch({ shell = shell, require = require}, " .. "'" .. currLitPath .. "'" .. ")"
		local l3 = "multishell.setTitle(id, " .. "'" .. currLitPath .. "'" .. ")"
		f.writeLine(l1)
		f.writeLine(l2)
	end
	sleep(0.5)
	term.clear()

	--install dependencies
	if currDeps ~= nil then
		for i, d in ipairs(currDeps) do
			currDepLitPath = currDepDir .. d.fileName
			depInstallSuccess = shell.run("wget", d.url, currDepLitPath)
		end
	end
	sleep(0.5)
	term.clear()

	--validate program install
	if progInstallSuccess == true then
		draw_text_term(1, 1, program .. ":" .. " Success!", colors.lime, colors.black)
	else
		draw_text_term(1, 1, program .. ":" .. " Failed!", colors.red, colors.black)
		draw_text_term(1, 2, "Rolling back install...", colors.yellow, colors.black)
		sleep(1)
		if fs.exists(currBackupDir) then
			if fs.exists(currBackupDir .. program .. "_old") then
				restoreFiles(currBackupDir, currLitPath, program)
				if fs.exists(currDepDir) then
					for i, d in ipairs(dependencies) do
						if fs.exists(currDepDir .. d.fileName .. "_old") then
							currDepLitPath = currDepDir .. d.fileName
							restoreFiles(currBackupDir, currDepLitPath, d.fileName)
						end
					end
				end
				draw_text_term(1, 3, "Files restored to previous version.", colors.yellow, colors.black)
			else
				fs.delete(currRootDir)
				draw_text_term(1, 3, "Files deleted.", colors.red, colors.black)
			end
		else
			fs.delete(currRootDir)
		end
		draw_text_term(1, 16, "Press enter to return to main menu.", colors.red, colors.black)
		wait = read()
		start()
	end

	--validate dependencies install
	if currDeps ~= nil then
		depPrintStartY = 2
		if depInstallSuccess == true then
			draw_text_term(1, depPrintStartY, "Dependencies: Success!", colors.lime, colors.black)
		else
			draw_text_term(1, depPrintStartY, "Dependencies: Failed!", colors.red, colors.black)
			draw_text_term(1, (depPrintStartY + 1), "Rolling back install...", colors.yellow, colors.black)
			sleep(1)
			if fs.exists(currBackupDir) then
				if fs.exists(currBackupDir .. program .. "_old") then
					restoreFiles(currBackupDir, currLitPath, program)
					if fs.exists(currDepDir) then
						for i, d in ipairs(dependencies) do
							if fs.exists(currDepDir .. d.fileName .. "_old") then
								currDepLitPath = currDepDir .. d.fileName
								restoreFiles(currBackupDir, currDepLitPath, d.fileName)
							end
						end
					end
					draw_text_term(1, (depPrintStartY + 2), "Files restored to previous version.", colors.yellow, colors.black)
				else
					fs.delete(currRootDir)
					draw_text_term(1, (depPrintStartY + 2), "Files deleted.", colors.red, colors.black)
				end
			else
				fs.delete(currRootDir)
				draw_text_term(1, (depPrintStartY + 2), "Files deleted.", colors.red, colors.black)
			end
			draw_text_term(1, 16, "Press enter to return to main menu.", colors.yellow, colors.black)
			wait = read()
			start()
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
		formatOption = i
	end
	draw_text_term(3, optionStartY, formatOption .. " - " .. "Format computer", colors.white, colors.black)
	optionStartY = optionStartY + 1
	draw_text_term(1, optionStartY, "Enter a number:", colors.yellow, colors.black)
	optionStartY = optionStartY + 1
	term.setCursorPos(1, optionStartY)
	term.setTextColor(colors.white)
	input = read()
	if tonumber(input) <= (maxNum) then
		for i, p in ipairs(programs) do
			if tonumber(input) == i then
				install(p.fileName, p.url, p.makeStartup)
			end
		end
	elseif tonumber(input) == formatOption then
		formatComputer()
	else
		draw_text_term(1, 16, "Please enter a valid number!", colors.red, colors.black)
		sleep(2)
		start()
	end
	start()
end

--start the main loop
function start()
	selectProgram()
end

start()
