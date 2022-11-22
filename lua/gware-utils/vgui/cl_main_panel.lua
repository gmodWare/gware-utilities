local PANEL = {}

function PANEL:Init()
    self:SSetSize(700, 450)
    self:Center()
    self:SetTitle("gWare Utilities")
    self:MakePopup()

    self.Sidebar = self:Add("VoidUI.Sidebar")

    self.Settings = self:Add("gWare.Utils.Settings")
    self.Vote = self:Add("gWare.Utils.Vote")
    self.Job = self:Add("gWare.Utils.Job")

    self.Sidebar:AddTab("Optionen", VoidUI.Icons.Settings, self.Settings, false)
    self.Sidebar:AddTab("Vote", VoidUI.Icons.Settings, self.Vote, false)
    self.Sidebar:AddTab("Job", VoidUI.Icons.Settings, self.Job, false)
end

vgui.Register("gWare.Utils.Frame", PANEL, "VoidUI.Frame")
