local L = gWare.Utils.Lang.GetPhrase

--[[
    Replaces both '/' and '!' including the
    command name with empty string.
    Returns: string
]]
function string.ReplacePrefix(str, command)
    return string.sub(str, #command + 3) -- prefix, space, AFTER the letter
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

--[[
    WIP: Command Handler Step 1
]]--
function string.isCommand(str, prefix)
    if not (str[1] == "!" or str[1] == "/") then return false end

    local spacePos = string.find(str, " ")
    local cmdName, message

    if not spacePos then
        message = ""
        cmdName = string.sub(str, 2)
    else 
        cmdName = string.sub(str, 2, spacePos)
        message = string.sub(str, spacePos + 1)
    end

    return cmdName:lower(), message
end

--[[
    Replaces 1 with true, and rest with false. Needed for SQL (fuck u)
    Returns: boolean
]]
function gWare.Utils.IntToBool(int)
    if int == 1 then
        return true
    else
        return false
    end
end

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
    Check if the player can access a specific gWare Module
    Works with SAM & CAMI
    Returns: boolean
]]--
function gWare.Utils.HasPermission(name, ply)
    if CLIENT then
        ply = LocalPlayer()
    end

    if SAM_LOADED then
        return ply:HasPermission(name)
    else
        return CAMI.PlayerHasAccess(ply, name)
    end
end

--[[
    Converts a string in to a vector data (fuck u sqllite)
    Returns: Vector
]]
function gWare.Utils.StringToVector(str)
    local args = string.Split(str, " ")

    x = args[1]
    y = args[2]
    z = args[3]

    return Vector(x, y, z)
end

--[[
    Returns the job index of a DarkRP team by its command (fuck u darkrp)
    Returns: Integer
]]
function gWare.Utils.GetJobIndexByCommand(command)
    for index, jobData in ipairs(RPExtraTeams) do
        if jobData.command != command then continue end

        return index
    end
end

--[[
    Checks if a string is empty and throws an error message if it is
]]--
function gWare.Utils.IsMessageEmpty(str, ply)
    ply = ply or LocalPlayer()

    if (not str) or (str:Trim() == "") then
        VoidLib.Notify(ply, L"notify_empty_name", L"notify_empty_desc", VoidUI.Colors.Red, 10)
        return true
    end

    return false
end