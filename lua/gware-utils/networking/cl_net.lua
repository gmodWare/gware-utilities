net.Receive("gWare.Utils.SendSettingToClient", function(len)
    local count = net.ReadUInt(5)

    for i = 1, count do
        local settingName = net.ReadString()
        local settingDescription = net.ReadString()
        local settingValue = net.ReadBool()
        local settingType = net.ReadString()

        gWare.Utils.Settings[settingName] = { name = settingName, description = settingDescription, value = settingValue, settingType = settingType}
    end
end)

hook.Add("InitPostEntity", "gWare.Utils.ClientReady", function()
    net.Start("gWare.Utils.ClientReady")
    net.SendToServer()
end)

net.Receive("gWare.Utils.UpdateClient", function(len)
    local name = net.ReadString
    local val = net.ReadBool

    gWare.Utils.Settings[name].value = val
end)

function gWare.Utils.UpdateSetting(settingName, settingValue)
    net.Start("gWare.Utils.UpdateServer")
        net.WriteString(settingName)
        net.WriteBool(settingValue)
    net.SendToServer()
end