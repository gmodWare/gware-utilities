--[[
    Command: /me <message>
    Description: Prints a out-of-character message within a small radius
    Example Command: /me Lol der ist eingach umgefallen xD
    Example Chat: [me] 501st CMD Menschlich: Lol der ist einfach umgefallen xD
]]

local L = gWare.Utils.Lang.GetPhrase

if SERVER then
    util.AddNetworkString("gWare.Commands.Me.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.me", function(sender, text)
        if not text:StartWithAny("/me ", "!me ") then return end

        local message = text:ReplacePrefix("me")

        if gWare.Utils.IsMessageEmpty(message, ply) then return end

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

        -- todo: translate command
        gWare.Utils.ChatPrint("me",
            sender:Nick() .. " " .. message
        )
    end)
end
