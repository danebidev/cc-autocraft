-- local root = fs.combine(shell.getRunningProgram(), "../")
-- local lib = require("lib")

peripheral.find("modem", rednet.open)

while true do
	io.write(">> ")
	local command = read()

	if command == "exit" then
		break
	end

	rednet.broadcast(command, "auto_crafting")

	local _, message = rednet.receive()
	print(message)
end
