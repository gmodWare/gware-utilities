local L = gWare.Utils.Lang.GetPhrase


local function getSetting(name)
    local val = false

    gWare.Utils.GetSetting(name, function(tblData)
        if tblData then val = true end
    end)

    return val
end

local i = 1
function gWare.Utils.AddSetting(tblData)
    gWare.Utils.Settings[i] = {id = tblData.id, value = tblData.defaultValue, settingType = tblData.settingType, darkRP = tblData.darkRP or false}
    gWare.Utils.IDs[tblData.id] = i
    i = i + 1

    if not getSetting(tblData.id) then
        gWare.Utils.InsertSetting(tblData.id, tblData.defaultValue)
    end
end

hook.Add("gWare.Utils.SettingsLoaded", "gWare.Utils.CacheSettings", function()
    gWare.Utils.GetAllSettings(function (tblData)
        for index, setting in ipairs(tblData) do
            -- clear out non-existent settings
            -- only happens if a setting is in the db, but not added via AddSetting()
            if not gWare.Utils.IDs[setting.setting_name] then
                continue
            end

            if setting.setting_value == "0" or setting.setting_value == "1" then
                gWare.Utils.Settings[index].value = gWare.Utils.IntToBool(tonumber(setting.setting_value))
            else
                gWare.Utils.Settings[index].value = setting.setting_value
            end

            if setting.setting_name == "language" then
                gWare.Utils.Config.Language = setting.setting_value
            end
        end

        for _, settingData in ipairs(gWare.Utils.Settings) do
            local settingName = settingData.id
            local settingType = settingData.settingType

            if settingType != "command" then continue end

            local settingPrefix = settingName:Replace("command_", "")

            for trigger, cmdObj in pairs(GWARE_COMMANDS) do
                if cmdObj:GetPrefix() != settingPrefix then continue end

                cmdObj:SetActive(not settingData.value)
                break
            end
        end
    end)
end)

function gWare.Utils.ChangeSetting(index, settingValue)
    local settingName = gWare.Utils.Settings[index].id
    local settingType = gWare.Utils.Settings[index].settingType

    if settingType == "command" then
        local settingPrefix = settingName:Replace("command_", "")

        for trigger, cmdObj in pairs(GWARE_COMMANDS) do
            if cmdObj:GetPrefix() == settingPrefix then
                cmdObj:SetActive(not settingValue)
                break
            end
        end
    end

    if not getSetting(settingName) then return end

    gWare.Utils.UpdateSetting(settingName, settingValue)
    gWare.Utils.Settings[index].value = settingValue

    gWare.Utils.UpdateClients(index, settingValue)
    hook.Run("gWare.Utils.SettingChanged", settingName, settingValue)
end

gWare.Utils.GetAllJobs(function(tblData)
    if tblData == nil then return end
    for _, jobData in ipairs(tblData) do
        gWare.Utils.JobAccess[jobData.setting_id] = gWare.Utils.JobAccess[jobData.setting_id] or {}
        gWare.Utils.JobAccess[jobData.setting_id][jobData.job_command] = true
    end
end)

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

hook.Add("gWare.Utils.SettingChanged", "gWare.Utils.ChangeLanguageVar", function(settingID, settingValue)
    if settingID != "language" then return end

    gWare.Utils.Config.Language = settingValue
end)

///////////////////////////
//       SETTINGS        //
///////////////////////////

-- family-sharing
hook.Add("PlayerAuthed", "gWare.Utils.FamilySharing", function(ply)
    if not gWare.Utils.GetSettingValue("family-sharing") then return end

    local s64 = ply:SteamID64()
    local ownerS64 = ply:OwnerSteamID64()

    if ownerS64 == s64 then return end

    ply:Kick("[gWare] Family Sharing is not allowed!")
end)

-- auto-workshop-dl
hook.Add("gWare.Utils.SettingsLoaded", "gWare.Utils.WorkshopDownload" , function()
    if not gWare.Utils.GetSettingValue("auto-workshop-dl") then return end
    for _, addon in ipairs(engine.GetAddons()) do
        if not addon.mounted then return end

        resource.AddWorkshop(addon.wsid)
    end
end)

-- suicide
hook.Add("CanPlayerSuicide", "gWare.Utils.PreventSuicide", function(ply)
    if not gWare.Utils.GetSettingValue("suicide") then return end

    VoidLib.Notify(ply, L"notify_disallowed-suicide_name", L"notify_disallowed-suicide_desc", VoidUI.Colors.Red, 5)
    return false
end)

-- auto-cloak
local function hideWeapons(ply, shouldHide)
    for _, ent in ipairs(ents.GetAll()) do
        if (ent:GetParent() == ply) then
            ent:SetNoDraw(shouldHide)
        end
    end
end

local hiddenPlayers = {}

hook.Add("PlayerNoClip", "gWare.Utils.HandleNoclipVanish", function(ply, desiredNoClipState)
    if not gWare.Utils.GetSettingValue("auto-cloak") or desiredNoClipState == nil then return end

    -- NOTE - I know this is scuffed, but I dont really have a better solution
    if (ulx and not CAMI.PlayerHasAccess(ply, "ulx noclip")) or (SAM_LOADED and not ply:HasPermission("can_noclip")) or not ply:IsAdmin() then
        return
    end

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

-- npc-weapon-drop
hook.Add("OnNPCKilled", "gWare.Utils.DisableNPCWeaponDrop", function(npc, attacker, inflictor)
    if not gWare.Utils.GetSettingValue("npc-weapon-drop") then return end

    local npcWeapon = npc:GetActiveWeapon()
    if (IsValid(npcWeapon)) then
        npcWeapon:Remove()
    end
end)

-- toolgun-sounds
hook.Add("EntityEmitSound", "gWare.Utils.DisableToolGunSound", function(data)
    if not gWare.Utils.GetSettingValue("toolgun-sounds") then return end

    local ent = data.Entity

    if (ent:IsValid() and ent:IsPlayer() and ent:GetActiveWeapon():IsValid() and ent:GetActiveWeapon():GetClass() == "gmod_tool") then
        return false
    end
end)

-- billboards
local advertCommand

hook.Add("DarkRPFinishedLoading", "gWare.Utils.DisableBlackboard", function()
    advertCommand = DarkRP.getChatCommand("advert")

    if gWare.Utils.GetSettingValue("billboards") then
        for _, ent in ipairs(ents.FindByClass("darkrp_billboard")) do
            ent:Remove()
        end

        DarkRP.removeChatCommand("advert")
    end
end)

hook.Add("gWare.Utils.SettingChanged", "gWare.Utils.DisableBlackboard", function(settingID, settingValue)
    if settingID != "billboards" then return end

    if settingValue then
        for _, ent in ipairs(ents.FindByClass("darkrp_billboard")) do
            ent:Remove()
        end

        DarkRP.removeChatCommand("advert")
    else
        DarkRP.chatCommands["advert"] = table.Copy(advertCommand)
    end
end)

hook.Add("canAdvert", "gWare.Utils.DisableBlackboard", function(ply)
    if gWare.Utils.GetSettingValue("billboards") then return false end
end)

-- player-weapon-drop
hook.Add("canDropWeapon", "gWare.Utils.DisablePlayerWepDrop", function()
    return not gWare.Utils.GetSettingValue("player-weapon-drop")
end)


///////////////////////////
// IN-GAME CONFIGURATION //
///////////////////////////

// Options

gWare.Utils.AddSetting({
    id = "language",
    defaultValue = "english",
    settingType = "lang-dropdown"
})

gWare.Utils.AddSetting({
    id = "npc-weapon-drop",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "toolgun-sounds",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "toolgun-effects",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "auto-cloak",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "killfeed",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "suicide",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "player-weapon-drop",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "auto-workshop-dl",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "billboards",
    defaultValue = false,
    settingType = "bool",
    darkRP = true
})

gWare.Utils.AddSetting({
    id = "family-sharing",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "voice-panels",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "spawnmenu",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "contextmenu",
    defaultValue = false,
    settingType = "bool"
})

gWare.Utils.AddSetting({
    id = "hide-door-owner",
    defaultValue = false,
    settingType = "bool",
    darkRP = true
})

gWare.Utils.AddSetting({
    id = "hide-fpp-owner",
    defaultValue = false,
    settingType = "bool",
    darkRP = true
})

gWare.Utils.AddSetting({
    id = "hide-chat-indicator",
    defaultValue = false,
    settingType = "bool",
    darkRP = true
})

gWare.Utils.AddSetting({
    id = "encrypted-comms",
    defaultValue = {},
    settingType = "job_multi_select",
    darkRP = true
})

gWare.Utils.AddSetting({
    id = "decode",
    defaultValue = {},
    settingType = "job_multi_select",
    darkRP = true
})

gWare.Utils.AddSetting({
    id = "disable-name-completion",
    defaultValue = false,
    settingType = "bool"
})


// Disable Commands

gWare.Utils.AddSetting({
    id = "command_act",
    name = "act",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_advert",
    name = "advert",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_comms",
    name = "comms",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_encrypted-comms",
    name = "encrypted-comms",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_decode",
    name = "decode",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_looc",
    name = "looc",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_mact",
    name = "mact",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_me",
    name = "me",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_ooc",
    name = "ooc",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_roll",
    name = "roll",
    defaultValue = false,
    settingType = "command"
})

gWare.Utils.AddSetting({
    id = "command_unstuck",
    name = "unstuck",
    defaultValue = false,
    settingType = "command"
})


hook.Run("gWare.Utils.SettingsLoaded")