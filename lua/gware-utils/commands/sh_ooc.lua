--[[
    Command: /ooc <message>
    Command2: // <message>
    Description: Prints a global out-of-character message
    Example Command: /ooc Lol der ist eingach umgefallen xD
    Example Chat: [LOOC] 501st CMD Menschlich: Lol der ist eingach umgefallen xD
]]

-- TODO: Don't forget to override darkrp ooc!
-- TODO: Fix Bug: When using '//' there is one additional space after the name which shouldnt be there
-- example Chat : '[OOC] Menschlich:  Hallo'

if SERVER then
    util.AddNetworkString("gWare.Commands.OOC.ChatMessage")

    hook.Add("PlayerSay", "gWare.Commands.OOC", function(ply, text)
        if not text:StartWithAny("/ooc", "//", "!ooc") then return end

        local message = text:ReplacePrefix("ooc")

        net.Start("gWare.Commands.OOC.ChatMessage")
            net.WriteString(message)
            net.WriteEntity(ply)
        net.Broadcast()

        return ""
    end)
end

if CLIENT then
    local colors = {
        ["brackets"] = Color(40, 42, 46),
        ["commandColor"] = Color(169, 75, 245)
    }

    net.Receive("gWare.Commands.OOC.ChatMessage", function()
        local message = net.ReadString()
        local sender = net.ReadEntity()

        gWare.Utils.Print(
            "ooc", 
            sender:Nick() .. ": " .. message
        )
    end)
end