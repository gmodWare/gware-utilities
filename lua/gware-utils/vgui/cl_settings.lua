local PANEL = {}

function PANEL:Init()
    self.bg = self:Add("VoidUI.BackgroundPanel")
    self.bg:Dock(FILL)
    self.bg:SDockMargin(10, 10, 10, 10)

    local scrollbar = self.bg:Add("VoidUI.ScrollPanel")
    scrollbar:Dock(FILL)
    scrollbar:SDockMargin(5, 5, 5, 5)

    for index, data in ipairs(gWare.Utils.Settings) do
        local option = scrollbar:Add("VoidUI.BackgroundPanel")
        option:Dock(TOP)
        option:SetTall(60)

        if data.settingType == "bool" then
            option.input = option:Add("VoidUI.Switch")
            option.input:SDockMargin(50, 0, 50, 0)
            option.input:SetChecked(data.value)

            function option.input.OnSelect(panel, value, data)
                local bool = gWare.Utils.IntToBool(value)
                gWare.Utils.UpdateSetting(index, bool)
            end

            option.input:Dock(RIGHT)
            option.input:MarginRight(10)
            option.input:SSetWide(90)
        end

        if data.settingType == "job_multi_select" then
            local selected = {}

            option.input = option:Add("VoidUI.SelectorButton")
            option.input.text = "Hinzufügen.."

            option.input.DoClick = function()
                local selector = vgui.Create("VoidUI.ItemSelect")
                selector:SetParent(option)
                selector:SetMultipleChoice(true)

                local jobTbl = {}

                for i, job in pairs(RPExtraTeams) do
                    jobTbl[job.command] = job.name 
                end

                selector:InitItems(jobTbl, function (tblKeys, tblValues)
                    option.input:Select(tblCommands, tblValues)
                    selected = selTbl
                end)
            end

            option.input:SSetWide(150)
        end

        if option.input then
            option.input:Dock(RIGHT)
            option.input:MarginRight(10)
        end

        option:SetTitle(data.name, data.description)
    end
end

function PANEL:Paint()
end

vgui.Register("gWare.Utils.Settings", PANEL)