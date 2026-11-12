print("---device---")

for _, name in ipairs(peripheral.getNames()) do
    print(name .. " -> " .. peripheral.getType(name))
end
