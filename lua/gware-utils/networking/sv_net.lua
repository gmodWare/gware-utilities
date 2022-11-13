util.AddNetworkString("gWare.Utils.UpdateClient")
util.AddNetworkString("gWare.Utils.ClientReady")
util.AddNetworkString("gWare.Utils.SendSettingToClient")
util.AddNetworkString("gWare.Utils.UpdateServer")

function gWare.Utils.SendSettingToClient(len, ply)
    local count = table.Count(gWare.Utils.Settings)

    net.Start("gWare.Utils.SendSettingToClient")
        net.WriteUInt(count, 5)
    for _, settingsData in pairs(gWare.Utils.Settings) do
        net.WriteString(settingsData.name)
        net.WriteString(settingsData.description)
        net.WriteBool(settingsData.value)
        net.WriteString(settingsData.settingType)
    end
    net.Send(ply)
end

function gWare.Utils.UpdateClient(settingName, settingValue)
    net.Start("gWare.Utils.UpdateClient")
        net.WriteString(settingName)
        net.WriteBool(settingValue)
    net.Broadcast()
end

net.Receive("gWare.Utils.ClientReady", gWare.Utils.SendSettingToClient)

net.Receive("gWare.Utils.UpdateServer", function(len, ply)
    local settingName = net.ReadString()
    local settingValue = net.ReadBool()

    gWare.Utils.ChangeSetting(settingName, settingValue)
end)