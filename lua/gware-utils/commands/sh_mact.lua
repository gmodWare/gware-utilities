--[[
    Command: /makt <message>
    Description: Prints a text in global chat with a [Akt] prefix
    Example Command: /makt schaltet den Reaktor aus.
    Example Chat: [Medic-Akt] 501st CMD Menschlich schaltet den Reaktor aus.
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.MAkt.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.MAkt", function(ply, text)
        if (text:lower():StartWithAny("/makt ", "/mact ")) then
            local message = text:ReplacePrefix("makt")

            if gWare.Utils.IsMessageEmpty(message, ply) then return end

            net.Start("gWare.Commands.MAkt.ChatMessage")
                net.WriteString(message)
                net.WriteEntity(ply)
            net.Broadcast()

            return ""
        end
    end)
end

if CLIENT then
    net.Receive("gWare.Commands.MAkt.ChatMessage", function()
        local receivedMessage = net.ReadString()
        local ply = net.ReadEntity()

        gWare.Utils.ChatPrint("mact",
            ply:Nick() .. " ", receivedMessage
        )
    end)
end
