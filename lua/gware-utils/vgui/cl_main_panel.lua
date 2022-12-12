local PANEL = {}

function PANEL:Init()
    self:SSetSize(730, 450)
    self:Center()
    self:SetTitle("gWare Utilities")
    self:MakePopup()

    self.Sidebar = self:Add("VoidUI.Sidebar")

    self.Settings = self:Add("gWare.Utils.Settings")
    self.Vote = self:Add("gWare.Utils.Vote")

    self.Sidebar:AddTab("Optionen", VoidUI.Icons.Settings, self.Settings, false)
    self.Sidebar:AddTab("Vote", VoidUI.Icons.Stats, self.Vote, false)
end

vgui.Register("gWare.Utils.Frame", PANEL, "VoidUI.Frame")
