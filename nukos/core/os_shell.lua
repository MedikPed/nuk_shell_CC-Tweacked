term.clear()
term.setCursorPos(1,1)

shell.setPath("/nukos/programs:" .. shell.path())

local intro_file = "nukos/core/intro.txt"

shell.run("cd nukos")

function load_settings_file(path_file_settings)
    local file = fs.open(path_file_settings, "r")
    local data  = file.readAll()
    file.close()
    local data_settings = textutils.unserialise(data) 
    return data_settings
end



function run_settings_program()
    shell.run("basic core/autoran.bas")
    sleep(1)
end


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

function init_animation(settings)

    local boot_messages = {
        "Initializing NUKOS shell modules and mounting low-level kernel drivers...",
        "Starting HAL (Hardware Abstraction Layer)...",
        "ACPI Power Management sync...",
        "Calibrating System Clock & RTC...",
        "Scanning PCIe Bus Enumerator...",
        "Mounting USB Host Controller...",
        "Allocating DMA Memory Controller channels...",
        "Binding Interrupt Request Handler (IRQ)...",
        "Verifying TPM 2.0 Security Enclave...",
        "Seeding Entropy & Random Number Generator...",
        "Connecting to IPC Message Broker...",
        "Loading NVMe Storage Driver...",
        "Mounting Virtual File System (VFS)...",
        "Initializing TCP/IPv6 Network Stack...",
        "Starting DNS Resolver & Cache Daemon...",
        "Validating TLS/SSL Certificates...",
        "Configuring Packet Filter & Firewall Engine...",
        "Initializing Audio DSP & Spatial Mixer...",
        "Mapping HID Input & Telemetry devices...",
        "Starting Bluetooth Low Energy Stack...",
        "Broadcasting Zero-Conf Service Discovery...",
        "Starting System Logger & Crash Reporter...",
        "Initializing Task Scheduler & Thread Pool...",
        "Loading Dynamic Linker & Shared Libraries...",
        "Loading global environment variables and user configurations...",
        "Starting Garbage Collector & Heap Allocator...",
        "Compiling Vulkan Graphics Pipeline & Shaders...",
        "Building Raytracing Acceleration Structure...",
        "Initializing Texture Streaming & Mipmap Cache...",
        "Starting Rigid Body Physics Simulation Engine...",
        "Connecting to Relational SQL Database Cluster...",
        "Warming up In-Memory Key-Value Store...",
        "Loading Neural Network Tensor Runtime weights...",
        "Initializing Natural Language Processing Tokenizer...",
        "Syncing Distributed File & Cloud Storage...",
        "Starting Container Orchestration Daemon...",
        "Preparing WebAssembly Sandbox Environment...",
        "Unlocking Cryptographic Key Vault & HSM...",
        "Starting Real-Time Telemetry & Metrics Aggregator...",
        "Indexing Global Asset & Content Delivery...",
        "Launching NUKOS User Interface Compositor and main terminal process..."
    }

    if settings.inicialization == true then
        term.clear()
        term.setCursorPos(1, 1)
        sleep(0.5)

        for i = 1, #boot_messages do
            write(boot_messages[i] .. " ")
            -- Разная задержка в зависимости от длины сообщения (тяжелые модули грузятся чуть дольше)
            local weight = math.floor(#boot_messages[i] / 15)
            sleep(math.random(2, 6 + weight) / 100)
            print("[ OK ]")
        end

        sleep(0.6)
    end

    term.clear()
    term.setCursorPos(1, 1)
end

function apply_theme(settings)
    local file_apply_theme = "theme.lua"
    local text = settings.theme_text_color
    local bg = settings.theme_bg_color
    shell.run(file_apply_theme,text,bg)
end


function show_table_info_shell()
    term.clear()
    print([[


        ###############################
        #    post-apocalyptic shell   #
        #         version-1.9         #
        #          By nekto           #
        #       OCTOBRT 2026 Y        #
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

function show_intro(settings)
    if settings and settings.write_intro == true then
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
end

local root = true
local word_password = "cedr"

run_settings_program()
local settings = load_settings_file("nukos/config_shell/Settings_file.txt")

init_animation(settings)
show_table_info_shell()
apply_theme(settings)
show_intro(settings)

if settings and settings.open_fetch == true then
    shell.run("programs/fetch.lua")
end


if settings and settings.open_help_menu_with_start == true then
    help_shell()
end

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
                    elseif command == "fg" then
                        print("Not found")
                    else 
                        shell.run(command, args)
                    end
                end
            end
        end
    end
end
