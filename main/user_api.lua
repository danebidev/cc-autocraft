local lib = dofile(fs.combine(Root, "lib.lua"))

local function run()
    peripheral.find("modem", rednet.open)

    while true do
        local sender, message = rednet.receive("recipe")

        local command = lib.split(message, " ")

        if command[1] == "get_raw" then
            if not Data.recipes[command[2]] then
                rednet.send(sender, "Recipe not found")
            else
                rednet.send(sender, textutils.serialize(Data.recipes[command[2]]))
            end
        end
    end
end

return { run }
