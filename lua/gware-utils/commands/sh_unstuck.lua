--[[
    Command: /unstuck
    Description: Help the player get out of a stuck situation.
    Example Command: /unstuck
    Example Chat: [Unstuck] You have 5 seconds to move out of the object.
]]

local L = gWare.Utils.Lang.GetPhrase

if SERVER then
    util.AddNetworkString("gWare.Commands.unstuck.ChatMessage")

    local delay = {}
    local noCollidedPlayers = {}

    hook.Add("PlayerSay", "gWare.Commands.unstuck", function(ply, chatInput)
        local text = chatInput:lower()

        if not text:StartWithAny("!unstuck", "/unstuck") then return end

        if gWare.Utils.GetSettingValue("command_unstuck") then return end

        if (delay[ply] or 0) > CurTime() then
            VoidLib.Notify(ply, L("notify_unstuck-error_name"), L("notify_unstuck-error-cooldown_desc"), VoidUI.Colors.Red, 2)
            return ""
        end

        local traceHull = util.TraceHull({
            start = ply:GetPos(),
            endpos = ply:GetPos(),
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            filter = ply
        })

        if (not traceHull.Hit or not IsValid(traceHull.Entity)) then
            VoidLib.Notify(ply, L("notify_unstuck-error_name"), L("notify_unstuck-error-invalid_desc"), VoidUI.Colors.Red, 2)
            return ""
        end

        timer.Simple(3, function()
            if IsValid(ply) then
                noCollidedPlayers[ply] = nil
                ply:SetCustomCollisionCheck(false)
            end
        end)

        ply:SetCustomCollisionCheck(true)
        noCollidedPlayers[ply] = true
        VoidLib.Notify(ply, L("notify_unstuck_name"), L("notify_unstuck-start_desc"), VoidUI.Colors.Green, 4)

        delay[ply] = CurTime() + 15

        return ""
    end)

    hook.Add("ShouldCollide", "gWare.Commands.unstuck", function(ent1, ent2)
        if (ent1:IsPlayer() and noCollidedPlayers[ent1]) or (ent2:IsPlayer() and noCollidedPlayers[ent2]) then
            return false
        end
    end)
end
