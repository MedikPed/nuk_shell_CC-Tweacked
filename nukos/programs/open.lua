local args = {...}
local terr = args[1]

if terr == "" or nil then
    print("Usage: open <file>")
else
    shell.run("edit",terr)
end
