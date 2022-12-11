hook.Add("gWare.Utils.ClientReady", "gWare.Utils.CheckDependency", function(ply)
    if (not ply:IsSuperAdmin() or gWare.Utils.Loaded) then return end

    ply:PrintMessage(HUD_PRINTCONSOLE, "For gWare to work, you need to install VoidLib. You can download it here: \nhttps://steamcommunity.com/sharedfiles/filedetails/?id=2078529432")
    ply:ChatPrint("For gWare to work, you need to install VoidLib. You can download it here: \nhttps://steamcommunity.com/sharedfiles/filedetails/?id=2078529432")
end)