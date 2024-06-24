local lib = require("lib")

CalcQueue = List.new()
local craft = {}

local function calc(item, quant)
    local recipe = Data.recipes[item]
    if not recipe then
        lib.printToMonitor("No recipe found for " .. item)
        return
    end

    if not craft[recipe.handler] then
        craft[recipe.handler] = {}
    end

    local to_craft = math.ceil(quant / recipe.qnt)

    if craft[recipe.handler][item] then
        craft[recipe.handler][item] = craft[recipe.handler][item] + to_craft
    else
        craft[recipe.handler][item] = to_craft
    end

    lib.printToMonitor("Crafting " .. to_craft .. " x " .. recipe.qnt .. " of " .. item .. " (" .. recipe.handler .. ")")

    for _, it in ipairs(recipe.rc) do
        if not it == "" then
            if not string.find(it, ":") then
                List.pushright(CalcQueue, { name = recipe.namespace .. ":" .. it, quant = to_craft })
            else
                List.pushright(CalcQueue, { name = it, quant = to_craft })
            end
        end
    end
end

local function start()
    while true do
        local item = List.popleft(CalcQueue)
        -- Serialize CalcQueue and print it
        lib.printToMonitor("CalcQueue: " .. textutils.serialize(CalcQueue))
        if item then
            calc(item.name, item.quant)
        end

        os.sleep(0.5)
    end
end

return { start = start }
