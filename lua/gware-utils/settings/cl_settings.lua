///////////////////////////
//       SETTINGS        //
///////////////////////////
hook.Add("gWare.Utils.ClientReady", "gWare.Utils.WaitingForClient", function()

    // Add hooks or functions in here, if u have to wait for client to get the settingsTable

    hook.Add("DrawDeathNotice", "gWare.Utils.KillFeed", function()
        if gWare.Utils.GetSettingValue("disableKillfeed") then return end

        return false
    end)

    hook.Add("ContextMenuOpen", "gWare.Utils.DisableCMenu", function()
        if not gWare.Utils.GetSettingValue("disableContextmenu") then return end // TODO : add cami permission

        return false
    end)

    hook.Add( "SpawnMenuOpen", "gWare.Utils.DisallowSpawnMenu", function()
        if not gWare.Utils.GetSettingValue("disableSpawnmenu") then return end // TODO : add cami permission

        return false
    end)

end)
