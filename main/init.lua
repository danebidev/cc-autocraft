-- Setup {{{
Root = fs.combine(shell.getRunningProgram(), "../../")
local lib = dofile(fs.combine(Root, "lib.lua"))

local monitor = peripheral.find("monitor") --[[@as ccTweaked.peripherals.Monitor]]

if not monitor then
    print("No monitor found")
end

monitor.clear()
monitor.setCursorPos(1, 1)

Lines = {}


lib.printToMonitor("[ ] Loading main.lua", monitor)
-- }}}

-- Recipe handlers {{{
local function findRecipeHandlers()
    lib.printToMonitor("[ ] Finding recipe handlers", monitor)

    local handlers = {}
    local num_handlers = 0

    local files = fs.list(fs.combine(Root, "recipe_handlers"))

    for _, file in ipairs(files) do
        local name = file:match("(.+).lua")
        if name then
            num_handlers = num_handlers + 1
            lib.printToMonitor('    Found handler "' .. name .. '"', monitor)
            handlers[name] = dofile(fs.combine(Root, "recipe_handlers", file))
        end
    end

    lib.printToMonitor("[x] Found " .. num_handlers .. " recipe handlers", monitor)

    return handlers
end

-- }}}

-- Drives {{{
local function findDrivesWithRecipes()
    lib.printToMonitor("[ ] Finding drives with recipes", monitor)

    local num_drives = 0

    local drives = {
        peripheral.find("drive", function(name, drive)
            if not drive.hasData() or not fs.exists(fs.combine(drive.getMountPath(), "recipes")) then
                return false
            end

            lib.printToMonitor("    Found drive " .. name .. " with recipes", monitor)
            num_drives = num_drives + 1
            return true
        end)
    }

    if not drives then
        lib.printToMonitor("[x] No drives found with recipes", monitor)
        return {}
    else
        lib.printToMonitor("[x] Found " .. num_drives .. " drives with recipes", monitor)
        return drives
    end
end
-- }}}

-- Recipes {{{
-- This function is horrible but ok
local function loadRecipes()
    lib.printToMonitor("[ ] Loading recipes", monitor)

    local recipes = {}
    local num_recipes = 0
    local drives = findDrivesWithRecipes()

    -- Load from all drives that have a recipes directory
    for _, drive in ipairs(drives) do
        --- @cast drive ccTweaked.peripherals.Drive
        lib.printToMonitor("    Loading recipes from drive " .. drive.getDiskID(), monitor)
        local path = fs.combine(drive.getMountPath(), "recipes")
        local handlers = fs.list(path)

        -- Load all handlers from each drive
        for _, handler in ipairs(handlers) do
            if fs.isDir(fs.combine(path, handler)) then
                local namespaces = fs.list(fs.combine(path, handler))

                -- Load all namespaces for each handler
                for _, namespace in ipairs(namespaces) do
                    if fs.isDir(fs.combine(path, handler, namespace)) then
                        local files = fs.list(fs.combine(path, handler, namespace))

                        -- Load all recipes for each namespace
                        for _, file in ipairs(files) do
                            local name = file:match("(.+).lua")
                            if name then
                                recipes[name] = dofile(fs.combine(path, handler, namespace, file))

                                -- Attaching this data here allows us to avoid writing it in the recipes themselves, saving space
                                recipes[name].name = namespace .. ":" .. name
                                recipes[name].handler = handler
                                num_recipes = num_recipes + 1

                                lib.printToMonitor("    Loaded recipe " .. name, monitor)
                            end
                        end
                    else
                        lib.printToMonitor(
                        "    Skipping non-directory " .. namespace .. " in " .. path .. "/" .. handler, monitor)
                    end
                end
            else
                lib.printToMonitor("    Skipping non-directory " .. handler .. " in " .. path, monitor)
            end
        end
    end

    lib.printToMonitor("[x] Loaded " .. num_recipes .. " recipes", monitor)

    return recipes
end
-- }}}

local crafting_calc = require("crafting_calc")

Data = {}
Data.handlers = findRecipeHandlers()
Data.recipes = loadRecipes()

parallel.waitForAll(require("user_api").run)
