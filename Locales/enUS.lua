local L = LibStub("AceLocale-3.0"):NewLocale("CEPGP_NoOfficerNote", "enUS", true)
if not L then return end

L["Alt Management"] = true
L["Recode EPGP on Main character"] = true
L["Recode EPGP on Main character Tooltips"] = "\nIf enabled,Main will get EP by using Alt to raid.\nCEPGP Setting:\"Synchronise Alt EP/GP\" will be enabled\nCEPGP Setting:\"Block Alt EPGP Modifications\" will be disabled"
L["EP Percent: "] = true
L["You CANNOT doing this at NoOfficerNote mode"] = true
L["Team"] = true
L["Not in Team"] = true
L["Import Instruction"] = "Paste 3 Columns data\nfrom google sheet.\n| ID | EP | GP |"
L["Export Instruction"] = "Gained EP/GP value list.\nYou can ctrl+c copy it to your sheet."
L["Import alt error"] = "There should be NOT an ALT in the list."
L["Everyone replied"] = true
L["Everyone replied"] = "所有人都回覆了"