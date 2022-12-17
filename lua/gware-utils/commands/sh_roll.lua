--[[
    Command: /roll
    Description: Prints a random number from 1-100 in the chat
    Example Chat: "Menschlich hat eine 52 gewürfelt!"
]]

local L = gWare.Utils.Lang.GetPhrase

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

    local function insertAt(original, pos, ...)
        local toInsert = {...}

        local firstHalf = original:sub(1, pos)
        local secondHalf = original:sub(pos + 1)

        local tbl = { [1] = firstHalf }

        table.Add(tbl, toInsert)
        table.insert(tbl, secondHalf)

        return tbl
    end

    net.Receive("GWare.RollCommand.ChatMessage", function()
        local randNum = net.ReadUInt(7)
        local ply = net.ReadEntity()

        local rollColor = getRollColor(randNum)
        local senderColor = RPExtraTeams[ply:Team()].color

        local translationText = L"command_roll_desc"

        local formatted = translationText:format(ply:Name(), randNum)
        
        local _, nameEnd = formatted:find(ply:Name(), 1, true)
        local numberStart, numberEnd = formatted:find(tostring(randNum), 1, true)
        
        local tbl = {
            senderColor,
            formatted:sub(1, nameEnd),
            color_white,
            formatted:sub(nameEnd + 1, numberStart - 1),
            rollColor,
            formatted:sub(numberStart, numberEnd),
            color_white,
            formatted:sub(numberEnd + 1)
        }

        gWare.Utils.PrintCommand("roll",
            unpack(tbl)
        )
    end)
end
