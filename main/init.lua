local monitor = peripheral.find("monitor") --[[@as ccTweaked.peripherals.Monitor]]

if not monitor then
    print("No monitor found")
end

monitor.clear()
monitor.setCursorPos(1, 1)

local root = fs.combine(shell.getRunningProgram(), "../../")

local lines = {}

local function printToMonitor(text)
    if not monitor then
        print(text)
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

local function deleteLastLine()
    if not monitor then
        return
    end

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

local handlers = {}

local files = fs.list(fs.combine(root, "recipe_handlers"))

for _, file in ipairs(files) do
    local name = file:match("(.+).lua")
    if name then
        handlers[name] = dofile(fs.combine(root, "recipe_handlers", file))
    end
end

printToMonitor("[x] Found " .. #handlers .. " recipe handlers")

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
