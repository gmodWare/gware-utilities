local PANEL = {}

function PANEL:Init()
    self.bg = self:Add("VoidUI.BackgroundPanel")
    self.bg:Dock(FILL)
    self.bg:SDockMargin(10, 10, 10, 10)

    local scrollbar = self.bg:Add("VoidUI.ScrollPanel")
    scrollbar:Dock(FILL)
    scrollbar:SDockMargin(5, 5, 5, 5)

    for _, data in pairs(gWare.Utils.Settings) do
        local option = scrollbar:Add("VoidUI.BackgroundPanel")
        option:Dock(TOP)
        option:SetTall(60)

        if data.settingType == "bool" then
            option.input = option:Add("VoidUI.Switch")
            option.input:SDockMargin(50, 0, 50, 0)
            option.input:SetChecked(data.value)

            function option.input:OnChange(val)
                gWare.Utils.UpdateSetting(data.name, val)
            end
        end

        option.input:Dock(RIGHT)
        option.input:MarginRight(10)
        option.input:SSetWide(90)

        option:SetTitle(data.name, data.description)
    end
end

function PANEL:Paint()
end

vgui.Register("gWare.Utils.Settings", PANEL)