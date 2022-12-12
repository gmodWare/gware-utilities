gWare.Utils.Settings = gWare.Utils.Settings or {}
gWare.Utils.IDs = gWare.Utils.IDs or {}
gWare.Utils.JobAccess = gWare.Utils.JobAccess or {}
gWare.Utils.NPCSpawns = gWare.Utils.NPCSpawns or {}
gWare.Utils.NPCJobs = gWare.Utils.NPCJobs or {}

function gWare.Utils.GetSettingValue(index)
    local id = gWare.Utils.IDs[index]

    if not id then
        error("Setting id '" .. tostring(index) .. "' does not exist!")
    end

    return gWare.Utils.Settings[id].value
end

function gWare.Utils.HasJobAccess(settingID, ply)
    local command = ply:getJobTable().command

    if not gWare.Utils.JobAccess[settingID] then
        return false
    end

    if gWare.Utils.JobAccess[settingID][command] then
        return true
    end

    return false
end

