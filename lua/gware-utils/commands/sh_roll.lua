--[[
    Command: /roll
    Description: Prints a random number from 1-100 in the chat
    Example Chat: "Menschlich hat eine 52 gewürfelt!"
]]

if SERVER then
    util.AddNetworkString("GWare.RollCommand.ChatMessage")

    hook.Add("PlayerSay", "GWare.RollCommand", function(ply, text)
        if (text:lower() == "/roll") or (text:lower() == "!roll") then
            local randomNumber = math.Rand(1, 100)

            net.Start("GWare.RollCommand.ChatMessage")
                net.WriteUInt(randomNumber, 7)
                net.WriteEntity(ply)
            net.Broadcast()
        end
    end)
end

if CLIENT then
    local colors = {
        ["perfect"] = Color(2, 2, 2),
        ["good"] = Color(2, 2, 2),
        ["ok"] = Color(2, 2, 2),
        ["bad"] = Color(138, 8, 8),
        ["default"] = Color(255, 255, 255),
        ["brackets"] = Color(231, 192, 15),
        ["commandColor"] = Color(154, 75, 245)
    }

    local pingColor = color_white

    local function GWareReturnRollColor(ping)
        if (ping <= 25) then
            pingColor = colors["bad"]
        elseif (ping <= 50) then
            pingColor = colors["ok"]
        elseif (ping <= 75) then
            pingColor = colors["good"]
        elseif (ping <= 100) then
            pingColor = colors["perfect"]
        end
    end

    net.Receive("GWare.RollCommand.ChatMessage", function()
        local randNum = net.ReadUInt(7)
        local ply = net.ReadEntity()

        GWareReturnRollColor(randNum)

        chat.AddText(colors["brackets"], "[", colors["commandColor"], "ROLL", colors["brackets"], "] ", ply:Nick() .. " hat eine ", pingColor, tostring(randNum), colors["commandColor"], " gerollt!")
    end)
end
