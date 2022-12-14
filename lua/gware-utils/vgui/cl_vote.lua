local L = gWare.Utils.Lang.GetPhrase

local PANEL = {}

function PANEL:Init()
    self.backgroundPanel = self:Add("VoidUI.BackgroundPanel")
    self.backgroundPanel:Dock(FILL)
    self.backgroundPanel:SDockMargin(10, 10, 10, 10)

    self.scrollBar = self.backgroundPanel:Add("VoidUI.ScrollPanel")
    self.scrollBar:Dock(FILL)

    self.questionTextPanel = self.scrollBar:Add("DPanel")
    self.questionTextPanel:SSetPos(5, 0)
    self.questionTextPanel:SSetSize(550, 50)
    self.questionTextPanel.Paint = function(s, w, h)
        draw.SimpleText(L"vote_question", "VoidUI.R20", 0, 0, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    end

    self.choiceTextPanel = self.scrollBar:Add("DPanel")
    self.choiceTextPanel:SSetPos(5, 100)
    self.choiceTextPanel:SSetSize(550, 50)
    self.choiceTextPanel.Paint = function(s, w, h)
        draw.SimpleText(L"vote_multiple-choice", "VoidUI.R20", 0, 0, VoidUI.Colors.White, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT)
    end

    self.question = self.scrollBar:Add("VoidUI.TextInput")
    self.question:SSetPos(0, 30)
    self.question:SSetSize(550, 50)
    self.question:SetPlaceholder(L"vote_question")

    local yPos = 130
    local choiceCounter = 1

    for i = 1, 2 do
        local choice = self.scrollBar:Add("VoidUI.TextInput")
        choice:SSetPos(0, yPos)
        choice:SSetSize(550, 50)
        choice:SetPlaceholder(L"vote_choice" .. " " .. i)

        choiceCounter = choiceCounter + 1
        yPos = yPos + 60
    end

    self.addChoice = self.scrollBar:Add("VoidUI.Button")
    self.addChoice:SSetPos(0, yPos + 5)
    self.addChoice:SSetSize(550, 35)
    self.addChoice:SetText(L"vote_add-choice")
    self.addChoice:SetFont("VoidUI.R20")
    self.addChoice:SetColor(VoidUI.Colors.Blue)
    self.addChoice.DoClick = function(s)
        if choiceCounter >= 5 + 1 then
            VoidLib.Notify(L"notify_max-vote-answers_name", L"notify_max-vote-answers_desc", VoidUI.Colors.Red, 5)
            return
        end

        local choice = self.scrollBar:Add("VoidUI.TextInput")
        choice:SSetPos(0, yPos)
        choice:SSetSize(550, 50)
        choice:SetPlaceholder(L"vote_choice" .. " " .. choiceCounter)

        choiceCounter = choiceCounter + 1
        yPos = yPos + 60

        self.addChoice:SSetPos(0, yPos + 5)
        self.removeChoice:SSetPos(0, yPos + 45)
        self.submit:SSetPos(0, yPos + 70)
    end

    self.removeChoice = self.scrollBar:Add("VoidUI.Button")
    self.removeChoice:SSetPos(0, yPos + 45)
    self.removeChoice:SSetSize(550, 35)
    self.removeChoice:SetText(L"vote_remove-choice")
    self.removeChoice:SetFont("VoidUI.R20")
    self.removeChoice:SetColor(VoidUI.Colors.Red)
    self.removeChoice.DoClick = function(s)
        if choiceCounter <= 2 + 1 then
            VoidLib.Notify(L"notify_min-vote-answers_name", L"notify_min-vote-answers_desc", VoidUI.Colors.Red, 5)
            return
        end

        local tblCount = #self.scrollBar:GetChildren()[1]:GetChildren()
        local choice = self.scrollBar:GetChildren()[1]:GetChildren()[tblCount]

        choice:Remove()

        choiceCounter = choiceCounter - 1
        yPos = yPos - 60

        self.addChoice:SSetPos(0, yPos + 5)
        self.removeChoice:SSetPos(0, yPos + 45)
        self.submit:SSetPos(0, yPos - 70)
    end

    local values = {}

    self.submit = self.backgroundPanel:Add("VoidUI.Button")
    self.submit:Dock(BOTTOM)
    self.submit:SDockMargin(0, 10, 25, 0)
    self.submit:SSetSize(550, 50)
    self.submit:SetFont("VoidUI.R28")
    self.submit:SetText(L"vote_submit")
    self.submit.DoClick = function()
        for _, panelData in ipairs(self.scrollBar:GetChildren()[1]:GetChildren()) do
            if panelData:GetName() != "VoidUI.TextInput" then continue end

            if panelData:GetValue() == "" then
                VoidLib.Notify(L"notify_vote-missing-fields_name", L"notify_vote-missing-fields_desc", VoidUI.Colors.Red, 5)

                table.Empty(values)
                return
            end

            table.insert(values, panelData:GetValue())
        end

        VoidLib.Notify(L"notify_vote-success_name", L"notify_vote-success_desc", VoidUI.Colors.Green, 5)
        gWare.Utils.SendVoteToServer(values)
    end
end

function PANEL:Paint(w, h)
end

vgui.Register("gWare.Utils.Vote", PANEL)