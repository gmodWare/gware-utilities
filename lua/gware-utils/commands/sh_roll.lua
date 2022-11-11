--[[
    Command: /roll
    Description: Prints a random number from 1-100 in the chat
    Example Chat: "Menschlich hat eine 52 gewürfelt!"
]]

if SERVER then
    util.AddNetworkString("GWare.RollCommand.ChatMessage")

    hook.Add("PlayerSay", "GWare.RollCommand", function(ply, text)
        if not (text:lower() == "/roll" or text:lower() == "!roll") then return end
        
        local randomNumber = math.Rand(1, 100)

        net.Start("GWare.RollCommand.ChatMessage")
            net.WriteUInt(randomNumber, 7)
            net.WriteEntity(ply)
        net.Broadcast()
    end)
end

if CLIENT then
    local colors = {
        ["perfect"] = Color(9, 168, 30),
        ["good"] = Color(160, 226, 6),
        ["ok"] = Color(172, 169, 14),
        ["bad"] = Color(138, 8, 8),
        ["brackets"] = Color(40, 42, 46),
        ["commandColor"] = Color(75, 92, 245)
    }

    local function getRollColor(ping)
        if (ping <= 25) then
            return colors["bad"]
        elseif (ping <= 50) then
            return colors["ok"]
        elseif (ping <= 75) then
            return colors["good"]
        elseif (ping <= 100) then
            return colors["perfect"]
        end
    end

    net.Receive("GWare.RollCommand.ChatMessage", function()
        local randNum = net.ReadUInt(7)
        local ply = net.ReadEntity()

        local rollColor = getRollColor(randNum)
        chat.AddText(colors["brackets"], "[", colors["commandColor"], "ROLL", colors["brackets"], "] ", color_white, ply:Nick() .. " hat eine ", rollColor, tostring(randNum), color_white, " gerollt!")
    end)
end
