--[[
    Command: /decode <message>
    Description: Decodes a message which was encrypted via /vfunk
    Example Command: /decode Borsjuu eft Ejfotuft.
    Example Chat: [Entschlüsselt] Antritt des Dienstes.
]]

local L = gWare.Utils.Lang.GetPhrase

local command = gWare.Utils.RegisterCommand({
    prefix = "decode",
    triggers = {"decode"},
})

command:OnServerSide(function(ply, message)
    if not gWare.Utils.HasJobAccess("decode", ply) then
        VoidLib.Notify(ply, L"notify_decode_name", L"notify_decode_desc", VoidUI.Colors.Red, 4)
        return ""
    end

    if gWare.Utils.IsMessageEmpty(message, ply) then return "" end

    local hexTbl = message:Split(" ")
    local clearText = ""

    for i, hex in ipairs(hexTbl) do
        if hex == "" then continue end

        local ascii = bit.tobit(tonumber(hex, 16))
        if not isnumber(ascii) then
            VoidLib.Notify(ply, L"notify_invalid-decode_name", L"notify_invalid-decode_desc", VoidUI.Colors.Red, 5)
            return ""
        end
        clearText = clearText .. string.char(ascii)
    end

    net.Start(command:GetNetID())
        net.WriteString(clearText)
    net.Send(ply)
end)

command:OnReceive(function()
    local text = net.ReadString()

    gWare.Utils.PrintCommand(command:GetPrefix(),
        text
    )
end)
