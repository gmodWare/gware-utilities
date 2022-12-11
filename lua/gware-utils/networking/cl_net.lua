net.Receive("gWare.Utils.SendSettingToClient", function(len)
    local count = net.ReadUInt(7)

    for i = 1, count do
        local settingID = net.ReadString()
        local settingName = net.ReadString()
        local settingDescription = net.ReadString()
        local settingValue = net.ReadType()
        local settingType = net.ReadString()

        gWare.Utils.Settings[i] = { id = settingID, name = settingName, description = settingDescription, value = settingValue, settingType = settingType}
        gWare.Utils.IDs[settingID] = i
    end

    hook.Run("gWare.Utils.ClientReady", LocalPlayer())
end)

net.Receive("gWare.Utils.SendJobsToClient", function(len)
    local count = net.ReadUInt(7)

    for i = 1, count do
        local jobDataCount = net.ReadUInt(7)
        local settigID = net.ReadString()

        for j = 1, jobDataCount do
            local jobCommand = net.ReadString()

            gWare.Utils.JobAccess[settigID] = gWare.Utils.JobAccess[settigID] or {}
            gWare.Utils.JobAccess[settigID][jobCommand] = true
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

hook.Add("InitPostEntity", "gWare.Utils.ClientReady", function()
    net.Start("gWare.Utils.ClientReady")
    net.SendToServer()
end)

function gWare.Utils.UpdateSettingBool(index, settingValue)
    net.Start("gWare.Utils.UpdateServerBool")
        net.WriteUInt(index, 5)
        net.WriteBool(settingValue)
    net.SendToServer()

    gWare.Utils.Settings[index].value = settingValue

    hook.Run("gWare.Utils.SettingChanged", gWare.Utils.Settings[index].id, settingValue)
end

function gWare.Utils.UpdateSettingString(index, settingValue)
    net.Start("gWare.Utils.UpdateServerString")
        net.WriteUInt(index, 5)
        net.WriteString(settingValue)
    net.SendToServer()

    gWare.Utils.Settings[index].value = settingValue

    hook.Run("gWare.Utils.SettingChanged", gWare.Utils.Settings[index].id, settingValue)
end

function gWare.Utils.ChangeJobAccess(jobCommand, settingID)
    gWare.Utils.JobAccess[settingID] = gWare.Utils.JobAccess[settingID] or {}

    if gWare.Utils.JobAccess[settingID][jobCommand] then
        gWare.Utils.JobAccess[settingID][jobCommand] = nil
    else
        gWare.Utils.JobAccess[settingID][jobCommand] = true
    end

    net.Start("gWare.Utils.ChangeJobAccess")
        net.WriteString(jobCommand)
        net.WriteString(settingID)
    net.SendToServer()
end

local function sc(x)
    return x / 1080 * ScrH()
end

net.Receive("gWare.Utils.VoteSystem.SendVoteToAll", function()
    local question = net.ReadString()
    local answersTbl = net.ReadTable()

    local voteFrame = vgui.Create("VoidUI.Frame")
    voteFrame:SSetSize(350, 450)
    voteFrame:SetPos(sc(50), sc(150))
    voteFrame:SetTitle(question)

    local scrollbar = voteFrame:Add("VoidUI.ScrollPanel")
    scrollbar:Dock(FILL)
    scrollbar:SDockMargin(5, 5, 5, 5)

    for k, v in ipairs(answersTbl) do
        local number = 0

        local answers = scrollbar:Add("VoidUI.Button")
        answers:SSetSize(300, 55)
        answers:Dock(TOP)
        answers:DockMargin(10, 10, 10, 10)
        answers:SetText(v.name .. "(" .. number .. ")")
        answers.DoClick = function()
            net.Start("gWare.Utils.UpdateVoteNum")
            net.SendToServer()

            net.Receive("gWare.Utils.UpdateVoteNumToClient", function()
                local newNum = number + net.ReadUInt(1)

                answers:SetText(v .. "(" .. newNum .. ")")

                timer.Create("RemoveFrame", 150, 1, function()
                    voteFrame:Close()
                end)
            end)
        end
    end
end)

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