local args = {...}
local filename = args[1]

local vari = {}
local arrays = {}
local stack_for = {}
local stack_while = {}
local stack_gosub = {}
local active_file = nil

local builtin_env = {
    RND = function(n)
        if n and n > 1 then return math.random(1, math.floor(n)) end
        return math.random()
    end,
    INT = math.floor,
    ABS = math.abs,
    SQR = math.sqrt,
    SIN = math.sin,
    COS = math.cos,
    LEN = function(s) return #tostring(s) end,
    VAL = function(s) return tonumber(s) or 0 end,
    STR = tostring,
    LEFT = function(s, n) return tostring(s):sub(1, n) end,
    RIGHT = function(s, n) return tostring(s):sub(-n) end,
    MID = function(s, start, len)
        s = tostring(s)
        if len then return s:sub(start, start + len - 1) end
        return s:sub(start)
    end,
    CHR = string.char,
    ASC = string.byte
}

local function eval(expr)
    if not expr then return nil end
    expr = expr:match("^%s*(.-)%s*$")
    
    local strings = {}
    local parsed = expr:gsub('(".-")', function(s)
        table.insert(strings, s)
        return "__STR" .. #strings .. "__"
    end)
    
    parsed = parsed:gsub("([%a_][%w_]*)%s*%((.-)%)", function(name, idx_expr)
        if builtin_env[name] then
            return name .. "(" .. idx_expr .. ")"
        end
        return string.format('_ARR_GET(%q, %s)', name, idx_expr)
    end)
    
    parsed = parsed:gsub("([%a_][%w_]*)", function(word)
        if word:match("^__STR%d+__$") or word == "_ARR_GET" then return word end
        if builtin_env[word] then return word end
        if word == "true" or word == "false" or word == "nil" or word == "and" or word == "or" or word == "not" then
            return word
        end
        if vari[word] ~= nil then
            if type(vari[word]) == "string" then
                return string.format("%q", vari[word])
            else
                return tostring(vari[word])
            end
        end
        return "0"
    end)
    
    parsed = parsed:gsub("__STR(%d+)__", function(idx)
        return strings[tonumber(idx)]
    end)
    
    local env = setmetatable({
        _ARR_GET = function(name, idx)
            if arrays[name] and arrays[name][idx] ~= nil then
                return arrays[name][idx]
            end
            return 0
        end
    }, { __index = builtin_env })
    
    local fn, err = load("return " .. parsed, "eval", "t", env)
    if fn then
        local ok, res = pcall(fn)
        if ok then return res end
    end
    return nil
end

local function find_line_index(lines, target_num)
    for i, num in ipairs(lines) do
        if num == target_num then return i end
    end
    return nil
end

local function basic_run(filename)
    local path = shell.resolve(filename)
    local file = fs.open(path, "r")
    
    if not file then 
        print("not found: " .. tostring(path))
        return
    end
    
    local program = {}
    while true do
        local line = file.readLine()
        if not line then break end
        local number, command = line:match("^(%d+)%s+(.+)$")
        if number then
            program[tonumber(number)] = command:match("^%s*(.-)%s*$")
        end
    end
    file.close()
    
    local lines = {} 
    for number in pairs(program) do
        table.insert(lines, number)
    end
    table.sort(lines)
    
    print("BASIC 0.4")
    print("RUNNING..")
    print("")
    
    local pc = 1
    
    while pc <= #lines do
        local line_num = lines[pc]
        local command = program[line_num]
        local jumped = false

        if command:match("^REM%s") or command == "REM" or command:match("^'") then

        elseif command == "CLS" then
            term.clear()
            term.setCursorPos(1, 1)

        elseif command:match("^LOCATE%s+(.+)%s*,%s*(.+)$") then
            local x_expr, y_expr = command:match("^LOCATE%s+(.+)%s*,%s*(.+)$")
            local x, y = eval(x_expr), eval(y_expr)
            if type(x) == "number" and type(y) == "number" then
                term.setCursorPos(math.floor(x), math.floor(y))
            end

        elseif command:match("^COLOR%s+(.+)$") then
            local col_name = eval(command:match("^COLOR%s+(.+)$"))
            if type(col_name) == "string" and colors[col_name] then
                term.setTextColor(colors[col_name])
            elseif type(col_name) == "number" then
                term.setTextColor(col_name)
            end

        elseif command:match("^BGCOLOR%s+(.+)$") then
            local col_name = eval(command:match("^BGCOLOR%s+(.+)$"))
            if type(col_name) == "string" and colors[col_name] then
                term.setBackgroundColor(colors[col_name])
            elseif type(col_name) == "number" then
                term.setBackgroundColor(col_name)
            end

        elseif command == "BEEP" then
            write("\a")

        elseif command == "END" or command == "STOP" then
            break

        elseif command:match("^SLEEP%s+(.+)$") then
            local sec = eval(command:match("^SLEEP%s+(.+)$"))
            if type(sec) == "number" then sleep(sec) end

        elseif command == "PRINT" then
            print("")

        elseif command:match("^PRINT%s+(.+);$") then
            local expr = command:match("^PRINT%s+(.+);$")
            write(tostring(eval(expr)))

        elseif command:match("^PRINT%s+(.+)$") then
            local expr = command:match("^PRINT%s+(.+)$")
            print(tostring(eval(expr)))

        elseif command:match("^INPUT%s+(.+)$") then
            local rest = command:match("^INPUT%s+(.+)$")
            local prompt, var_name = rest:match('^"(.-)"%s*,%s*([%a_][%w_]*)$')
            if not var_name then
                var_name = rest:match("^([%a_][%w_]*)$")
            end
            if var_name then
                if prompt then write(prompt) else write("? ") end
                local inp = read()
                vari[var_name] = tonumber(inp) or inp
            else
                print("?SYNTAX ERROR IN " .. line_num)
                break
            end

        elseif command:match("^INKEY%s+([%a_][%w_]*)$") then
            local var_name = command:match("^INKEY%s+([%a_][%w_]*)$")
            local _, key = os.pullEvent("key")
            vari[var_name] = keys.getName(key) or ""

        elseif command:match("^DIM%s+([%a_][%w_]*)%s*%((.+)%)$") then
            local arr_name, size_expr = command:match("^DIM%s+([%a_][%w_]*)%s*%((.+)%)$")
            local size = tonumber(eval(size_expr)) or 10
            arrays[arr_name] = {}
            for i = 0, size do arrays[arr_name][i] = 0 end

        elseif command:match("^([%a_][%w_]*)%s*%((.+)%)%s*=%s*(.+)$") then
            local arr_name, idx_expr, val_expr = command:match("^([%a_][%w_]*)%s*%((.+)%)%s*=%s*(.+)$")
            local idx = eval(idx_expr)
            if not arrays[arr_name] then arrays[arr_name] = {} end
            arrays[arr_name][idx] = eval(val_expr)

        elseif command:match("^LET%s+([%a_][%w_]*)%s*=%s*(.+)$") or command:match("^([%a_][%w_]*)%s*=%s*(.+)$") then
            local var_name, expr = command:match("^LET%s+([%a_][%w_]*)%s*=%s*(.+)$")
            if not var_name then
                var_name, expr = command:match("^([%a_][%w_]*)%s*=%s*(.+)$")
            end
            vari[var_name] = eval(expr)

        elseif command:match("^GOTO%s+(%d+)$") then
            local target = tonumber(command:match("^GOTO%s+(%d+)$"))
            local idx = find_line_index(lines, target)
            if idx then
                pc = idx
                jumped = true
            else
                print("?UNDEFINED LINE " .. target .. " IN " .. line_num)
                break
            end

        elseif command:match("^GOSUB%s+(%d+)$") then
            local target = tonumber(command:match("^GOSUB%s+(%d+)$"))
            local idx = find_line_index(lines, target)
            if idx then
                table.insert(stack_gosub, pc + 1)
                pc = idx
                jumped = true
            else
                print("?UNDEFINED LINE " .. target .. " IN " .. line_num)
                break
            end

        elseif command == "RETURN" then
            local ret_idx = table.remove(stack_gosub)
            if ret_idx then
                pc = ret_idx
                jumped = true
            else
                print("?RETURN WITHOUT GOSUB IN " .. line_num)
                break
            end

        elseif command:match("^IF%s+(.+)%s+THEN%s+(%d+)(.*)$") then
            local cond, then_line, else_part = command:match("^IF%s+(.+)%s+THEN%s+(%d+)(.*)$")
            local else_line = else_part:match("^%s+ELSE%s+(%d+)$")
            
            local target = nil
            if eval(cond) then
                target = tonumber(then_line)
            elseif else_line then
                target = tonumber(else_line)
            end
            
            if target then
                local idx = find_line_index(lines, target)
                if idx then
                    pc = idx
                    jumped = true
                else
                    print("?UNDEFINED LINE " .. target .. " IN " .. line_num)
                    break
                end
            end

        elseif command:match("^FOR%s+([%a_][%w_]*)%s*=%s*(.+)%s+TO%s+(.+)$") then
            local var_name, start_expr, rest = command:match("^FOR%s+([%a_][%w_]*)%s*=%s*(.+)%s+TO%s+(.+)$")
            local end_expr, step_expr = rest:match("^(.+)%s+STEP%s+(.+)$")
            if not end_expr then
                end_expr = rest
                step_expr = "1"
            end
            vari[var_name] = eval(start_expr)
            table.insert(stack_for, {
                var = var_name,
                limit = eval(end_expr),
                step = eval(step_expr) or 1,
                line_idx = pc
            })

        elseif command == "NEXT" or command:match("^NEXT%s+([%a_][%w_]*)$") then
            local loop_data = stack_for[#stack_for]
            if loop_data then
                vari[loop_data.var] = vari[loop_data.var] + loop_data.step
                local cond = false
                if loop_data.step >= 0 then
                    cond = vari[loop_data.var] <= loop_data.limit
                else
                    cond = vari[loop_data.var] >= loop_data.limit
                end
                
                if cond then
                    pc = loop_data.line_idx + 1
                    jumped = true
                else
                    table.remove(stack_for)
                end
            else
                print("?NEXT WITHOUT FOR IN " .. line_num)
                break
            end

        elseif command:match("^WHILE%s+(.+)$") then
            local cond = command:match("^WHILE%s+(.+)$")
            if eval(cond) then
                table.insert(stack_while, { cond = cond, line_idx = pc })
            else
                local depth = 1
                while pc < #lines and depth > 0 do
                    pc = pc + 1
                    local next_cmd = program[lines[pc]]
                    if next_cmd:match("^WHILE%s+") then depth = depth + 1 end
                    if next_cmd == "WEND" then depth = depth - 1 end
                end
            end

        elseif command == "WEND" then
            local loop_data = stack_while[#stack_while]
            if loop_data then
                if eval(loop_data.cond) then
                    pc = loop_data.line_idx + 1
                    jumped = true
                else
                    table.remove(stack_while)
                end
            else
                print("?WEND WITHOUT WHILE IN " .. line_num)
                break
            end

        elseif command:match("^RUN%s+(.+)$") then
            local cmd_str = eval(command:match("^RUN%s+(.+)$"))
            if type(cmd_str) == "string" then
                shell.run(cmd_str)
            end

        elseif command:match("^CHAIN%s+(.+)$") then
            local next_file = eval(command:match("^CHAIN%s+(.+)$"))
            if type(next_file) == "string" then
                basic_run(next_file)
                break
            end

        elseif command:match("^KILL%s+(.+)$") then
            local target_file = eval(command:match("^KILL%s+(.+)$"))
            if type(target_file) == "string" then
                local full_path = shell.resolve(target_file)
                if fs.exists(full_path) then fs.delete(full_path) end
            end

        elseif command:match("^OPEN%s+(.+)%s*,%s*(.+)$") then
            local file_expr, mode_expr = command:match("^OPEN%s+(.+)%s*,%s*(.+)$")
            local fname, fmode = eval(file_expr), eval(mode_expr)
            if type(fname) == "string" and type(fmode) == "string" then
                if active_file then active_file.close() end
                active_file = fs.open(shell.resolve(fname), fmode)
            end

        elseif command:match("^FWRITE%s+(.+)$") then
            local text = eval(command:match("^FWRITE%s+(.+)$"))
            if active_file then
                active_file.writeLine(tostring(text))
            end

        elseif command:match("^FREAD%s+([%a_][%w_]*)$") then
            local var_name = command:match("^FREAD%s+([%a_][%w_]*)$")
            if active_file then
                local line = active_file.readLine()
                vari[var_name] = tonumber(line) or line or ""
            end

        elseif command == "CLOSE" then
            if active_file then
                active_file.close()
                active_file = nil
            end

        else
            print("?SYNTAX ERROR IN " .. line_num)
            break
        end
        
        if not jumped then
            pc = pc + 1
        end
    end
    
    if active_file then
        active_file.close()
        active_file = nil
    end
end

if filename then
    basic_run(filename)
else
    print("Usage: basic <file>")
end
