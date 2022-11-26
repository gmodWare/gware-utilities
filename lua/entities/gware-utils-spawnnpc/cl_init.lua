include("shared.lua")

function ENT:SetName(name)
    self.name = name
end

function ENT:Draw()
    if not self.name then return end
    self:DrawModel()

    local mins, maxs = self:WorldSpaceAABB()
    local height = maxs.z - mins.z

    local offset = Vector( 0, 0, height + 25)
    local ang = LocalPlayer():EyeAngles()
    local pos = self:GetPos() + offset + ang:Up()

    local myPos = LocalPlayer():GetPos()

    if myPos:Distance(pos) > 600 then return end

    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    surface.SetFont("VoidUI.R28")
    local width, height = surface.GetTextSize(self.name)
    local br = 8 -- space outline for text
    local boxWidth = width + 20

    cam.Start3D2D( pos, ang, 0.25 )
        surface.SetDrawColor(Color(0, 0, 0, 160))
        surface.DrawOutlinedRect(-boxWidth / 2, -br, boxWidth, height + (2 * br))

        surface.DrawRect(-boxWidth / 2 + 2, -br + 2, boxWidth - 4, height + (2 * br) - 4)
        surface.SetDrawColor(255, 255, 255, 200)
        draw.DrawText(self.name, "VoidUI.R28", -boxWidth / 2 + 10, -1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    cam.End3D2D()
end