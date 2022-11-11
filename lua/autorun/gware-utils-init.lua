gWare = gWare or {}
gWare.Utils = gWare.Utils or {}

-- TODO: load files
if SERVER then
    AddCSLuaFile("gware-utils/commands/sh_akt.lua")
    AddCSLuaFile("gware-utils/commands/sh_decode.lua")
    AddCSLuaFile("gware-utils/commands/sh_funk.lua")
    AddCSLuaFile("gware-utils/commands/sh_looc.lua")
    AddCSLuaFile("gware-utils/commands/sh_ooc.lua")
    AddCSLuaFile("gware-utils/commands/sh_roll.lua")
    AddCSLuaFile("gware-utils/commands/sh_vfunk.lua")
    AddCSLuaFile("gware-utils/settings/sv_settings.lua")
end

if CLIENT then
    -- Sowy Leute heute kein GTA
end

-- Shared
include("gware-utils/commands/sh_akt.lua")
include("gware-utils/commands/sh_decode.lua")
include("gware-utils/commands/sh_funk.lua")
include("gware-utils/commands/sh_looc.lua")
include("gware-utils/commands/sh_ooc.lua")
include("gware-utils/commands/sh_roll.lua")
include("gware-utils/commands/sh_vfunk.lua")
include("gware-utils/settings/sv_settings.lua")