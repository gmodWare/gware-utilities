gWare.Utils.Settings = gWare.Utils.Settings or {}
gWare.Utils.IDs = gWare.Utils.IDs or {}
gWare.Utils.JobAccess = gWare.Utils.JobAccess or {}
gWare.Utils.NPCSpawns = gWare.Utils.NPCSpawns or {}
gWare.Utils.NPCJobs = gWare.Utils.NPCJobs or {}

function gWare.Utils.GetSettingValue(index)
    return gWare.Utils.Settings[gWare.Utils.IDs[index]].value
end

function gWare.Utils.HasJobAccess(settingID, ply)
    local command = ply:getJobTable().command

    if gWare.Utils.JobAccess[settingID][command] then
        return true
    end

    return false
end

