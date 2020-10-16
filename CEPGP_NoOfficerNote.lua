--local addonName, CEPGP_NON = ...
--local addon = addon = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("CEPGP_NoOfficerNote")

--[[ Globals ]]--
CEPGP_NON_Addon = "CEPGP_NoOfficerNote"
CEPGP_NON_LoadedAddon = false

SLASH_CEPGPNON1 = "/CEPNON"
SLASH_CEPGPNON2 = "/cepnon"
SlashCmdList["CEPGPNON"] = CEPGP_NON_SlashCmd

--[[ SAVED VARIABLES ]]--

CEPGP_NON_DB = {};
CEPGP_NON_INDEX = 0
CEPGP_NON_RECORD_ON_MAIN_ENABLE = true
CEPGP_NON_RECORD_ON_MAIN_DISCOUNT = 100

--[[ Code ]]--

local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", CEPGP_NON_OnEvent)


--[[ WOW API HOOK ]]--
local origGuildRosterSetOfficerNote = GuildRosterSetOfficerNote
local origCanEditOfficerNote = CanEditOfficerNote
local origGetGuildRosterInfo = GetGuildRosterInfo
local origGetNumGuildMembers = GetNumGuildMembers

function CEPGP_NON_SaveEPGP(index, offNote)
	if CEPGP_NON_DB[index] == nil then return; end
	
	-- add the decimal part. because cepgp will calculate the EP/GP by math.floor
	local EP, GP, ep, gp 
	EP = tonumber(strsub(offNote, 1, strfind(offNote, ",")-1));
	GP = tonumber(strsub(offNote, strfind(offNote, ",")+1, string.len(offNote)));
	GP = math.max(GP, CEPGP.GP.Min);
	ep = tostring(EP + CEPGP_NON_DB[index]["IMPORT_EP_DECIMAL"])
	gp = tostring(GP + CEPGP_NON_DB[index]["IMPORT_GP_DECIMAL"])
	CEPGP_NON_DB[index]["ONOTE"] = ep .. "," .. gp
	CEPGP_NON_DB[index]["EP"] = ep
	CEPGP_NON_DB[index]["GP"] = gp
	CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
	
	if CEPGP_isML() == 0 then
		local msg = "NON_NEW;"..index..";"..CEPGP_NON_DB[index]["NAME"]..";"..CEPGP_NON_DB[index]["EP"]..";"..CEPGP_NON_DB[index]["GP"]..";"..CEPGP_NON_DB[index]["ALT"]..";"..CEPGP_NON_DB[index]["IMPORT_EP"]..";"..CEPGP_NON_DB[index]["IMPORT_GP"]..";"
		CEPGP_messageGroup(msg, "raid", false, 0);
	end
end

function CEPGP_NON_GuildRosterSetOfficerNote_Hook(index, offNote)
	if IsInRaid() then
		CEPGP_NON_SaveEPGP(index, offNote)
		return
	end
	return origGuildRosterSetOfficerNote(index, offNote)
end

function CEPGP_NON_CanEditOfficerNote_Hook()
	if IsInRaid() then
		return true
	end
	return origCanEditOfficerNote()
end

function CEPGP_NON_GetGuildRosterInfo_Hook(index)
	if IsInRaid() then
		if CEPGP_NON_DB[index] == nil then
			return nil
		else
			-- name, rank, rankIndex, level, class, zone, note, officernote, online, status, classFileName, achievementPoints, achievementRank, isMobile, isSoREligible, standingID
			return CEPGP_NON_DB[index]["NAME"], "", 0, 60, CEPGP_NON_DB[index]["CLASS"], "", "", CEPGP_NON_DB[index]["ONOTE"], 1, 0, CEPGP_NON_DB[index]["classFileName"]
		end
	end
	return origGetGuildRosterInfo(index)
end

function CEPGP_NON_GetNumGuildMembers_Hook(index)
	if IsInRaid() then
		return #CEPGP_NON_DB
	end
	return origGetNumGuildMembers()
end

--[[ CEPGP HOOK ]]--
local function AddHook()
	_G.CEPGP_getEPGP = CEPGP_getEPGP_Override
	_G.CEPGP_getGuildInfo = CEPGP_getGuildInfo_Override
	_G.CEPGP_getIndex = CEPGP_getIndex_Override
	_G.CEPGP_formatExport = CEPGP_formatExport_Override
	_G.CEPGP_charIsExcluded = CEPGP_charIsExcluded_Override
	_G.CEPGP_addAltEPGP = CEPGP_addAltEPGP_Override
	_G.CEPGP_encodeClassString = CEPGP_encodeClassString_Override
	_G.CEPGP_import = CEPGP_NON_import
	_G.CEPGP_export = CEPGP_NON_export
	CEPGP_callItem = CEPGP_callItem_Hook
	CEPGP_IncAddonMsg = CEPGP_IncAddonMsg_Hook
	CEPGP_getPlayerClass = CEPGP_getPlayerClass_Hook
	CEPGP_sendLootMessage = CEPGP_sendLootMessage_Hook
	CEPGP_UpdateGuildScrollBar = CEPGP_UpdateGuildScrollBar_Hook

	GuildRosterSetOfficerNote = CEPGP_NON_GuildRosterSetOfficerNote_Hook
	CanEditOfficerNote = CEPGP_NON_CanEditOfficerNote_Hook
	GetNumGuildMembers = CEPGP_NON_GetNumGuildMembers_Hook
	GetGuildRosterInfo = CEPGP_NON_GetGuildRosterInfo_Hook

	_G["CEPGP_options_alt_mangement_add_link"]:SetScript('OnClick', function()
		local main = CEPGP_options_alt_mangement_main_link:GetText();
		local alt = CEPGP_options_alt_mangement_alt_link:GetText();
		
		if #main == 0 or #alt == 0 then return; end
		
		--local mainIndex = CEPGP_getIndex(main);
		--local altIndex = CEPGP_getIndex(alt);
		--if not mainIndex then
		--	CEPGP_NON_print(main .. " is not on team list", true);
		--	return;
		--end
		--if not altIndex then
		--	CEPGP_NON_print(alt .. " is not on team list", true);
		--	return;
		-- end
		
		CEPGP_options_alt_mangement_main_link:SetText(main);
		CEPGP_options_alt_mangement_alt_link:SetText(alt);
		
		if main == alt then
			return;
		end
		
		PlaySound(799);
		CEPGP_addCharacterLink(main, alt);
		CEPGP_options_alt_mangement_main_link:ClearFocus();
		CEPGP_options_alt_mangement_alt_link:SetFocus();
		CEPGP_UpdateAltScrollBar();
	end);

	_G["CEPGP_guild_add_EP"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true); end);
	_G["CEPGP_guild_decay"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true);	end);
	_G["CEPGP_guild_decay_EP"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true); end);
	_G["CEPGP_guild_decay_GP"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true); end);
	_G["CEPGP_guild_reset"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true); end);
	_G["CEPGP_button_guild_dump"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true); end);
	_G["CEPGP_button_guild_restore"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true); end);
	_G["CEPGP_button_guild_filter"]:SetScript('OnClick', function() CEPGP_NON_print(L["You CANNOT doing this at NoOfficerNote mode"], true); end);

	_G["CEPGP_button_guild"]:SetText(L["Team"])
	_G["CEPGP_guild_add_EP"]:SetText("")
	_G["CEPGP_guild_decay"]:SetText("")
	_G["CEPGP_guild_decay_EP"]:SetText("")
	_G["CEPGP_guild_decay_GP"]:SetText("")
	_G["CEPGP_guild_reset"]:SetText("")
	_G["CEPGP_button_guild_dump"]:SetText("")
	_G["CEPGP_button_guild_restore"]:SetText("")
	_G["CEPGP_button_guild_filter"]:SetText("")
	_G["CEPGP_guild_CEPGP_mode"]:SetText("Current View: Team")

	CEPGP_Info.ClassColours[""]= {
		r = 1,
		g = 1,
		b = 1,
		colorStr = "#FFFFFF"
	}
end

--[[ CORE ]]--
function CEPGP_NON_SlashCmd()
	CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
	CEPGP_populateFrame();
	ShowUIPanel(CEPGP_frame);
	CEPGP_toggleFrame("");
	CEPGP_toggleFrame("CEPGP_guild");
	CEPGP_mode = "guild";
	CEPGP_populateFrame();
end

local function SaveSettings(self)
	if CEPGP_NON_RECORD_ON_MAIN_ENABLE then
		CEPGP.Alt.BlockAwards = false;
		CEPGP.Alt.SyncEP = true;
		CEPGP.Alt.SyncGP = true;
	end
end

local function GuiSetting()
	CEPGP_NON_options:Hide()
	CEPGP_NON_options.name = "Classic EPGP NoOfficerNote"
	CEPGP_NON_options.okay = SaveSettings
	InterfaceOptions_AddCategory(CEPGP_NON_options)

	_G["CEPGP_NON_options_text"]:SetText(L["Alt Management"])
	_G["CEPGP_NON_options_record_on_main_enable_text"]:SetText(L["Recode EPGP on Main character"])
	_G["CEPGP_NON_options_record_on_main_enable"]:SetScript('OnEnter', function() 
		GameTooltip:Show();
		GameTooltip:SetOwner(_G["CEPGP_NON_options_record_on_main_enable"], "ANCHOR_TOPRIGHT");
		GameTooltip:SetText(L["Recode EPGP on Main character Tooltips"]);
	end);
	_G["CEPGP_NON_options_record_on_main_discount_text"]:SetText(L["EP Percent: "])
	_G["CEPGP_NON_import_guide_text"]:SetText(L["Import Instruction"]);
	_G["CEPGP_NON_export_guide_text"]:SetText(L["Export Instruction"]);
	_G["CEPGP_NON_Raid_Warning_text"]:SetText(L["You have to be in a Raid"]);
end

local function Init()
	if (_G.CEPGP) then
		GuiSetting()
		AddHook()		
		CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
		if #CEPGP_NON_DB == 0 then
			CEPGP_NON_CreateNewMember(1, UnitName("player"), "0", "1", "0", 0, 1)
		end
    end
end

function CEPGP_NON_CreateNewMember(index, name, ep, gp, isAlt, import_ep, import_gp)
	CEPGP_NON_DB[index] = {}
	local class, classFileName, classIndex = UnitClass(name);
	if class ~= nil	then 
		CEPGP_NON_DB[index]["CLASS"] = class 
		CEPGP_NON_DB[index]["classFileName"] = classFileName
	else
		CEPGP_NON_DB[index]["CLASS"] = "UNKNOWN"
		CEPGP_NON_DB[index]["classFileName"] = "UNKNOWN"
	end

	CEPGP_NON_DB[index]["EP"] = ep
	CEPGP_NON_DB[index]["GP"] = gp
	CEPGP_NON_DB[index]["ONOTE"] = ep .. "," .. gp
	CEPGP_NON_DB[index]["ALT"] = isAlt

	CEPGP_NON_DB[index]["NAME"] = name
	CEPGP_NON_DB[index]["IMPORT_EP"] = import_ep
	CEPGP_NON_DB[index]["IMPORT_GP"] = import_gp
	CEPGP_NON_DB[index]["IMPORT_EP_DECIMAL"] = math.fmod(CEPGP_NON_DB[index]["IMPORT_EP"], 1)
	CEPGP_NON_DB[index]["IMPORT_GP_DECIMAL"] = math.fmod(CEPGP_NON_DB[index]["IMPORT_GP"], 1)
end

function CEPGP_NON_print(str, err)
	if not str then return; end;
	if err == nil then
		DEFAULT_CHAT_FRAME:AddMessage("|c00FFF569CEPGP_NON: " .. tostring(str) .. "|r");
	else
		DEFAULT_CHAT_FRAME:AddMessage("|c00FFF569CEPGP_NON:|r " .. "|c00FF0000Error|r|c00FFF569 - " .. tostring(str) .. "|r");
	end
end

function CEPGP_NON_OnEvent(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == CEPGP_NON_Addon and CEPGP_NON_LoadedAddon == false then
        self:UnregisterEvent("ADDON_LOADED")
        CEPGP_NON_LoadedAddon = true
		Init()
    end
end

local LastItemCall = nil
function CEPGP_NON_Ticker_Countdown(id, gp, buttons, timeout)
	if not id then return; end
	if tonumber(timeout) <= 0 then return; end

	LastItemCall = GetTime();
	local timestamp = LastItemCall;
	local timer = timeout-1;
	
	local callback;
	callback = C_Timer.NewTicker(1, function()
		if LastItemCall ~= timestamp or not CEPGP_Info.Loot.Distributing then
			callback._remainingIterations = 1;
			return;
		end
		if (CEPGP_ntgetn(CEPGP_Info.Loot.ItemsTable) == CEPGP_Info.Loot.NumOnline) then
			callback._remainingIterations = 1;
			if CEPGP.Loot.RaidWarning then
				SendChatMessage(L["Everyone replied"]  , "RAID_WARNING", CEPGP_LANGUAGE);
			else
				SendChatMessage(L["Everyone replied"] , "RAID", CEPGP_LANGUAGE);
			end
			return;
		end

		if timer == 0 then
			if CEPGP.Loot.RaidWarning then
				SendChatMessage('{rt7} {rt7} {rt7} {rt7} {rt7}' , "RAID_WARNING", CEPGP_LANGUAGE);
			else
				SendChatMessage('{rt7} {rt7} {rt7} {rt7} {rt7}', "RAID", CEPGP_LANGUAGE);
			end
			return;
		elseif timer < 10 then
			if CEPGP.Loot.RaidWarning then
				SendChatMessage(tostring(timer) , "RAID_WARNING", CEPGP_LANGUAGE);
			else
				SendChatMessage(tostring(timer), "RAID", CEPGP_LANGUAGE);
			end
		end
		timer = timer - 1;
	end, timeout);
  end


--[[ GUI functions ]]--
function CEPGP_NON_importStandings()
	if not IsInRaid() then 
		CEPGP_NON_Raid_Warning:Show()
		return; 
	end

	CEPGP_NON_DB = {};
	CEPGP_NON_INDEX = 0
	CEPGP.Traffic = {};

	local impString = CEPGP_NON_import_dump:GetText();
	impString = string.gsub(impString, "    ", "," )
	impString = strtrim(impString)
	local lines = { strsplit("\n", impString) }
	for i = 1, table.getn(lines) do
		local name, ep, gp = strsplit(",", lines[i])
		if name ~= "" and name ~= nil and name ~= "ID" then
			CEPGP_NON_INDEX = CEPGP_NON_INDEX + 1
			local EP = (tonumber(ep))
			local GP = (tonumber(gp))
			CEPGP_NON_CreateNewMember(CEPGP_NON_INDEX, name, tostring(EP), tostring(GP), "0", tostring(EP), tostring(GP))
		end
	end

	-- add alt list
	for m, t in pairs(CEPGP.Alt.Links) do
		local indexMain = CEPGP_getIndex(m);
		if indexMain then
			for k, v in pairs(t) do
				local indexAlt = CEPGP_getIndex(v)
				if CEPGP_NON_RECORD_ON_MAIN_ENABLE and indexAlt then
					CEPGP_NON_print(L["Import alt error"], true)
					CEPGP_NON_DB = {};
					CEPGP_NON_INDEX = 0
					return
				else
					CEPGP_NON_INDEX = CEPGP_NON_INDEX + 1
					local ep, gp = CEPGP_getEPGP(m, indexMain)
					CEPGP_NON_CreateNewMember(CEPGP_NON_INDEX, v, ep, gp, "1", CEPGP_NON_DB[indexMain]["IMPORT_EP"], CEPGP_NON_DB[indexMain]["IMPORT_GP"])
				end
			end
		end
	end

	CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
	CEPGP_NON_import:Hide()
	CEPGP_NON_import_dump:SetText("")
end

--[[ CEPGP HOOK functions ]]--
hooksecurefunc("CEPGP_addCharacterLink", function(main, alt)
	if CEPGP.Alt.Links[main][#CEPGP.Alt.Links[main]] == alt then
		local mainIndex = -1
		local altIndex = -1
		for i = 1, #CEPGP_NON_DB do
			if CEPGP_NON_DB[i]["NAME"] == main then
				CEPGP_NON_DB[i]["ALT"] = "0"
				mainIndex = i
			elseif CEPGP_NON_DB[i]["NAME"] == alt then
				CEPGP_NON_DB[i]["ALT"] = "1"
				altIndex = i
			end
		end

		if mainIndex ~= -1 and altIndex == -1 then	-- found main and didn't found alt in the list
			CEPGP_NON_INDEX = CEPGP_NON_INDEX + 1
			local ep, gp = CEPGP_getEPGP(main, mainIndex)
			CEPGP_NON_CreateNewMember(CEPGP_NON_INDEX, alt, ep, gp, "1", CEPGP_NON_DB[indexMain]["IMPORT_EP"], CEPGP_NON_DB[indexMain]["IMPORT_GP"])
			CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
		end
	end
end)

local origCEPGP_callItem = CEPGP_callItem
local origCEPGP_IncAddonMsg = CEPGP_IncAddonMsg
local origCEPGP_getPlayerClass = CEPGP_getPlayerClass
local origCEPGP_sendLootMessage = CEPGP_sendLootMessage
local origCEPGP_UpdateGuildScrollBar = CEPGP_UpdateGuildScrollBar


function CEPGP_callItem_Hook(id, gp, buttons, timeout)
	if timeout then
		CEPGP_NON_Ticker_Countdown(id, gp, buttons, timeout)
	end
	origCEPGP_callItem(id, gp, buttons, timeout)
end

function CEPGP_IncAddonMsg_Hook(message, sender, channel)
	local args = CEPGP_split(message, ";"); -- The broken down message, delimited by semi-colons
	if args[1] == "NON_NEW" then
		CEPGP_NON_CreateNewMember(tonumber(args[2]), args[3], args[4], args[5], args[6], args[7], args[8] )
	end

	origCEPGP_IncAddonMsg(message, sender, channel)
end

function CEPGP_getPlayerClass_Hook(name, index)
	if not name then return; end
	index = CEPGP_getIndex(name)
	if index then
		if CEPGP_NON_DB[index]["class"]  == "UNKNOWN" then 
			localizedClass, englishClass, classIndex = UnitClass(name);
			if localizedClass ~= nil then 
				CEPGP_NON_DB[index]["class"] = localizedClass
				CEPGP_NON_DB[index]["classFileName"]  = englishClass
			end
		end
	end
	return origCEPGP_getPlayerClass(name, index)
end

function CEPGP_sendLootMessage_Hook(message)
	local args = CEPGP_split(message, ";");
	local name = args[2]
	local index = CEPGP_getIndex(name)
	if index then
		local msg = "NON_NEW;"..index..";"..CEPGP_NON_DB[index]["NAME"]..";"..CEPGP_NON_DB[index]["EP"]..";"..CEPGP_NON_DB[index]["GP"]..";"..CEPGP_NON_DB[index]["ALT"]..";"..CEPGP_NON_DB[index]["IMPORT_EP"]..";"..CEPGP_NON_DB[index]["IMPORT_GP"]..";"
		CEPGP_messageGroup(msg, "raid", false, 0);
	end

	origCEPGP_sendLootMessage(message)
end

function CEPGP_UpdateGuildScrollBar_Hook()
	if not IsInRaid() then return; end

	origCEPGP_UpdateGuildScrollBar()
end
--[[ CEPGP Override functions ]]--

function CEPGP_getEPGP_Override(name, index)
    if not index and not name then return; end
    local EP, GP = nil;

	if not index then
		index = CEPGP_getIndex(name)
	end

    if CEPGP_NON_DB[index] == nil then 
        return 0, CEPGP.GP.Min;
    else
        local offNote = CEPGP_NON_DB[index]["ONOTE"]
        EP = tonumber(strsub(offNote, 1, strfind(offNote, ",")-1));
		GP = tonumber(strsub(offNote, strfind(offNote, ",")+1, string.len(offNote)));
		GP = math.max(GP, CEPGP.GP.Min);
        return EP, GP
    end
end

function CEPGP_getGuildInfo_Override(name)
    if not name then return; end
    if CEPGP_Info.Guild.Roster[name] then
		local index = CEPGP_getIndex(name);
		local oNote = CEPGP_NON_DB[index]["ONOTE"];
		return index, CEPGP_Info.Guild.Roster[name][2], CEPGP_Info.Guild.Roster[name][3], CEPGP_Info.Guild.Roster[name][4], oNote, CEPGP_Info.Guild.Roster[name][6], CEPGP_Info.Guild.Roster[name][7];  -- index, class, Rank, RankIndex, OfficerNote, PR, className in English
	else
        return nil
	end
end

function CEPGP_getIndex_Override(name)
	if not name then return; end
	local i
	for i = 1, #CEPGP_NON_DB do
		if CEPGP_NON_DB[i]["NAME"] == name then
			return i
		end
	end
	return nil
end

function CEPGP_formatExport_Override()
	local allID = ""
	local allEP = ""
	local allGP = ""
	for i = 1, #CEPGP_NON_DB do
		if CEPGP_NON_DB[i]["ALT"] == "0" then
			local offNote = CEPGP_NON_DB[i]["ONOTE"]
			EP = tonumber(strsub(offNote, 1, strfind(offNote, ",")-1));
			GP = tonumber(strsub(offNote, strfind(offNote, ",")+1, string.len(offNote)));
			GP = math.max(GP, CEPGP.GP.Min);
			local strID = CEPGP_NON_DB[i]["NAME"]
			local strEP = tostring(EP - CEPGP_NON_DB[i]["IMPORT_EP"])
			local strGP = tostring(GP - CEPGP_NON_DB[i]["IMPORT_GP"])
			if i == 1 then
				allID = strID
				allEP = strEP
				allGP = strGP
			else
				allID = allID .. "\n" .. strID
				allEP = allEP .. "\n" .. strEP
				allGP = allGP .. "\n" .. strGP
			end
		end
	end
	_G["CEPGP_NON_export_dump_ID"]:SetText(allID);
	_G["CEPGP_NON_export_dump_EP"]:SetText(allEP);
	_G["CEPGP_NON_export_dump_GP"]:SetText(allGP);
	_G["CEPGP_NON_export_dump_EP"]:HighlightText();
	_G["CEPGP_NON_export_dump_EP"]:SetFocus();
		
end

function CEPGP_charIsExcluded_Override(name, index)
	return false;
end

function CEPGP_addAltEPGP_Override(EP, GP, alt, main)
	local success, failMsg = pcall(function()
		if CEPGP_NON_RECORD_ON_MAIN_ENABLE then
			EP = EP * (CEPGP_NON_RECORD_ON_MAIN_DISCOUNT / 100)
		end
		if not main or CEPGP.Alt.BlockAwards then return; end
		local indexAlt = CEPGP_getIndex(alt);
		local mainEP, mainGP = CEPGP_getEPGP(main, CEPGP_Info.Guild.Roster[main][1]);
		local altEP, altGP = CEPGP_getEPGP(alt, index);
		
		mainEP = math.max(mainEP + EP, 0);
		mainGP = math.max(mainGP + GP, CEPGP.GP.Min + math.max(GP, 0));

		altEP = math.max(altEP + EP, 0);
		altGP = math.max(altGP + GP, CEPGP.GP.Min + math.max(GP, 0));	
		
		local mainEP_decimal = math.fmod(mainEP,1)

		mainEP = math.floor(mainEP)
		mainGP = math.floor(mainGP)
		altEP = math.floor(altEP)
		altGP = math.floor(altGP)

		if CEPGP_NON_RECORD_ON_MAIN_ENABLE then
			local indexMain = CEPGP_getIndex(main);
			CEPGP_NON_DB[indexMain]["IMPORT_EP_DECIMAL"] = mainEP_decimal
			CEPGP_NON_DB[indexAlt]["IMPORT_EP_DECIMAL"] = mainEP_decimal
			GuildRosterSetOfficerNote(indexMain, mainEP .. "," .. mainGP);	--	Both EPGP are being synced
			GuildRosterSetOfficerNote(indexAlt, mainEP .. "," .. mainGP);	--	Both EPGP are being synced
		else
			if CEPGP.Alt.SyncEP and CEPGP.Alt.SyncGP then
				GuildRosterSetOfficerNote(indexAlt, mainEP .. "," .. mainGP);	--	Both EPGP are being synced
			elseif CEPGP.Alt.SyncEP then
				GuildRosterSetOfficerNote(indexAlt, mainEP .. "," .. altGP);	--	Only EP is being synced
			elseif CEPGP.Alt.SyncGP then
				GuildRosterSetOfficerNote(indexAlt, altEP .. "," .. mainGP);	--	Only GP is being synced
			else
				GuildRosterSetOfficerNote(indexAlt, altEP .. "," .. altGP);	--	Alt standings are not synced with main
			end
			C_Timer.After(1, function()
				CEPGP_syncToMain(alt, indexAlt, main);
			end);
		end
		
	end);
	
	if not success then
		CEPGP_NON_print("Could not process changes to EPGP for " .. alt, true);
		CEPGP_NON_print(failMsg, true);
	end
end

function CEPGP_encodeClassString_Override(class, str)
	
	local colours = {
		["DRUID"] = "00FF7D0A",
		["HUNTER"] = "00A9D271",
		["MAGE"] = "0040C7EB",
		["PALADIN"] = "00F58CBA",
		["PRIEST"] = "00FFFFFF",
		["ROGUE"] = "00FFF569",
		["SHAMAN"] = "000070DE",
		["WARLOCK"] = "008787ED",
		["WARRIOR"] = "00C79C6E",
		[""] = "00FFFFFF"
	}
	if class then
		return "|c" .. colours[class] .. str .. "|r";
	else
		return "|cFFFFFFFF" .. str .. "|r";
	end
end


