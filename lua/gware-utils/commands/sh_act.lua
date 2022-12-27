--[[
    Command: /akt <message>
    Description: Prints a text in global chat with a [Akt] prefix
    Example Command: /akt schaltet den Reaktor aus.
    Example Chat: [Akt] 501st CMD Menschlich schaltet den Reaktor aus.
]]

local command = gWare.Utils.RegisterCommand({
    prefix = "act",
    triggers = {"akt", "act"},
})

command:OnServerSide(function(ply, message)
    if gWare.Utils.IsMessageEmpty(message, ply) then return "" end

    net.Start(command.netMsg)
        net.WriteString(message)
        net.WriteEntity(ply)
    net.Broadcast()
end)

command:OnReceive(function()
    local receivedMessage = net.ReadString()
    local ply = net.ReadEntity()

    gWare.Utils.PrintCommand(command:GetPrefix(),
        ply:Nick() .. " ", receivedMessage
    )
end)
