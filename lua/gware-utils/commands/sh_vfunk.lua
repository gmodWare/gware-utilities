--[[
    Command: /vfunk <name>* <nachricht>
    Description: Funkt eine verschlüsselte Nachricht, welche alle der empfangende Spieler
                entschlüsselt sehen kann, und alle anderen verschlüsselt.
                Basierend auf dem teil, den der spieler eingegeben hat, soll dann im Funk 
                der volle Spielername stehen. Wenn kein Spieler gefunden wird, dann sehen
                alle Spieler den Text verschlüsselt. Mit /decode kann man den Text 
                wieder leserlich machen.
    Example Command: /vfunk Ryzen* Antritt des Dienstes.
    Example Chat: [Verschlüsselter Funk] *1835 Menschlich an 5125 Ryzen* Antritt des Dienstes.
    Example Encrypted Chat: [Verschlüsselter Funk] *1835 Menschlich an 5125 Ryzen* Borsjuu eft Ejfotuft.
]]

if SERVER then
    hook.Add("PlayerSay", "gWare.Commands.vfunk", function(ply, chatInput)
        local text = chatInput:lower()

        if not text:StartWithAny("/vfunk", "!vfunk") then return end

        local args = text:Split(text, " ")
        local message = args[1]:ReplacePrefix("vfunk")
    end)
end
