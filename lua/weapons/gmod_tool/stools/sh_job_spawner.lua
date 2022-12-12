TOOL.Category = "gWare-Utils"
TOOL.Name = "DarkRP Job Spawn Setter"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Information = {
	{ name = "left", stage = 0 },
}

local npcSpawns

if CLIENT then
    npcSpawns = false

    language.Add("Tool.sh_job_spawner.name", "DarkRP Job Spawn Setter")
    language.Add("Tool.sh_job_spawner.desc", "Setze die Spawns, eines DarkRP Jobs")
    language.Add("Tool.sh_job_spawner.left", "Spawne einen NPC und gebe ihm einen Namen")
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
    nameInput:SetText("DarkRP Job Spawn Setter", "Wähle einen Namen für deinen NPC und Spawne ihn.")
    nameInput:WrapText()
    nameInput:Continue("Spawnen", function(textInput)
        local ent = ents.CreateClientside("gware_utils_spawnnpc")
        ent:SetModel("models/player/monk.mdl")
        ent:SetName(textInput)
        ent:SetPos(self:GetOwner():GetEyeTrace().HitPos)
        ent:SetMaterial("models/shadertest/shader4")

        gWare.Utils.AddNPC(textInput, ent:GetPos())

        VoidLib.Notify("gWare Job Spawn Setter", "Du hast erfolgreich den NPC " .. textInput .. " erstellt.", VoidUI.Colors.Green, 5)

        Reload()
    end)

    nameInput:Cancel("Abbrechen", function()
        return
    end)
end

function TOOL:RightClick(trace)

end

function TOOL.BuildCPanel(panel)
    local background = vgui.Create("VoidUI.BackgroundPanel", panel)
    background:SetPos(-10, 0)
    background:SSetSize(350, 948)
    background.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0 , w, h, VoidUI.Colors.Background)
    end

    local npcDropdown = vgui.Create("VoidUI.Dropdown", background)
    npcDropdown:Center()
    npcDropdown:SetPos(25, 20)
    npcDropdown:SSetSize(panel:GetWide() * 17, 50)
    npcDropdown:SetValue("Select NPC")

    for npcName, _ in pairs(gWare.Utils.NPCSpawns) do
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
    clearButton:SetText("Delete Jobs from NPC")
    clearButton:SetColor(VoidUI.Colors.Red)
    clearButton.DoClick = function()
        if not npcDropdown:GetSelected() then
            VoidLib.Notify("ERROR", "Du musst ein NPC auswählen!", VoidUI.Colors.Red, 5)
            return
        end

        if table.IsEmpty(jobList:GetSelected()) then
            VoidLib.Notify("ERROR", "Du musst Jobs auswählen die du löschen möchtest!", VoidUI.Colors.Red, 5)
            return
        end

        local npcName, data = npcDropdown:GetSelected()

        for _, panelData in ipairs(jobList:GetSelected()) do
            for _, jobData in pairs(RPExtraTeams) do
                if jobData.name != panelData:GetColumnText(1) then continue end

                local jobCommand = jobData.command

                gWare.Utils.DeleteJobsFromNPC(npcName, jobCommand)
            end
        end

        VoidLib.Notify("gWare Job Spawn Setter", "Die Jobs spawnen absofort nicht mehr bei dem NPC " .. npcName, VoidUI.Colors.Red, 5)

        Reload()
    end

    local addButton = vgui.Create("VoidUI.Button", background)
    addButton:SetPos(20, 520)
    addButton:SSetSize(280, 50)
    addButton:SetFont("VoidUI.R22")
    addButton:SetText("Add Jobs to NPC")
    addButton.DoClick = function()
        if not npcDropdown:GetSelected() then
            VoidLib.Notify("ERROR", "Du musst ein NPC auswählen!", VoidUI.Colors.Red, 5)
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

            VoidLib.Notify("gWare Job Spawn Setter", "Die Jobs spawnen absofort bei dem NPC " .. npcName, VoidUI.Colors.Green, 5)

            Reload()
        end
    end

    local deleteButton = vgui.Create("VoidUI.Button", background)
    deleteButton:SetPos(20, 850)
    deleteButton:SSetSize(280, 75)
    deleteButton:SetFont("VoidUI.R22")
    deleteButton:SetText("Delete Selected NPC")
    deleteButton:SetColor(VoidUI.Colors.Red)
    deleteButton.DoClick = function()
        if not npcDropdown:GetSelected() then
            VoidLib.Notify("ERROR", "Du musst ein NPC auswählen!", VoidUI.Colors.Red, 5)
            return
        end

        local npcName, data = npcDropdown:GetSelected()

        VoidLib.Notify("gWare Job Spawn Setter", "Du hast " .. npcName .. " erfolgreich gelöscht!", VoidUI.Colors.Red, 5)

        gWare.Utils.DeleteNPC(npcName)

        Reload()
        RemoveClientEnts()
    end
end

function TOOL:MakeGhostHuman(model, pos, angle)
    if SERVER then return end

    if IsValid(self.GhostHuman) then
        self.GhostHuman:Remove()
    end

    self.GhostHuman = ents.CreateClientProp(model)
    self.GhostHuman:SetModel(model)
    self.GhostHuman:SetPos( pos )
	self.GhostHuman:SetAngles( angle )
	self.GhostHuman:Spawn()

    self.GhostHuman:PhysicsDestroy()

	self.GhostHuman:SetMoveType( MOVETYPE_NONE )
	self.GhostHuman:SetNotSolid( true )
	self.GhostHuman:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self.GhostHuman:SetColor( Color( 255, 255, 255, 150 ) )
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