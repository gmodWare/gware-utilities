///////////////////////////
//       SETTINGS        //
///////////////////////////

hook.Add("gWare.Utils.ClientReady", "gWare.Utils.WaitingForClient", function()

    -- Add hooks or functions in here, if u have to wait for client to get the settingsTable
    cvars.AddChangeCallback("gmod_drawtooleffects", function(convar_name, value_old, value_new)
        if (gWare.Utils.GetSettingValue("toolgun-effects") and value_new == "1") then
            RunConsoleCommand("gmod_drawtooleffects", "0")
        end
    end)

    hook.Add("gWare.Utils.SettingChanged", "gWare.Utils.PreventToolGunEffect", function(setting, value)
        if (setting == "toolgunEffects" and value == false) then
            RunConsoleCommand("gmod_drawtooleffects", "0")
        end
    end)

    hook.Add("InitPostEntity", "gWare.Utils.PreventToolGunEffect", function()
        if (gWare.Utils.GetSettingValue("toolgun-effects")) then
            RunConsoleCommand("gmod_drawtooleffects", "0")
        end
    end)
 
    hook.Add("DrawDeathNotice", "gWare.Utils.KillFeed", function()
        if gWare.Utils.GetSettingValue("killfeed") then return end

        return false
    end)

    hook.Add("ContextMenuOpen", "gWare.Utils.DisableCMenu", function()
        if not gWare.Utils.GetSettingValue("contextmenu") then return end

        return false
    end)

    hook.Add( "SpawnMenuOpen", "gWare.Utils.DisallowSpawnMenu", function()
        if not gWare.Utils.GetSettingValue("spawnmenu") then return end

        return false
    end)
end)
