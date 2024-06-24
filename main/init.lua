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

-- Recipes {{{
local function loadRecipes()
    printToMonitor("[ ] Loading recipes")

    local recipes = {}
    local drives = findDrivesWithRecipes()

    for name, drive in pairs(drives) do
        local path = fs.combine(drive.getMountPath(), "recipes")
        local handlers = fs.list(path)

        for _, handler in ipairs(handlers) do
            if not fs.isDir(handler) then
                printToMonitor("    Skipping non-directory " .. handler .. " in " .. path)
                goto continue
            end

            local namespaces = fs.list(fs.combine(path, handler))

            for _, namespace in ipairs(namespaces) do
                if not fs.isDir(namespace) then
                    printToMonitor("    Skipping non-directory " .. namespace .. " in " .. path .. "/" .. handler)
                    goto continue2
                end

                local files = fs.list(fs.combine(path, handler, namespace))

                for _, file in ipairs(files) do
                    local name = file:match("(.+).lua")
                    if name then
                        recipes[name] = dofile(fs.combine(path, handler, namespace, file))
                        recipes[name].name = namespace .. ":" .. name
                        recipes[name].handler = handler
                        printToMonitor("    Loaded recipe " .. name)
                    end
                end

                ::continue2::
            end

            ::continue::
        end
    end

    printToMonitor("[x] Loaded recipes")

    return recipes
end
-- }}}

local crafting_calc = dofile(fs.combine(root, "main/crafting_calc.lua"))

Data = {}
Data.handlers = findRecipeHandlers()
Data.recipes = loadRecipes()

-- Rednet user interface {{{
local function user_interface()
    printToMonitor("[ ] Starting user interface")

    peripheral.find("modem", rednet.open)

    while true do
        local sender, message, protocol = rednet.receive("input")

        printToMonitor("Received recipe request from " .. sender)
    end
end
-- }}}

parallel.waitForAll(user_interface)
