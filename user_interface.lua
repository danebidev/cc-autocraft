-- local root = fs.combine(shell.getRunningProgram(), "../")
-- local lib = require("lib")

peripheral.find("modem", rednet.open)

while true do
	io.write(">> ")
	local command = read()

	local id = rednet.lookup("autocrafting", "main")

	if not id then
		print("No server found")
		break
	end

	if command == "exit" then
		break
	end

	rednet.send(id, command, "autocrafting")

	local _, message = rednet.receive("autocrafting")
	print(message)
end
