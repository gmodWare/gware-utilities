--[[
    Command: /ooc <message>
    Command2: // <message>
    Description: Prints a global out-of-character message
    Example Command: /ooc Lol der ist eingach umgefallen xD
    Example Chat: [LOOC] 501st CMD Menschlich: Lol der ist eingach umgefallen xD
]]

if SERVER then
    util.AddNetworkString("gWare.Commands.OOC.ChatMessage")

    hook.Add("DarkRPFinishedLoading", "gWare.Commands.OOC", function()
        DarkRP.removeChatCommand("ooc")
    end)

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
    net.Receive("gWare.Commands.OOC.ChatMessage", function()
        local message = net.ReadString()
        local sender = net.ReadEntity()

        gWare.Utils.PrintCommand("ooc",
            sender:Nick() .. ": " .. message
        )
    end)
end
