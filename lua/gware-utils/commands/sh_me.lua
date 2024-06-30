--[[
    Command: /me <message>
    Description: Prints a out-of-character message within a small radius
    Example Command: /me Lol der ist eingach umgefallen xD
    Example Chat: [me] 501st CMD Menschlich: Lol der ist einfach umgefallen xD
]]

local command = gWare.Utils.RegisterCommand({
    prefix = "me",
    triggers = {"me"},
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
    net.Send(receivers)
end)

command:OnReceive(function()
    local message = net.ReadString()
    local plyName = net.ReadString()

    local color = team.GetColor(ply:Team())

    chat.AddText(color, plyName .. " " .. message, color_white)
end)
