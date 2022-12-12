local L = gWare.Utils.Lang.GetPhrase
local sc = VoidUI.Scale


local PANEL = {}

function PANEL:Init()
    self.bg = self:Add("VoidUI.BackgroundPanel")
    self.bg:Dock(FILL)
    self.bg:SDockMargin(10, 10, 10, 10)

    local this = self

    local scrollbar = self.bg:Add("VoidUI.ScrollPanel")
    scrollbar:Dock(FILL)
    scrollbar:SDockMargin(5, 5, 5, 5)

    for index, data in ipairs(gWare.Utils.Settings) do
        local option = scrollbar:Add("VoidUI.BackgroundPanel")
        option:Dock(TOP)
        option:SSetTall(60)
        option.strSlightFont = "VoidUI.S18"
        option.Paint = function(self, w, h)
            draw.RoundedBox(12, 0, 0, w, h, VoidUI.Colors.Primary)
            draw.SimpleText(self.title, self.textFont, sc(15), sc(15), self.textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(self.strDesc, self.strSlightFont, sc(15), sc(58), self.slightColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
        end

        if data.settingType == "bool" then
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
        end

        if data.settingType == "job_multi_select" then
            option.input = option:Add("VoidUI.SelectorButton")
            option.input.text = "Hinzufügen.."

            local selected = {}

            gWare.Utils.JobAccess[data.id] = gWare.Utils.JobAccess[data.id] or {}
            local jobCache = gWare.Utils.JobAccess[data.id]

            local jobTbl = {}

            -- add all darkrp jobs to choices
            for i, job in pairs(RPExtraTeams) do
                jobTbl[job.command] = job.name
            end

            -- show all currently selected choices
            for jobCmd, jobName in pairs(jobTbl) do
                if not jobCache[jobCmd] then continue end
                option.input:Select(jobCmd, jobName)
            end

            option.input.DoClick = function()
                local selector = vgui.Create("VoidUI.ItemSelect")
                selector:SetParent(option)
                selector:SetMultipleChoice(true)

                -- select choices from jobCache
                for jobCommand, bool in pairs(jobCache) do
                    selector.choices[jobCommand] = true
                end

                selector:InitItems(jobTbl, function (tblKeys, tblValues)
                    option.input:Select(tblKeys, tblValues)
                    selected = selTbl
                    gWare.Utils.ChangeJobAccess(selector.recentItem.key, data.id)
                end)
            end

            option.input:SSetWide(150)
        end

        if data.settingType == "lang-dropdown" then
            option.input = option:Add("VoidUI.Dropdown")
            option.input:Dock(RIGHT)
            option.input:MarginRight(10)
            option.input:SSetWide(120)

            for i, lang in ipairs(gWare.Utils.Lang.AvailableLangs) do
                local selected = lang:lower() == gWare.Utils.Config.Language:lower()
                option.input:AddChoice(lang, lang:lower(), selected)
            end

            option.input.OnSelect = function(self, index, value, data)
                gWare.Utils.Config.Language = value

                gWare.Utils.UpdateSettingString(index, value)
                this:GetParent():Close()
            end
        end

        if option.input then
            option.input:Dock(RIGHT)
            option.input:MarginRight(10)
        end

        option:SetTitle(L("setting_" .. data.id.. "_name"), L("setting_" .. data.id .. "_desc"))
    end
end


vgui.Register("gWare.Utils.Settings", PANEL)