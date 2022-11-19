if CLIENT then

    local PANEL = {}

    function PANEL:Init()
        local scrollbar = self:Add("VoidUI.ScrollPanel")
        scrollbar:Dock(FILL)
        scrollbar:SDockMargin(5, 5, 5, 5)

        local questionV = ""

        local question = scrollbar:Add("VoidUI.TextInput")
        question:SSetSize(300, 55)
        question:Dock(TOP)
        question:DockMargin(10, 10, 10, 10)
        question:SetValue("Question:")

        questionV = question:GetValue()

        local answers = 2

        local answer

        local valueTbl = {}

        for i = 1, answers do
            answer = scrollbar:Add("VoidUI.TextInput")
            answer:SSetSize(250, 50)
            answer:Dock(TOP)
            answer:DockMargin(10, 10, 10, 10)
            answer:SetValue("Answer " .. i)

            valueTbl[#valueTbl + 1] = {
                answer = answer:GetValue()
            }
        end

        local addNewAnswer = scrollbar:Add("VoidUI.Button")
        addNewAnswer:SSetSize(250, 50)
        addNewAnswer:Dock(TOP)
        addNewAnswer:DockMargin(10, 10, 10, 10)
        addNewAnswer:SetText("Add New Answer")
        addNewAnswer.DoClick = function()

        end

        local sendVote = scrollbar:Add("VoidUI.Button")
        sendVote:SSetSize(250, 50)
        sendVote:Dock(TOP)
        sendVote:DockMargin(10, 10, 10, 10)
        sendVote:SetText("Send Vote")
        sendVote.DoClick = function()
            if (questionV == "") or (questionV == nil) or (questionV == "Question:") then
                VoidLib.Notify("ERROR", "You didn't have give a Question", VoidUI.Colors.Red, 5)
                return
            end


            self:Remove()

            net.Start("gWare.VoteSystem.SendVoteToAll")
                net.WriteString(questionV)
                net.WriteUInt(#valueTbl, 6)
                for k, v in ipairs(valueTbl) do
                    net.WriteString(v)
                end
            net.SendToServer()

            VoidLib.Notify("SUCCESSFULLY", "You have start a vote", VoidUI.Colors.Green, 5)
        end
    end

    function PANEL:Paint()

    end

    vgui.Register("gWare.Utils.Vote", PANEL)
end

if SERVER then
    local nets = {
        "gWare.VoteSystem.SendVoteToAll"
    }

    for k, v in pairs(nets) do
        util.AddNetworkString(v)
    end

    net.Receive("gWare.VoteSystem.SendVoteToAll", function(len, ply)
        local question = net.ReadString()
        local answerAmmount = net.ReadUInt(6)

        local answers = {}

        for i = 1, answerAmmount do
            answers[#answers + 1] = {
                value = net.ReadString()
            }
        end

        PrintTable(answers)

    end)
end