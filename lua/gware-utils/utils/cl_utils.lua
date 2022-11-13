--[[
    Used to get the prefix for a command including colors
    Returns: varargs (colored string)
]]--
function gWare.Utils.GetCommandPrefix(name)
    local colors = gWare.Utils.Colors
    local commandColor = colors.Commands[name] or colors.Commands["default"]
    return {colors.Brackets, "[", commandColor, name:upper(), colors.Brackets, "] ", color_white}
end

function gWare.Utils.Print(prefix, ...)
    local text = {...}

    local prefixTbl = gWare.Utils.GetCommandPrefix(prefix)
    local combinedTable = table.Add(prefixTbl, text)

    chat.AddText(unpack(combinedTable))
end
