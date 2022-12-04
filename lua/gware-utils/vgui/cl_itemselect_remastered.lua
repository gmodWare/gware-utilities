// TODO: when VoidLib is updated on workshop we can use the normal ItemSelect again

local sc = VoidUI.Scale

local PANEL = {}

function PANEL:Init()
	self.multipleChoice = false
end

function PANEL:InitItems(tbl, callback)
	self.itemsTbl = tbl
	self.callback = callback

    self:SSetSize(280, 335)
    self:MakePopup()

    local cx, cy = input.GetCursorPos()
    self:SetPos(cx-sc(40), cy + sc(10))

    local root = self

	self.panel = self:Add("Panel")
	self.panel:Dock(FILL)
	self.panel:DockMargin(14, 14, 14, 14)

	self.search = self.panel:Add("VoidUI.TextInput")
	self.search:Dock(TOP)
	self.search:SetTall(36)
	self.search.entry:SetPlaceholderText("Search...")
	self.search.entry:SetFont("VoidUI.R24")

	self.search:SetColorScheme(VoidUI.Colors.White, VoidUI.Colors.White, VoidUI.Colors.Background, VoidUI.Colors.Black)

	function self.search.entry:OnFocusChanged(res)
		timer.Simple(0, function ()
			if (!IsValid(self)) then return end
			if (!res and !root:HasFocus()) then
				root:Remove()
			end
		end)
	end

	self.items = self.panel:Add("VoidUI.ScrollPanel")
	self.items:Dock(TOP)
	self.items:DockMargin(0, 22, 0, 0)
	self.items:SetTall(250)

	self.items.defaultColor = VoidUI.Colors.Background

	self.performSearch = function (str)

		self.items:Clear()

		local totalItems = 0
		for k, v in pairs(tbl) do
			if (!self.SearchFunc) then
				if (!string.find(string.lower(v), string.lower(str))) then continue end
			else
				if (!self.SearchFunc(k, str, v)) then continue end
			end

			totalItems = totalItems + 1

			local item = self.items:Add("DButton")
			item:Dock(TOP)
			item:DockMargin(0, 0, 0, 6)
			item:SetTall(37)
			item:SetText("")

			item.Paint = function (self, w, h)
				local color = (self:IsHovered() and VoidUI.Colors.GrayText) or VoidUI.Colors.InputLight
				if (root.multipleChoice and root.choices[k]) then
					color = VoidUI.Colors.Blue
				end
				draw.RoundedBox(6, 0, 0, w, h, color)

				draw.SimpleText(v, "VoidUI.R24", 10, h/2, VoidUI.Colors.Gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			item.DoClick = function ()
				if (self.multipleChoice) then
                    self.choices[k] = !self.choices[k]
                    self.recentItem = {
                        ["key"] = k,
                        ["value"] = v,
                        ["added"] = tobool(self.choices[k]),
                    }
					self:CallbackMultiple()
				else
					callback(k, v)
					self:Remove()
				end
			end
		end
	end

	self.performSearch("")

	function self.search.entry:OnValueChange(val)
		root.performSearch(val)
	end
end

function PANEL:SetMultipleChoice(b)
	self.multipleChoice = b
	self.choices = {}
end

function PANEL:CallbackMultiple()
	if (self.multipleChoice) then
		local tbl = {}
		local tbl1 = {}
		for k, v in pairs(self.choices) do
			if (v) then
				tbl[#tbl + 1] = k 
				tbl1[#tbl1 + 1] = self.itemsTbl[k]
			end
		end
		self.callback(tbl, tbl1)
	end
end

function PANEL:OnFocusChanged(res)
	timer.Simple(0, function ()
		if (!IsValid(self)) then return end
		if (self.search.entry:HasFocus()) then return end
		if (!res) then self:Remove() end
	end)
end

function PANEL:Think()
    self:MoveToFront()
end

function PANEL:Paint(w, h)

	local x, y = self:LocalToScreen(0, 0)

	BSHADOWS.BeginShadow()
		surface.SetDrawColor(VoidUI.Colors.Primary)
		surface.DrawRect(x,y,w,h)
	BSHADOWS.EndShadow(1, 1, 1, 140, 1, 1)
end


vgui.Register("VoidUI.ItemSelect2", PANEL, "EditablePanel")