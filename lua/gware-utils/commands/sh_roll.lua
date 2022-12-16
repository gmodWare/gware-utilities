--[[
    Command: /roll
    Description: Prints a random number from 1-100 in the chat
    Example Chat: "Menschlich hat eine 52 gewürfelt!"
]]

if SERVER then
    util.AddNetworkString("GWare.RollCommand.ChatMessage")

    hook.Add("PlayerSay", "GWare.RollCommand", function(ply, text)
        if not text:lower():StartWithAny("/roll") then return end

        local randomNumber = math.Rand(1, 100)

        net.Start("GWare.RollCommand.ChatMessage")
            net.WriteUInt(randomNumber, 7)
            net.WriteEntity(ply)
        net.Broadcast()

        return ""
    end)
end

if CLIENT then
    local function getRollColor(ping)
        if (ping <= 25) then
            return gWare.Utils.Colors.Bad
        elseif (ping <= 50) then
            return gWare.Utils.Colors.Okay
        elseif (ping <= 75) then
            return gWare.Utils.Colors.Good
        elseif (ping <= 100) then
            return gWare.Utils.Colors.Perfect
        end
    end

    net.Receive("GWare.RollCommand.ChatMessage", function()
        local randNum = net.ReadUInt(7)
        local ply = net.ReadEntity()

        local rollColor = getRollColor(randNum)
        local numStr = tostring(randNum)

        local senderColor = RPExtraTeams[ply:Team()].color

        gWare.Utils.PrintCommand("roll",
            -- todo: translate this command
            senderColor, ply:Nick(), color_white, " hat eine ", rollColor, numStr, color_white, " gerollt!"
        )
    end)
end
