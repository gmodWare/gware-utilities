--[[---------------------------------------------------------
    Name: Setup
-----------------------------------------------------------]]
gWare = gWare or {}
gWare.Utils = gWare.Utils or {}

local authors = "by Menschlich, kxx & Luiggi"
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
gWare.Addons["Utils"] = true

gWare.Utils.Lang = gWare.Utils.Lang or {}
gWare.Utils.Dir = "gware-utils"

--[[---------------------------------------------------------
    Name: Directory Walker
-----------------------------------------------------------]]

function gWare.Utils.Load(dir)
    local files = file.Find(dir .. "/" .. "*", "LUA")

    for k, filename in pairs(files) do
        if filename:StartWith("cl") then

            AddCSLuaFile(dir .. "/" .. filename)

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

            local load = include(dir .. "/" .. filename)
            if load then load() end
        end
    end
end

function gWare.Utils.AddCSDir(dir)
    local files = file.Find(dir .. "/" .. "*", "LUA")

    for k, v in pairs(files) do
        AddCSLuaFile(dir .. "/" .. v)

        if CLIENT then
            include(dir .. "/" .. v)
        end
    end
end

--[[---------------------------------------------------------
    Name: Functions
-----------------------------------------------------------]]


function gWare.Utils.Print(str, type)
    local color = Color(23, 89, 255)

    if type == "error" then
        color = Color(255, 23, 23)
    elseif type == "warning" then
        color = Color(255, 182, 23)
    end

    MsgC(color, "gWare Utilities ", Color(255, 255, 255), "» ", Color(255, 255, 255), str, "\n")
end

--[[---------------------------------------------------------
    Name: Loading
-----------------------------------------------------------]]

function gWare.Utils.LoadAll()
    -- load libraries first
    gWare.Utils.Load(gWare.Utils.Dir .. "/libs")

    -- init languages
    gWare.Lang:Init("Utils")

    -- then database
    gWare.Utils.Load(gWare.Utils.Dir)

    -- then the rest in best order
    gWare.Utils.Load(gWare.Utils.Dir .. "/utils")
    gWare.Utils.Load(gWare.Utils.Dir)
    gWare.Utils.Load(gWare.Utils.Dir .. "/settings")
    gWare.Utils.Load(gWare.Utils.Dir .. "/networking")
    gWare.Utils.Load(gWare.Utils.Dir .. "/commands")
    gWare.Utils.Load(gWare.Utils.Dir .. "/permissions")

    -- finally add clientside files
    gWare.Utils.AddCSDir(gWare.Utils.Dir .. "/vgui")

    MsgC(Color(23, 89, 255), UtilsBranding, Color(255, 255, 255), authors, "\n\n")
    gWare.Utils.Print("gWare successfully loaded.")
    gWare.Utils.Loaded = true
end

hook.Add("Initialize", "gWare.Init", function()
    if (not DarkRP) then
        gWare.Utils.Print("DarkRP is required to run gWare Utilities.", "error")
        return
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
end)
