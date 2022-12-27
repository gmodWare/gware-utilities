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

local command = gWare.Utils.RegisterCommand({
    prefix = "comms",
    triggers = {"funk", "comms"},
})

command:OnServerSide(function(ply, text)
    local args = text:Split("*")

    if #args < 2 then
        VoidLib.Notify(ply, L("notify_invalid-comms_name"), L("notify_invalid-comms_desc"), VoidUI.Colors.Red, 8)
        return ""
    end

    local namePart = text:sub(1, text:find("*"))
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

    net.Start(command:GetNetID())
        net.WriteString(message)
        net.WriteString(receiverName)
        net.WriteEntity(ply)
        net.WriteColor(receiverColor)
    net.Broadcast()
end)

command:OnReceive(function()
    local col = gWare.Utils.Colors

    local message = net.ReadString()
    local receiverName = net.ReadString()
    local sender = net.ReadEntity()
    local receiverColor = net.ReadColor()

    local senderColor = RPExtraTeams[sender:Team()].color
    local toTranslated = (" " .. L"general_to" .. " ")

    gWare.Utils.PrintCommand(command:GetPrefix(),
        senderColor, sender:Nick(), color_white, col.Orange, toTranslated, receiverColor, receiverName, col.Brackets, " » ", color_white, message
    )
end)
