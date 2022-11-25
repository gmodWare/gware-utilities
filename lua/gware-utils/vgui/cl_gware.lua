local function OpenMenu()
    vgui.Create("gWare.Utils.Frame")
end

hook.Add("OnPlayerChat", "gWare.Utils.OpenSettingsMenu1", function(ply, text)
    if LocalPlayer() != ply then return end

    if text:lower():StartWithAny("!gware", "/gware", "!gw", "/gw") then
        OpenMenu()

        return true
    end
end)

list.Set("DesktopWindows", "gware_settings", {
    title = "gWare",
    icon = "gware/gware_icon.png",
    init = function(icon, window)
        -- todo: check for access
        OpenMenu()
    end
})