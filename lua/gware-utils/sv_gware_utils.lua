local voidlibStr = [[
[]=============================================================================[]
    For gWare to work, you need to install VoidLib. You can download it here:
    https://steamcommunity.com/sharedfiles/filedetails/?id=2078529432
[]=============================================================================[] 
]]

hook.Add("gWare.Utils.ClientReady", "gWare.Utils.CheckDependency", function(ply)
    if (gWare.Utils.Loaded or not ply:IsSuperAdmin()) then return end

    ply:PrintMessage(HUD_PRINTCONSOLE, voidlibStr)
    ply:ChatPrint(voidlibStr)
end)