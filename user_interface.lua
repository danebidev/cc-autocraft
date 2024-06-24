local lib = dofile(fs.combine(Root, "lib.lua"))

peripheral.find("modem", rednet.open)

while true do
    print(">> ")
    local command = read()

    if command == "exit" then
        break
    end

    rednet.broadcast(command)
end
