--[[
    Command: /akt <message>
    Description: Prints a text in global chat with a [Akt] prefix
    Example Command: /akt schaltet den Reaktor aus.
    Example Chat: [Akt] 501st CMD Menschlich schaltet den Reaktor aus.
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.Akt.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.Akt", function(ply, text)
        if (text:lower():StartWith("/akt")) then
            local message = text:Replace("/akt ", "")

            net.Start("gWare.Commands.Akt.ChatMessage")
                net.WriteString(message)
                net.WriteEntity(ply)
            net.Broadcast()

            return ""
        end
    end)
end

if CLIENT then
    local colors = {
        ["brackets"] = Color(40, 42, 46),
        ["commandColor"] = Color(234, 245, 75)
    }

    net.Receive("gWare.Commands.Akt.ChatMessage", function()
        local receivedMessage = net.ReadString()
        local ply = net.ReadEntity()

        chat.AddText(colors["brackets"], "[", colors["commandColor"], "AKT", colors["brackets"], "] ", color_white, ply:Nick() .. " " .. receivedMessage)
    end)
end