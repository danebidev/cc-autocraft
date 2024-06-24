local lib = require("lib")

local function run()
	lib.printToMonitor("[x] Started user API")
	peripheral.find("modem", rednet.open)

	rednet.host("autocrafting", "main")

	while true do
		local sender, message = rednet.receive("autocrafting")

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

return { run = run }
