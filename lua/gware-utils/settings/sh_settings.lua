gWare.Utils.Settings = gWare.Utils.Settings  or {}

gWare.Utils.GetAllSettings(function (settingName, settingValue)
    gWare.Utils.Settings[settingName] = settingValue
end)

function gWare.Utils.GetSettingValue(settingName)
    local val = false

    gWare.Utils.GetSetting(settingName, function (settingValue)
        val = settingValue
    end)

    return val
end


