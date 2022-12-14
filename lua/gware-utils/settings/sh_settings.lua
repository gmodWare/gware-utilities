gWare.Utils.Settings = gWare.Utils.Settings or {}
gWare.Utils.IDs = gWare.Utils.IDs or {}
gWare.Utils.JobAccess = gWare.Utils.JobAccess or {}
gWare.Utils.NPCSpawns = gWare.Utils.NPCSpawns or {}
gWare.Utils.NPCJobs = gWare.Utils.NPCJobs or {}
gWare.Utils.Vote = gWare.Utils.Vote or {}
gWare.Utils.VoteMember = gWare.Utils.VoteMember or {}

gWare.Utils.Config = gWare.Utils.Config or {}
gWare.Utils.Config.Language = gWare.Utils.Config.Language or "english"

function gWare.Utils.GetSettingValue(index)
    local id = gWare.Utils.IDs[index]

    if not id then
        error("Setting id '" .. tostring(index) .. "' does not exist!")
    end

    return gWare.Utils.Settings[id].value
end

function gWare.Utils.HasJobAccess(settingID, ply)
    if (not DarkRP) then return true end

    local command = ply:getJobTable().command

    if not gWare.Utils.JobAccess[settingID] then
        return false
    end

    if gWare.Utils.JobAccess[settingID][command] then
        return true
    end

    return false
end
