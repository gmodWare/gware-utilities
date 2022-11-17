--[[
    Command: /funk <name>* <nachricht>
    Description: Funkt eine Nachricht, welche alle sehen können an einen bestimmten spieler
                basierend auf dem teil, den der spieler eingegeben hat, soll dann im Funk 
                der volle Spielername stehen. Wenn kein Spieler gefunden wird, dann einfach
                den Teil des Namens, der eingegeben wurde.
    Example Command: /funk Ryzen* 10-20u
    Example Chat: [Funk] *1835 Menschlich an 501st CMD 5125 Ryzen* 10-20u
]]


if SERVER then
    util.AddNetworkString("gWare.Commands.Funk.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.funk", function(ply, text)
        if not (text:lower():StartWithAny("/funk", "!funk")) then return end

        local args = text:Split("*")
        local start = args[1]

        local namePart = start:ReplacePrefix("funk") 
        local message = args[2]

        if not message then 
            VoidLib.Notify(ply, "Invalider Funk", "Funk Beispiel: /funk Commander Rex* Wo befinden Sie sich?", VoidUI.Colors.Red, 10)
            return
        end

        local target = gWare.Utils.GetPlayerByNamePart(namePart)
        local fullName = target and target:Name() or namePart

        net.Start("gWare.Commands.Funk.ChatMessage")
            net.WriteString(message)
            net.WriteString(fullName)
            net.WriteEntity(ply)
        net.Broadcast()

        return ""
    end)
end

if CLIENT then
    local colors = {
        ["color1"] = Color(0, 38, 255),
        ["brackets"] = Color(40, 42, 46),
        ["commandColor"] = Color(245, 200, 75)
    }

    net.Receive("gWare.Commands.Funk.ChatMessage", function()
        local message = net.ReadString()
        local receiverName = net.ReadString()
        local sender = net.ReadEntity()

        gWare.Utils.Print("funk",
            "*" .. sender:Nick() .. " an " .. receiverName .. "* ", color_white, message
        )
    end)
end
