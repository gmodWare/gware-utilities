util.AddNetworkString("gWare.Utils.ClientReady")
util.AddNetworkString("gWare.Utils.SendSettingToClient")
util.AddNetworkString("gWare.Utils.SendJobsToClient")
util.AddNetworkString("gWare.Utils.UpdateServerBool")
util.AddNetworkString("gWare.Utils.UpdateServerString")
util.AddNetworkString("gWare.Utils.ChangeJobAccess")
util.AddNetworkString("gWare.Utils.AddNPC")
util.AddNetworkString("gWare.Utils.AddJobsToNPC")
util.AddNetworkString("gWare.Utils.DeleteJobsFromNPC")
util.AddNetworkString("gWare.Utils.DeleteNPC")
util.AddNetworkString("gWare.Utils.GetNPCSpawnsAndJobs")
util.AddNetworkString("gWare.Utils.SendNPCSpawnsToClient")
util.AddNetworkString("gWare.Utils.SendNPCJobsToClient")
util.AddNetworkString("gWare.Utils.UpdateNPCSpawn")
util.AddNetworkString("gWare.Utils.UpdateNPCJobs")
util.AddNetworkString("gWare.Utils.SendVoteToServer")
util.AddNetworkString("gWare.Utils.BroadcastVote")
util.AddNetworkString("gWare.Utils.SendResultToServer")
util.AddNetworkString("gWare.Utils.SendResultsToClients")
util.AddNetworkString("gWare.Utils.UpdateClients")

function gWare.Utils.SendNPCSpawnsAndJobsToClient(ply)
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

function gWare.Utils.SendSettingToClient(ply)
    local count = #gWare.Utils.Settings

    net.Start("gWare.Utils.SendSettingToClient")
        net.WriteUInt(count, 7)
        for _, settingsData in ipairs(gWare.Utils.Settings) do
            net.WriteString(settingsData.id)
            net.WriteType(settingsData.value)
            net.WriteString(settingsData.settingType)
        end
    net.Send(ply)
end

function gWare.Utils.SendJobsToClient(ply)
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

net.Receive("gWare.Utils.ClientReady", function(len, ply)
    hook.Run("gWare.Utils.ClientReady", ply)
end)

function gWare.Utils.SendEverythingToClient(ply)
    gWare.Utils.SendSettingToClient(ply)
    gWare.Utils.SendJobsToClient(ply)
    gWare.Utils.SendNPCSpawnsAndJobsToClient(ply)
end

hook.Add("gWare.Utils.ClientReady", "gWare.Utils.SendEverythingToClient", gWare.Utils.SendEverythingToClient)

function gWare.Utils.UpdateClients(index, settingValue)
    net.Start("gWare.Utils.UpdateClients")
        net.WriteUInt(index, 5)
        net.WriteType(settingValue)
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
    if not ply:HasGWarePermission("edit_settings") then return end

    local index = net.ReadUInt(5)
    local settingValue = net.ReadBool()

    gWare.Utils.ChangeSetting(index, settingValue)
end)

net.Receive("gWare.Utils.UpdateServerString", function(len, ply)
    if not ply:HasGWarePermission("edit_settings") then return end

    local index = net.ReadUInt(5)
    local settingValue = net.ReadString()

    gWare.Utils.ChangeSetting(index, settingValue)
end)

net.Receive("gWare.Utils.ChangeJobAccess", function(len, ply)
    if not ply:HasGWarePermission("edit_settings") then return end

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

net.Receive("gWare.Utils.AddNPC", function(len, ply)
    if not ply:HasGWarePermission("set_job_spawns") then return end

    local name = net.ReadString()
    local pos = net.ReadVector()

    gWare.Utils.UpdateNPCSpawn(name, pos)
    gWare.Utils.InsertNPCSpawn(name, pos)
end)

net.Receive("gWare.Utils.DeleteNPC", function(len, ply)
    if not ply:HasGWarePermission("set_job_spawns") then return end

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
    if not ply:HasGWarePermission("set_job_spawns") then return end

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
    if not ply:HasGWarePermission("set_job_spawns") then return end

    local name = net.ReadString()
    local jobCommand = net.ReadString()
    local index = gWare.Utils.GetJobIndexByCommand(jobCommand)

    DarkRP.removeTeamSpawnPos(index)

    gWare.Utils.UpdateNPCJobs(name, jobCommand)
    gWare.Utils.DeleteNPCJob(name, jobCommand)
end)

function gWare.Utils.BroadcastVote(voteTable)
    local count = #voteTable

    net.Start("gWare.Utils.BroadcastVote")
        net.WriteUInt(count, 3)
        for _, voteValue in ipairs(voteTable) do
            net.WriteString(voteValue)
        end
    net.Broadcast()

    timer.Simple(31, function()
        local result = 0
        local index = 1

        for answerIndex, votes in ipairs(gWare.Utils.Vote) do
            if votes > result then
                result = votes
                index = answerIndex
            end
        end

        net.Start("gWare.Utils.SendResultsToClients")
            net.WriteUInt(index, 3)
            net.WriteUInt(result, 7)
        net.Broadcast()
    end)
end

net.Receive("gWare.Utils.SendVoteToServer", function(len, ply)
    local count = net.ReadUInt(3)
    local values = {}

    table.Empty(gWare.Utils.Vote)
    table.Empty(gWare.Utils.VoteMember)

    for i = 1, count do
        local value = net.ReadString()

        table.insert(values, value)
    end

    for index, _ in ipairs(values) do
        if index == 1 then continue end

        gWare.Utils.Vote[index - 1] = 0
    end

    gWare.Utils.BroadcastVote(values)
end)

net.Receive("gWare.Utils.SendResultToServer", function(len, ply)
    if gWare.Utils.VoteMember[ply] then return end

    local index = net.ReadUInt(3)

    gWare.Utils.VoteMember[ply] = true
    gWare.Utils.Vote[index] = gWare.Utils.Vote[index] + 1
end)
