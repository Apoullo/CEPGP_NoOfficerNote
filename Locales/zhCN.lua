local L = LibStub("AceLocale-3.0"):NewLocale("CEPGP_NoOfficerNote", "zhCN")
if not L then return end

L["Alt Management"] = "小号管理"
L["Recode EPGP on Main character"] = "纪录EPGP到大号身上"
L["Recode EPGP on Main character Tooltips"] = "使用CEPGP里的小号设定列表。\n用小号出团时获得的EPGP会记录在大号身上。\n若勾选，则CEPGP的小号设定里： \n \"Synchronise Alt EP/GP\"会自动启动\n \"Block Alt EPGP Modifications\"会自动取消。"
L["EP Percent: "] = "EP 百分比: "
L["You CANNOT doing this at NoOfficerNote mode"] = "\"不使用干部注记\"的模式下无法执行该动作"
L["Team"] = "出团名单"
L["Not in Team"] = "非团员"
L["Import Instruction"] = "将Google表单里\n| ID | EP | GP |\n三个栏位的所有资料贴入"
L["Export Instruction"] = "本次出团获得的EPGP列表\n用 ctrl+c 复制到你自己的表单中"
L["Import alt error"] = "失败，出团名单里面不能有小号"
L["Everyone replied"] = "所有人都回覆了"
L["You have to be in a Raid"] = "你必须要在团队之中"
L["You are not the Loot Master"] = "你不是装备分配者"
