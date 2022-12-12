function gWare.Utils.AddPermission(type, name, description)
    if type == "CAMI" then
        CAMI.RegisterPrivilege({
            Name = "can_access_c-menu",
            MinAccess = "superadmin",
            Description = "Can the player open the c-menu?",
        })
    elseif type == "SAM" then
        CAMI.UnregisterPrivilege(name)
        sam.permissions.add(name, "gWare", "superadmin")
    end
end

local function AddPermissionsToSAM()
    gWare.Utils.AddPermission("SAM", "can_access_c-menu")
    gWare.Utils.AddPermission("SAM", "can_access_spawnmenu")
    gWare.Utils.AddPermission("SAM", "can_access_vote")
    gWare.Utils.AddPermission("SAM", "can_change_gware_settings")
    gWare.Utils.AddPermission("SAM", "can_set_jobs-spawns_gware_tool")
end


////////////////
// META TABLE //
////////////////

local meta = FindMetaTable("Player")

function meta:HasGWarePermission(name)
    if SAM_LOADED then
        return self:HasPermission(name)
    else
        return CAMI.PlayerHasAccess(self, name)
    end
end


gWare.Utils.AddPermission("CAMI", "can_access_c-menu", "Can the player open the c-menu?")
gWare.Utils.AddPermission("CAMI", "can_access_spawnmenu", "Can the player open the spawnmenu?")
gWare.Utils.AddPermission("CAMI", "can_access_vote", "Can the player open the vote menu?")
gWare.Utils.AddPermission("CAMI", "can_change_gware_settings", "Can the player change the gWare settings?")
gWare.Utils.AddPermission("CAMI", "can_set_jobs-spawns_gware_tool", "Can the player set the job spawns per gWare tool?")

if SAM_LOADED then
    AddPermissionsToSAM()
else
    hook.Add("SAM.LoadedConfig", "gWare.Utils.SamModules.WaitForClient", function()
        AddPermissionsToSAM()
    end)
end

hook.Add("OnContextMenuOpen", "gWare.Utils.ContextMenuCheck", function()
    if not gWare.Utils.GetSettingValue("contextmenu") then return end
    if not LocalPlayer():HasGWarePermission("can_access_c-menu") then return false end
end)

hook.Add("OnSpawnMenuOpen", "gWare.Utils.SpawnMenuCheck", function()
    if not gWare.Utils.GetSettingValue("spawnmenu") then return end
    if not LocalPlayer():HasGWarePermission("can_access_spawnmenu") then return false end
end)
