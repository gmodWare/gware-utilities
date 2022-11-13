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