local PANEL = {}

function PANEL:Init()
    self.bg = self:Add("VoidUI.BackgroundPanel")
    self.bg:Dock(FILL)
    self.bg:SDockMargin(10, 10, 10, 10)
    self.bg:SetTitle("Einstellungen", "")
end

function PANEL:Paint()
end

vgui.Register("gWare.Utils.Settings", PANEL)