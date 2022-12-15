--[[
    Command: /advert <message>
    Description: Prints a text in global chat with a [Advert] prefix
    Example Command: /advert schaltet den Reaktor aus.
    Example Chat: [Advert] Kommt zu Nexus Gaming
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.Advert.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.Advert", function(ply, text)
        if not gWare.Utils.GetSettingValue("billboards") then return end

        if (text:lower():StartWithAny("/advert ")) then
            local message = text:ReplacePrefix("advert")

            if gWare.Utils.IsMessageEmpty(message, ply) then return "" end

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

        gWare.Utils.PrintCommand("advert",
            ply:Nick() .. ": ", receivedMessage
        )
    end)
end
