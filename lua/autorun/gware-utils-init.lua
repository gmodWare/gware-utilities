--[[---------------------------------------------------------
	Name: Setup
-----------------------------------------------------------]]
gWare = gWare or {}
gWare.Utils = gWare.Utils or {}

local authors = "by Menschlich, kxx & Ryzen"
local UtilsBranding = [[  
     __          __            
     \ \        / /            
   __ \ \  /\  / /_ _ _ __ ___ 
  / _` \ \/  \/ / _` | '__/ _ \
 | (_| |\  /\  / (_| | | |  __/
  \__, | \/  \/ \__,_|_|  \___|
   __/ |                       
  |___/  ]]

gWare.Addons = gWare.Addons or {}
gWare.Addons["gWareUtils"] = true

gWare.Utils.Lang = gWare.Utils.Lang or {}

function gWare.Utils.Lang.Get(phrase)
    gWare.Lang:GetLangPhrase("gWareUtils", phrase)
end

gWare.Utils.Dir = "gware-utils"

--[[---------------------------------------------------------
	Name: Directory Walker
-----------------------------------------------------------]]
 
function gWare.Utils.Load(dir)
	local files = file.Find(dir.. "/".. "*", "LUA")

	for k, filename in pairs(files) do
		if filename:StartWith("cl") then

			AddCSLuaFile(dir.. "/".. filename)

			if CLIENT then
				local load = include(dir .. "/" .. filename)
				if load then load() end
			end
		end

		if filename:StartWith("sv") then
			if SERVER then
				local load = include(dir .. "/" .. filename)
				if load then load() end
			end
		end

		if filename:StartWith("sh") then
			AddCSLuaFile(dir .. "/" .. filename)

			local load = include(dir .. "/".. filename)
			if load then load() end
		end
	end
end

function gWare.Utils.AddCSDir(dir)
	local files = file.Find(dir .. "/".. "*", "LUA")

	for k, v in pairs(files) do
		AddCSLuaFile(dir.. "/".. v)

		if CLIENT then
			include(dir.. "/".. v)
		end
	end
end

--[[---------------------------------------------------------
	Name: Functions
-----------------------------------------------------------]]

function gWare.Utils.Print(...)
	MsgC(Color(23, 89, 255), "[gWare Utilities]: ", Color(255, 255, 255), ..., "\n")
end

--[[---------------------------------------------------------
	Name: Loading
-----------------------------------------------------------]]

function gWare.Utils.LoadAll()
    -- load libraries first
    gWare.Utils.Load(gWare.Utils.Dir .. "/libs")

    -- then database
    gWare.Utils.Load(gWare.Utils.Dir)

    -- then the rest in best order
    gWare.Utils.Load(gWare.Utils.Dir .. "/utils")
    gWare.Utils.Load(gWare.Utils.Dir)
    gWare.Utils.Load(gWare.Utils.Dir .. "/settings")
    gWare.Utils.Load(gWare.Utils.Dir .. "/networking")
    gWare.Utils.Load(gWare.Utils.Dir .. "/commands")

    -- finally add clientside files
    gWare.Utils.AddCSDir(gWare.Utils.Dir .. "/vgui")

    MsgC(Color(23, 89, 255), "\n", UtilsBranding, Color(255, 255, 255), authors, "\n\n")
    gWare.Utils.Print("gWare successfully loaded.")
    gWare.Utils.Loaded = true
end

if not gWare.Utils.Loaded then
    if VoidLib then
        gWare.Utils.LoadAll()
    else
        hook.Add("VoidLib.Loaded", "gWare.Init.WaitForVoidLib", function ()
            gWare.Utils.LoadAll()
        end)
    end
end
