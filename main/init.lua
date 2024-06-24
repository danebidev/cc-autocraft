-- Setup {{{
local monitor = peripheral.find("monitor") --[[@as ccTweaked.peripherals.Monitor]]

if not monitor then
	print("No monitor found")
end

monitor.clear()
monitor.setCursorPos(1, 1)

local root = fs.combine(shell.getRunningProgram(), "../../")

local lines = {}

local function printToMonitor(text)
	print(text)

	if not monitor then
		return
	end

	table.insert(lines, text)

	if #lines > monitor.getSize() - 1 then
		table.remove(lines, 1)
	end

	monitor.clear()
	monitor.setCursorPos(1, 1)
	for i, line in ipairs(lines) do
		monitor.setCursorPos(1, i)
		monitor.write(line)
	end
end

printToMonitor("[ ] Loading main.lua")
-- }}}

-- Recipe handlers {{{
local function findRecipeHandlers()
	printToMonitor("[ ] Finding recipe handlers")

	local handlers = {}
	local num_handlers = 0

	local files = fs.list(fs.combine(root, "recipe_handlers"))

	for _, file in ipairs(files) do
		local name = file:match("(.+).lua")
		if name then
			num_handlers = num_handlers + 1
			printToMonitor('    Found handler "' .. name .. '"')
			handlers[name] = dofile(fs.combine(root, "recipe_handlers", file))
		end
	end

	printToMonitor("[x] Found " .. num_handlers .. " recipe handlers")

	return handlers
end

-- }}}

-- Drives {{{
local function findDrivesWithRecipes()
	printToMonitor("[ ] Finding drives with recipes")

	local num_drives = 0

	local drives = peripheral.find("drive", function(name, drive)
		if not drive.hasData() or not fs.exists(fs.combine(drive.getMountPath(), "recipes")) then
			return false
		end

		printToMonitor("    Found drive " .. name .. " with recipes")
		num_drives = num_drives + 1
		return true
	end)

	if not drives then
		printToMonitor("[x] No drives found with recipes")
		return {}
	else
		printToMonitor("[x] Found " .. num_drives .. " drives with recipes")
		return drives
	end
end
-- }}}

local handlers = findRecipeHandlers()
local drives = findDrivesWithRecipes()
local crafting_calc = dofile(fs.combine(root, "main/crafting_calc.lua"))

-- Rednet user interface {{{
local function user_interface()
	printToMonitor("[ ] Starting user interface")

	rednet.open("top") -- Wireless modem

	while true do
		local sender, message, protocol = rednet.receive("input")

		printToMonitor("Received recipe request from " .. sender)
		rednet.send(sender, { handlers = handlers, drives = drives }, "recipe")
	end
end
-- }}}

parallel.waitForAll(user_interface)
