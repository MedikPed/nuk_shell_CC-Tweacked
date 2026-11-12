
local fetch = [[                                  
 ###   ##  ##   ### 
 ###   ##  ##   ##  
 ###:  ##  ## :##:  
 ####  ##  ##.##:   
 ##:#: ##  #####    
 ## ## ##  #####    
 ## ## ##  #####:   
 ## :#:##  ##::##   
 ##  ####  ##  ##   
 ##  :###  ##  :##  
 ##   ###  ##   ##  
 ##   ###  ##   :## 
 Custom shell
                                                                                                      
]]
 
for line in string.gmatch(fetch, "[^\r\n]+") do
    print(line)
    sleep(0.05)
end

shell.run("drive.lua")
shell.run("time")
