///////////////////////////
//       SETTINGS        //
///////////////////////////
hook.Add("gWare.Utils.ClientReady", "gWare.Utils.WaitingForClient", function()

    // Add hooks or functions in here, if u have to wait for client to get the settingsTable
    cvars.AddChangeCallback("gmod_drawtooleffects", function(convar_name, value_old, value_new)
        if (not gWare.Utils.GetSettingValue("toolgunEffects") and value_new == "1") then
            RunConsoleCommand("gmod_drawtooleffects", "0")
        end
    end)

    hook.Add("gWare.Utils.SettingChanged", "gWare.Utils.PreventToolGunEffect", function(setting, value)
        if (setting == "toolgunEffects" and value == false) then
            RunConsoleCommand("gmod_drawtooleffects", "0")
        end
    end)

    hook.Add("InitPostEntity", "gWare.Utils.PreventToolGunEffect", function()
        if (not gWare.Utils.GetSettingValue("toolgunEffects")) then
            RunConsoleCommand("gmod_drawtooleffects", "0")
        end
    end)

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
