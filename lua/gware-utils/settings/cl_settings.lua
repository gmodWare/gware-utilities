///////////////////////////
//       SETTINGS        //
///////////////////////////
hook.Add("gWare.Utils.ClientReady", "gWare.Utils.WaitingForClient", function()

    // Add hooks or functions in here, if u have to wait for client to get the settingsTable

    hook.Add("DrawDeathNotice", "gWare.Utils.KillFeed", function()
        local index = 5
        if not gWare.Utils.GetSettingValue(index) then return end

        return false
    end)
end)
