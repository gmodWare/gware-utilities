local function getSetting(name)
    local val = false

    gWare.Utils.GetSetting(name, function(tblData)
        if tblData then val = true end
    end)

    return val
end

local i = 1
function gWare.Utils.AddSetting(tblData)
    gWare.Utils.Settings[i] = {id = tblData.id, name = tblData.name, description = tblData.description, value = tblData.defaultValue, settingType = tblData.settingType}
    gWare.Utils.IDs[tblData.id] = i
    i = i + 1

    if not getSetting(tblData.name) then
        gWare.Utils.InsertSetting(tblData.name, tblData.defaultValue)
    end

    gWare.Utils.GetAllSettings(function (sqlData)
        local sqlDataCount = table.Count(sqlData)
        local settingsDataCount = table.Count(gWare.Utils.Settings)

        if settingsDataCount != sqlDataCount then return end

        timer.Simple(0, function ()
            hook.Run("gWare.Utils.SettingsLoaded")
        end)
    end)
end

hook.Add("gWare.Utils.SettingsLoaded", "gWare.Utils.CacheSettings", function()
    gWare.Utils.GetAllSettings(function (tblData)
        for index, settings in ipairs(tblData) do
            local settingValue = gWare.Utils.IntToBool(tonumber(settings.setting_value))

            gWare.Utils.Settings[index].value = settingValue
        end
    end)
end)

function gWare.Utils.ChangeSetting(index, settingValue)
    local settingName = gWare.Utils.Settings[index].name

    if not getSetting(settingName) then return end

    gWare.Utils.UpdateSetting(settingName, settingValue)
    gWare.Utils.Settings[index].value = settingValue

    gWare.Utils.UpdateClient(index, settingValue)
end

gWare.Utils.GetAllJobs(function(tblData)
    if tblData == nil then return end
    for _, jobData in ipairs(tblData) do
        gWare.Utils.JobAccess[jobData.setting_id] = gWare.Utils.JobAccess[jobData.setting_id] or {}
        gWare.Utils.JobAccess[jobData.setting_id][jobData.job_command] = true
    end
end)

///////////////////////////
//       SETTINGS        //
///////////////////////////

-- FamilySharing
hook.Add("PlayerAuthed", "gWare.Utils.FamilySharing", function(ply)
    if not gWare.Utils.GetSettingValue("familySharing") then return end

    local s64 = ply:SteamID64()
    local ownerS64 = ply:OwnerSteamID64()

    if ownerS64 == s64 then return end

    ply:Kick("[gWare] Du wurdest gekickt, aufgrund von Family Sharing!")
end)


-- workshopDownload
hook.Add("gWare.Utils.SettingsLoaded", "gWare.Utils.WorkshopDownload" , function()
    if not gWare.Utils.GetSettingValue("workshopDownload") then return end
    for _, addon in ipairs(engine.GetAddons()) do
        if not addon.mounted then return end

        resource.AddWorkshop(addon.wsid)
    end
end)


-- commitSuicide
hook.Add("CanPlayerSuicide", "gWare.Utils.PreventSuicide", function(ply)
    return gWare.Utils.GetSettingValue("commitSuicide")
end)


-- automatic noclip
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


-- npcDisabledWeapons
hook.Add("OnNPCKilled", "gWare.Utils.DisableNPCWeaponDrop", function(npc, attacker, inflictor)
    if (not gWare.Utils.GetSettingValue("npcDisabledWeapons")) then return end

    local npcWeapon = npc:GetActiveWeapon()
    if (IsValid(npcWeapon)) then
        npcWeapon:Remove()
    end
end)



///////////////////////////
// IN-GAME CONFIGURATION //
///////////////////////////

gWare.Utils.AddSetting({
    id = "npcDisabledWeapons",
    name = "NPC Waffen Drop",
    description = "Sollen NPCs beim Tod ihre Waffe fallen lassen?",
    defaultValue = true,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "toolgunSounds",
    name = "Toolgun Geräusche",
    description = "Soll die Toolgun beim benutzen Geräusche machen?",
    defaultValue = true,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "toolgunEffects",
    name = "Toolgun Effekte",
    description = "Soll die Toolgun beim benutzen Effekte machen?",
    defaultValue = true,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "automaticCloak",
    name = "Automatischer Cloak bei Noclip",
    description = "Soll der Spieler bei Noclip automatisch unsichtbar werden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "showKillfeed",
    name = "Killfeed anzeigen",
    description = "Sollen Spielertode rechts oben angezeigt werden?",
    defaultValue = true,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "commitSuicide",
    name = "Selbstmord erlauben?",
    description = "Kann ein spieler sich selbst umbringen (Konsolen Befehl)?",
    defaultValue = true,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "weaponDrop",
    name = "Spieler Waffen drop erlauben?",
    description = "Kann ein Spieler seine Waffen fallen lassen?",
    defaultValue = true,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "workshopDownload",
    name = "Automatischer Workshop-Download",
    description = "Sollen alle User bei joinen die Kollektion automatisch downloaden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "darkrpBlackboard",
    name = "DarkRP Tafeln aktivieren?",
    description = "Sollen bei '/advert' Tafeln gespawned werden?",
    defaultValue = true,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "familySharing",
    name = "Family Sharing verbieten?",
    description = "Sollen User die Family-Sharing benutzen, sofort gekickt werden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "voicePanels",
    name = "Sprachanzeige deaktiveren?",
    description = "Soll die Sprachanzeige Rechts unten deaktiviert werden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableSpawnmenu",
    name = "Spawnmenü für User deaktivieren?",
    description = "Braucht man eine permission um das Spawnmenü öffnen zu können?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableContextmenu",
    name = "Context-Menü für User deaktivieren?",
    description = "Braucht man eine permission um das C-Menü öffnen zu können?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "jobExample",
    name = "This is an job example?",
    description = "Braucht der user eine permission um das Context-Menü öffnen zu können?",
    defaultValue = {},
    settingType = "job_multi_select"
})
