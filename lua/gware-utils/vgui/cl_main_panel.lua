local L = gWare.Utils.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self:SSetSize(730, 450)
    self:Center()
    self:SetTitle("gWare Utilities")
    self:MakePopup()

    self.Sidebar = self:Add("VoidUI.Sidebar")

    self.Settings = self:Add("gWare.Utils.Settings")
    self.Commands = self:Add("gWare.Utils.Commands")
    self.Vote = self:Add("gWare.Utils.Vote")

    self.Sidebar:AddTab(L"tab_options", VoidUI.Icons.Settings, self.Settings, false)
    self.Sidebar:AddTab(L"tab_commands", VoidUI.Icons.Settings, self.Commands, false)
    self.Sidebar:AddTab(L"tab_vote", VoidUI.Icons.Stats, self.Vote, false)
end

vgui.Register("gWare.Utils.Frame", PANEL, "VoidUI.Frame")
