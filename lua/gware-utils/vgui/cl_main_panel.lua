local PANEL = {}

function PANEL:Init()
    self:SSetSize(700, 450)
    self:Center()
    self:SetTitle("gWare Utilities")
    self:MakePopup()

    self.Sidebar = self:Add("VoidUI.Sidebar")

    self.Settings = self:Add("gWare.Utils.Settings")
    self.Sidebar:AddTab("Einstellungen", VoidUI.Icons.Settings, self.Settings, false)
    self.Sidebar:AddTab("Einstellungen", VoidUI.Icons.Upgrades, self.Settings, false)
    self.Sidebar:AddTab("Einstellungen", VoidUI.Icons.Trophy, self.Settings, false)
    self.Sidebar:AddTab("Einstellungen", VoidUI.Icons.Faction, self.Settings, false)
end

vgui.Register("gWare.Utils.Frame", PANEL, "VoidUI.Frame")
