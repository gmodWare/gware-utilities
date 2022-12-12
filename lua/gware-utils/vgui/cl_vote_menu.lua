local PANEL = {}

function PANEL:SetValueTable(tbl)
    self.valueTable = tbl
    self:SetTitle(self.valueTable[1])
end

function PANEL:SetActivePanel(panel)
    self.activePanel = panel
end

function PANEL:SendResultToServer()
    timer.Simple(120, function()
        if not self.pick then return end

        net.Start("gWare.Utils.SendResultToServer")
            net.WriteUInt(self.pick, 3)
        net.SendToServer()

        self:Remove()
    end)
end

function PANEL:Init()
    self:SSetSize(300, 400)
    self:SetPos(20, 250)
    self:ShowCloseButton(true)
    self:SetFont("VoidUI.R20")
    self:MakePopup()

    //self:SendResultToServer()
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
                draw.RoundedBox(0, 0, 0, w, h, VoidUI.Colors.Blue)
            end

            draw.SimpleText(index - 1 .. "  |  " .. values, "VoidUI.R20", 5, 5, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
        end

        button.DoClick = function()
            self:SetActivePanel(button)
            self.pick = index - 1
        end
    end
end

vgui.Register("gWare.Utils.VoteMenu", PANEL, "VoidUI.Frame")

concommand.Add("gw", function()
    local frame = vgui.Create("gWare.Utils.VoteMenu")

    local tbl = {
       [1] = "Das ist eine Frage?",
       [2] = "Woman are niceaadadad",
       [3] = "Humanity is niceadda",
       [4] = "kxx is hot ><asdd",
    }

    frame:SetValueTable(tbl)
    frame:Vote()
end)