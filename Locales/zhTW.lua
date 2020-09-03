local L = LibStub("AceLocale-3.0"):NewLocale("CEPGP_NoneOfficeNote", "zhTW")
if not L then return end

L["Alt Management"] = "分身管理"
L["Recode EPGP on Main character"] = "紀錄EPGP到本尊身上"
L["Recode EPGP on Main character Tooltips"] = "使用CEPGP裡的分身設定列表。\n用分身出團時獲得的EPGP會記錄在本尊身上。\n若勾選，則CEPGP的分身設定裡：\n  \"Synchronise Alt EP/GP\"會自動啟動\n  \"Block Alt EPGP Modifications\"會自動取消。"
L["EP Percent: "] = "EP 百分比: "
L["You CANNOT doing this at NoneOfficeNote mode"] = "\"不使用幹部註記的模式\"下無法執行該動作"
L["Team"] = "出團名單"
L["Not in Team"] = "非團員"
L["Import Instruction"] = "將Google表單裡\n| ID | EP | GP |\n三個欄位的所有資料貼入"
L["Export Instruction"] = "本次出團獲得的EPGP列表\n用 ctrl+c 複製到你自己的表單中"