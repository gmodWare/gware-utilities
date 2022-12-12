--[[
    Command: /looc <message>
    Description: Prints a out-of-character message within a small radius
    Example Command: /looc Lol der ist eingach umgefallen xD
    Example Chat: [LOOC] 501st CMD Menschlich: Lol der ist einfach umgefallen xD
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.LOOC.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.LOOC", function(sender, text)
        if not text:StartWithAny("/looc ", "!looc ") then return end

        local message = text:ReplacePrefix("looc")

        if message:Trim() == "" then
            -- todo: translate this
            VoidLib.Notify(sender, "Invalider LOOC", "Du kannst keine leere Nachricht senden!", VoidUI.Colors.Red, 5)
            return
        end

        local receivers = {sender}
        local distSqr = 500 * 500

        for _, ply in ipairs(player.GetAll()) do
            if ply:GetPos():DistToSqr(sender:GetPos()) > distSqr then continue end

            table.insert(receivers, ply)
        end

        net.Start("gWare.Commands.Looc.ChatMessage")
            net.WriteString(message)
            net.WriteEntity(sender)
        net.Send(receivers)

        return ""
    end)
end

if CLIENT then
    net.Receive("gWare.Commands.LOOC.ChatMessage", function()
        local message = net.ReadString()
        local sender = net.ReadEntity()

        gWare.Utils.PrChatPrintint("looc",
            sender:Nick() .. ": " .. message
        )
    end)
end
