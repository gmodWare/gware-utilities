net.Receive("gWare.Utils.SendSettingToClient", function(len)
    local count = net.ReadUInt(5)

    for i = 1, count do
        local settingID = net.ReadString()
        local settingName = net.ReadString()
        local settingDescription = net.ReadString()
        local settingValue = net.ReadBool()
        local settingType = net.ReadString()

        gWare.Utils.Settings[i] = { name = settingName, description = settingDescription, value = settingValue, settingType = settingType}
        gWare.Utils.IDs[settingID] = i
    end

    hook.Run("gWare.Utils.ClientReady")
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

hook.Add("InitPostEntity", "gWare.Utils.ClientReady", function()
    net.Start("gWare.Utils.ClientReady")
    net.SendToServer()
end)

net.Receive("gWare.Utils.UpdateClient", function(len)
    local index = net.ReadUInt(5)
    local settingValue = net.ReadBool()

    gWare.Utils.Settings[index].value = settingValue
end)

function gWare.Utils.UpdateSetting(index, settingValue)
    net.Start("gWare.Utils.UpdateServer")
        net.WriteUInt(index, 5)
        net.WriteBool(settingValue)
    net.SendToServer()
end

function gWare.Utils.ChangeJobAccess(jobCommand, settingID)
    if gWare.Utils.JobAccess[settingID][jobCommand] then
        gWare.Utils.JobAccess[settingID][jobCommand] = nil
    end

    if not gWare.Utils.JobAccess[settingID][jobCommand] then
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
        local answers = scrollbar:Add("VoidUI.Button")
        answers:SSetSize(300, 55)
        answers:Dock(TOP)
        answers:DockMargin(10, 10, 10, 10)
        answers:SetText(v.value)
    end
end)