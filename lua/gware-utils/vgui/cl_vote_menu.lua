local PANEL = {}
local pick

function PANEL:SetValueTable(tbl)
    self.valueTable = tbl
    self:SetTitle(self.valueTable[1])
end

function PANEL:SetActivePanel(panel)
    self.activePanel = panel
end

function PANEL:SendResultToServer()
    timer.Create("gWare.Vote", 30, 1, function()
        self:Remove()

        if not pick then return end

        net.Start("gWare.Utils.SendResultToServer")
            net.WriteUInt(pick, 3)
        net.SendToServer()

        hook.Remove("PlayerButtonDown", "gWare.Utils.RegisterVoteByKeyInput")
    end)
end

function PANEL:RegisterVoteByKeyInput()
    hook.Add("PlayerButtonDown", "gWare.Utils.RegisterVoteByKeyInput", function(ply, key)
        if not IsFirstTimePredicted() then return end

        if self.valueTable[key] then
            local voteButton = self.scrollBar:GetChildren()[1]:GetChildren()
            local choice = key - 1

            self:SetActivePanel(voteButton[choice])
            pick = choice
        end
    end)
end

function PANEL:Init()
    self:SSetSize(300, 400)
    self:SetPos(20, 250)
    self:ShowCloseButton(true)
    self:SetFont("VoidUI.R20")

    self:SetKeyboardInputEnabled(false)

    self:SendResultToServer()
    self:RegisterVoteByKeyInput()
end

function PANEL:Vote()
    self.background = self:Add("VoidUI.BackgroundPanel")
    self.background:Dock(FILL)
    self.background:SDockMargin(10, 10, 10, 10)
    self.background:SetTitle(self.valueTable[1])

    self.scrollBar = self.background:Add("VoidUI.ScrollPanel")
    self.scrollBar:Dock(FILL)
    self.scrollBar:DockMargin(0, 40, 0, 0)

    for index, values in ipairs(self.valueTable) do
        if index == 1 then continue end

        local button = self.scrollBar:Add("DButton")
        button:Dock(TOP)
        button:SSetSize(175, 35)
        button:DockMargin(0, 5, 0, 0)
        button:SetText("")
        button.Paint = function(s, w, h)
            if s:IsHovered() || self.activePanel == s then
                draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Blue)
            end

            draw.SimpleText(index - 1 .. "  |  " .. values, "VoidUI.R20", 5, 8, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end

        button.DoClick = function()
            self:SetActivePanel(button)
            pick = index - 1
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Background)

    self.timeLeft = math.Round(timer.TimeLeft("gWare.Vote"))

    self:SetTitle(self.valueTable[1] .. " (" .. self.timeLeft .. ")")
end

function PANEL:OnRemove()
    hook.Remove("PlayerButtonDown", "gWare.Utils.RegisterVoteByKeyInput")
end

vgui.Register("gWare.Utils.VoteMenu", PANEL, "VoidUI.Frame")