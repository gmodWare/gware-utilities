GWARE_COMMANDS = {}

local COMMANDS_CLASS = {}
COMMANDS_CLASS.__index == COMMANDS_CLASS

function COMMAND_CLASS:Create(prefix, triggers)
    local newObject = setmetatable({}, COMMANDS_CLASS)
    newObject.prefix = prefix -- used for color & translation
    newObject.triggers = triggers
    newObject.netMsg = "gWare.Commands." .. prefix

    GWARE_COMMANDS[prefix] = newObject

    return newObject
end



-- public constructor
function gWare.Utils.RegisterCommand(dataTbl)
    return COMMAND_CLASS:Create(dataTbl)
end


function gWare.Utils.IsActiveCommand(text)
    if text[1] != "!" or text[1] != "/" then return end

    -- check if command exists & is active
end