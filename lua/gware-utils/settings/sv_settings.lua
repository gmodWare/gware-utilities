local function getSetting(name)
    local val = false

    gWare.Utils.GetSetting(name, function(tblData)
        if tblData then val = true end
    end)

    return val
end

function gWare.Utils.AddSetting(tblData)
    gWare.Utils.Settings[tblData.name] = {name = tblData.name, description = tblData.description, value = tblData.defaultValue, settingType = tblData.settingType}

    timer.Simple(0, function()
        hook.Run("gWare.Utils.SettingsLoaded")
    end)

    if getSetting(tblData.name) then return end
    gWare.Utils.InsertSetting(tblData.name, tblData.defaultValue)
end

hook.Add("gWare.Utils.SettingsLoaded", "gWare.Utils.CacheSettings", function()
    gWare.Utils.GetAllSettings(function (tblData)
        for _, settings in ipairs(tblData) do
            local settingName = settings.setting_name
            local settingValue = gWare.Utils.IntToBool(tonumber(settings.setting_value))

            gWare.Utils.Settings[settingName].value = settingValue
        end
    end)
end)

gWare.Utils.AddSetting({
    name = "kxx",
    description = "kxx ist toll",
    defaultValue = false,
    settingType = "bool"
})
gWare.Utils.AddSetting({
    name = "menschlich",
    description = "menschlich ist toll",
    defaultValue = true,
    settingType = "bool"
})
gWare.Utils.AddSetting({
    name = "ryzen",
    description = "ryzen ist toll",
    defaultValue = true,
    settingType = "bool"
})