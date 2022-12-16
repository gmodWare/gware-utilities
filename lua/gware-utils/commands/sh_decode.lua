--[[
    Command: /decode <message>
    Description: Decodes a message which was encrypted via /vfunk
    Example Command: /decode Borsjuu eft Ejfotuft.
    Example Chat: [Entschlüsselt] Antritt des Dienstes.
]]

local L = gWare.Utils.Lang.GetPhrase

if SERVER then
    util.AddNetworkString("gWare.Commands.decode.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.decode", function(ply, chatInput)
        local text = chatInput:lower()

        if not text:StartWithAny("/decode ") then return end

        if not gWare.Utils.HasJobAccess("decode", ply) then
            VoidLib.Notify(ply, L"notify_decode_name", L"notify_decode_desc", VoidUI.Colors.Red, 4)
            return ""
        end

        local encrypted = text:ReplacePrefix("decode ")

        if gWare.Utils.IsMessageEmpty(encrypted, ply) then return "" end

        local hexTbl = encrypted:Split(" ")
        local clearText = ""

        for i, hex in ipairs(hexTbl) do
            if hex == "" then continue end

            local ascii = bit.tobit(tonumber(hex, 16))
            clearText = clearText .. string.char(ascii)
        end

        net.Start("gWare.Commands.decode.ChatMessage")
            net.WriteString(clearText)
        net.Send(ply)

        return ""
    end)
end

if CLIENT then
    net.Receive("gWare.Commands.decode.ChatMessage", function()
        local text = net.ReadString()

        gWare.Utils.PrintCommand("decode", 
            text
        )
    end)
end
