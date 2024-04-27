local L = function() end

hook.Add("Utils.Lang.LanguagesLoaded", "gWare.net.waitForLang", function()
    L = gWare.Utils.Lang.GetPhrase
end)

net.Receive("gWare.Utils.SendSettingToClient", function(len)
    local count = net.ReadUInt(7)

    for i = 1, count do
        local settingID = net.ReadString()
        local settingValue = net.ReadType()
        local settingType = net.ReadString()
        local darkRP = net.ReadBool()

        gWare.Utils.Settings[i] = { id = settingID, value = settingValue, settingType = settingType, darkRP = darkRP }
        gWare.Utils.IDs[settingID] = i
    end

    local languageID = gWare.Utils.IDs["language"]
    local loadedLanguage = languageID and gWare.Utils.Settings[languageID]
    gWare.Utils.Config.Language = loadedLanguage and loadedLanguage.value or "english"

    hook.Run("gWare.Utils.ClientReady", LocalPlayer())
end)

net.Receive("gWare.Utils.SendJobsToClient", function(len)
    local count = net.ReadUInt(7)

    for i = 1, count do
        local jobDataCount = net.ReadUInt(7)
        local settingID = net.ReadString()

        for j = 1, jobDataCount do
            local jobCommand = net.ReadString()

            gWare.Utils.JobAccess[settingID] = gWare.Utils.JobAccess[settingID] or {}
            gWare.Utils.JobAccess[settingID][jobCommand] = true
        end
    end
end)

net.Receive("gWare.Utils.SendNPCSpawnsToClient", function(len)
    local count = net.ReadUInt(7)

    for i = 1, count do
        local name = net.ReadString()
        local pos = net.ReadVector()

        gWare.Utils.NPCSpawns[name] = pos
    end
end)

net.Receive("gWare.Utils.SendNPCJobsToClient", function(len)
    local count = net.ReadUInt(7)

    for i = 1, count do
        local dataCount = net.ReadUInt(7)
        local name = net.ReadString()

        gWare.Utils.NPCJobs[name] = gWare.Utils.NPCJobs[name] or {}

        for j = 1, dataCount do
            local jobCommand = net.ReadString()

            gWare.Utils.NPCJobs[name][jobCommand] = true
        end
    end
end)

net.Receive("gWare.Utils.UpdateClients", function()
    local index = net.ReadUInt(5)
    local settingValue = net.ReadType()

    if not gWare.Utils.Settings[index] then return end

    if gWare.Utils.Settings[index].id == "language" then
        RunConsoleCommand("spawnmenu_reload")
        gWare.Utils.Config.Language = settingValue
    end

    gWare.Utils.Settings[index].value = settingValue

    hook.Run("gWare.Utils.SettingChanged", gWare.Utils.Settings[index].id, settingValue)
end)

hook.Add("InitPostEntity", "gWare.Utils.ClientReady", function()
    net.Start("gWare.Utils.ClientReady")
    net.SendToServer()
end)

function gWare.Utils.UpdateSettingBool(index, settingValue)
    net.Start("gWare.Utils.UpdateServerBool")
        net.WriteUInt(index, 5)
        net.WriteBool(settingValue)
    net.SendToServer()

    if not gWare.Utils.Settings[index] then return end

    gWare.Utils.Settings[index].value = settingValue
end

function gWare.Utils.UpdateSettingString(index, settingValue)
    net.Start("gWare.Utils.UpdateServerString")
        net.WriteUInt(index, 5)
        net.WriteString(settingValue)
    net.SendToServer()

    if not gWare.Utils.Settings[index] then return end

    gWare.Utils.Settings[index].value = settingValue
end

function gWare.Utils.ChangeJobAccess(jobCommand, settingID)
    net.Start("gWare.Utils.ChangeJobAccess")
        net.WriteString(jobCommand)
        net.WriteString(settingID)
    net.SendToServer()
end

function gWare.Utils.SendVoteToServer(voteTable)
    local count = #voteTable

    net.Start("gWare.Utils.SendVoteToServer")
        net.WriteUInt(count, 3)
        for _, voteValue in ipairs(voteTable) do
            net.WriteString(voteValue)
        end
    net.SendToServer()
end

function gWare.Utils.AddNPC(npcName, npcPos)
    net.Start("gWare.Utils.AddNPC")
        net.WriteString(npcName)
        net.WriteVector(npcPos)
    net.SendToServer()
end

function gWare.Utils.DeleteNPC(npcName)
    net.Start("gWare.Utils.DeleteNPC")
        net.WriteString(npcName)
    net.SendToServer()
end

function gWare.Utils.AddJobsToNPC(npcName, jobCommand)
    net.Start("gWare.Utils.AddJobsToNPC")
        net.WriteString(npcName)
        net.WriteString(jobCommand)
    net.SendToServer()
end

function gWare.Utils.DeleteJobsFromNPC(npcName, jobCommand)
    net.Start("gWare.Utils.DeleteJobsFromNPC")
        net.WriteString(npcName)
        net.WriteString(jobCommand)
    net.SendToServer()
end

net.Receive("gWare.Utils.UpdateNPCSpawn", function(len)
    local name = net.ReadString()
    local pos = net.ReadVector()

    gWare.Utils.NPCJobs[name] = gWare.Utils.NPCJobs[name] or {}

    if gWare.Utils.NPCSpawns[name] then
        gWare.Utils.NPCJobs[name] = nil
        gWare.Utils.NPCSpawns[name] = nil
        return
    end

    gWare.Utils.NPCSpawns[name] = pos
end)

net.Receive("gWare.Utils.UpdateNPCJobs", function(len)
    local name = net.ReadString()
    local jobCommand = net.ReadString()

    gWare.Utils.NPCJobs[name] = gWare.Utils.NPCJobs[name] or {}

    if gWare.Utils.NPCJobs[name][jobCommand] then
        gWare.Utils.NPCJobs[name][jobCommand] = nil
        return
    end

    gWare.Utils.NPCJobs[name][jobCommand] = true
end)

net.Receive("gWare.Utils.BroadcastVote", function()
    local count = net.ReadUInt(3)

    table.Empty(gWare.Utils.Vote)

    for i = 1, count do
        local value = net.ReadString()

        gWare.Utils.Vote[i] = value
    end

    local voteMenu = vgui.Create("gWare.Utils.VoteMenu")
    voteMenu:SetValueTable(gWare.Utils.Vote)
    voteMenu:Vote()
end)

net.Receive("gWare.Utils.SendResultsToClients", function(len)
    local winningAnswerIndex = net.ReadUInt(3) + 1
    local result = net.ReadUInt(7)
    local answerResult = gWare.Utils.Vote[winningAnswerIndex]

    local text = result > 0 and L"vote_winner" or L"vote_winner_none"

    if result == 0 then
        gWare.Utils.PrintCommand("vote", text .. " :c")

        return
    end

    gWare.Utils.PrintCommand("vote", answerResult .. " | " .. text .. " [" .. result .. "]!")
end)

net.Receive("gWare.Utils.BroadcastUpdatedJobAccess", function(lem)
    local jobCommand = net.ReadString()
    local settingID = net.ReadString()

    gWare.Utils.JobAccess[settingID] = gWare.Utils.JobAccess[settingID] or {}

    if gWare.Utils.JobAccess[settingID][jobCommand] then
        gWare.Utils.JobAccess[settingID][jobCommand] = nil
        return
    end

    gWare.Utils.JobAccess[settingID][jobCommand] = true
end)
