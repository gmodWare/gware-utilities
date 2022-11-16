gWare.Utils.Settings = gWare.Utils.Settings or {}
gWare.Utils.IDs = gWare.Utils.IDs or {}

function gWare.Utils.GetSettingValue(index)
    return gWare.Utils.Settings[gWare.Utils.IDs[index]].value
end