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

    recipe = recipe.rc

    for _, item in ipairs(recipe) do
        calc(item, to_craft)
    end
end

local function start()
    while true do
        local item = List.popleft(CalcQueue)
        if item then
            calc(item)
        end

        os.sleep(0.5)
    end
end

return { start = start }
