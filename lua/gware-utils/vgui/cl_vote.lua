local PANEL = {}
local scrw, scrh = ScrW(), ScrH()

local function sc(x)
    return x / 1080 * scrh
end

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

    local answers = 3

    local answer

    local valueTbl = {}

    for i = 1, answers do
        answer = scrollbar:Add("VoidUI.TextInput")
        answer:SSetSize(250, 50)
        answer:Dock(TOP)
        answer:DockMargin(10, 10, 10, 10)
        answer:SetValue("Answer " .. i)
        answer.OnValueChange = function()
            valueTbl[#valueTbl + 1] = answer:GetValue()
        end
    end

    local addNewAnswer = scrollbar:Add("VoidUI.Button")
    addNewAnswer:SSetSize(250, 50)
    addNewAnswer:Dock(TOP)
    addNewAnswer:DockMargin(10, 10, 10, 10)
    addNewAnswer:SetText("Add New Answer")
    addNewAnswer.DoClick = function()
        answers = answers + 1
    end

    local sendVote = scrollbar:Add("VoidUI.Button")
    sendVote:SSetSize(250, 50)
    sendVote:Dock(TOP)
    sendVote:DockMargin(10, 10, 10, 10)
    sendVote:SetText("Send Vote")
    sendVote.DoClick = function()

        print("Do Click!")

        questionV = question:GetValue()

        if (questionV == "") or (questionV == nil) or (questionV == "Question:") then
            VoidLib.Notify("ERROR", "You didn't have give a Question", VoidUI.Colors.Red, 5)
            return
        end


        self:Remove()

        net.Start("gWare.Utils.VoteSystem.SendVoteToServer")
            net.WriteString(questionV)
            for k, v in ipairs(valueTbl) do
                net.WriteString(v)
            end
            net.WriteUInt(#valueTbl, 3)
        net.SendToServer()

        print("Sended Netmessage!")

        VoidLib.Notify("SUCCESSFULLY", "You have start a vote", VoidUI.Colors.Green, 5)
    end
end

function PANEL:Paint()

end

vgui.Register("gWare.Utils.Vote", PANEL)