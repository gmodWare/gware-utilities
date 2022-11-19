hook.Add("CanPlayerSuicide", "gWare.Utils.PreventSuicide", function(ply)
    return gWare.Utils.GetSettingValue("commitSuicide")
end)

// this doesn't seem to hide the physgun glow, i dont know why
local function hideWeapons(ply, shouldHide)
    for _, v in pairs(ply:GetWeapons()) do
        v:SetNoDraw(should_hide)
    end

    local physgunBeams = ents.FindByClassAndParent("physgun_beam", ply)
    if (physgunBeams) then
        for i = 1, #physgunBeams do
            physgunBeams[i]:SetNoDraw(should_hide)
        end
    end
end

local hiddenPlayers = {}

hook.Add("PlayerNoClip", "gWare.Utils.HandleNoclipVanish", function(ply, desiredNoClipState)
    if (not gWare.Utils.GetSettingValue("automaticCloak")) then return end

    ply:SetNoDraw(desiredNoClipState)
    ply:DrawWorldModel(not desiredNoClipState)
    ply:SetRenderMode(desiredNoClipState and RENDERMODE_TRANSALPHA or RENDERMODE_NORMAL)
    ply:Fire("alpha", desiredNoClipState and 0 or 255, 0)
    hideWeapons(ply, desiredNoClipState)

    hiddenPlayers[ply] = desiredNoClipState and true or nil
end)

hook.Add("PlayerSpawn", "gWare.Utils.DisableCloak", function(ply)
    hiddenPlayers[ply] = nil
end)

hook.Add("PlayerSwitchWeapon", "gWare.Utils.DisableCloak", function(ply)
    if (hiddenPlayers[ply]) then
        timer.Create("gWare.Utils.HideWeps" .. ply:SteamID(), 0, 1, function()
            if (IsValid(ply) and hiddenPlayers[ply]) then
                hideWeapons(ply, true)
            end
        end)
    end
end)

hook.Add("OnNPCKilled", "gWare.Utils.DisableNPCWeaponDrop", function(npc, attacker, inflictor)
    if (not gWare.Utils.GetSettingValue("npcDisabledWeapons")) then return end

    local npcWeapon = npc:GetActiveWeapon()
    if (IsValid(npcWeapon)) then
        npcWeapon:Remove()
    end
end)