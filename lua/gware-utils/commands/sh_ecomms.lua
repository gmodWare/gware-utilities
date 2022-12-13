--[[
    Command: /vfunk <name>* <nachricht>
    Description: Funkt eine verschlüsselte Nachricht, welche alle der empfangende Spieler
                entschlüsselt sehen kann, und alle anderen verschlüsselt.
                Basierend auf dem teil, den der spieler eingegeben hat, soll dann im Funk 
                der volle Spielername stehen. Wenn kein Spieler gefunden wird, dann sehen
                alle Spieler den Text verschlüsselt. Mit /decode kann man den Text 
                wieder leserlich machen.
    Example Command: /vfunk Ryzen* Antritt des Dienstes.
    Example Chat: [Verschlüsselter Funk] *1835 Menschlich an 5125 Ryzen* Antritt des Dienstes.
    Example Encrypted Chat: [Verschlüsselter Funk] *1835 Menschlich an 5125 Ryzen* 0f 12 3e 2d e3 f1 9d 5a 8b 4d 90
]]

local L = gWare.Utils.Lang.GetPhrase

if SERVER then
    util.AddNetworkString("gWare.Commands.vFunk.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.vfunk", function(ply, chatInput)
        local text = chatInput:lower()

        if not text:StartWithAny("/vfunk ", "/ecomms ", "/encrypted ", "/ec ") then return end

        if not gWare.Utils.HasJobAccess("encrypted-comms", ply) then
            VoidLib.Notify(ply, L"notify_missing-perms-encrypted_name", L"notify_missing-perms-encrypted_desc", VoidUI.Colors.Red, 4)
            return 
        end

        local args = text:Split("*")
        local start = args[1]

        local namePart = start:ReplacePrefix("vfunk", "ecomms", "encrypted", "ec") 
        local message = args[2]

        if not message then 
            VoidLib.Notify(ply, L"notify_invalid-encrypted-ecomms_name", L"notify_invalid-encrypted-ecomms_desc", VoidUI.Colors.Red, 10)
            return
        end

        local target = gWare.Utils.GetPlayerByNamePart(namePart)
        local receiver = target or namePart

        local charCodes = { string.byte(message, 1, string.len(message)) }
        local encrypted = ""

        for _, ascii in pairs(charCodes) do
            local hex = bit.tohex(ascii)
            local modifiedHex = hex:gsub("0*", "", 1)
            encrypted = encrypted .. modifiedHex .. " "
        end

        local clearTextReceivers = {}
        table.insert(clearTextReceivers, ply)

        if IsEntity(receiver) then
            table.insert(clearTextReceivers, receiver)
        end

        local receiverName = IsEntity(receiver) and receiver:Name() or receiver

        -- send encrypted message to everyone except receiver and sender
        net.Start("gWare.Commands.vFunk.ChatMessage")
            net.WriteString(encrypted)
            net.WriteString(receiverName)
            net.WriteEntity(ply)
        net.SendOmit(clearTextReceivers)

        -- now send clear text to sender and receiver
        net.Start("gWare.Commands.vFunk.ChatMessage")
            net.WriteString(message)
            net.WriteString(receiverName)
            net.WriteEntity(ply)
        net.Send(clearTextReceivers)

        return ""
    end)
end

if CLIENT then
    local col = gWare.Utils.Colors

    net.Receive("gWare.Commands.vFunk.ChatMessage", function()
        local message = net.ReadString()
        local receiverName = net.ReadString()
        local sender = net.ReadEntity()

        local toTranslated = " " .. L"general_to" .. " "

        gWare.Utils.PrintCommand("encrypted-comms", 
            gWare.Utils.Colors.Orange, "*", sender:Nick() .. toTranslated .. receiverName .. "* ", color_white, message
        )
    end)
end
