term.clear()
term.setCursorPos(1,1)

shell.setPath("/nukos/programs:" .. shell.path())
local intro_file = "nukos/intro.txt"
shell.run("cd nukos")

local stop_word = {
    ["edit startup.lua"] = true;
    ["edit startup"] = true;
    ["edit os_shell.lua"] = true;
    ["edit os_shell"] = true;
    ["startup"] = true;
    ["startup.lua"] = true;
    ["os.shell"] = true;
    ["os_shell.lua"] = true;
    ["rm startup.lua"] = true;
    ["rm os_shell.lua"] = true;
    ["rm os_shell"] = true;
    ["rm -r nukos"] = true
}

function show_table_info_shell()
    print([[


        ###############################
        #    post-apocalyptic shell   #
        #         version-1.9         #
        #          By nekto           #
        #       OCTOBRT 1983 Y        #
        #   ALL WRONGS RESERVED lol   #
        ###############################
    ]])
    sleep(1)
    term.clear()
    term.setCursorPos(1,1)
end

function  help_shell()
    local help_prog = "help_shell.lua"
    shell.run(help_prog)
end

function show_intro()
    if fs.exists(intro_file) then
        local file = fs.open(intro_file,"r")

        for line in file.readLine do
            print(line)
            sleep(0.01)
        end
        file.close()
    else
        print("Not found file  - ".. intro_file)
    end
end

local root = false
local word_password = "cedr"

show_table_info_shell()
show_intro()

while true do
    io.write(">>")
    local inp = read()
    
    inp = inp:match("^%s*(.-)%s*$")

    if inp ~= "" then
        local pref, cmd = inp:match("^(&)%s*(.+)")

        if pref then 
            if cmd == "exit" then
                io.write("Write password:")
                local  passw = read("*")
                if passw == word_password then
                    break
                end
            elseif cmd == "cls" then
                term.clear()
                term.setCursorPos(1,1)
            elseif cmd == "gui" then
                print("In development, coming soon")
            elseif cmd == "help" then
                help_shell()
            elseif cmd == "cat" then
                shell.run(cat)
            end
        else
            if stop_word[inp] and not root then
                print("You do not have root privileges.")
            else
                local command, args = inp:match("^(%S+)%s*(.*)$")
                if command then 
                    if command == "help" then
                        print("Not found")
                    elseif  command == "shell" then
                        print("Not found")
                    else 
                        shell.run(command, args)
                    end
                end
            end
        end
    end
end
