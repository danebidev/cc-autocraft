local monitor = peripheral.find("monitor")

if monitor then
    monitor.setTextScale(0.5)
    monitor.clear()
    monitor.setCursorPos(1, 1)
    monitor.write("Hello, World!")
else
    print("No monitor found")
end
