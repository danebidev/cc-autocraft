local root = fs.combine(shell.getRunningProgram(), "../")
local lib = require("lib")

peripheral.find("modem", rednet.open)

while true do
	print(">> ")
	local command = read()

	if command == "exit" then
		break
	end

	rednet.broadcast(command)

	local _, message = rednet.receive()
	print(message)
end
