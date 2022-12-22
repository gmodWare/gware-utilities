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

        if gWare.Utils.GetSettingValue("command_comms") then return end

        local args = text:Split("*")

        if #args < 2 then
            VoidLib.Notify(ply, L("notify_invalid-comms_name"), L("notify_invalid-comms_desc"), VoidUI.Colors.Red, 8)
            return ""
        end

        local start = args[1]

        local namePart = start:ReplacePrefix("funk", "comms")
        local message = args[2]:sub(2)

        if not message then
            VoidLib.Notify(ply, L"notify_invalid-comms_name", L"notify_invalid-comms_desc", VoidUI.Colors.Red, 8)
            return
        end

        local receiver = gWare.Utils.GetPlayerByNamePart(namePart)

        local receiverName = namePart
        local receiverColor = VoidUI.Colors.Blue

        if IsEntity(receiver) then
            receiverName = receiver:Name()
            receiverColor = RPExtraTeams[receiver:Team()].color
        end

        net.Start("gWare.Commands.Funk.ChatMessage")
            net.WriteString(message)
            net.WriteString(receiverName)
            net.WriteEntity(ply)
            net.WriteColor(receiverColor)
        net.Broadcast()

        return ""
    end)
end

if CLIENT then
    local col = gWare.Utils.Colors

    net.Receive("gWare.Commands.Funk.ChatMessage", function()
        local message = net.ReadString()
        local receiverName = net.ReadString()
        local sender = net.ReadEntity()
        local receiverColor = net.ReadColor()

        local senderColor = RPExtraTeams[sender:Team()].color
        local toTranslated = (" " .. L"general_to" .. " ")

        gWare.Utils.PrintCommand("comms",
            senderColor, sender:Nick(), color_white, col.Orange, toTranslated, receiverColor, receiverName, col.Brackets, " » ", color_white, message
        )
    end)
end
