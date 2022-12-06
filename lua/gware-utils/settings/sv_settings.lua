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

    hook.Run("gWare.Utils.SettingChanged", gWare.Utils.Settings[index].id, settingValue)
end

gWare.Utils.GetAllJobs(function(tblData)
    if tblData == nil then return end
    for _, jobData in ipairs(tblData) do
        gWare.Utils.JobAccess[jobData.setting_id] = gWare.Utils.JobAccess[jobData.setting_id] or {}
        gWare.Utils.JobAccess[jobData.setting_id][jobData.job_command] = true
    end
end)

hook.Add("gWare.Utils.SettingsLoaded", "gWare.Utils.WaitForAddon", function()
    gWare.Utils.GetAllNPCPos(function (npcTblData)
        for _, npcData in ipairs(npcTblData) do
    
            gWare.Utils.NPCSpawns[npcData.npc_name] = gWare.Utils.StringToVector(npcData.npc_pos)
            gWare.Utils.NPCJobs[npcData.npc_name] = gWare.Utils.NPCJobs[npcData.npc_name] or {}
    
            gWare.Utils.GetNPCJobs(npcData.npc_name, function (jobTblData)
                for _, jobData in ipairs(jobTblData) do
    
                    gWare.Utils.NPCJobs[npcData.npc_name][jobData.job_command] = true
                end
            end)
        end
    end)
end)

///////////////////////////
//       SETTINGS        //
///////////////////////////

-- FamilySharing
hook.Add("PlayerAuthed", "gWare.Utils.FamilySharing", function(ply)
    if not gWare.Utils.GetSettingValue("disableFamilySharing") then return end

    local s64 = ply:SteamID64()
    local ownerS64 = ply:OwnerSteamID64()

    if ownerS64 == s64 then return end

    ply:Kick("[gWare] Du wurdest aufgrund von Family Sharing gekickt!")
end)


-- workshopDownload
hook.Add("gWare.Utils.SettingsLoaded", "gWare.Utils.WorkshopDownload" , function()
    if not gWare.Utils.GetSettingValue("enableWorkshopDownload") then return end
    for _, addon in ipairs(engine.GetAddons()) do
        if not addon.mounted then return end

        resource.AddWorkshop(addon.wsid)
    end
end)


-- commitSuicide
hook.Add("CanPlayerSuicide", "gWare.Utils.PreventSuicide", function(ply)
    if not gWare.Utils.GetSettingValue("disallowSuicide") then return end
    
    VoidLib.Notify(ply, "Anti-Selbstmord", "Du kannst keinen Selbstmord begehen!", VoidUI.Colors.Red, 5)
    return false
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
    if not gWare.Utils.GetSettingValue("enableCloakOnNoclip") then return end
    print((desiredNoClipState and "Started" or "Leaved") .. " noclip") -- not getting printed, broken?

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
    if not gWare.Utils.GetSettingValue("disableNPCWeaponDrop") then return end

    local npcWeapon = npc:GetActiveWeapon()
    if (IsValid(npcWeapon)) then
        npcWeapon:Remove()
    end
end)


-- toolgunSounds
hook.Add("EntityEmitSound", "gWare.Utils.DisableToolGunSound", function(data)
    if not gWare.Utils.GetSettingValue("disableToolgunSounds") then return end

    if (data.Entity:IsValid() and data.Entity:IsPlayer() and data.Entity:GetActiveWeapon():IsValid() and data.Entity:GetActiveWeapon():GetClass() == "gmod_tool") then
        return false
    end
end)


-- darkrpBlackboard
hook.Add("canAdvert", "gWare.Utils.DisableBlackboard", function(ply)
    if not gWare.Utils.GetSettingValue("disableDarkRPBlackboard") then return end
    
    return false
end)

///////////////////////////
// IN-GAME CONFIGURATION //
///////////////////////////

gWare.Utils.AddSetting({
    id = "disableNPCWeaponDrop",
    name = "NPC Waffen Drop",
    description = "Waffendrop von NPCs deaktivieren?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableToolgunSounds",
    name = "Toolgun Geräusche",
    description = "Toolgun Geräusche deaktiviern?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableToolgunEffects",
    name = "Toolgun Effekte",
    description = "Toolgun Effekte deaktivieren?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "enableCloakOnNoclip",
    name = "Automatischer Cloak bei Noclip",
    description = "Automatisch Cloaken bei Noclip?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableKillfeed",
    name = "Killfeed ausblenden",
    description = "Sollen Spielertode ausgeblendet werden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disallowSuicide",
    name = "Selbstmord verbieten?",
    description = "'Kill' in Konsole verbieten?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disablePlayersWeaponDrop",
    name = "Spieler Waffen drop verbieten?",
    description = "Der Spieler kann keine Waffen fallen lassen?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "enableWorkshopDownload",
    name = "Automatischer Workshop-Download",
    description = "Sollen alle User bei joinen die Kollektion automatisch downloaden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableDarkRPBlackboard",
    name = "DarkRP Tafeln deaktvieren?",
    description = "Sollen bei '/advert' keine Tafeln gespawned werden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableFamilySharing",
    name = "Family Sharing verbieten?",
    description = "Sollen User die Family-Sharing benutzen, sofort gekickt werden?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableVoicePanels",
    name = "Sprachanzeige deaktiveren?",
    description = "Sprachanzeige rechts unten deaktivieren?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableSpawnmenu",
    name = "Spawnmenü deaktivieren?",
    description = "Braucht man eine permission um das Spawnmenü öffnen zu können?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "disableContextmenu",
    name = "Context-Menü deaktivieren?",
    description = "Braucht man eine permission um das C-Menü öffnen zu können?",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "encryptedComms",
    name = "Encrypted Comms Stuff?",
    description = "Braucht der user eine permission um das Context-Menü öffnen zu können?",
    defaultValue = {},
    settingType = "job_multi_select"
})
