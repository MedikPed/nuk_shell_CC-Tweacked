local args = {...}
local filename  = args[1]

if not filename then
    print("Usage: cat <filename>")
    return
end

if not fs.exists(filename) then
    print("Error: File '" .. filename .. "' not found.")
    return
end

if fs.isDir(filename) then
    print("Error: '" .. filename .. "' is a folder, not a file.")
    return
end


local file = fs.open(filename, "r")
if file then
    local content = file.readAll()
    file.close()

    print(content)
else
    print("Failed to open the file for reading.")
end
