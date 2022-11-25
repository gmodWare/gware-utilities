--[[
    Command: /advert <message>
    Description: Prints a text in global chat with a [Advert] prefix
    Example Command: /advert schaltet den Reaktor aus.
    Example Chat: [Advert] Kommt zu Nexus Gaming
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.Advert.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.Advert", function(ply, text)
        if gWare.Utils.GetSettingValue("darkrpBlackboard") then return end

        if (text:lower():StartWithAny("/advert ", "!advert ")) then
            local message = text:ReplacePrefix("advert")

            net.Start("gWare.Commands.Advert.ChatMessage")
                net.WriteString(message)
                net.WriteEntity(ply)
            net.Broadcast()

            return ""
        end
    end)
end

if CLIENT then
    net.Receive("gWare.Commands.Advert.ChatMessage", function()
        local receivedMessage = net.ReadString()
        local ply = net.ReadEntity()

        gWare.Utils.Print("advert",
            ply:Nick() .. ": ", receivedMessage
        )
    end)
end
