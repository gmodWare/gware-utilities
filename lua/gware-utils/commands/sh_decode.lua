--[[
    Command: /decode <message>
    Description: Decodes a message which was encrypted via /vfunk
    Example Command: /decode Borsjuu eft Ejfotuft.
    Example Chat: [Entschlüsselt] Antritt des Dienstes.
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.decode.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.decode", function(ply, chatInput)
        local text = chatInput:lower()

        if not text:StartWithAny("!decode ", "/decode ") then return end

        if not gWare.Utils.HasJobAccess("decode", ply) then
            -- todo: translate this
            VoidLib.Notify(ply, "error", "You cannot deocode encrypted comms!", VoidUI.Colors.Red, 4)
            return 
        end

        local encrypted = text:ReplacePrefix("decode")

        if not encrypted then
            VoidLib.Notify(ply, "Invalider Decode", "Decode Beispiel: /decode 20 68 61 6c 6c 6f", VoidUI.Colors.Red, 10)
            return
        end

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

        gWare.Utils.ChatPrint("Entschlüsselt", 
            text
        )
    end)
end
