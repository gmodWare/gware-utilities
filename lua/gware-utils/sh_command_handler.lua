GWARE_COMMANDS = {}

local COMMAND_CLASS = {}
COMMAND_CLASS.__index = COMMAND_CLASS

AccessorFunc(COMMAND_CLASS, "active", "Active", FORCE_BOOL)
AccessorFunc(COMMAND_CLASS, "prefix", "Prefix", FORCE_STRING) -- upcoming feature


/* 
    dataTbl:
    - prefix: string
    - triggers: table<string>
*/
function COMMAND_CLASS:Create(dataTbl)
    local newObject = setmetatable({}, COMMAND_CLASS)
    newObject.prefix = dataTbl.prefix -- used for color & translation
    newObject.triggers = dataTbl.triggers -- how to run the chat command (e.g. !help, !h, !commands)
    newObject.netMsg = "gWare.Commands." .. dataTbl.prefix
    newObject.active = true

    for _, trigger in ipairs(dataTbl.triggers) do
        GWARE_COMMANDS[trigger] = newObject
    end

    return newObject
end

function COMMAND_CLASS:OnServerSide(callback)
    if CLIENT then return end

    util.AddNetworkString(self.netMsg)
    self.OnServerSideCalled = callback
end

function COMMAND_CLASS:OnReceive(callback)
    if SERVER then return end

    net.Receive(self.netMsg, callback)
end

function COMMAND_CLASS:Run(sender, msg)
    self.OnServerSideCalled(sender, msg)
end

function COMMAND_CLASS:GetNetID()
    return self.netMsg
end


-- public constructor
function gWare.Utils.RegisterCommand(dataTbl)
    return COMMAND_CLASS:Create(dataTbl)
end

function gWare.Utils.GetCommand(text)
    if text[1] != "/" then return nil end

    local cmd = text:sub(2)
    local msg

    local spacePos = text:find(" ")
    if spacePos then
        cmd = text:sub(2, spacePos - 1)
        msg = text:sub(spacePos + 1)
    end

    local cmdObj = GWARE_COMMANDS[cmd]

    return cmdObj, msg
end

hook.Add("PlayerSay", "gWare.Commands.CommandHandler", function(sender, text)
    local cmdObj, msg = gWare.Utils.GetCommand(text)

    if not cmdObj then return end
    if not cmdObj:GetActive() then return end

    cmdObj:Run(sender, msg)

    return ""
end)
