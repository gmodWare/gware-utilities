hook.Add("CanPlayerSuicide", "gWare.Utils.PreventSuicide", function(ply)
    return gWare.Utils.GetSettingValue("commitSuicide")
end)

local invisList = {}

hook.Add("PlayerNoClip", "gWare.Utils.HandleNoclipVanish", function(ply, desiredNoClipState)
    if (desiredNoClipState) then
        ply:DrawShadow(false)
        ply:SetMaterial("models/effects/vol_light001")
        ply:SetRenderMode(RENDERMODE_TRANSALPHA)
        ply:Fire("alpha", 0)

        local aWeapon = ply:GetaWeapon()
        if (IsValid(aWeapon)) then
            aWeapon:SetRenderMode( RENDERMODE_TRANSALPHA )
			aWeapon:Fire( "alpha", visibility )
			aWeapon:SetMaterial( "models/effects/vol_light001" )
			if (aWeapon:GetClass() == "gmod_tool") then
				ply:DrawWorldModel( false )
			end
        end

        invisList[ply] = {
            vis = true,
            wep = aWeapon
        }
    else
        ply:DrawShadow(true)
        ply:SetMaterial("")
        ply:SetRenderMode(RENDERMODE_NORMAL)
        ply:Fire("alpha", 255)

        local aWeapon = ply:GetaWeapon()
        if (IsValid(aWeapon)) then
            aWeapon:SetRenderMode( RENDERMODE_NORMAL )
			aWeapon:Fire( "alpha", 255, 0 )
			aWeapon:SetMaterial( "" )
            if (aWeapon:GetClass() == "gmod_tool") then
                ply:DrawWorldModel(true)
            end
        end

        invisList[ply] = nil
    end
end)

local activeWeapon

hook.Add("Think", "gWare.Utils.HandleInvis", function()
    if (table.IsEmpty(invisList)) then return end

	for player, invisInfo in pairs(invisList) do
        if (not IsValid(player)) then
            inivsList[player] = nil
            continue
        end

        activeWeapon = player:GetActiveWeapon()
        if (player:Alive() and IsValid(activeWeapon) and activeWeapon ~= invisInfo.wep) then
            if (invisInfo.wep and IsValid(invisInfo.wep)) then
                invisInfo.wep:SetRenderMode(RENDERMODE_NORMAL)
                invisInfo.wep:Fire("alpha", 255)
                invisInfo.wep:SetMaterial("")
            end

            invisList[player].wep = activeWeapon
        end
    end
end)