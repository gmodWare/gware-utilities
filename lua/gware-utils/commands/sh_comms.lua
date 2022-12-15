--[[
    Command: /funk <name>* <nachricht>
    Description: Funkt eine Nachricht, welche alle sehen können an einen bestimmten spieler
                basierend auf dem teil, den der spieler eingegeben hat, soll dann im Funk 
                der volle Spielername stehen. Wenn kein Spieler gefunden wird, dann einfach
                den Teil des Namens, der eingegeben wurde.
    Example Command: /funk Ryzen* 10-20u
    Example Chat: [Funk] *1835 Menschlich an 501st CMD 5125 Ryzen* 10-20u
]]

local L = gWare.Utils.Lang.GetPhrase

if SERVER then
    util.AddNetworkString("gWare.Commands.Funk.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.funk", function(ply, text)
        if not (text:lower():StartWithAny("/funk ", "/comms ")) then return end

        local args = text:Split("*")

        if #args < 2 then
            VoidLib.Notify(ply, L("notify_invalid-comms_name"), L("notify_invalid-comms_desc"), VoidUI.Colors.Red, 10)
            return
        end

        local start = args[1]

        local namePart = start:ReplacePrefix("funk", "comms")
        local message = args[2]:sub(2)

        if gWare.Utils.IsMessageEmpty(encrypted, ply) then return end

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
    net.Receive("gWare.Commands.Funk.ChatMessage", function()
        local message = net.ReadString()
        local receiverName = net.ReadString()
        local sender = net.ReadEntity()

        local toTranslated = " " .. L"general_to" .. " "

        gWare.Utils.PrintCommand("comms",
            "*" .. sender:Nick() .. toTranslated .. receiverName .. "* ", color_white, message
        )
    end)
end
