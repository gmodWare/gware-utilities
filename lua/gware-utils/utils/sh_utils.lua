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
    for k, prefix in ipairs({"!", "/"}) do
        str = string.Replace(str, prefix, "")
    end
    
    return string.Replace(str, command .. " ", "")
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
