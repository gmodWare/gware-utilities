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
    if message:Trim() == "" then return end

    net.Start(command.netMsg)
        net.WriteString(message)
        net.WriteEntity(ply)
    net.Broadcast()
end)

command:OnReceive(function()
    local receivedMessage = net.ReadString()
    local ply = net.ReadEntity()

    gWare.Utils.PrintCommand("mact",
        ply:Nick() .. " ", receivedMessage
    )
end)
