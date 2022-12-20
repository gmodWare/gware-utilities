local L = gWare.Utils.Lang.GetPhrase
local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
    self.bg = self:Add("VoidUI.BackgroundPanel")
    self.bg:Dock(FILL)
    self.bg:SDockMargin(10, 10, 10, 10)

    local scrollbar = self.bg:Add("VoidUI.ScrollPanel")
    scrollbar:Dock(FILL)
    scrollbar:SDockMargin(5, 5, 5, 5)

    for index, data in ipairs(gWare.Utils.Settings) do
        if data.settingType != "command" then continue end

        local option = scrollbar:Add("VoidUI.BackgroundPanel")
        option:Dock(TOP)
        option:SSetTall(60)
        option.strSlightFont = "VoidUI.S18"
        option.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)
            draw.SimpleText(self.title, self.textFont, sc(15), sc(15), self.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(self.strDesc, self.strSlightFont, sc(15), sc(58), self.slightColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end

        option.input = option:Add("VoidUI.Switch")
        option.input:SDockMargin(50, 0, 50, 0)
        option.input:SetChecked(data.value)

        function option.input.OnSelect(panel, value, data)
            local bool = gWare.Utils.IntToBool(value)
            gWare.Utils.UpdateSettingBool(index, bool)
        end

        option.input:Dock(RIGHT)
        option.input:MarginRight(10)
        option.input:SSetWide(90)

        option:SetTitle(L(data.id) , L("commands_desc") .. " " .. L(data.id))
    end
end


vgui.Register("gWare.Utils.Commands", PANEL)