--[[
    Command: /akt <message>
    Description: Prints a text in global chat with a [Akt] prefix
    Example Command: /akt schaltet den Reaktor aus.
    Example Chat: [Akt] 501st CMD Menschlich schaltet den Reaktor aus.
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.Akt.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.Akt", function(ply, text)
        if (text:lower():StartWithAny("/akt", "!akt")) then
            local message = text:ReplacePrefix("akt")

            net.Start("gWare.Commands.Akt.ChatMessage")
                net.WriteString(message)
                net.WriteEntity(ply)
            net.Broadcast()

            return ""
        end
    end)
end

if CLIENT then
    net.Receive("gWare.Commands.Akt.ChatMessage", function()
        local receivedMessage = net.ReadString()
        local ply = net.ReadEntity()

        gWare.Utils.Print("akt", ply:Nick() .. " ", receivedMessage)
    end)
end
