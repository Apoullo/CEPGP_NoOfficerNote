--[[ Globals ]]--
local L = LibStub("AceLocale-3.0"):GetLocale("CEPGP_NoneOfficeNote")

CEPGP_NON_Addon = "CEPGP_NoneOfficeNote"
CEPGP_NON_LoadedAddon = false

SLASH_CEPGPNON1 = "/CEPNON"
SLASH_CEPGPNON2 = "/cepnon"
SlashCmdList["CEPGPNON"] = CEPGP_NON_SlashCmd

local LOG_FRAME_WIDTH = 800
local LOG_FRAME_HEIGHT = 500

local CEPGP_import_Hook = nil
local LeftScrollList = nil
local LeftEditBox = nil
local MidScrollList = nil
local MidEditBox = nil
local RightScrollList = nil
local RightEditBox = nil

--[[ SAVED VARIABLES ]]--

CEPGP_NON_DB = {};
CEPGP_NON_INDEX = 0
CEPGP_NON_RECORD_ON_MAIN_ENABLE = false
CEPGP_NON_RECORD_ON_MAIN_DISCOUNT = 50

--[[ Code ]]--

local frame = CreateFrame("Frame")
frame:RegisterEvent("VARIABLES_LOADED")
frame:RegisterEvent("ADDON_LOADED")

function CEPGP_NON_SlashCmd()
	CEPGP_populateFrame();
	ShowUIPanel(CEPGP_frame);
	CEPGP_toggleFrame("");
	CEPGP_updateGuild();
	CEPGP_toggleFrame("CEPGP_guild");
	CEPGP_mode = "guild";
	CEPGP_populateFrame();
end

local function AddHook()
	_G.CEPGP_getEPGP = CEPGP_getEPGP_Hook
	_G.CEPGP_getGuildInfo = CEPGP_getGuildInfo_Hook
	_G.CEPGP_getIndex = CEPGP_getIndex_Hook
	_G.CEPGP_getPlayerClass = CEPGP_getPlayerClass_Hook
	_G.CEPGP_rosterUpdate = CEPGP_rosterUpdate_Hook
	_G.CEPGP_formatExport = CEPGP_formatExport_Hook
	_G.CEPGP_charIsExcluded = CEPGP_charIsExcluded_Hook
	_G.CEPGP_addAltEPGP = CEPGP_addAltEPGP_Hook
	_G.CEPGP_encodeClassString = CEPGP_encodeClassString_Hook
	_G.CEPGP_import = CEPGP_NON_import
	_G.CEPGP_export = CEPGP_NON_export
	GuildRosterSetOfficerNote = CEPGP_GuildRosterSetOfficerNote_Hook
	CanEditOfficerNote = CEPGP_CanEditOfficerNote_Hook

	_G["CEPGP_options_alt_mangement_add_link"]:SetScript('OnClick', function()
		local main = CEPGP_options_alt_mangement_main_link:GetText();
		local alt = CEPGP_options_alt_mangement_alt_link:GetText();
		
		if #main == 0 or #alt == 0 then return; end
		
		--local mainIndex = CEPGP_getIndex(main);
		--local altIndex = CEPGP_getIndex(alt);
		--if not mainIndex then
		--	CEPGP_print(main .. " is not on team list", true);
		--	return;
		--end
		--if not altIndex then
		--	CEPGP_print(alt .. " is not on team list", true);
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

	_G["CEPGP_guild_add_EP"]:SetScript('OnClick', function() CEPGP_print(L["You CANNOT doing this at NoneOfficeNote mode"], true); end);
	_G["CEPGP_guild_decay"]:SetScript('OnClick', function() CEPGP_print(L["You CANNOT doing this at NoneOfficeNote mode"], true);	end);
	_G["CEPGP_guild_decay_EP"]:SetScript('OnClick', function() CEPGP_print(L["You CANNOT doing this at NoneOfficeNote mode"], true); end);
	_G["CEPGP_guild_decay_GP"]:SetScript('OnClick', function() CEPGP_print(L["You CANNOT doing this at NoneOfficeNote mode"], true); end);
	_G["CEPGP_guild_reset"]:SetScript('OnClick', function() CEPGP_print(L["You CANNOT doing this at NoneOfficeNote mode"], true); end);
	_G["CEPGP_button_guild_dump"]:SetScript('OnClick', function() CEPGP_print(L["You CANNOT doing this at NoneOfficeNote mode"], true); end);
	_G["CEPGP_button_guild_restore"]:SetScript('OnClick', function() CEPGP_print(L["You CANNOT doing this at NoneOfficeNote mode"], true); end);
	_G["CEPGP_button_guild"]:SetText(L["Team"])
	
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
	CEPGP_NON_options.name = "Classic EPGP NonOfficeNote"
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
end

local function Init()
	if (_G.CEPGP) then
		GuiSetting()
		AddHook()		
		CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
    end
end

function CEPGP_NON_CreateNewMember(index, name, ep, gp)
	CEPGP_NON_DB[index] = {}
	CEPGP_NON_UpdateMember(index, name, ep, gp, "", "")
end

function CEPGP_NON_UpdateMember(index, name, ep, gp, class, classFileName)
	local pr = math.floor((ep/gp)*100)/100
	CEPGP_NON_DB[index]["ONOTE"] = ep .. "," .. gp
	CEPGP_NON_DB[index]["PR"] = pr
	CEPGP_NON_DB[index]["NAME"] = name
	if class ~= nil then CEPGP_NON_DB[index]["CLASS"] = class end
	if classFileName ~= nil then CEPGP_NON_DB[index]["classFileName"] = classFileName end
end

local function OnEvent(self, event, arg1)
    if arg1 ~= CEPGP_NON_Addon then return end
    if event == "ADDON_LOADED" and CEPGP_NON_LoadedAddon == false then
        self:UnregisterEvent("ADDON_LOADED")
        CEPGP_NON_LoadedAddon = true
        Init()
    end
end

frame:SetScript("OnEvent", OnEvent)

function CEPGP_NON_importStandings()
	CEPGP_NON_DB = {};
	CEPGP_NON_INDEX = 0
	TRAFFIC = {};

	local impString = CEPGP_NON_import_dump:GetText();
	impString = string.gsub(impString, "    ", "," )
	impString = strtrim(impString)
	local lines = { strsplit("\n", impString) }
	for i = 1, table.getn(lines) do
		local name, ep, gp = strsplit(",", lines[i])
		if name ~= "" and name ~= nil and name ~= "ID" then
			CEPGP_NON_INDEX = CEPGP_NON_INDEX + 1
			local EP = math.floor(tonumber(ep))
			local GP = math.floor(tonumber(gp))
			CEPGP_NON_CreateNewMember(CEPGP_NON_INDEX, name, tostring(EP), tostring(GP))
			CEPGP_NON_DB[CEPGP_NON_INDEX]["IMPORT_EP"] = EP
			CEPGP_NON_DB[CEPGP_NON_INDEX]["IMPORT_GP"] = GP
			CEPGP_NON_DB[CEPGP_NON_INDEX]["ALT"] = false
		end
	end

	for m, t in pairs(CEPGP.Alt.Links) do
		for k, v in pairs(t) do
			local index = CEPGP_getIndex(m);
			if index then
				CEPGP_NON_INDEX = CEPGP_NON_INDEX + 1
				local ep, gp = CEPGP_getEPGP(m, index)
				CEPGP_NON_CreateNewMember(CEPGP_NON_INDEX, v, ep, gp)
				CEPGP_NON_DB[CEPGP_NON_INDEX]["ALT"] = true
			end
		end
	end

	CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
	CEPGP_NON_import:Hide()
	CEPGP_NON_import_dump:SetText("")
end

-- Hook Functions --

function CEPGP_getEPGP_Hook(name, index)
    if not index and not name then return; end
    local EP, GP = nil;

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

function CEPGP_getGuildInfo_Hook(name)
    if not name then return; end
    if CEPGP_roster[name] then
		local index = CEPGP_getIndex(name);
		local oNote = CEPGP_NON_DB[index]["ONOTE"];
		return index, CEPGP_roster[name][2], CEPGP_roster[name][3], CEPGP_roster[name][4], oNote, CEPGP_roster[name][6], CEPGP_roster[name][7];  -- index, class, Rank, RankIndex, OfficerNote, PR, className in English
	else
        return nil
	end
end

function CEPGP_getIndex_Hook(name)
	if not name then return; end
	local i
	for i = 1, #CEPGP_NON_DB do
		if CEPGP_NON_DB[i]["NAME"] == name then
			return i
		end
	end
	return nil
end

function CEPGP_getPlayerClass_Hook(name, index)
	if not index and not name then return; end
	if index == nil then index = CEPGP_getIndex(name); end
	local class;
	if name == "Guild" then
		return _, {r=0, g=1, b=0};
	end
	if name == "Raid" then
		return _, {r=1, g=0.10, b=0.10};
    end
    if index then
        classFileName = CEPGP_NON_DB[index]["classFileName"] 
		return class, CEPGP_Info.ClassColours[classFileName];
	else
		return nil;
	end
end

function CEPGP_rosterUpdate_Hook(event)
	if CEPGP_Info.IgnoreUpdates or not CEPGP_Info.Initialised then return; end
	if event == "GUILD_ROSTER_UPDATE" then
		if CEPGP_Info.Polling then
			CEPGP_Info.Rescan = true;
			return;
		end
		--CEPGP_Info.LastUpdate = GetTime()+(CEPGP.PollRate*GetNumGuildMembers());
		CEPGP_Info.Polling = true;
		local pRate = CEPGP.PollRate;
		local quit = false;
		--local timer = CEPGP_Info.LastUpdate;
		--local numGuild = GetNumGuildMembers();
		
		if CanEditOfficerNote() then
			CEPGP_guild_add_EP:Show();
			CEPGP_guild_decay:Show();
			CEPGP_guild_reset:Show();
			CEPGP_raid_add_EP:Show();
			CEPGP_button_guild_restore:Show();
			CEPGP_button_guild_import:Show();
		else --[[ Hides context sensitive options if player cannot edit officer notes ]]--
			CEPGP_guild_add_EP:Hide();
			CEPGP_guild_decay:Hide();
			CEPGP_guild_reset:Hide();
			CEPGP_raid_add_EP:Hide();
			CEPGP_button_guild_restore:Hide();
			CEPGP_button_guild_import:Hide();
		end
		
		CEPGP_updateGuild();

		CEPGP_roster = {}
		local i = 0;
		for i = 1, #CEPGP_NON_DB do
			CEPGP_roster[CEPGP_NON_DB[i]["NAME"]] = {
				[1] = i,
				[2] = CEPGP_NON_DB[i]["CLASS"],
				[3] = "",	-- rank
				[4] = 0,	-- rankIndex
				[5] = CEPGP_NON_DB[i]["ONOTE"],
				[6] = CEPGP_NON_DB[i]["PR"],
				[7] =  CEPGP_NON_DB[i]["classFileName"],
				[8] = true
			};
		end
		
		CEPGP_rosterUpdate("GROUP_ROSTER_UPDATE");

        if _G["CEPGP_guild"]:IsVisible() and #CEPGP_NON_DB > 0 then
            CEPGP_UpdateGuildScrollBar();
        elseif _G["CEPGP_raid"]:IsVisible() then
            CEPGP_UpdateRaidScrollBar();
        end
        if #CEPGP_NON_DB > 0 then
            CEPGP_UpdateStandbyScrollBar();
        end
        
        if CEPGP_Info.QueuedAnnouncement then
            CEPGP_Info.QueuedAnnouncement();
            CEPGP_Info.QueuedAnnouncement = nil;
        end
        
        for _, func in pairs(CEPGP_Info.RosterStack) do
            func();
        end
        CEPGP_Info.RosterStack = {};
        CEPGP_Info.Polling = false;
        if CEPGP_Info.Rescan then
            CEPGP_Info.Rescan = false;
            CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE");
        end

		
	elseif event == "GROUP_ROSTER_UPDATE" then
		if IsInRaid() then
			_G["CEPGP_button_raid"]:Show();
		else
			_G["CEPGP_button_raid"]:Hide();
			_G["CEPGP_raid"]:Hide();
			CEPGP_raidRoster = {};
		end
		--CEPGP_raidRoster = {};
		
		local tempRoster = {};
		for _, player in pairs(CEPGP_raidRoster) do
			if player[1] then
				tempRoster[player[1]] = "";
			end
		end
		
		local function update()
			for index, player in ipairs(CEPGP_raidRoster) do
				if tempRoster[player[1]] then
					table.remove(CEPGP_raidRoster, index);
				end
			end
		
			if UnitInRaid("player") then
				ShowUIPanel(CEPGP_button_raid);
			else --[[ Hides the raid and loot distribution buttons if the player is not in a raid group ]]--
				CEPGP_mode = "guild";
				CEPGP_toggleFrame("CEPGP_guild");
				
			end
			if _G["CEPGP_raid"]:IsVisible() then
				CEPGP_UpdateRaidScrollBar();
			end
		end
		
		local i = 0;
		--for i = 1, GetNumGroupMembers() do
		local limit = GetNumGroupMembers();
		C_Timer.NewTicker(CEPGP.PollRate, function()
			i = i + 1;
			local name = GetRaidRosterInfo(i);
			if name then
				tempRoster[name] = nil;
			end
			if not UnitInRaid("player") then
				CEPGP_standbyRoster = {};
				CEPGP_UpdateStandbyScrollBar();
			else
				for k, v in ipairs(CEPGP_standbyRoster) do
					if v[1] == name then
						table.remove(CEPGP_standbyRoster, k); --Removes player from standby list if they have joined the raid
						if CEPGP_isML() == 0 then
							CEPGP_SendAddonMsg("StandbyRemoved;" .. name .. ";You have been removed from the standby list because you have joined the raid.", "RAID");
						end
						CEPGP_UpdateStandbyScrollBar();
					end
				end
			end
			
			local _, _, _, _, class, classFileName = GetRaidRosterInfo(i);
			local index = CEPGP_getIndex(name);
			local rank;
			
			if index then
				
				rank = "";
				local rankIndex = 0;
				
				EP, GP = CEPGP_getEPGP(name, index);
				local PR = math.floor((EP/GP)*100)/100;
				
				CEPGP_raidRoster[i] = {
					[1] = name,
					[2] = class,
					[3] = rank,
					[4] = rankIndex,
					[5] = EP,
					[6] = GP,
					[7] = PR,
					[8] = classFileName
                };
                CEPGP_NON_UpdateMember(index, name, EP, GP, class, classFileName)
			else
				rank = L["Not in Team"] ;
				CEPGP_raidRoster[i] = {
					[1] = name,
					[2] = class,
					[3] = rank,
					[4] = 11,
					[5] = 0,
					[6] = BASEGP,
					[7] = 0,
					[8] = classFileName
				};
            end
			if i == limit then
				update();
			end
		end, limit);
	end
end

function CEPGP_formatExport_Hook()
	local allID = ""
	local allEP = ""
	local allGP = ""
	for i = 1, #CEPGP_NON_DB do
		if CEPGP_NON_DB[i]["ALT"] == false then
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

function CEPGP_charIsExcluded_Hook(name, index)
	return false;
end

function CEPGP_addAltEPGP_Hook(EP, GP, alt, main)
	local success, failMsg = pcall(function()
		if CEPGP_NON_RECORD_ON_MAIN_ENABLE then
			EP = EP * (CEPGP_NON_RECORD_ON_MAIN_DISCOUNT / 100)
		end
		if not main or CEPGP.Alt.BlockAwards then return; end
		local index = CEPGP_getIndex(alt);
		local mainEP, mainGP = CEPGP_getEPGP(main, CEPGP_roster[main][1]);
		local altEP, altGP = CEPGP_getEPGP(alt, index);
		
		mainEP = math.max(mainEP + EP, 0);
		mainGP = math.max(mainGP + GP, CEPGP.GP.Min + math.max(GP, 0));
		
		altEP = math.max(altEP + EP, 0);
		altGP = math.max(altGP + GP, CEPGP.GP.Min + math.max(GP, 0));
		
		if CEPGP.Alt.SyncEP and CEPGP.Alt.SyncGP then
			GuildRosterSetOfficerNote(index, mainEP .. "," .. mainGP);	--	Both EPGP are being synced
		elseif CEPGP.Alt.SyncEP then
			GuildRosterSetOfficerNote(index, mainEP .. "," .. altGP);	--	Only EP is being synced
		elseif CEPGP.Alt.SyncGP then
			GuildRosterSetOfficerNote(index, altEP .. "," .. mainGP);	--	Only GP is being synced
		else
			GuildRosterSetOfficerNote(index, altEP .. "," .. altGP);	--	Alt standings are not synced with main
		end
		
		C_Timer.After(1, function()
			CEPGP_syncToMain(alt, index, main);
		end);
	end);
	
	if not success then
		CEPGP_print("Could not process changes to EPGP for " .. alt, true);
		CEPGP_print(failMsg, true);
	end
end

function CEPGP_encodeClassString_Hook(class, str)
	
	local colours = {
		["DRUID"] = "00FF7D0A",
		["HUNTER"] = "00A9D271",
		["MAGE"] = "0040C7EB",
		["PALADIN"] = "00F58CBA",
		["PRIEST"] = "00FFFFFF",
		["ROGUE"] = "00FFF569",
		["SHAMAN"] = "000070DE",
		["WARLOCK"] = "008787ED",
		["WARRIOR"] = "00C79C6E"
	}
	if class ~= nil and class ~= "" then
		return "|c" .. colours[class] .. str .. "|r";
	else
		return "|cFFFFFFFF" .. str .. "|r";
	end
end

function CEPGP_GuildRosterSetOfficerNote_Hook(index, offNote)
    if CEPGP_NON_DB[index] == nil then
        return
    else
        CEPGP_NON_DB[index]["ONOTE"] = offNote
        CEPGP_rosterUpdate("GUILD_ROSTER_UPDATE")
    end
end

function CEPGP_CanEditOfficerNote_Hook()
    return true
end