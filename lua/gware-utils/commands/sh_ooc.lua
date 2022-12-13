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
        local symbol = text[1]
        if not text:StartWithAny(symbol .. "ooc ", "// ") then return end

        local message

        if text:StartWith(symbol .. "ooc ") then
            message = text:sub(6)
        else
            message = text:sub(4)
        end

        if gWare.Utils.IsMessageEmpty(message, ply) then return end

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

        gWare.Utils.PrintCommand("ooc", 
            sender:Nick() .. ": " .. message
        )
    end)
end