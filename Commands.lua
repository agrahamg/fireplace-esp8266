local commands = {}
commands["prefix"] = "01111000100101111"

local function toTime(body, callback)
    local command = {}
    local i = 1
    local time = 0
    body:gsub(".", function(c)
        if c ~= ";" then

            if c == "1" then
                command[i] = 600
                command[i+1] = 300
            else
                command[i] = 300
                command[i+1] = 600
            end
            i = i+2
        else
            -- add delay to the last command
            command[#command] = 31000
            callback(command)
        end
    end)
end


local function generate(value)
    local tmp = {}
    tmp["recompute"] = true
    tmp["stringValue"] = value 
    return tmp    
end

function commands.get (value, time, callback)
    
    local table = {}
    local values = {}
    table['time'] = time
    table['values'] = values
    
    local command = commands[value]

    if command == nil then 
        return error('thats not real') 
    end
    
    local complete = 0
    

    local function checkForDone()
        if complete == #command then
            callback(table)
        end
    end

    for i,v in ipairs(command) do 
        print(i)
        print(v)
        if v['recompute'] then 
            print('generating')
            toTime(commands['prefix'] .. v['stringValue'] .. ";", function (value)
               v['value'] =  value
               v['recompute'] = false
               values[i] = value
               complete = complete + 1
               checkForDone()
            end)
        else
            values[i] = v['value']
            complete = complete + 1
            checkForDone()
        end
    end
end


commands["on"] = {generate("110011")}
commands["off"] = {generate("110111")}
commands["down"] = {generate("000000")}
commands["up"] = {generate("111011")}
commands["full_down"] = {commands["down"][1],generate("101001")}
commands["full_up"] = {commands["up"][1],generate("101000")}

return commands