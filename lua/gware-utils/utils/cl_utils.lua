local L = gWare.Utils.Lang.GetPhrase

--[[
    Used to get the prefix for a command including colors
    Returns: varargs (colored string)
]]--
function gWare.Utils.GetCommandPrefix(key)
    print("trying to get " .. key)
    local colors = gWare.Utils.Colors
    local commandColor = colors.Commands[key] or colors.Commands["default"]
    local commandPrefix = L("command_" .. key)
    return {colors.Brackets, "[", commandColor, commandPrefix, colors.Brackets, "] ", color_white}
end

--[[
    Prints a colored message with the given prefix followed
    by the varargs given.
    
    Example code usage: gWare.Utils.PrintCommand("akt", color_white, ply:Nick(), " ", message)
    Example chat usage: '/akt isst eine Banane'
    Chat: '[AKT] Menschlich isst eine Banane'
]]
function gWare.Utils.PrintCommand(commandName, ...)
    local text = {...}

    local prefixTbl = gWare.Utils.GetCommandPrefix(commandName)
    local combinedTable = table.Add(prefixTbl, text)

    chat.AddText(unpack(combinedTable))
end

hook.Add("InitPostEntity", "gWare.Utils.InitPostEntity", function()
    function g_VoicePanelList:OnChildAdded(child)
        if not gWare.Utils.GetSettingValue("voice-panels") then return end
        
        if (child:IsValid()) then
            child:Remove()
        end
    end
end)