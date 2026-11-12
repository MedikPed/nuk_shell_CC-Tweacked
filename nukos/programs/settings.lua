local args = {...}
local autostart = tonumber(args[1])
local  Settings_file =  "nukos/config_shell/settings_file.txt"

local def_settings = {
    inicialization = true,
    write_intro = true,
    open_help_menu_with_start = false,
    open_fetch = false,
    theme_text_color =  colors.white,
    theme_bg_color =  colors.black
} 

function check_file()
    if fs.exists(Settings_file) then
        print("check complite!")
    else 
        print("file in "..Settings_file.."not found")
        print("create new file...")
        sleep(0.1)
        local file_path = fs.open(Settings_file,"w")
        file_path.write(textutils.serialize(def_settings))
        file_path.close()
    end
end

function help_list(hlp)
    hlp = [[
    0 - exit
    ]]
    print(hlp) 
end


if autostart == 1 then
    check_file()
else
    help_list()
    while true do
        io.write("&>>")
        local inp = read()
        
        if inp == "" or nil then
            print("Command not found")
        end
        
        if inp == "0" then
            break
        end             
    end
end
