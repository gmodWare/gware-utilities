--[[
    Command: /ooc <message>
    Command2: // <message>
    Description: Prints a global out-of-character message
    Example Command: /ooc Lol der ist eingach umgefallen xD
    Example Chat: [LOOC] 501st CMD Menschlich: Lol der ist eingach umgefallen xD
]]

local command = gWare.Utils.RegisterCommand({
    prefix = "ooc",
    triggers = {"ooc", "/"},
})

command:OnServerSide(function(sender, message)
    if gWare.Utils.IsMessageEmpty(message, sender) then return "" end

    net.Start(command:GetNetID())
        net.WriteString(message)
        net.WriteString(sender:Name())
        net.WriteTeam(sender)
    net.Broadcast()
end)

command:OnReceive(function()
    local message = net.ReadString()
    local senderName = net.ReadString()
    local senderColor = team.GetColor(net.ReadTeam())

    gWare.Utils.PrintCommand(command:GetPrefix(),
        senderColor, senderName,  gWare.Utils.Colors.Brackets, " » ", color_white, message
    )
end)
