--[[
    Command: /funk <name>* <nachricht>
    Description: Funkt eine Nachricht, welche alle sehen können an einen bestimmten spieler
                basierend auf dem teil, den der spieler eingegeben hat, soll dann im Funk 
                der volle Spielername stehen. Wenn kein Spieler gefunden wird, dann einfach
                den Teil des Namens, der eingegeben wurde.
    Example Command: /funk Ryzen* 10-20u
    Example Chat: [Funk] *1835 Menschlich an 501st CMD 5125 Ryzen* 10-20u
]]


if SERVER then
    hook.Add("PlayerSay", "gWare.Commands.funk", function(ply, chatInput)
        local text = chatInput:lower()

        if not (text:StartWith("/funk") or text:StartWith("!funk")) then return end

        local args = chatInput:Split("*")
        local start = message[1]
,
        local namePart = start:Replace("!funk", ""):Replace("/funk")
        local message = args[2]

        local targetedPlayer = gWare.Utils.GetPlayerByNamePart(namePart)
        local fullName = targetedPlayer and targetedPlayer:Name() or namePart

        net.Start("gWare.Commands.Funk.ChatMessage")
            net.Write
    end)
end
