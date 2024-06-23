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

printToMonitor("[x] Loading main.lua")

printToMonitor("[ ] Finding drives with recipes")

local drives = peripheral.find("drive", function(name, object)
    return object.hasData()
end)

if not drives then
    printToMonitor("[x] No drives found with recipes")
    return
end

printToMonitor("[x] Found " .. #drives .. " drives with recipes")
