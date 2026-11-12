local args = {...}
local color_theme = tonumber(args[2])
local color_text_theme = tonumber(args[1])

function load_settings_file(path_file_settings)
    local file = fs.open(path_file_settings, "r")
    local data  = file.readAll()
    file.close()
    local data_settings = textutils.unserialise(data) 
    return data_settings
end

function apply()
    if color_theme then term.setBackgroundColor(color_theme) end
    if color_text_theme then term.setTextColor(color_text_theme) end
    term.clear()
    term.setCursorPos(1,1)
end

local settings = load_settings_file("nukos/config_shell/Settings_file.txt")

if color_text_theme == 3 then
    print([[
=======Color chart=======
1     - white
2     - orange
4     - magenta
8     - lightBlue
16    - yellow
32    - lime
64    - pink
128   - gray
256   - lightGray
512   - cyan
1024  - purple
2048  - blue
4096  - brown
8192  - green
16384 - red
32768 - black
=======Command=======
3 - show this menu
5 - reload theme
]])
elseif color_text == 5 then
    if color_theme then term.setBackgroundColor(settings.color_bg_theme) end
    if color_text_theme then term.setTextColor(settings.color_text_theme) end   
    term.clear()
    term.setCursorPos(1,1)
else 
    apply()
end
