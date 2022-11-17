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
end

database:Connect()

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
        query:Insert(jobCommand)
        query:Insert(settingID)
    query:Execute()
end

function gWare.Utils.GetJob(settingID, callback)
    local query = database:Select("gware_jobsaccess")
        query:Where("setting_id", settingID)
        query:Select("job_command")
        query:Callback(function (tblData)
            callback(tblData)
        end)
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