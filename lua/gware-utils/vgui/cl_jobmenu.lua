local PANEL = {}

function PANEL:Init()
    local scrollbar = self:Add("VoidUI.ScrollPanel")
    scrollbar:Dock(FILL)
    scrollbar:SDockMargin(5, 5, 5, 5)

    local ply = LocalPlayer()
    local plyName = ""

    local plyPanel = scrollbar:Add("VoidUI.Dropdown")
    plyPanel:SSetSize(350, 55)
    plyPanel:Dock(TOP)
    plyPanel:DockMargin(10, 10, 10, 10)
    plyPanel:SetValue("Which Player")
    for k, v in ipairs(player.GetAll()) do
        plyPanel:AddChoice(v:Nick(), v)
    end
    plyPanel.OnSelect = function(selfPly, index, value)
        plyName, ply = selfPly:GetSelected()
    end

    local job = ""

    local jobPanel = scrollbar:Add("VoidUI.Dropdown")
    jobPanel:SSetSize(350, 55)
    jobPanel:Dock(TOP)
    jobPanel:DockMargin(10, 10, 10, 10)
    jobPanel:SetValue("Which Job")
    for k, v in ipairs(team.GetAllTeams()) do
        jobPanel:AddChoice(v.Name)
    end
    jobPanel.OnSelect = function(selfJob, index, value)
        job = selfJob:GetSelected()
    end

    local setButton = scrollbar:Add("VoidUI.Button")
    setButton:SSetSize(350, 55)
    setButton:Dock(TOP)
    setButton:DockMargin(10, 10, 10, 10)
    setButton:SetText("Set Job")
    setButton.DoClick = function()
        --if (ply == LocalPlayer()) or (ply == "") or (ply == nil) or (plyName == "") or (plyName == nil) or (plyName == "Which Player") or (job == "") or (job == "Which Job") or (job == nil) then
            --VoidLib.Notify("ERROR", "You forgot something!", VoidUI.Colors.Red, 5)
            --return
        --end

        net.Start("gWare.Utils.JobSetter.SetJob")
            net.WriteString(job)
            net.WriteEntity(ply)
        net.SendToServer()

        VoidLib.Notify("SUCCESSFULLY", "You set someone into a job!", VoidUI.Colors.Green, 5)
    end
end

function PANEL:Paint()

end

vgui.Register("gWare.Utils.Job", PANEL)