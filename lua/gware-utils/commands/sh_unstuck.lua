--[[
    Command: /unstuck
    Description: Help the player get out of a stuck situation.
    Example Command: /unstuck
    Example Chat: [Unstuck] You have 5 seconds to move out of the object.
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.unstuck.ChatMessage")

    local delay = {}
    local currentlyGhosted = {}

    hook.Add("PlayerSay", "gWare.Commands.unstuck", function(ply, chatInput)
        local text = chatInput:lower()

        if text ~= "/unstuck" and text ~= "!unstuck" then return end

        if (delay[ply] or 0) > CurTime() then
            net.Start("gWare.Commands.unstuck.ChatMessage")
                net.WriteString("You are currently on cooldown for this command.")
            net.Send(ply)
            return ""
        end

        local traceHull = util.TraceHull({
            start = ply:GetPos(),
            endpos = ply:GetPos(),
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            filter = ply
        })

        if (not traceHull.Hit) then
            net.Start("gWare.Commands.unstuck.ChatMessage")
                net.WriteString("You seem to not be stuck in an object.")
            net.Send(ply)
            return ""
        end

        currentlyGhosted[ply] = true
        timer.Simple(5, function()
            currentlyGhosted[ply] = nil
            net.Start("gWare.Commands.unstuck.ChatMessage")
                net.WriteString("You are now longer no collided.")
            net.Send(ply)
        end)

        net.Start("gWare.Commands.unstuck.ChatMessage")
            net.WriteString("You are no collided for 5 seconds.")
        net.Send(ply)

        delay[ply] = CurTime() + 1

        return ""
    end)

    hook.Add("ShouldCollide", "gWare.Commands.unstuck", function(ent1, ent2)
        print(ent1, ent2)
        if (ent1:IsPlayer() and currentlyGhosted[ent1]) or (ent2:IsPlayer() and currentlyGhosted[ent2]) then
            return false
        end
    end)
end

if CLIENT then
    net.Receive("gWare.Commands.unstuck.ChatMessage", function()
        local text = net.ReadString()

        gWare.Utils.ChatPrint("Unstuck",
            text
        )
    end)
end
