local database = VoidLib.Database:Create({
    host = "localhost",
    username = "username",
    password = "password",
    database = "database",
    port = 3306,
    useMySQL = false,
})

function database:OnConnected()
    local query = database:Create("gware_settings")
        query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
        query:Create("setting_name", "VARCHAR(15) NOT NULL")
        query:Create("setting_value", "BOOLEAN")
        query:PrimaryKey("id")
    query:Execute()

    query = database:Create("gware_jobsaccess")
        query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
        query:Create("job_command", "VARCHAR(15) NOT NULL")
        query:Create("setting_id", "VARCHAR(15) NOT NULL")
        query:PrimaryKey("id")
    query:Execute()

    query = database:Create("gware_npc_spawns")
        query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
        query:Create("npc_name", "VARCHAR(15) NOT NULL")
        query:Create("npc_pos", "INTEGER")
        query:PrimaryKey("id")
    query:Execute()

    query = database:Create("gware_npc_jobs")
        query:Create("id", "INTEGER NOT NULL AUTO_INCREMENT")
        query:Create("npc_name", "VARCHAR(15) NOT NULL")
        query:Create("job_command", "VARCHAR(15) NOT NULL")
        query:PrimaryKey("id")
    query:Execute()
end

database:Connect()

function gWare.Utils.InsertNPCJob(npc_name, job_command)
    local query = database:Insert("gware_npc_jobs")
        query:Insert("npc_name", npc_name)
        query:Insert("job_command", job_command)
    query:Execute()
end

function gWare.Utils.GetNPCJobs(npc_name, callback)
    local query = database:Select("gware_npc_jobs")
        query:Where("npc_name", npc_name)
        query:Select("job_command")
        query:Callback(function (tblData)
            if not tblData then return end
            callback(tblData)
        end)
    query:Execute()
end

function gWare.Utils.DeleteNPCJob(npc_name, job_command)
    local query = database:Delete("gware_npc_jobs")
        query:Where("npc_name", npc_name)
        query:Where("job_command", job_command)
    query:Execute()
end

function gWare.Utils.InsertNPCSpawn(npc_name, npc_pos)
    local query = database:Insert("gware_npc_spawns")
        query:Insert("npc_name", npc_name)
        query:Insert("npc_pos", npc_pos)
    query:Execute()
end

function gWare.Utils.GetAllNPCPos(callback)
    local query = database:Select("gware_npc_spawns")
        query:Select("npc_name")
        query:Select("npc_pos")
        query:Callback(function (tblData)
            if not tblData then return end
            callback(tblData)
        end)
    query:Execute()
end

function gWare.Utils.DeleteNPCSpawn(npc_name)
    local query = database:Delete("gware_npc_spawns")
        query:Where("npc_name", npc_name)
    query:Execute()
end

function gWare.Utils.InsertSetting(setting_name, setting_value)
    local query = database:Insert("gware_settings")
        query:Insert("setting_name", setting_name)
        query:Insert("setting_value", setting_value)
    query:Execute()
end

function gWare.Utils.UpdateSetting(setting_name, setting_value)
    local query = database:Update("gware_settings")
        query:Where("setting_name", setting_name)
        query:Update("setting_value", setting_value)
    query:Execute()
end

function gWare.Utils.GetSetting(setting_name, callback)
    local query = database:Select("gware_settings")
        query:Where("setting_name", setting_name)
        query:Select("setting_value")
        query:Callback(function (tblData)
            callback(tblData)
        end)
    query:Execute()
end

function gWare.Utils.GetAllSettings(callback)
    local query = database:Select("gware_settings")
        query:Select("setting_name")
        query:Select("setting_value")
        query:Callback(function (tblData)
            callback(tblData)
        end)
    query:Execute()
end

function gWare.Utils.InsertJob(jobCommand, settingID)
    local query = database:Insert("gware_jobsaccess")
        query:Insert("job_command", jobCommand)
        query:Insert("setting_id", settingID)
    query:Execute()
end

function gWare.Utils.DeleteJob(jobCommand, settingID)
    local query = database:Delete("gware_jobsaccess")
        query:Where("job_command", jobCommand)
        query:Where("setting_id", settingID)
    query:Execute()
end

function gWare.Utils.GetAllJobs(callback)
    local query = database:Select("gware_jobsaccess")
        query:Select("job_command")
        query:Select("setting_id")
        query:Callback(function (tblData)
            callback(tblData)
        end)
    query:Execute()
end