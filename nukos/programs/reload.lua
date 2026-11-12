local args = {...}
local sleep_time = tonumber(args[1])

if sleep_time == 0 or " " then 
    shell.run("reboot")
else 
    print("It will reboot in "..sleep_time)
    sleep(sleep_time)
    shell.run("reboot")
end
