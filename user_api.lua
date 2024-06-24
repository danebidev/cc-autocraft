local lib = require("lib")

local function run()
    lib.printToMonitor("[x] Started user API")
    peripheral.find("modem", rednet.open)

    rednet.host("autocrafting", "main")

    while true do
        local sender, message = rednet.receive("autocrafting")

        local command = lib.split(message, " ")

        if command[1] == "craft" then
            local quant = tonumber(command[3]) or 1
            List.pushright(CalcQueue, { name = command[2], quant = quant })
            rednet.send(sender, "Added " .. quant .. " " .. command[2] .. " to the queue", "autocrafting")
        end
    end
end

return { run = run }
