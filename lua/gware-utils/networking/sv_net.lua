util.AddNetworkString("gWare.Utils.UpdateClient")
util.AddNetworkString("gWare.Utils.ClientReady")

function gWare.Utils.UpdateClient(len, ply)
    local count = table.Count(gWare.Utils.Settings)

    net.Start("gWare.Utils.UpdateClient")
        net.WriteUInt(count, 5)
    for _, settingsData in pairs(gWare.Utils.Settings) do
        net.WriteString(settingsData.name)
        net.WriteString(settingsData.description)
        net.WriteBool(settingsData.defaultValue)
        net.WriteString(settingsData.settingType)
    end
    net.Send(ply)
end

net.Receive("gWare.Utils.ClientReady", gWare.Utils.UpdateClient)