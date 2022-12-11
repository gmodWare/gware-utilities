util.AddNetworkString("gWare.Utils.VoteSystem.SendVoteToAll")
util.AddNetworkString("gWare.Utils.ClientReady")
util.AddNetworkString("gWare.Utils.SendSettingToClient")
util.AddNetworkString("gWare.Utils.SendJobsToClient")
util.AddNetworkString("gWare.Utils.UpdateServerBool")
util.AddNetworkString("gWare.Utils.UpdateServerString")
util.AddNetworkString("gWare.Utils.ChangeJobAccess")
util.AddNetworkString("gWare.Utils.VoteSystem.SendVoteToServer")
util.AddNetworkString("gWare.Utils.JobSetter.SetJob")
util.AddNetworkString("gWare.Utils.AddNPC")
util.AddNetworkString("gWare.Utils.AddJobsToNPC")
util.AddNetworkString("gWare.Utils.DeleteJobsFromNPC")
util.AddNetworkString("gWare.Utils.DeleteNPC")
util.AddNetworkString("gWare.Utils.GetNPCSpawnsAndJobs")
util.AddNetworkString("gWare.Utils.SendNPCSpawnsToClient")
util.AddNetworkString("gWare.Utils.SendNPCJobsToClient")
util.AddNetworkString("gWare.Utils.UpdateNPCSpawn")
util.AddNetworkString("gWare.Utils.UpdateNPCJobs")
util.AddNetworkString("gWare.Utils.UpdateVoteNum")
util.AddNetworkString("gWare.Utils.UpdateVoteNumToClient")


function gWare.Utils.SendNPCSpawnsAndJobsToClient(len, ply)
    local npcSpawnsCount = table.Count(gWare.Utils.NPCSpawns)

    net.Start("gWare.Utils.SendNPCSpawnsToClient")
        net.WriteUInt(npcSpawnsCount, 7)
        for npcName, npcPos in pairs(gWare.Utils.NPCSpawns) do
            net.WriteString(npcName)
            net.WriteVector(npcPos)
        end
    net.Send(ply)

    local npcJobsCount = table.Count(gWare.Utils.NPCJobs)

    net.Start("gWare.Utils.SendNPCJobsToClient")
        net.WriteUInt(npcJobsCount, 7)
        for npcName, data in pairs(gWare.Utils.NPCJobs) do
            local dataCount = table.Count(data)

            net.WriteUInt(dataCount, 7)
            net.WriteString(npcName)

            for jobCommand, _ in pairs(data) do
                net.WriteString(jobCommand)
            end
        end
    net.Send(ply)
end

function gWare.Utils.SendSettingToClient(len, ply)
    local count = #gWare.Utils.Settings

    net.Start("gWare.Utils.SendSettingToClient")
        net.WriteUInt(count, 7)
        for _, settingsData in ipairs(gWare.Utils.Settings) do
            net.WriteString(settingsData.id)
            net.WriteString(settingsData.name)
            net.WriteString(settingsData.description)
            net.WriteType(settingsData.value)
            net.WriteString(settingsData.settingType)
        end
    net.Send(ply)
end

function gWare.Utils.SendJobsToClient(len, ply)
    local count = table.Count(gWare.Utils.JobAccess)

    net.Start("gWare.Utils.SendJobsToClient")
        net.WriteUInt(count, 7)
        for settingID, jobData in pairs(gWare.Utils.JobAccess) do
            local jobDataCount = table.Count(jobData)

            net.WriteUInt(jobDataCount, 7)
            net.WriteString(settingID)

            for jobCommand, _ in pairs(jobData) do
                net.WriteString(jobCommand)
            end
        end
    net.Send(ply)
end

function gWare.Utils.SendEverythingToClient(len, ply)
    gWare.Utils.SendSettingToClient(len, ply)
    gWare.Utils.SendJobsToClient(len, ply)
    gWare.Utils.SendNPCSpawnsAndJobsToClient(len, ply)
end

net.Receive("gWare.Utils.ClientReady", gWare.Utils.SendEverythingToClient)

function gWare.Utils.UpdateClient(index, settingValue)
    net.Start("gWare.Utils.UpdateClient")
        net.WriteUInt(index, 5)
        net.WriteBool(settingValue)
    net.Broadcast()
end

function gWare.Utils.UpdateNPCSpawn(name, pos)
    net.Start("gWare.Utils.UpdateNPCSpawn")
        net.WriteString(name)
        net.WriteVector(pos)
    net.Broadcast()

    gWare.Utils.NPCJobs[name] = gWare.Utils.NPCJobs[name] or {}

    if gWare.Utils.NPCSpawns[name] then
        gWare.Utils.NPCJobs[name] = nil
        gWare.Utils.NPCSpawns[name] = nil
        return
    end

    gWare.Utils.NPCSpawns[name] = pos
end

function gWare.Utils.UpdateNPCJobs(name, jobCommand)
    net.Start("gWare.Utils.UpdateNPCJobs")
        net.WriteString(name)
        net.WriteString(jobCommand)
    net.Broadcast()

    gWare.Utils.NPCJobs[name] = gWare.Utils.NPCJobs[name] or {}

    if gWare.Utils.NPCJobs[name][jobCommand] then
        gWare.Utils.NPCJobs[name][jobCommand] = nil
        return
    end

    gWare.Utils.NPCJobs[name][jobCommand] = true
end

net.Receive("gWare.Utils.UpdateServerBool", function(len, ply)
    //if not ply:HasGWarePermission("can_change_gware_settings") then return end

    local index = net.ReadUInt(5)
    local settingValue = net.ReadBool()

    gWare.Utils.ChangeSetting(index, settingValue)
end)

net.Receive("gWare.Utils.UpdateServerString", function(len, ply)
    //if not ply:HasGWarePermission("can_change_gware_settings") then return end

    local index = net.ReadUInt(5)
    local settingValue = net.ReadString()

    gWare.Utils.ChangeSetting(index, settingValue)
end)

net.Receive("gWare.Utils.ChangeJobAccess", function(len, ply)
    if not ply:HasGWarePermission("can_change_gware_settings") then return end

    local jobCommand = net.ReadString()
    local settingID = net.ReadString()

    gWare.Utils.JobAccess[settingID] = gWare.Utils.JobAccess[settingID] or {}

    if gWare.Utils.JobAccess[settingID][jobCommand] then
        gWare.Utils.JobAccess[settingID][jobCommand] = nil
        gWare.Utils.DeleteJob(jobCommand, settingID)
        return
    end

    gWare.Utils.JobAccess[settingID][jobCommand] = true
    gWare.Utils.InsertJob(jobCommand, settingID)
end)

net.Receive("gWare.Utils.VoteSystem.SendVoteToServer", function(len, ply)
    local question = net.ReadString()
    local value = net.ReadString()
    local num = net.ReadUInt(3)

    print("Read Informations!")

    local valueTBL = {}

    for i = 1, num do
        valueTBL[#valueTBL + 1] = {
            name = value,
        }
    end

    PrintTable(valueTBL)

    net.Start("gWare.Utils.VoteSystem.SendVoteToAll")
        net.WriteString(question)
        net.WriteTable(valueTBL)
    net.Broadcast()
end)

net.Receive("gWare.Utils.JobSetter.SetJob", function(len, ply)
    local job = net.ReadString()
    local ent = net.ReadEntity()

    -- TODO: refactor this name wtf?!
    if not ply:HasGWarePermission("can_set_jobs-spawns_gware_tool") then return end

    local setTeam = target_ply.changeTeam or target_ply.SetTeam
    setTeam(ent, job, true)
end)

net.Receive("gWare.Utils.AddNPC", function(len, ply)
    if not ply:HasGWarePermission("can_set_jobs-spawns_gware_tool") then return end

    local name = net.ReadString()
    local pos = net.ReadVector()

    gWare.Utils.UpdateNPCSpawn(name, pos)
    gWare.Utils.InsertNPCSpawn(name, pos)
end)

net.Receive("gWare.Utils.DeleteNPC", function(len, ply)
    if not ply:HasGWarePermission("can_set_jobs-spawns_gware_tool") then return end

    local name = net.ReadString()

    gWare.Utils.GetNPCJobs(name, function(tblData)
        for _, jobData in ipairs(tblData) do
            local jobCommand = jobData.job_command
            local index = gWare.Utils.GetJobIndexByCommand(jobCommand)

            DarkRP.removeTeamSpawnPos(index)
        end
    end)

    gWare.Utils.UpdateNPCSpawn(name, Vector(zero))
    gWare.Utils.DeleteAllNPCJobs(name)
    gWare.Utils.DeleteNPCSpawn(name)
end)

net.Receive("gWare.Utils.AddJobsToNPC", function(len, ply)
    if not ply:HasGWarePermission("can_set_jobs-spawns_gware_tool") then return end

    local name = net.ReadString()
    local jobCommand = net.ReadString()
    local index = gWare.Utils.GetJobIndexByCommand(jobCommand)
    local pos = gWare.Utils.NPCSpawns[name]

    DarkRP.removeTeamSpawnPos(index)
    DarkRP.addTeamSpawnPos(index, pos)

    gWare.Utils.UpdateNPCJobs(name, jobCommand)
    gWare.Utils.InsertNPCJob(name, jobCommand)
end)

net.Receive("gWare.Utils.DeleteJobsFromNPC", function(len, ply)
    if not ply:HasGWarePermission("can_set_jobs-spawns_gware_tool") then return end

    local name = net.ReadString()
    local jobCommand = net.ReadString()
    local index = gWare.Utils.GetJobIndexByCommand(jobCommand)

    DarkRP.removeTeamSpawnPos(index)

    gWare.Utils.UpdateNPCJobs(name, jobCommand)
    gWare.Utils.DeleteNPCJob(name, jobCommand)
end)

net.Receive("gWare.Utils.UpdateVoteNum", function(len, ply)
    local value = 1

    net.Start("gWare.Utils.UpdateVoteNumToClient")
        net.WriteUInt(value, 1)
    net.Broadcast()
end)