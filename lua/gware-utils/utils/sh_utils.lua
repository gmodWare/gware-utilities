function gWare.Utils.GetPlayerByNamePart(namePart)
    for _, ply in ipairs(player.GetAll()) do
        if ply:Name():lower():find(namePart) then
            return ply
        end
    end

    return nil
end
