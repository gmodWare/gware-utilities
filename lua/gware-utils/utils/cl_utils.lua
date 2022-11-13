--[[
    Used to get the prefix for a command including colors
    Returns: varargs (colored string)
]]--
function gWare.Utils.GetCommandPrefix(name)
    local colors = gWare.Utils.Colors
    local commandColor = colors.Commands[name] or color.Commands["default"]
    return unpack({colors.Brackets, "[", commandColor, name:upper(), colors.Brackets, "] ", color_white})
end
