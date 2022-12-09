local branch = "master"
local rawURL = "https://raw.githubusercontent.com/gmodWare/gware-lang/"
local apiEndPoint = "https://api.github.com/gmodWare/gware-lang/git/trees/master?recursive=1"

gWare.Lang = gWare.Lang or {}

if (SERVER) then
    util.AddNetworkString("gWare.Lang.NetworkLocalLanguages")

    concommand.Add("gware_reloadlangs", function(ply, cmd, args)
        if (!ply:IsSuperAdmin()) then return end

        for name, v in pairs(gWare.Addons) do
            local gTable = _G[name]
            if (!gTable) then continue end

            gWare.Lang:LoadLocalLanguages(name, true)
            gWare.Lang:NetworkLocalLanguages(name, gTable.Lang.LocalLanguages)

            if (table.Count(gTable.Lang.LocalLanguages) > 0) then
                gWare.Lang:NetworkLocalLanguages(name, gTable.Lang.LocalLanguages)
            end
        end

        print("Successfully reloaded local languages!")
    end)
end

if (CLIENT) then
    net.Receive("gWare.Lang.NetworkLocalLanguages", function()
        local addon = net.ReadString()
        local tbl = VoidLib.ReadCompressedTable()

        local gTable = _G[addon]
        if (!gTable) then return end

        gTable.Lang.Langs = tbl

        print("Received local languages from server!")
    end)
end

function gWare.Lang:Init(addon)
    local gTable = _G[addon]
    if (!gTable) then return end

    gTable.Lang = gTable.Lang or {}
    gTable.Lang.Langs = gTable.Lang.Langs or {}
    gTable.Lang.AvailableLangs = gTable.Lang.AvailableLangs or {}

    function gTable.Lang.GetPhrase(phrase, x)
        return gWare.Lang:GetLangPhrase(addon, phrase, x)
    end

    -- We need to wait until first tick is called because of HTTP API not working yet
    hook.Add("Tick", "gWare.Lang.InitTick" .. addon, function()
        hook.Remove("Tick", "gWare.Lang.InitTick" .. addon)

        gWare.Lang:DownloadLanguages(addon, function(failed)
            if (failed) then
                print("Failed to fetch available languages - using only local languages!")
            end

            timer.Simple(2, function () -- Wait until files are written
                gWare.Lang:LoadLanguages(addon)
            end)
        end)
    end)
end

function gWare.Lang:GetAvailableLanguages(addon, callback, failCallback)
    local gTable = _G[addon]
    if (!gTable) then return end
    local url = apiEndpoint

    http.Fetch(url, function (body, size, headers, code)
        -- Success
        if (code != 200 or !body or body == "") then
            print("Couldn't get available languages - error code " .. code .. " (please try again later)")
            return
        end

        local tbl = util.JSONToTable(body)
        if (!tbl or table.Count(tbl) < 1) then
            print("Couldn't parse available languages - no languages exist?")
            return
        end

        local langs = {}
        for k, fileTbl in pairs(tbl.tree) do
            if (!string.StartWith(fileTbl.path, addon) or addon == fileTbl.path) then continue end

            local fileName = string.Replace(fileTbl.path, addon .. "/")
            if (fileName == ".gitkeep") then continue end

            local name = string.Replace(fileName, ".json", "")
            langs[#langs + 1] = name
        end

        callback(langs)

    end, function (err)
        -- Failure
        print("Couldn't get available languages - error: " .. err)
        failCallback()
    end)
end

function gWare.Lang:GetLangPhrase(addon, phrase)
    local gTable = _G[addon]
    if (!gTable) then return end

    local langRef = gTable.Config.Language
    if (!langRef) then
        print("Tried to get langauge phrase, but no selected language! Falling back to English.")
        gTable.Config.Language = "English"

        return phrase
    end

    -- We don't want the reference
    local lang = string.lower(langRef)

    local langs = gTable.Lang.Langs
    if (!langs) then
        print("Langs table not initialized yet!")
        return phrase
    end
    
    local returnVal = phrase
    if (langs[lang] and langs[lang][phrase]) then
        -- If the language has the phrase
        returnVal = langs[lang][phrase]
    elseif (langs["english"] and langs["english"][phrase]) then
        -- If not, fallback to english
        returnVal = langs["english"][phrase]
    end

    if (x) then
        returnVal = VoidLib.StringFormat(returnVal, x)
    end

    -- If no langauge has the phrase, return the phrase itself
    return returnVal
end

function gWare.Lang:IsLanguageInstalled(addon, lang)
    local langFile = "gware-languages/" .. addon .. "/" .. lang .. ".json"
    return file.Exists(langFile, "DATA"), langFile
end

function gWare.Lang:IsLatest(addon, lang, newLang)
    local isInstalled, path = self:IsLanguageInstalled(addon, lang)
    if (!isInstalled) then return false, false end

    local langContent = file.Read(path)

    local existingLangCRC = util.CRC(langContent)
    local newLangCRC = util.CRC(newLang)

    return newLangCRC == existingLangCRC, true
end

function gWare.Lang:WriteLanguage(addon, lang, json)
    if (!file.Exists("gware-languages", "DATA")) then
        file.CreateDir("gware-languages")
    end

    if (!file.Exists("gware-languages/" .. addon, "DATA")) then
        file.CreateDir("gware-languages/" .. addon)
    end

    file.Write("gware-languages/" .. addon .. "/" .. lang .. ".json", json)
end

function gWare.Lang:LoadLocalLanguages(addon, reload)
    if (!SERVER) then return end

    local gTable = _G[addon]
    if (!gTable) then return end

    local files = file.Find("gware-languages/" .. addon .. "/*.json", "DATA")
    local langs = {}

    for k, v in pairs(files) do
        local langName = string.Replace(v, ".json", "")
        if (!reload) then
            if (gTable.Lang.Langs[langName]) then continue end
        end

        local json = file.Read("gware-languages/" .. addon .. "/" .. v)

        local tbl = util.JSONToTable(json)
        local length = table.Count(tbl or {})
        if (!tbl or length < 1) then
            print("Tried to load " .. v .. ", but langauge file is corrupt/empty!")
            continue
        end

        print("Loaded " .. langName .. " local language! (" .. length .. " phrases)")

        langs[langName] = tbl
    end

    gTable.Lang.LocalLanguages = langs

    gWare.Lang:NetworkLocalLanguages(addon, langs)

    local totalLangs = table.Count(langs) 
    if (totalLangs > 0) then
        table.Merge(gTable.Lang.Langs, langs)

        print("Loaded " .. totalLangs .. " local languages!")
    end
end

function gWare.Lang:NetworkLocalLanguages(addon, tbl, ply)
    if (!SERVER) then return end

    net.Start("gWare.Lang.NetworkLocalLanguages")
        net.WriteString(addon)
        VoidLib.WriteCompressedTable(tbl)
    if (ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function gWare.Lang:LoadLanguages(addon)
    local gTable = _G[addon]
    if (!gTable) then return end

    for _, lang in pairs(gTable.Lang.AvailableLangs or {}) do
        local langExists, langFile = self:IsLanguageInstalled(addon, lang)
        if (!langExists) then
            print("Tried to load " .. lang .. ", but langauge is not installed!")
            continue
        end

        local json = file.Read(langFile)
        if (!json or json == "") then
            print("Tried to load " .. lang .. ", but langauge file is empty!")
            continue
        end
        
        local tbl = util.JSONToTable(json)
        if (!tbl or table.Count(tbl) < 1) then
            print("Tried to load " .. lang .. ", but langauge file is corrupt/empty!")
            continue
        end

        gTable.Lang.Langs[lang] = tbl
    end

    gWare.Lang:LoadLocalLanguages(addon)

    if (table.Count(gTable.Lang.Langs) < 1) then
        print("Tried to load languages, but none downloaded!")
        return
    end

    gTable:Log("Loaded " .. table.Count(gTable.Lang.Langs) .. " languages!", "Languages")

    gTable.Lang.LanguagesLoaded = true
    hook.Run(addon .. ".Lang.LanguagesLoaded")
end

function gWare.Lang:DownloadLanguages(addon, callback)
    local gTable = _G[addon]
    if (!gTable) then return end

    self:GetAvailableLanguages(addon, function(languages)
        gTable.Lang.AvailableLangs = languages

        local callbacksDone = 0

        if (#languages == 0) then
            callback()
        end

        for _, lang in pairs(languages) do
            local formattedLangName = lang:gsub("^%l", string.upper)
            local url = rawUrl .. branch .. "/" .. addon .. "/" .. lang .. ".json"
            http.Fetch(url, function (body, size, headers, code)
                callbacksDone = callbacksDone + 1
            
                if (code != 200 or !body or body == "") then
                    print("Couldn't get " .. lang .. " language: " .. code .. " (please try again later)")
                    if (callbacksDone == #languages) then
                        callback()
                    end
                    return
                end

                local tbl = util.JSONToTable(body)
                if (!tbl or table.Count(tbl) < 1) then
                    print("Couldn't parse language " .. lang .. " - incorrect or empty JSON!")
                    if (callbacksDone == #languages) then
                        callback()
                    end
                    return
                end

                local isLatest, isUpdating = gWare.Lang:IsLatest(addon, lang, body)
                if (!isLatest) then
                    local operationString = isUpdating and "Updated" or "Downloaded"
                    print(operationString .. " " .. formattedLangName .. " language")

                    self:WriteLanguage(addon, lang, body)
                elseif (gTable.Debug) then
                    print(formattedLangName .. " language is up to date!", "Languages")
                end

                if (callbacksDone == #languages) then
                    callback()
                end
                

            end, function (err)
                print("Couldn't download " .. lang .. " language - error: " .. err)
            end)
        end

    end, function ()
        -- Failed
        callback(true)
    end)
end