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

hook.Add("PlayerSay", "gWare.Utils.SendMenu", function(ply, text)
    if text:lower():StartWithAny("!gware", "/gware", "!gw", "/gw") then
        if not ply:HasGWarePermission("edit_settings") then
            VoidLib.Notify(ply, gWare.Utils.Lang.GetPhrase("notify_no-permissions_name"), gWare.Utils.Lang.GetPhrase("notify_no-permissions_desc"), VoidUI.Colors.Red, 6)
            return
        end

        net.Start("gWare.Utils.SendMenu")
        net.Send(ply)

        return ""
    end
end)