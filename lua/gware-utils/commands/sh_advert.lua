--[[
    Command: /advert <message>
    Description: Prints a text in global chat with a [Advert] prefix
    Example Command: /advert schaltet den Reaktor aus.
    Example Chat: [Advert] Kommt zu Nexus Gaming
]]

local command = gWare.Utils.RegisterCommand({
    prefix = "advert",
    triggers = {"advert"},
})

command:OnServerSide(function(ply, message)
    if not gWare.Utils.GetSettingValue("billboards") then return end

    if gWare.Utils.IsMessageEmpty(message, ply) then return "" end

    net.Start(command:GetNetID())
        net.WriteString(message)
        net.WriteString(ply:Name())
        net.WriteTeam(ply)
    net.Broadcast()
end)

command:OnReceive(function()
    local receivedMessage = net.ReadString()
    local name = net.ReadString
    local playerColor = team.GetColor(net.ReadTeam())

    gWare.Utils.PrintCommand("advert",
        playerColor, name, gWare.Utils.Colors.Brackets, " » ", color_white, receivedMessage
    )
end)
