local monitor = peripheral.find("monitor") --[[@as ccTweaked.peripherals.Monitor]]

if not monitor then
    print("No monitor found")
end

monitor.clear()
monitor.setCursorPos(1, 1)

local lines = {}

local function printToMonitor(text)
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

local function deleteLastLine()
    table.remove(lines, #lines)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    for i, line in ipairs(lines) do
        monitor.setCursorPos(1, i)
        monitor.write(line)
    end
end

printToMonitor("[x] Loading main.lua")

printToMonitor("[ ] Finding recipe handlers")


local recipe_handler_folder = fs.combine(shell.getRunningProgram(), "../recipe_handlers")

if not fs.exists(recipe_handler_folder) or not fs.isDir(recipe_handler_folder) then
    deleteLastLine()
    printToMonitor("[x] No recipe handlers found")
    return
end

local recipe_handlers = {}

local files = fs.list(recipe_handler_folder)

for _, file in ipairs(files) do
    local path = fs.combine(recipe_handler_folder, file)
    if fs.isDir(path) then
        printToMonitor("[ ] Loading recipe handler " .. file)
        local handler = dofile(fs.combine(path, "handler.lua"))
        recipe_handlers[file] = handler
        deleteLastLine()
        printToMonitor("[x] Loaded recipe handler " .. file)
    end
end

printToMonitor("[x] Found " .. #files .. " recipe handlers")

printToMonitor("[ ] Finding drives with recipes")

local num_drives = 0

local drives = peripheral.find("drive", function(_, object)
    if not object.hasData() then
        return false
    end
    num_drives = num_drives + 1
    return true
end)

deleteLastLine()

if not drives then
    printToMonitor("[x] No drives found with recipes")
else
    printToMonitor("[x] Found " .. num_drives .. " drives with recipes")
end
