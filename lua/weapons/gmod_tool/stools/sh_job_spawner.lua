TOOL.Category = "gWare-Utils"
TOOL.Name = "DarkRP Job Spawn Setter"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Information = {
    { name = "left", stage = 0 },
}
TOOL.AddToMenu = DarkRP and true or false

local L = gWare.Utils.Lang.GetPhrase

local npcSpawns

if CLIENT then
    npcSpawns = false

    hook.Add("Utils.Lang.LanguagesLoaded", "gWare.Tool.WaitForLang", function()
        L = gWare.Utils.Lang.GetPhrase

        language.Add("tool.sh_job_spawner.name", L("tool_name"))
        language.Add("tool.sh_job_spawner.desc", L("tool_desc"))
        language.Add("tool.sh_job_spawner.left", L("tool_leftclick"))
    end)
end

local function Reload()
    if SERVER then return end

    RunConsoleCommand("spawnmenu_reload")
end

local function RemoveClientEnts()
    timer.Simple(0, function()
        for _, ent in ipairs(ents.GetAll()) do
            if ent:GetClass() != "gware_utils_spawnnpc" then continue end

            ent:Remove()
        end

        npcSpawns = false
    end)
end

function TOOL:LeftClick(trace)
    if SERVER then return end
    if not IsFirstTimePredicted() then return end

    local nameInput = vgui.Create("VoidUI.ValuePopup")
    nameInput:SetText(L("tool_name"), L("tool_choose-name"))
    nameInput:WrapText()
    nameInput:Continue(L("tool_spawn"), function(textInput)
        local ent = ents.CreateClientside("gware_utils_spawnnpc")
        ent:SetModel("models/player/monk.mdl")
        ent:SetName(textInput)
        ent:SetPos(self:GetOwner():GetEyeTrace().HitPos)
        ent:SetMaterial("models/shadertest/shader4")

        gWare.Utils.AddNPC(textInput, ent:GetPos())
        VoidLib.Notify(L("notify_jobsetter-created_name"), L("notify_jobsetter-created_desc"):format(textInput), VoidUI.Colors.Green, 5)
        Reload()
    end)

    nameInput:Cancel(L("tool_abort"), function()
        return
    end)
end

function TOOL:RightClick(trace)
end

function TOOL.BuildCPanel(panel)
    local background = vgui.Create("VoidUI.BackgroundPanel", panel)
    background:SetPos(-10, 0)
    background:SSetSize(350, 948)
    background.Paint = function(self, w, h)
        draw.RoundedBox(3, 0, 0 , w, h, VoidUI.Colors.Background)
    end

    local npcDropdown = vgui.Create("VoidUI.Dropdown", background)
    npcDropdown:Center()
    npcDropdown:SetPos(25, 20)
    npcDropdown:SSetSize(panel:GetWide() * 17, 50)
    npcDropdown:SetValue("Select NPC")

    for npcName, bool in pairs(gWare.Utils.NPCSpawns) do
        npcDropdown:AddChoice(npcName)
    end

    local jobList = vgui.Create("VoidUI.Table", background)
    jobList:SetPos(25, 100)
    jobList:SSetSize(panel:GetWide() * 17, 250)
    local column = jobList:AddColumn("Ausgewählter NPC")
    jobList:SetMultiSelect(true)

    npcDropdown.OnSelect = function()
        local npcName, data = npcDropdown:GetSelected()

        jobList:Clear()
        column:SetName(npcName)

        for jobCommand, _ in pairs(gWare.Utils.NPCJobs[npcName]) do
            for _, jobData in pairs(RPExtraTeams) do
                if jobData.command != jobCommand then continue end

                jobList:AddLine(jobData.name)
            end
        end
    end

    local clearButton = vgui.Create("VoidUI.Button", background)
    clearButton:SetPos(20, 450)
    clearButton:SSetSize(280, 50)
    clearButton:SetFont("VoidUI.R22")
    clearButton:SetText(L("tool_delete-jobs"))
    clearButton:SetColor(VoidUI.Colors.Red)
    clearButton.DoClick = function()
        if not npcDropdown:GetSelected() then
            VoidLib.Notify(L"notify_jobsetter-select-npc_name", L"notify_jobsetter-select-npc_desc", VoidUI.Colors.Red, 5)
            return
        end

        if table.IsEmpty(jobList:GetSelected()) then
            VoidLib.Notify(L"notify_jobsetter-select-jobs_name", L"notify_jobsetter-select-jobs_desc", VoidUI.Colors.Red, 5)
            return
        end

        local npcName, data = npcDropdown:GetSelected()

        for _, panelData in ipairs(jobList:GetSelected()) do
            for _, jobData in pairs(RPExtraTeams) do
                if jobData.name != panelData:GetColumnText(1) then continue end

                gWare.Utils.DeleteJobsFromNPC(npcName, jobData.command)
            end
        end

        VoidLib.Notify(L"notify_jobsetter-removed-spawns_name", L("notify_jobsetter-removed-spawns_name"):format(npcName), VoidUI.Colors.Red, 5)
        Reload()
    end

    local addButton = vgui.Create("VoidUI.Button", background)
    addButton:SetPos(20, 520)
    addButton:SSetSize(280, 50)
    addButton:SetFont("VoidUI.R22")
    addButton:SetText(L("tool_add-jobs"))
    addButton.DoClick = function()
        if not npcDropdown:GetSelected() then
            VoidLib.Notify(L("notify_jobsetter-select-npc_name"), L("notify_jobsetter-select-npc_desc"), VoidUI.Colors.Red, 5)
            return
        end

        local npcName, data = npcDropdown:GetSelected()

        local selector = vgui.Create("VoidUI.ItemSelect")
        selector:SetParent(addButton)
        selector:SetMultipleChoice(true)

        local jobTbl = {}
        local jobCache = {}

        for _, jobData in pairs(RPExtraTeams) do
            local jobCommand = jobData.command
            local jobName = jobData.name

            jobTbl[jobCommand] = jobName

            for _, panelData in ipairs(jobList:GetLines()) do
                if jobTbl[jobCommand] != panelData:GetValue(1) then continue end

                jobTbl[jobCommand] = nil
            end
        end

        selector:InitItems(jobTbl, function(tblKey, tblValue)
            for index, jobCommand in ipairs(tblKey) do
                if jobCache[jobCommand] then continue end

                jobCache[index] = jobCommand
            end
        end)

        selector.OnRemove = function()
            if table.IsEmpty(jobCache) then return end

            for _, jobCommand in ipairs(jobCache) do
                gWare.Utils.AddJobsToNPC(npcName, jobCommand)
            end

            VoidLib.Notify(L("notify_jobsetter-spawn-added_name"), L("notify_jobsetter-spawn-added_desc"):format(npcName), VoidUI.Colors.Green, 5)
            Reload()
        end
    end

    local deleteButton = vgui.Create("VoidUI.Button", background)
    deleteButton:SetPos(20, 850)
    deleteButton:SSetSize(280, 75)
    deleteButton:SetFont("VoidUI.R22")
    deleteButton:SetText(L("tool_delete-npc"))
    deleteButton:SetColor(VoidUI.Colors.Red)
    deleteButton.DoClick = function()
        if not npcDropdown:GetSelected() then
            VoidLib.Notify(L("notify_jobsetter-select-npc_name"), L("notify_jobsetter-select-npc_desc"), VoidUI.Colors.Red, 5)
            return
        end

        local npcName, data = npcDropdown:GetSelected()

        VoidLib.Notify(L("notify_jobsetter-deleted_name"), L("notify_jobsetter-deleted_name"):format(npcName), VoidUI.Colors.Red, 5)
        gWare.Utils.DeleteNPC(npcName)

        Reload()
        RemoveClientEnts()
    end
end

local ghostColor = Color( 255, 255, 255, 150 )

function TOOL:MakeGhostHuman(model, pos, angle)
    if SERVER then return end

    if IsValid(self.GhostHuman) then
        self.GhostHuman:Remove()
    end

    self.GhostHuman = ents.CreateClientProp(model)
    self.GhostHuman:SetModel(model)
    self.GhostHuman:SetPos(pos)
    self.GhostHuman:SetAngles(angle)
    self.GhostHuman:Spawn()

    self.GhostHuman:PhysicsDestroy()

    self.GhostHuman:SetMoveType(MOVETYPE_NONE)
    self.GhostHuman:SetNotSolid(true)
    self.GhostHuman:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self.GhostHuman:SetColor(ghostColor)
end

function TOOL:UpdateGhostHuman()
    if SERVER then return end

    self.GhostHuman:SetPos(self:GetOwner():GetEyeTrace().HitPos)
    self.GhostHuman:SetAngles(Angle(zero))
end

function TOOL:Think()
    if SERVER then return end

    if not npcSpawns then
        self:Deploy()
    end

    self:MakeGhostHuman("models/player/monk.mdl", self:GetOwner():GetEyeTrace().HitPos, Angle(zero))
    self:UpdateGhostHuman()
end

function TOOL:Deploy()
    if not L then L = gWare.Utils.Lang.GetPhrase end
    if SERVER then return end
    if not IsFirstTimePredicted() then return end

    npcSpawns = true

    for npcName, npcPos in pairs(gWare.Utils.NPCSpawns) do
        local ent = ents.CreateClientside("gware_utils_spawnnpc")
        ent:SetModel("models/player/monk.mdl")
        ent:SetName(npcName)
        ent:SetPos(npcPos)
        ent:SetMaterial("models/shadertest/shader4")
    end
end

function TOOL:Holster()
    if SERVER then return end
    if not IsValid(self.GhostHuman) then return end

    self.GhostHuman:Remove()
    RemoveClientEnts()
end