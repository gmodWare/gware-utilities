-- WORK IN PROGRESS
--[[
    Command: /id
    Description: Shows your cloneid to to other players in your area
    Example Command: /id
    Example Chat: [ID] 501st CMD Menschlich shows his ID: 5431


local L = gWare.Utils.Lang.GetPhrase

local command = gWare.Utils.RegisterCommand({
    prefix = "id",
    triggers = {"id", "cloneid", "klonid"},
})

command:OnServerSide(function(sender)
    if not VoidChar then return end

    local receivers = {sender}
    local distSqr = 500 * 500

    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():DistToSqr(sender:GetPos()) > distSqr then continue end

        table.insert(receivers, ply)
    end

    local cloneid = ply:GetCharacter().clone_id

    local showTag = VoidChar.Config.ShowHashtag
    cloneid = showTag and VoidChar.Config.CustomSymbol or cloneid

    net.Start(command:GetNetID())
        net.WriteString(cloneid)
        net.WriteEntity(sender)
    net.Send(receivers)
end)

command:OnReceive(function()
    local cloneid = net.ReadString()
    local ply = net.ReadEntity()

    local color = team.GetColor(ply:Team())

    local idFrom = ("ID " .. L"general_from" .. " ")

    gWare.Utils.PrintCommand(command:GetPrefix(),
        color, idFrom, ply:Nick(), gWare.Utils.Colors.Brackets, " » ", color_white, cloneid
    )
end)

--]]
