gWare.Utils.Colors = {
    Brackets = Color(50, 54, 61),

    Perfect = Color(9, 168, 30),
    Good = Color(160, 226, 6),
    Okay = Color(172, 104, 14),
    Bad =  Color(151, 28, 28),
    Orange = Color(218, 178, 0),

    -- TODO: Split commands in prefix and actual text in the brackets
    -- this will be used for example in "vfunk" => "Verschlüsselter Funk"
    Commands = {
        -- no translation for this one
        ["default"] = Color(150, 150, 150),

        -- these have their own translation
        ["act"] = Color(234, 245, 75),
        ["decode"] = Color(234, 245, 75),
        ["comms"] = Color(0, 38, 255),
        ["ooc"] = Color(169, 75, 245),
        ["looc"] = Color(205, 75, 245),
        ["roll"] = Color(75, 92, 245),
        ["encrypted-comms"] = Color(48, 15, 194),
        ["mact"] = Color(87, 32, 93),
        ["advert"] = Color(2, 84, 17),
    }
}
