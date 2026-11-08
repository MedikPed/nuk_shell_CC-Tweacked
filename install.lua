-- === НАСТРОЙКА РЕПОЗИТОРИЯ ===
local USERNAME = "MedikPed"
local REPO = "nuk_shell_CC-Tweacked"
local BRANCH = "main"

-- Базовый URL для скачивания публичных raw-файлов напрямую с GitHub
local base_url = "https://raw.githubusercontent.com/" .. USERNAME .. "/" .. REPO .. "/" .. BRANCH .. "/"

-- Точный список всех файлов на основе вашей структуры репозитория
local file_list = {
    { remote = "startup.lua",                 local_path = "startup.lua" },
    { remote = "nukos/intro.txt",             local_path = "nukos/intro.txt" },
    { remote = "nukos/os_shell.lua",          local_path = "nukos/os_shell.lua" },
    { remote = "nukos/programs/cat.lua",      local_path = "nukos/programs/cat.lua" },
    { remote = "nukos/programs/df.lua",       local_path = "nukos/programs/df.lua" },
    { remote = "nukos/programs/help_shell.lua", local_path = "nukos/programs/help_shell.lua" }
}

term.clear()
term.setCursorPos(1,1)
print("=================================")
print("     NUKOS SYSTEM INSTALLER      ")
print("=================================")
sleep(0.5)

-- Цикл загрузки файлов напрямую через HTTP API
for i, file in ipairs(file_list) do
    write("[" .. i .. "/" .. #file_list .. "] Downloading: " .. file.local_path .. "... ")
    
    local full_url = base_url .. file.remote
    local response, err = http.get(full_url, { ["Cache-Control"] = "no-cache" })
    
    if response then
        local content = response.readAll()
        response.close()
        
        -- Компьютер сам создаст папки nukos/ и programs/, если их еще нет
        local local_file = fs.open(file.local_path, "w")
        local_file.write(content)
        local_file.close()
        
        print("SUCCESS")
    else
        print("FAIL!")
        print("Error: " .. (err or "Unknown error"))
        return
    end
end

print("=================================")
print("Installation successful!")
print("Rebooting in 3 seconds...")
sleep(3)
os.reboot()
