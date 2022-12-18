--[[
    Command: /me <message>
    Description: Prints a out-of-character message within a small radius
    Example Command: /me Lol der ist eingach umgefallen xD
    Example Chat: [me] 501st CMD Menschlich: Lol der ist einfach umgefallen xD
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.Me.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.me", function(sender, text)
        if not text:StartWithAny("/me ") then return end

        local message = text:ReplacePrefix("me")

        if gWare.Utils.IsMessageEmpty(message, sender) then return "" end

        local receivers = {sender}
        local distSqr = 500 * 500

        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(sender:GetPos()) > distSqr then continue end

            table.insert(receivers, ply)
        end

        net.Start("gWare.Commands.Me.ChatMessage")
            net.WriteString(message)
            net.WriteEntity(sender)
        net.Send(receivers)

        return ""
    end)
end

if CLIENT then
    net.Receive("gWare.Commands.Me.ChatMessage", function()
        local message = net.ReadString()
        local sender = net.ReadEntity()

        local color = RPExtraTeams[sender:Team()].color

        chat.AddText(color, sender:Name() .. " " .. message, color_white)
    end)
end
