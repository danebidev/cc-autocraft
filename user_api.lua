local lib = require("lib")

local function run()
    lib.printToMonitor("[x] Started user API")
    peripheral.find("modem", rednet.open)

    rednet.host("autocrafting", "main")

    while true do
        local sender, message = rednet.receive("autocrafting")

        local command = lib.split(message, " ")

        if command[1] == "craft" then
            List.pushright(CalcQueue, { name = command[2], quant = tonumber(command[3]) or 1 })
        end
    end
end

return { run = run }
