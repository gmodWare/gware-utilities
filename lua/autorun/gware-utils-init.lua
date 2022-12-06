gWare = gWare or {}
gWare.Utils = gWare.Utils or {}

gWare.Addons = gWare.Addons or {}
gWare.Addons["gWareUtils"] = true

local rootDir = "gware-utils"

local function AddFile(File, dir)
    local fileSide = string.lower(string.Left(File, 3))

    if SERVER and fileSide == "sv_" then
        include(dir .. File)
    elseif fileSide == "sh_" then
        if SERVER then
            AddCSLuaFile(dir .. File)
        end

        include(dir .. File)
    elseif fileSide == "cl_" then
        if SERVER then
            AddCSLuaFile(dir .. File)
        elseif CLIENT then
            include(dir .. File)
        end
    end
end

local function IncludeDir(dir)
    dir = dir .. "/"
    local File, Directory = file.Find(dir .. "*", "LUA")

    for k, v in ipairs(File) do
        if string.EndsWith(v, ".lua") then
            AddFile(v, dir)
        end
    end

    for k, v in ipairs(Directory) do
        IncludeDir(dir .. v)
    end
end

if (VoidLib) then
    AddFile("sh_cami.lua", "autorun/")
    IncludeDir(rootDir)
    print("[gWare Utils] Addon Loaded Successfully")
else
    hook.Add("VoidLib.Loaded", "gWare.Utils.Init.WaitForVoidLib", function ()
        AddFile("sh_cami.lua", "autorun/")
        IncludeDir(rootDir)
        print("[gWare Utils] Addon Loaded Successfully")
    end)
end

