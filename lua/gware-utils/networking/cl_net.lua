net.Receive("gWare.Utils.UpdateClient", function(len)
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