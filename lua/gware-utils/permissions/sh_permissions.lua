function gWare.Utils.AddPermission(type, name, description)
    if type == "CAMI" then
        CAMI.RegisterPrivilege({
            Name = name,
            MinAccess = "superadmin",
            Description = description,
        })
    elseif type == "SAM" then
        CAMI.UnregisterPrivilege("gware_"..name)
        sam.permissions.add(name, "gmodWare", "superadmin")
    end
end

local function AddPermissionsToSAM()
    gWare.Utils.AddPermission("SAM", "open_context_menu")
    gWare.Utils.AddPermission("SAM", "open_spawnmenu")
    gWare.Utils.AddPermission("SAM", "create_vote")
    gWare.Utils.AddPermission("SAM", "edit_settings")
    gWare.Utils.AddPermission("SAM", "set_job_spawns")
end


////////////////
// META TABLE //
////////////////

local meta = FindMetaTable("Player")

function meta:HasGWarePermission(name)
    if SAM_LOADED then
        return self:HasPermission(name)
    else
        return CAMI.PlayerHasAccess(self, "gware_"..name)
    end
end


gWare.Utils.AddPermission("CAMI", "gware_open_context_menu", "Can the player open the c-menu?")
gWare.Utils.AddPermission("CAMI", "gware_open_spawnmenu", "Can the player open the spawnmenu?")
gWare.Utils.AddPermission("CAMI", "gware_create_vote", "Can the player open the vote menu?")
gWare.Utils.AddPermission("CAMI", "gware_edit_settings", "Can the player change the gWare settings?")
gWare.Utils.AddPermission("CAMI", "gware_set_job_spawns", "Can the player set the job spawns per gWare tool?")

if SAM_LOADED then
    AddPermissionsToSAM()
else
    hook.Add("SAM.LoadedConfig", "gWare.Utils.SamModules.WaitForClient", function()
        AddPermissionsToSAM()
    end)
end



