--[[
    Command: /makt <message>
    Description: Prints a text in global chat with a [Akt] prefix
    Example Command: /makt schaltet den Reaktor aus.
    Example Chat: [Medic-Akt] 501st CMD Menschlich schaltet den Reaktor aus.
]]

local command = gWare.Utils.RegisterCommand({
    prefix = "mact",
    triggers = {"makt", "mact"},
})

command:OnServerSide(function(ply, message)
    if gWare.Utils.IsMessageEmpty(message, ply) then return "" end

    net.Start(command:GetNetID())
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
