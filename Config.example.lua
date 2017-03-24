--copy this file to Config.lua
local table = {}

table["password"] = "secret"
function table.allow (payload)
    return false
end

return table
