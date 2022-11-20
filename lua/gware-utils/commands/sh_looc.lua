--[[
    Command: /looc <message>
    Description: Prints a out-of-character message within a small radius
    Example Command: /looc Lol der ist eingach umgefallen xD
    Example Chat: [LOOC] 501st CMD Menschlich: Lol der ist einfach umgefallen xD
]]

local function CheckPos(ply, target, dist)
    local distSqr = dist * dist

    return ply:GetPos():DistToSqr(target:GetPos()) < distSqr
end

if SERVER then
    util.AddNetworkString("gWare.Commands.LOOC.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.LOOC", function(ply, text)
        if not text:StartWithAny("/looc", "!looc") then return end

        local message = text:ReplacePrefix("looc")

        if message:Trim() == "" then
            VoidLib.Notify(ply, "Invalider LOOC", "Du kannst keinen Leere Nachricht senden!", VoidUI.Colors.Red, 5)
            return
        end

        for k, v in ipairs(player.GetAll()) do
            if not (CheckPos(ply, v, 500)) then return end
        end

        net.Start("gWare.Commands.LOOC.ChatMessage")
            net.WriteString(message)
            net.WriteEntity(ply)
        net.Broadcast()

        return ""
    end)
end

if CLIENT then
    local colors = {
        ["brackets"] = Color(40, 42, 46),
        ["commandColor"] = Color(169, 75, 245)
    }

    net.Receive("gWare.Commands.LOOC.ChatMessage", function()
        local message = net.ReadString()
        local sender = net.ReadEntity()

        gWare.Utils.Print("looc",
            sender:Nick() .. ": " .. message
        )
    end)
end
