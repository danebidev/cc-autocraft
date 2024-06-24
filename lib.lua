local function printToMonitor(text, monitor)
    print(text)

    if not monitor then
        return
    end

    table.insert(Lines, text)

    if #Lines > monitor.getSize() - 1 then
        table.remove(Lines, 1)
    end

    monitor.clear()
    monitor.setCursorPos(1, 1)
    for i, Line in ipairs(Lines) do
        monitor.setCursorPos(1, i)
        monitor.write(line)
    end
end

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return { printToMonitor, split }
