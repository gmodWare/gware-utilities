util.AddNetworkString("gWare.Utils.UpdateClient")
util.AddNetworkString("gWare.Utils.ClientReady")
util.AddNetworkString("gWare.Utils.SendSettingToClient")
util.AddNetworkString("gWare.Utils.SendJobsToClient")
util.AddNetworkString("gWare.Utils.UpdateServer")
util.AddNetworkString("gWare.Utils.ChangeJobAccess")

function gWare.Utils.SendSettingToClient(len, ply)
    local count = #gWare.Utils.Settings

    net.Start("gWare.Utils.SendSettingToClient")
        net.WriteUInt(count, 5)
        for _, settingsData in ipairs(gWare.Utils.Settings) do
            net.WriteString(settingsData.id)
            net.WriteString(settingsData.name)
            net.WriteString(settingsData.description)
            net.WriteBool(settingsData.value)
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

net.Receive("gWare.Utils.ClientReady", gWare.Utils.SendSettingToClient)
net.Receive("gWare.Utils.ClientReady", gWare.Utils.SendJobsToClient)

function gWare.Utils.UpdateClient(index, settingValue)
    net.Start("gWare.Utils.UpdateClient")
        net.WriteUInt(index, 5)
        net.WriteBool(settingValue)
    net.Broadcast()
end

net.Receive("gWare.Utils.UpdateServer", function(len, ply)
    local index = net.ReadUInt(5)
    local settingValue = net.ReadBool()

    gWare.Utils.ChangeSetting(index, settingValue)
end)

net.Receive("gWare.Utils.ChangeJobAccess", function(len, ply)
    local jobCommand = net.ReadString()
    local settingID = net.ReadString()

    if gWare.Utils.JobAccess[settingID][jobCommand] then
        gWare.Utils.JobAccess[settingID][jobCommand] = nil
        gWare.Utils.DeleteJob(jobCommand, settingID)

        return
    end

    gWare.Utils.JobAccess[settingID][jobCommand] = true
    gWare.Utils.InsertJob(jobCommand, settingID)
end)