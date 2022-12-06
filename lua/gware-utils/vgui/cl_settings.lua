local L = gWare.Utils.Lang.Get


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
                // TODO: when VoidLib is updated on workshop we can use the normal ItemSelect again
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

        if option.input then
            option.input:Dock(RIGHT)
            option.input:MarginRight(10)
        end

        option:SetTitle(L("setting_" .. data.id.. "_name"), L("setting_" .. data.id .. "_desc"))
    end
end

function PANEL:Paint()
end

vgui.Register("gWare.Utils.Settings", PANEL)