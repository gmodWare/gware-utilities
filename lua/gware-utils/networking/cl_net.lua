net.Receive("gWare.Utils.SendSettingToClient", function(len)
    local count = net.ReadUInt(5)

    for i = 1, count do
        local settingName = net.ReadString()
        local settingDescription = net.ReadString()
        local settingValue = net.ReadBool()
        local settingType = net.ReadString()

        gWare.Utils.Settings[i] = { name = settingName, description = settingDescription, value = settingValue, settingType = settingType}
    end

    hook.Run("gWare.Utils.ClientReady")
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