--[[
    Command: /akt <message>
    Description: Prints a text in global chat with a [Akt] prefix
    Example Command: /akt schaltet den Reaktor aus.
    Example Chat: [Akt] 501st CMD Menschlich schaltet den Reaktor aus.
]]

local actCommand = gWare.Utils.RegisterCommand({
    prefix = "act",
    triggers = {"akt", "act"},
})

actCommand:OnServerSide(function(ply, message)
    if message:Trim() == "" then return end

    net.Start(actCommand.netMsg)
        net.WriteString(message)
        net.WriteEntity(ply)
    net.Broadcast()
end)

actCommand:OnReceive(function()
    local receivedMessage = net.ReadString()
    local ply = net.ReadEntity()

    gWare.Utils.PrintCommand("act",
        ply:Nick() .. " ", receivedMessage
    )
end)
