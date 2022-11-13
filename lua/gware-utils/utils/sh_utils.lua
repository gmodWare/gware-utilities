--[[
    Finds a player by a part of its name
    Returns: player | nil
]]
function gWare.Utils.GetPlayerByNamePart(namePart)
    for _, ply in ipairs(player.GetAll()) do
        if ply:Name():lower():find(namePart) then
            return ply
        end
    end

    return nil
end

--[[
    Replaces both '/' and '!' including the
    command name with empty string.
    Returns: string
]]
function string.ReplacePrefix(str, command)
    local prefix1 = "!" .. command
    local prefix2 = "/" .. command

    local temp = string.Replace(str, prefix1)
    
    return string.Replace(temp, prefix2)
end

--[[
    Checks multiple arguments with 'StartWith'
    Returns: boolean
]]
function string.StartWithAny(str, ...)
    local args = {...}

    for _, v in ipairs(args) do
        if string.StartWith(str, v) then 
            return true 
        end
    end

    return false
end
