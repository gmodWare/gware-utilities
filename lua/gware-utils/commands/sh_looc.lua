--[[
    Command: /looc <message>
    Description: Prints a out-of-character message within a small radius
    Example Command: /looc Lol der ist eingach umgefallen xD
    Example Chat: [LOOC] 501st CMD Menschlich: Lol der ist einfach umgefallen xD
]]

local command = gWare.Utils.RegisterCommand({
    prefix = "looc",
    triggers = {"looc"},
})

command:OnServerSide(function(sender, message)
    if gWare.Utils.IsMessageEmpty(message, sender) then return "" end

    local receivers = {sender}
    local distSqr = 500 * 500

    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():DistToSqr(sender:GetPos()) > distSqr then continue end

        table.insert(receivers, ply)
    end

    net.Start(command:GetNetID())
        net.WriteString(message)
        net.WriteString(sender:Name())
        net.WriteTeam(sender)
    net.Send(receivers)
end)

command:OnReceive(function()
    local message = net.ReadString()
    local senderName = net.ReadString()
    local senderColor = team.GetColor(net.ReadTeam())

    gWare.Utils.PrintCommand(command:GetPrefix(),
        senderColor, senderName, gWare.Utils.Colors.Brackets, " » ", color_white, message
    )
end)
