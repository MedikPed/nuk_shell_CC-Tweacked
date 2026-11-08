local free = fs.getFreeSpace("/")
local total = fs.getCapacity("/")
print("Capacity:   " .. total .. " bytes")
print("Free space: " .. free .. " bytes")
