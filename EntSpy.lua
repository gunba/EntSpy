require "Window"

----------------------------------------------------------------
-- EntSpy Module Definition
-----------------------------------------------------------------------------------------------
local EntSpy = {} 
local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:GetLocale("EntSpy", true)
local GeminiLocale = Apollo.GetPackage("Gemini:Locale-1.0").tPackage

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------
function EntSpy:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 
	
	--list of units/relevant units
	self.tUnitList = {}
	self.tUnitListRel = {}
	self.tUnitListRelCount = {}
	self.tUnitListLine = {}
	
	self.aSortedUnitRef = {}
	self.tPrefixList = {}
	
	self.tQuestList = {}
	self.tEventList = {}
	self.tPosList = {}
	
	self.tMarkers = {}
	self.tMarkers["Quest"] = {}
	self.tMarkers["Path"] = {}
	self.tMarkers["Event"] = {}
	self.tMarkers["Challenge"] = {}
	self.tLines = {}
	
	self.sPlayerSearch = nil
	self.nDistLimit = 0
	self.uSetUnit = nil
	self.nLoadedSave = 0
	self.bChalActivate = false
	
	self.cat = {}
	
	self:RegisterCats()
	
	self.tBattleground = {}
	self.tBattleground["4472"] = 1
	self.tBattleground["797"] = 1
	
	self.tAdventure = {}
	self.tAdventure["1181"] = 1
	self.tAdventure["1393"] = 1
	
	self.colors = {}
	self.colors.CatChallenge = 'fcff7a00' -- light red
	self.colors.CatQuest = 'ffffff00' -- white (default)
	self.colors.CatPath = 'ff00ff00' -- green
	self.colors.CatEvent = 'ffffff00' -- same as quest
	
	self.Category = {}
	self.Category[self.cat.PVPStalker] 					= {color = {a=1,r=1,g=0,b=0}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Stalker", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "PVP", 		linecolor = 'FFFA5858'}
	self.Category[self.cat.PVPEngineer] 				= {color = {a=1,r=1,g=0,b=0}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Engineer", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "PVP", 		linecolor = 'FFFA5858'}
	self.Category[self.cat.PVPWarrior] 					= {color = {a=1,r=1,g=0,b=0}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Warrior", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "PVP", 		linecolor = 'FFFA5858'}
	self.Category[self.cat.PVPMedic] 					= {color = {a=1,r=1,g=0,b=0}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Medic", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "PVP", 		linecolor = 'FFFA5858'}
	self.Category[self.cat.PVPSpellslinger] 			= {color = {a=1,r=1,g=0,b=0}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Spellslinger", 				mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "PVP", 		linecolor = 'FFFA5858'}
	self.Category[self.cat.PVPEsper] 					= {color = {a=1,r=1,g=0,b=0}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Esper", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "PVP", 		linecolor = 'FFFA5858'}
	self.Category[self.cat.PVPMount] 					= {color = {a=1,r=1,g=0,b=0}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Dead_01", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "PVP", 		linecolor = 'FFFA5858'}
	self.Category[self.cat.Quest] 						= {color = {a=1,r=1,g=0.7,b=0.7}, 		sprite = "CRB_DEMO_WrapperSprites:sprDemo_SumIconKills", 				mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "QuestUnit", 	linecolor = 'FFFACC2E'}
	self.Category[self.cat.QuestSimple] 				= {color = {a=1,r=1,g=1,b=0.8}, 		sprite = "CRB_MinimapSprites:sprMM_Tradeskill", 					mindist = 0, 	cullable = 1, miny = 100, groupable = 1, parentopt = "QuestUnit", 	linecolor = 'FFFACC2E'}
	self.Category[self.cat.Event] 						= {color = {a=1,r=1,g=0.7,b=0.7}, 		sprite = "CRB_DEMO_WrapperSprites:sprDemo_SumIconKills", 				mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "Event", 		linecolor = 'FFFACC2E'}
	self.Category[self.cat.EventSimple] 				= {color = {a=1,r=1,g=1,b=0.8}, 		sprite = "CRB_MinimapSprites:sprMM_Tradeskill", 					mindist = 0, 	cullable = 1, miny = 100, groupable = 1, parentopt = "Event", 		linecolor = 'FFFACC2E'}
	self.Category[self.cat.Challenge]					= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CRB_MinimapSprites:sprMM_TargetObjective", 					mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "Challenge", 	linecolor = 'FFFE9A2E'}
	self.Category[self.cat.QuestNewMain] 				= {color = {a=1,r=1,g=1,b=1}, 			sprite = "ClientSprites:MiniMapNewQuest", 						mindist = 0, 	cullable = 0, miny = 100, groupable = 1, parentopt = "QuestNPC", 		linecolor = 'FF04B431'}
	self.Category[self.cat.QuestNew] 					= {color = {a=1,r=1,g=1,b=1}, 			sprite = "ClientSprites:MiniMapNewQuest", 						mindist = 0, 	cullable = 0, miny = 100, groupable = 1, parentopt = "QuestNPC", 		linecolor = 'FF04B431'}
	self.Category[self.cat.QuestReward] 				= {color = {a=1,r=1,g=1,b=1}, 			sprite = "ClientSprites:MiniMapQuestComplete", 						mindist = 0, 	cullable = 1, miny = 100, groupable = 1, parentopt = "QuestNPC", 		linecolor = 'FF04B431'}
	self.Category[self.cat.QuestTalkTo] 				= {color = {a=1,r=1,g=1,b=0.5}, 		sprite = "Crafting_CircuitSprites:btnCircuit_SquareGlass_BluePressed", 		mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "QuestUnit",		linecolor = 'FFFACC2E'}	
	
	self.Category[self.cat.Explorer] 					= {color = {a=1,r=0.7,g=0.7,b=0.7}, 	sprite = "CRB_PlayerPathSprites:spr_Path_Explorer_Stretch", 			mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "Path",		linecolor = 'FFBCF5A9'}				
	self.Category[self.cat.Soldier] 					= {color = {a=1,r=0.7,g=0.7,b=0.7}, 	sprite = "CRB_PlayerPathSprites:spr_Path_Soldier_Stretch", 				mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "Path",		linecolor = 'FFBCF5A9'}	
	self.Category[self.cat.Scientist] 					= {color = {a=1,r=0.7,g=0.7,b=0.7}, 	sprite = "CRB_PlayerPathSprites:spr_Path_Scientist_Stretch", 			mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "Path",		linecolor = 'FFBCF5A9'}	
	self.Category[self.cat.Settler]						= {color = {a=1,r=0.7,g=0.7,b=0.7}, 	sprite = "CRB_PlayerPathSprites:spr_Path_Settler_Stretch", 				mindist = 10, 	cullable = 1, miny = 100, groupable = 1, parentopt = "Path",		linecolor = 'FFBCF5A9'}	
	self.Category[self.cat.Spell] 						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CRB_Basekit:kitAccent_Frame_BlueSolid", 					mindist = 20, 	cullable = 1, miny = 100, groupable = 0}
	self.Category[self.cat.Search] 						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Mission_Explorer_ScavengerHunt", 			mindist = 0, 	cullable = 1, miny = 100, groupable = 1}
	self.Category[self.cat.Questloot] 					= {color = {a=1,r=1,g=1,b=1}, 			sprite = "ClientSprites:GroupLootIcon", 							mindist = 0, 	cullable = 1, miny = 100, groupable = 1, parentopt = "QuestUnit",		linecolor = 'FFFACC2E'}	
	self.Category[self.cat.Primes]						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Guild_UI_Guild_Skull", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 1, parentopt = "Prime",		linecolor = 'FFE6E6E6'}	
	self.Category[self.cat.Group]						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_AccountInventory_CharacterBound", 	mindist = 30, 	cullable = 0, miny = 100, groupable = 0, parentopt = "Group",		linecolor = 'FFA9F5F2'}	
 	self.Category[self.cat.Pending]						= {color = {a=0,r=0,g=0,b=0}, 			sprite = "achievements:sprAchievements_Icon_Solo", 					mindist = 30, 	cullable = 1, miny = 100, groupable = 0, parentopt = "Pending",		linecolor = 'FFFA5858'}	
	self.Category[self.cat.Subdue]						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Tooltip_Restricted", 			mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "Subdue",		linecolor = 'FFFA5858'}	
	self.Category[self.cat.Guild]						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Achievement_Achievement_Guild", 				mindist = 30, 	cullable = 0, miny = 100, groupable = 0, parentopt = "Guild",		linecolor = 'FF2ECCFA'}	
	self.Category[self.cat.Lore] 						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CRB_DatachronSprites:sprDC_Alert_Quest", 					mindist = 10, 	cullable = 0, miny = 100, groupable = 0, parentopt = "Lore",		linecolor = 'FFF5F6CE'}	
	self.Category[self.cat.Trail] 						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CRB_TargetFrameSprites:sprTF_PathExplorer", 				mindist = 10, 	cullable = 0, miny = 100, groupable = 0, parentopt = "Trail",		linecolor = 'FFF3E2A9'}	
	self.Category[self.cat.Stash] 						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CRB_ChallengeTrackerSprites:sprChallengeTypeLootLarge", 		mindist = 10, 	cullable = 0, miny = 100, groupable = 1}
	
	--WT
	self.Category[self.cat.WTWalatiki]					= {color = {a=1,r=1,g=1,b=1}, 			sprite = "ClientSprites:ComboStarFull", 							mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "MODP",		linecolor = 'FFFA5858'}	 
 
	--WOTW
	self.Category[self.cat.WOTWChampion]				= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CRB_WarriorSprites:sprWar_CenterArt", 					mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "MODA",		linecolor = 'FFFA5858'}	 
	self.Category[self.cat.WOTWEnergyNode]				= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CRB_InterfaceMenuList:spr_InterfaceMenuList_RedFlagStretch", 		mindist = 0, 	cullable = 0, miny = 100, groupable = 0, parentopt = "MODA",		linecolor = 'FFFA5858'}	 	

	--MT
	self.Category[self.cat.MTWater]						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Adventure_Malgrave_Water", 		mindist = 0, 	cullable = 1, miny = 100, groupable = 1, parentopt = "MODA",		linecolor = 'FFFA5858'}	 
	self.Category[self.cat.MTFeed]						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Adventure_Malgrave_Feed", 		mindist = 0, 	cullable = 1, miny = 100, groupable = 1, parentopt = "MODA",		linecolor = 'FFFA5858'}	 
	self.Category[self.cat.MTFood]						= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Adventure_Malgrave_Food", 		mindist = 0, 	cullable = 1, miny = 100, groupable = 1, parentopt = "MODA",		linecolor = 'FFFA5858'}	 
	self.Category[self.cat.MTCaravan]					= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_MapNode_Map_GroupMember", 					mindist = 60, 	cullable = 0, miny = 100, groupable = 1, parentopt = "MODA",		linecolor = 'FFFA5858'}	 
	self.Category[self.cat.MTChompa]					= {color = {a=1,r=1,g=1,b=1}, 			sprite = "IconSprites:Icon_Windows_UI_CRB_Marker_Pig", 				mindist = 0, 	cullable = 0, miny = 100, groupable = 1, parentopt = "MODA",		linecolor = 'FFFA5858'}		
		
	self.Category[self.cat.Mining] 						= {color = {a=1,r=1,g=0.2,b=0.2}, 		sprite = "CM_SpellslingerSprites:sprSlinger_NodeBar_InCombatOrange", 		mindist = 10, 	cullable = 0, miny = 100, groupable = 1, parentopt = "Mining",		linecolor = 'FFF78181'}	
	self.Category[self.cat.RelicHunting] 				= {color = {a=1,r=0.2,g=1,b=0.2}, 		sprite = "CM_SpellslingerSprites:sprSlinger_NodeBar_InCombatOrange", 		mindist = 10, 	cullable = 0, miny = 100, groupable = 1, parentopt = "RelicHunting",	linecolor = 'FFD8F781'}	
	self.Category[self.cat.Survivalist] 				= {color = {a=1,r=1,g=0.2,b=1}, 		sprite = "CM_SpellslingerSprites:sprSlinger_NodeBar_InCombatOrange", 		mindist = 10, 	cullable = 0, miny = 100, groupable = 1, parentopt = "Survivalist",	linecolor = 'FF04B45F'}	
	self.Category[self.cat.Farming] 					= {color = {a=1,r=1,g=1,b=1}, 			sprite = "CM_SpellslingerSprites:sprSlinger_NodeBar_InCombatOrange", 		mindist = 10, 	cullable = 0, miny = 100, groupable = 1, parentopt = "Farming",		linecolor = 'FFCEF6CE'}	
	
	
    return o
end

function EntSpy:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 
------------------------------------------------------------------------------------
-- EntSpy OnLoad
-----------------------------------------------------------------------------------------------
function EntSpy:OnLoad()
    
	self.xmlDoc = XmlDoc.CreateFromFile("EntSpy.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	
	
	--unit creation/destruction
	Apollo.RegisterEventHandler("UnitCreated", 					"OnUnitCreated", self) --unit
	Apollo.RegisterEventHandler("UnitDestroyed", 				"OnUnitDestroyed", self) --unit
	
	--zone events
	Apollo.RegisterEventHandler("SubZoneChanged", 				"OnZoneChanged", self)
	Apollo.RegisterEventHandler("ChatZoneChange", 				"OnZoneChanged", self)
	Apollo.RegisterEventHandler("ChangeWorld", 					"OnZoneChanged", self)
	
	
	--unit events
	Apollo.RegisterEventHandler("UnitActivationTypeChanged", 	"OnUnitChanged", self)
	Apollo.RegisterEventHandler("TargetUnitChanged", 			"OnUnitTargetChanged", self)
	Apollo.RegisterEventHandler("UnitNameChanged", 				"OnUnitChanged", self)
	
	--challenge events
	Apollo.RegisterEventHandler("ChallengeAbandon", 			"OnChallengeRemoved", self) --challenge id v
	Apollo.RegisterEventHandler("ChallengeFailTime", 			"OnChallengeRemoved", self)
    Apollo.RegisterEventHandler("ChallengeFailArea", 			"OnChallengeRemoved", self)
	Apollo.RegisterEventHandler("ChallengeCompleted", 			"OnChallengeRemoved", self)
	Apollo.RegisterEventHandler("ChallengeFailGeneric", 		"OnChallengeRemoved", self)
	Apollo.RegisterEventHandler("ChallengeActivate", 			"OnChallengeCreate", self) 
	Apollo.RegisterEventHandler("ChallengeUpdated", 			"OnChallengeUpdate", self)	--challenge id ^	
	
	--quest events
	Apollo.RegisterEventHandler("QuestObjectiveUpdated", 		"OnQuestUpdate", self)
	Apollo.RegisterEventHandler("QuestStateChanged", 			"OnQuestUpdate", self)
	Apollo.RegisterEventHandler("QuestTrackedChanged", 			"OnQuestUpdate", self)
		
	--public event events
	Apollo.RegisterEventHandler("PublicEventObjectiveLocationAdded", 		"OnEventUpdate", self)
	Apollo.RegisterEventHandler("PublicEventObjectiveUpdate", 				"OnEventUpdate", self)
	Apollo.RegisterEventHandler("PublicEventObjectiveLocationRemoved", 		"OnEventUpdate", self)
	Apollo.RegisterEventHandler("PublicEventStart", 						"OnEventUpdate", self)
	Apollo.RegisterEventHandler("PublicEventUpdate", 						"OnEventUpdate", self)
	
	--path events
	Apollo.RegisterEventHandler("PathLevelUp", 							"OnPathUpdate", self)
	Apollo.RegisterEventHandler("PlayerPathMissionAdvanced", 			"OnPathUpdate", self)
	Apollo.RegisterEventHandler("PlayerPathMissionComplete", 			"OnPathUpdate", self)
	Apollo.RegisterEventHandler("PlayerPathMissionUnlocked", 			"OnPathUpdate", self)
			
	--slash commands
	Apollo.RegisterSlashCommand("es", "OnEntSpyOpt", self)
	Apollo.RegisterSlashCommand("estoggle", "OnEntSpyEnable", self)
	Apollo.RegisterSlashCommand("esdev", "TestFunc", self)
	Apollo.RegisterSlashCommand("esdev2", "TestFunc2", self)
	
	--interface events
	Apollo.RegisterEventHandler("InterfaceMenuListHasLoaded", "OnInterfaceMenuListHasLoaded", self)
	Apollo.RegisterEventHandler("ToggleEntSpy", "OnEntSpyOpt", self)
	Apollo.RegisterEventHandler("ToggleEntSpyEnable", "OnEntSpyEnable", self)
	
	self.markertimer = ApolloTimer.Create(1, true, "OnMarkerTimer", self)
	self.parsetimer = ApolloTimer.Create(1, true, "OnParseTimer", self)
	self.chaldelay = nil
	
	self.drawtimer = nil
	self.linetimer = nil
	
	self.xmlDoc = XmlDoc.CreateFromFile("EntSpy.xml")
	
	self.EntSpyForm = Apollo.LoadForm(self.xmlDoc, "EntSpyForm", nil, self)
	self.EntSpyFrame = Apollo.LoadForm(self.xmlDoc, "EntSpyFrame", nil, self)
	
	self.gui = {}
	self.gui.radio = {}
	self.gui.txt = {}
	self.gui.lbl = {}
	
	self.tUserSettings = {}
	self.tUserSettings.l = {}
	self.tUserSettings.Cat = {}
	self.tUserSettings.Line = {}
	
	self:RegisterGUIElements()
	--self:LocalizeGUIElements()
	
	if self.nLoadedSave == 0 then
		self:RestoreDefaultSettings()
	end

	self:TabScopePressed()
	
	self.uPlayerUnit = GameLib.GetPlayerUnit()
	self.uPlayerPath = self:GetPlayerPath()
	self.uPlayerChallenge = nil
	
end

-----------------------------------------------------------------------------------------------
-- EntSpy OnDocLoaded
-----------------------------------------------------------------------------------------------

function EntSpy:OnSave(eLevel)
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character) then
		return
	end

	local tSave = self.tUserSettings
	
	return tSave
end

function EntSpy:OnRestore(eLevel,tSavedData)

	if tSavedData and tSavedData.Cat and tSavedData.Line then
			
			--categories
			self.gui.radio.CatMining:SetCheck(tSavedData.Cat["Mining"])
			self.gui.radio.CatRelicHunting:SetCheck(tSavedData.Cat["RelicHunting"])
			self.gui.radio.CatFarming:SetCheck(tSavedData.Cat["Farming"])
			self.gui.radio.CatSurvivalist:SetCheck(tSavedData.Cat["Survivalist"])
			self.gui.radio.CatQuest:SetCheck(tSavedData.Cat["QuestNPC"])
			self.gui.radio.CatQuestUnits:SetCheck(tSavedData.Cat["QuestUnit"])
			self.gui.radio.CatChallenge:SetCheck(tSavedData.Cat["Challenge"])
			self.gui.radio.CatPrimes:SetCheck(tSavedData.Cat["Prime"])
			self.gui.radio.CatPath:SetCheck(tSavedData.Cat["Path"])
			self.gui.radio.CatPVP:SetCheck(tSavedData.Cat["PVP"])
			self.gui.radio.CatGroup:SetCheck(tSavedData.Cat["Group"])
			self.gui.radio.CatSubdue:SetCheck(tSavedData.Cat["Subdue"])
			self.gui.radio.CatEvent:SetCheck(tSavedData.Cat["Event"])
			self.gui.radio.CatGuild:SetCheck(tSavedData.Cat["Guild"])
			self.gui.radio.CatModPVE:SetCheck(tSavedData.Cat["MODA"])
			self.gui.radio.CatModPVP:SetCheck(tSavedData.Cat["MODP"])
			self.gui.radio.CatTrail:SetCheck(tSavedData.Cat["Trail"])
			self.gui.radio.CatLore:SetCheck(tSavedData.Cat["Lore"])
			
			--line categories
			self.gui.radio.LineMining:SetCheck(tSavedData.Line["Mining"])
			self.gui.radio.LineRelicHunting:SetCheck(tSavedData.Line["RelicHunting"])
			self.gui.radio.LineFarming:SetCheck(tSavedData.Line["Farming"])
			self.gui.radio.LineSurvivalist:SetCheck(tSavedData.Line["Survivalist"])
			self.gui.radio.LineQuest:SetCheck(tSavedData.Line["QuestNPC"])
			self.gui.radio.LineQuestUnits:SetCheck(tSavedData.Line["QuestUnit"])
			self.gui.radio.LineChallenge:SetCheck(tSavedData.Line["Challenge"])
			self.gui.radio.LinePrimes:SetCheck(tSavedData.Line["Prime"])
			self.gui.radio.LinePath:SetCheck(tSavedData.Line["Path"])
			self.gui.radio.LinePVP:SetCheck(tSavedData.Line["PVP"])
			self.gui.radio.LineGroup:SetCheck(tSavedData.Line["Group"])
			self.gui.radio.LineSubdue:SetCheck(tSavedData.Line["Subdue"])
			self.gui.radio.LineEvent:SetCheck(tSavedData.Line["Event"])
			self.gui.radio.LineGuild:SetCheck(tSavedData.Line["Guild"])
			self.gui.radio.LineModPVE:SetCheck(tSavedData.Line["MODA"])
			self.gui.radio.LineModPVP:SetCheck(tSavedData.Line["MODP"])
			self.gui.radio.LineTrail:SetCheck(tSavedData.Line["Trail"])
			self.gui.radio.LineLore:SetCheck(tSavedData.Line["Lore"])
			
			--line opts
			self.gui.radio.OptEnableLines:SetCheck(tSavedData.OptEnableLines)
				
			--general
			self.gui.radio.OptEnabled:SetCheck(tSavedData.OptEnabled)
			self.gui.radio.OptEnableBG:SetCheck(tSavedData.OptEnableBG)
			self.gui.radio.OptEnableInst:SetCheck(tSavedData.OptEnableInst)
			self.gui.radio.OptEnableInstCombat:SetCheck(tSavedData.OptEnableInstCombat)	
									
			--unit options
			self.gui.radio.OptEnableUnitName:SetCheck(tSavedData.OptEnableUnitName)
			self.gui.radio.OptEnableUnitIcons:SetCheck(tSavedData.OptEnableUnitIcons)
			self.gui.radio.OptEnableUnitDist:SetCheck(tSavedData.OptEnableUnitDist)
			self.gui.radio.OptEnableUnitName:SetCheck(tSavedData.OptEnableUnitName)
			self.gui.radio.OptEnableUnitPVPColors:SetCheck(tSavedData.OptEnableUnitPVPColors)
			self.gui.radio.OptEnableUnitHideTarget:SetCheck(tSavedData.OptEnableUnitHideTarget)
			
			--marker options
			self.gui.radio.OptEnableMarkers:SetCheck(tSavedData.OptEnableMarkers)
			self.gui.radio.OptEnableMarkerAutoChallenge:SetCheck(tSavedData.OptEnableMarkerAutoChallenge)
			self.gui.radio.OptEnableMarkerName:SetCheck(tSavedData.OptEnableMarkerName)
			self.gui.radio.OptEnableMarkerDist:SetCheck(tSavedData.OptEnableMarkerDist)
			self.gui.radio.OptEnableMarkerPath:SetCheck(tSavedData.OptEnableMarkerPath)
			self.gui.radio.OptEnableMarkerEvent:SetCheck(tSavedData.OptEnableMarkerEvent)
			self.gui.radio.OptEnableMarkerQuest:SetCheck(tSavedData.OptEnableMarkerQuest)
			self.gui.radio.OptEnableMarkerChallenge:SetCheck(tSavedData.OptEnableMarkerChallenge)
			
			--unit settings
			self.gui.txt.OptUnitMaxCat:SetText(tSavedData.OptUnitMaxCat)
			self.gui.txt.OptUnitMaxTotal:SetText(tSavedData.OptUnitMaxTotal)
			self.gui.txt.OptUnitMergeDist:SetText(tSavedData.OptUnitMergeDist)			
			self.gui.txt.OptUnitIconScale:SetText(tSavedData.OptUnitIconScale)
			self.gui.txt.OptUnitDistText:SetText(tSavedData.OptUnitDistText)
			
			--marker settings
			self.gui.txt.OptMarkerMinDist:SetText(tSavedData.OptMarkerMinDist)
			self.gui.txt.OptMarkerMaxDist:SetText(tSavedData.OptMarkerMaxDist)
			self.gui.txt.OptMarkerScale:SetText(tSavedData.OptMarkerScale)
			
			--line settings
			self.gui.txt.OptLineMaximum:SetText(tSavedData.OptLineMaximum)
			self.gui.txt.OptLineScale:SetText(tSavedData.OptLineScale)
			self.gui.txt.OptLineDots:SetText(tSavedData.OptLineDots)

		 			
			self:CheckBoxRefresh()
			self.nLoadedSave = 1
	end
	
end  

function EntSpy:OnInterfaceMenuListHasLoaded()

	self.uPlayerUnit = GameLib.GetPlayerUnit()
	Event_FireGenericEvent("InterfaceMenuList_NewAddOn", "EntSpy", {"ToggleEntSpy", "", "CRB_HousingSprites:btnLaunchEyeNormal"})
	self:CheckBoxRefresh()
	self:OnZoneChanged()
	ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_Realm, "Thank you for using EntSpy. Enjoy your lines with a side of bugs! Report any new issues in the comments. Type /es (or use the menu) to open the settings. Developed by Gnb-Myrcalus")
	self:TabScopePressed()

	
end


function EntSpy:TestFunc()
	Print(GameLib.GetWorldDifficulty())
	local setunit
	if not setunit then
		setunit = GameLib.GetPlayerUnit():GetTarget()
	end
	Print(table.tostring(setunit:GetActivationState()))
	Print(setunit:GetType())
end


function EntSpy:OnDocLoaded()

    self.EntSpyForm:Show(false, true)
	self.EntSpyFrame:Show(true, true)
		
end

-----------------------------------------------------------------------------------------------
-- Marker functions
-----------------------------------------------------------------------------------------------
function EntSpy:CreateMarker(pos, id, name, color, type, taskid)
	if self.tUserSettings.OptEnableBG == false and self.tBattleground[tostring(GameLib.GetCurrentWorldId())] == 1 then
		return
	elseif self.tUserSettings.OptEnableInst == false and GameLib.GetWorldDifficulty() > 0 then
		return
	elseif self.tUserSettings.OptEnabled == false or self.tUserSettings.OptEnableMarkers == false then
		return
	elseif self.tQuestList[taskid] or self.tEventList[taskid] then
		return
	elseif self.uPlayerUnit and not (self.uPlayerChallenge and self.tUserSettings.Cat["Challenge"] == true) and not self.tMarkers[type][id] then
		self.tMarkers[type][id] = {marker = Apollo.LoadForm("EntSpy.xml", "Marker", "InWorldHudStratum", self), worldloc = pos, cid = taskid}
		self.tMarkers[type][id].marker:Show(false)
		local dist = self:DistToLoc(self.uPlayerUnit:GetPosition(), pos)
		local scale = 0.6 * self.tUserSettings.OptMarkerScale
		self.tMarkers[type][id].marker:SetWorldLocation(pos)
		
		if self.tUserSettings.OptEnableMarkerName == true then
			self.tMarkers[type][id].marker:FindChild("Name"):SetText(self:StringHandle(name))
		end
		
		self.tMarkers[type][id].marker:SetScale(scale)
		self.tMarkers[type][id].marker:SetBGColor(color)
	end
end

function EntSpy:DrawPixie(tbl, x, y)

	if self.tUserSettings.OptEnableUnitIcons == true then
	local nBackground = self.EntSpyFrame:AddPixie({
		  strText = nil,
		  strFont = nil,
		  bLine = false,
		  strSprite = self.Category[tbl.cat].sprite,
		  cr = self.Category[tbl.cat].color,
		  loc = {
		    fPoints = {0,0,0,0},
		    nOffsets = {x-tbl.size, y-25-tbl.size, x+tbl.size, y-25+tbl.size}
			},
		})
	end
	local strDynName = nil
	if tbl.multiple == 0 or self.Category[tbl.cat].groupable == 0 then
		strDynName = self:StringHandle(tbl.unit:GetName())
	else
		strDynName = self:StringHandle(tbl.unit:GetName()) .. " (" .. tbl.multiple + 1 .. ")"
	end
	if self.tUserSettings.OptEnableUnitName == true then
		local nText = self.EntSpyFrame:AddPixie({
			  strText = strDynName,
			  strFont = "CRB_Header9",
			  bLine = false,
			  strSprite = nil,
			  cr = {a=0,r=0.0,g=0.00,b=0},
			  loc = {
			    fPoints = {0,0,0,0},
			    nOffsets = {x-100, y-25, x+100, y+25}
				},
			 flagsText = {
			    DT_CENTER = true,
			    DT_VCENTER = true
			  }
			})
	end
	if (self:DistToLoc(self.uPlayerUnit:GetPosition(), tbl.unit)) > self.tUserSettings.OptUnitDistText and self.tUserSettings.OptEnableUnitDist == true then
	local nDistance = self.EntSpyFrame:AddPixie({
		  strText = self:StringHandle(math.floor(self:DistToLoc(self.uPlayerUnit:GetPosition(), tbl.unit)) .. "m"),
		  strFont = "CRB_Pixel",
		  bLine = false,
		  strSprite = nil,
		  cr = {a=0,r=0.0,g=0.00,b=0},
		  loc = {
		    fPoints = {0,0,0,0},
		    nOffsets = {x-100, y-12, x+100, y+38}
			},
		 flagsText = {
		    DT_CENTER = true,
		    DT_VCENTER = true
		  }
		})
	end


end

function EntSpy:ParseUnit(unit)

	self.uPlayerUnit = GameLib.GetPlayerUnit()
	
	if not self.uPlayerUnit then return end
	
	local sEntType = nil

	local ugt = unit:GetType()
	local ugn = unit:GetName()
	local uid = unit:GetId()
	local uact = unit:GetActivationState()
	
	--REMOVE UNITS THAT ARE HIDDEN BY GENERAL USER SELECTION AND CHECK FOR OBVIOUS UNIT RELEVANCE
	
	--user choices start here
	if self.tUserSettings.OptEnableBG == false and self.tBattleground[tostring(GameLib.GetCurrentWorldId())] == 1 then
		return
	elseif self.tUserSettings.OptEnableInst == false and GameLib.GetWorldDifficulty() > 0 then
		return
	elseif self.tUserSettings.OptEnableUnitHideTarget == true and self.uPlayerUnit:GetTarget() == unit then
		return 
	-- general hiding starts here
	elseif uact.Busy ~= nil and uact.Busy.bIsActive == true and unit:GetDispositionTo(self.uPlayerUnit) > 1 then
		return
	elseif unit:IsDead() then
		return
	elseif self.tUserSettings.OptEnableInstCombat and self.uPlayerUnit:IsInCombat() == true and GameLib.GetWorldDifficulty() > 0 and self.tAdventure[tostring(GameLib.GetCurrentWorldId())] == nil and self.tBattleground[tostring(GameLib.GetCurrentWorldId())] == nil and ugt ~= "Pickup" then
		return
	elseif self.tUserSettings.OptEnabled == false then
		return
	--obvious unit relevance here
	elseif L["LocalizationStash"] == ugn then 
		sEntType = self:SetEntType(sEntType, self.cat.Stash)
	elseif self:StringFind(ugn, L["LocalizationTrail"]) and self.uPlayerPath == "Explorer" then
		sEntType = self:SetEntType(sEntType, self.cat.Trail)
	end
		
	---HANDLE MODULES
	sEntType = self:SetEntType(sEntType, self:HandleModuleMT(unit))
	sEntType = self:SetEntType(sEntType, self:HandleModuleWOTW(unit))
	sEntType = self:SetEntType(sEntType, self:HandleModuleWT(unit))
	
	--SOME PATH UNITS WON'T MAKE IT PAST NEXT CHECK - THEY SKIP THE DULL CHECK
	sEntType = self:SetEntType(sEntType, self:GenPathData(unit))
	sEntType = self:SetEntType(sEntType, self:GenLoreData(unit))
	sEntType = self:SetEntType(sEntType, self:GenQuestData(unit))
	
	--IF UNIT IS A USELESS SIMPLE/COLLIDABLE WE CAN'T CLICK (i.e. ALREADY USED) REMOVE
	--THIS CURRENTLY HIDES SOME QUEST-GIVER SIMPLES (THOUGH THESE HAVE THEIR OWN OUT OF ADDON ICONS)
	--WE CAN SEPERATE QUEST DATA AND REWARD DATA?
	if not sEntType and self:GenUsefulness(unit) == 1 then
			return
	end

	--CHECK SEARCH/REWARD DATA/QUEST DATA
	
	if not sEntType then
		sEntType = self:SetEntType(sEntType, self:GenRewardData(unit))
		sEntType = self:SetEntType(sEntType, self:GenEventData(unit))
		sEntType = self:SetEntType(sEntType, self:IsSearch(ugn))
	end

	--HANDLE UNIT TYPE SPECIFICS
	if ugt == "Player" then
		sEntType = self:SetEntType(sEntType, self:HandlePlayer(unit))
	elseif ugt == "Collectible" then
		sEntType = self:SetEntType(sEntType, self:HandleCollectible(unit))
	elseif ugt == "Harvest" then
		sEntType = self:SetEntType(sEntType, self:HandleHarvest(unit))
	elseif ugt == "NonPlayer" or ugt == "Turret" then
		sEntType = self:SetEntType(sEntType, self:HandleNonPlayer(unit))
	elseif ugt == "Simple" or ugt == "SimpleCollidable" or ugt == "Taxi" then
		sEntType = self:SetEntType(sEntType, self:HandleSimple(unit))
	elseif ugt == "PinataLoot" then
		sEntType = self:SetEntType(sEntType, self:HandleLoot(unit))
	elseif ugt == "Pickup" then
		sEntType = self:SetEntType(sEntType, self:HandlePickup(unit))
	end

	--NO CATEGORY - BAIL OUT
	if not sEntType then return	end

	--get position data
	local pos = unit:GetPosition()
	local playerPos = self.uPlayerUnit:GetPosition()
	local dist = self:DistToLoc(self.uPlayerUnit:GetPosition(), pos)
	
	--if challenge active and mobtype isnt a challenge escape
	if (self.uPlayerChallenge and sEntType ~= self.cat.Challenge and sEntType ~= self.cat.Search and self.tUserSettings.Cat["Challenge"]) then
		return
	elseif not dist then 
		return 
	else 
		if dist < self.Category[sEntType].mindist then
			return
		elseif dist > self.nDistLimit and self.Category[sEntType].cullable == 1 then
			--add unit as pending since it's being hidden - it should still count towards the next count
			self.tUnitListRel[unit:GetId()] = {unit = unit, cat = self.cat.Pending, size = 0, multiple = 0}
			return
		end
	end

	--scale icon - REWRITE?
	local vardists = (math.min((((1/(dist/2)) / 0.67)) * 400, 20)) * self.tUserSettings.OptUnitIconScale
	
	--maybe we can group this unit with another unit first
	if self.Category[sEntType].groupable == 1 then
		for _, tbl in pairs(self.tUnitListRel) do
			local posu = GameLib.GetUnitScreenPosition(tbl.unit)
			local post = GameLib.GetUnitScreenPosition(unit)
			if posu.bOnScreen and post.bOnScreen and tbl.cat == sEntType then
				local distsp = self:CalculateDistance(Vector3.New(posu.nX - post.nX, posu.nY - post.nY, 0 - 0))
				if distsp < self.tUserSettings.OptUnitMergeDist then
					tbl.multiple = tbl.multiple + 1
					if self:DistToLoc(self.uPlayerUnit:GetPosition(), tbl.unit) > self:DistToLoc(self.uPlayerUnit:GetPosition(), unit) then
						self.tUnitListRel[unit:GetId()] = {unit = unit, cat = sEntType, size = vardists, multiple = tbl.multiple}
						self.tUnitListRel[tbl.unit:GetId()] = nil
					end
					return
				end
			end
		end
	end

	--maybe we are drawing too many of this type of unit
	if self.Category[sEntType].cullable == 1 then
		local nEntCount = 0
		local nFurthestUnitDist = self:DistToLoc(self.uPlayerUnit:GetPosition(), unit)
		local nFurthestUnitID = uid
		for _, tbl in pairs(self.tUnitListRel) do
			local posu = GameLib.GetUnitScreenPosition(tbl.unit)
			local post = GameLib.GetUnitScreenPosition(unit)
			if tbl.cat == sEntType and posu.bOnScreen and post.bOnScreen then
				nEntCount = nEntCount + 1
				if self:DistToLoc(self.uPlayerUnit:GetPosition(), tbl.unit) > nFurthestUnitDist then
					nFurthestUnitDist = self:DistToLoc(self.uPlayerUnit:GetPosition(), tbl.unit)
					nFurthestUnitID = tbl.unit:GetId()
				end
			end
		end
		
		if nEntCount >= self.tUserSettings.OptUnitMaxCat  then
			if nFurthestUnitID == uid then
				return
			else
				self.tUnitListRel[nFurthestUnitID] = nil	
			end
		end
	end
	
	--IT PASSED ALL THE CHECKS, ADD IT TO THE TABLE

	self.tUnitListRel[unit:GetId()] = {unit = unit, cat = sEntType, size = vardists, multiple = 0}
	
end

function EntSpy:OnMarkerTimer()

		self.uPlayerUnit = GameLib.GetPlayerUnit()
		if self.uPlayerUnit then
			for catkey, cat in pairs(self.tMarkers) do
				for _, markerdata in pairs(cat) do
					local dist = self:DistToLoc(markerdata.worldloc, self.uPlayerUnit)
					if markerdata.marker:IsOnScreen() and dist < self.tUserSettings.OptMarkerMaxDist and dist > self.tUserSettings.OptMarkerMinDist and not self.tEventList[markerdata.cid] and not self.tQuestList[markerdata.cid] then
						markerdata.marker:Show(true)
						if self.tUserSettings.OptEnableMarkerDist == true then
							markerdata.marker:FindChild("Dist"):SetText(math.floor(dist) .. "m")
						end
					else
						if catkey == "Challenge" and self.bChalActivate == false and self.tUserSettings.OptEnableMarkerAutoChallenge == true and self.tUserSettings.OptMarkerMinDist > dist and markerdata.cid and not self.uPlayerChallenge then
							ChallengesLib.ActivateChallenge(markerdata.cid)
							self.bChalActivate = true
							self.chaldelay = ApolloTimer.Create(1, true, "OnActivateChallenge", self)
						end
						markerdata.marker:Show(false)
					end
				end
			end
				
	end
			
end

function EntSpy:OnActivateChallenge()
	self.bChalActivate = false
end

function EntSpy:OnParseTimer()

	self.uPlayerUnit = GameLib.GetPlayerUnit()
	self.uPlayerPath = self:GetPlayerPath()

	if self.uPlayerUnit then
		
		if self.uPlayerUnit:IsInCCState(Unit.CodeEnumCCState.Blind) == true then return end
		
			--build distance table and max unit culling
			--important that this is designed as an 'array'
			--for numeric sorting purposes (so we can grab #x later on)
			
			
			--default
			self.nDistLimit = 600
			if self.aSortedUnitRef and self.aSortedUnitRef[self.tUserSettings.OptUnitMaxTotal] then
				self.nDistLimit = self.aSortedUnitRef[self.tUserSettings.OptUnitMaxTotal].dist
			end
		
			--reset lists
			self.tUnitListRel = {}
			self.tUnitListLine = {}
			self.tPrefixList = {}
			self.tQuestList = {}
			self.tEventList = {}
			self.tPosList = {}	

				
			--save mob prefixes for prime feature
			for _, unit in pairs (self.tUnitList) do
				local sPrefix = split(unit:GetName(), " ")[1]
				if sPrefix ~= nil then
					if self.tPrefixList[sPrefix] ~= nil then
						self.tPrefixList[sPrefix] = self.tPrefixList[sPrefix] + 1
					else
						self.tPrefixList[sPrefix] = 0
					end
				end
			end
			
			--if unit is on screen, parse away
			for _, unit in pairs(self.tUnitList) do
				local tScreenPos = GameLib.GetUnitScreenPosition(unit)
				self:ParseUnit(unit)
			end
			
			--build a dist table after unit rel
			self.aSortedUnitRef = {}
			self.tUnitListLine = {}
			local i = 1
			for _, tunit in pairs (self.tUnitListRel) do
				self.aSortedUnitRef[i] = {dist = self:DistToLoc(self.uPlayerUnit:GetPosition(), tunit.unit), unit = tunit.unit}
				i = i + 1
			end
			
			table.sort(self.aSortedUnitRef, compare)
			
			for _, tbl in pairs(self.tLines) do
					self:ClearMarker(tbl)
			end			
			
			if self.tUserSettings.OptEnableLines == true and #self.aSortedUnitRef > 0 then
				for i=1, #self.aSortedUnitRef do 
					if not self.tUnitListLine[self.tUserSettings.OptLineMaximum] then
						if (self.tUserSettings.Line[self.Category[self.tUnitListRel[self.aSortedUnitRef[i].unit:GetId()].cat].parentopt] == nil or self.tUserSettings.Line[self.Category[self.tUnitListRel[self.aSortedUnitRef[i].unit:GetId()].cat].parentopt] == true) then
							if self.tUnitListRel[self.aSortedUnitRef[i].unit:GetId()].cat ~= "Pending" then
								self.tUnitListLine[i] = {unit = self.aSortedUnitRef[i].unit, cat = self.tUnitListRel[self.aSortedUnitRef[i].unit:GetId()].cat}
							end
						end
					else
						break
					end
				end
				
				self.tLines = {}
				
				for key, linetarget in pairs(self.tUnitListLine) do
					self.tLines[key] = {}
					for i = 1, math.min(self.tUserSettings.OptLineDots) do
						self.tLines[key][i] = Apollo.LoadForm("EntSpy.xml", "LineMarker", "InWorldHudStratum", self)
						self.tLines[key][i]:SetBGColor(self.Category[linetarget.cat].linecolor)
						self.tLines[key][i]:SetScale(self.tUserSettings.OptLineScale)
					end
				end
				
				self:OnLineTimer()
			end

			if self.drawtimer then
				self.drawtimer:Stop()
			end
			
			self.drawtimer = ApolloTimer.Create(0.01, true, "OnDrawTimer", self)
			
			if self.linetimer then
				self.linetimer:Stop()
			end
			
			self.linetimer = ApolloTimer.Create(0.01, true, "OnLineTimer", self)

			
		end

end

function EntSpy:OnDrawTimer()
	if self.uPlayerUnit then
		self.EntSpyFrame:DestroyAllPixies()
		if self.uPlayerUnit:IsInCCState(Unit.CodeEnumCCState.Blind) == true then return end
		for _, tbl in pairs(self.tUnitListRel) do
			local tScreenPos = GameLib.GetUnitScreenPosition(tbl.unit)
			if tScreenPos and tScreenPos.bOnScreen and tbl.cat ~= self.cat.Pending and tbl.unit:IsValid() then
				self:DrawPixie(tbl, tostring(tScreenPos.nX), tostring(tScreenPos.nY))
			end
		end

	end
end

function EntSpy:OnLineTimer()

	if not self.uPlayerUnit then return end
	
	local tPlayerPos = self.uPlayerUnit:GetPosition()
	local tPlayerVector = Vector3.New(tPlayerPos.x, tPlayerPos.y, tPlayerPos.z)
	local tTargetPos = nil
	local tTargetVector = nil

	for key, linetarget in pairs(self.tUnitListLine) do
		tTargetPos = linetarget.unit:GetPosition()
		if tTargetPos then
			tTargetVector = Vector3.New(tTargetPos.x, tTargetPos.y, tTargetPos.z)
			for i = 1, self.tUserSettings.OptLineDots do
				local fraction = i/(self.tUserSettings.OptLineDots * 1.5)
				self.tLines[key][i]:SetWorldLocation(Vector3.InterpolateLinear(tPlayerVector, tTargetVector, fraction))
				if self.tLines[key][i]:IsOnScreen() then
					self.tLines[key][i]:Show(true, true)
				else
					self.tLines[key][i]:Show(false, true)
				end
			end
		end
	end

end

function EntSpy:CalculateDistance(vector)
	return math.sqrt(math.pow(vector.x, 2) + math.pow(vector.y, 2) + math.pow(vector.z, 2))
end

function EntSpy:DistToLoc(loc, unit)
			local unitPos
			if type(unit) == "table" then
				unitPos = unit
			else
				unitPos = unit:GetPosition()
			end
			local distance = self:CalculateDistance(Vector3.New(loc.x - unitPos.x, loc.y - unitPos.y, loc.z - unitPos.z))
			if distance then 
				return distance
			else
				return nil
			end
end

function EntSpy:StringHandle(s)
	if (string.len(s) > 14) then
		s = string.sub(s, 0, 12)
		s = s .. ".."
	end
	return s
end

----------------------------------------------------------------------------------
-- UnitType Handlers - Using general 'Gen*Data' functions and some specific code
-----------------------------------------------------------------------------------------------

function EntSpy:IsSearch(uname)
	if uname ~= nil and self.sPlayerSearch ~= nil then
		local tSplit = split(self.sPlayerSearch, ";")
		for _, searchSplit in pairs(tSplit) do
			if self:StringFind(uname, searchSplit) then
				return self.cat.Search
			end
		end
	end
end

function EntSpy:HandlePlayer(unit)
	
	if not self.uPlayerUnit:IsInCombat() then
		if unit:IsInYourGroup() then 	
			return self.cat.Group
		end
		
		if self.uPlayerUnit:GetGuildName() and unit:GetGuildName() == self.uPlayerUnit:GetGuildName() then 
			return self.cat.Guild
		end
	end

	if unit:IsPvpFlagged() then 
	
		local sEntType

		if unit:GetFaction() ~= self.uPlayerUnit:GetFaction() then
			if not sEntType then
				if unit:GetClassId() == GameLib.CodeEnumClass.Stalker then
					sEntType = self.cat.PVPStalker
				elseif unit:GetClassId() == GameLib.CodeEnumClass.Medic then
					sEntType = self.cat.PVPMedic
				elseif unit:GetClassId() == GameLib.CodeEnumClass.Engineer then
					sEntType = self.cat.PVPEngineer
				elseif unit:GetClassId() == GameLib.CodeEnumClass.Esper then
					sEntType = self.cat.PVPEsper
				elseif unit:GetClassId() == GameLib.CodeEnumClass.Spellslinger then
					sEntType = self.cat.PVPSpellslinger
				elseif unit:GetClassId() == GameLib.CodeEnumClass.Warrior then
					sEntType = self.cat.PVPWarrior
				else
					sEntType = self.cat.PVPMount
				end
			end
		
			if self.tUserSettings.OptEnableUnitPVPColors == true then
				local colr = unit:GetHealth() / unit:GetMaxHealth()
				local colg = 1 - colr
				local colb = 0
				local color = {a=1,r=colr,g=colg,b=colb}
				self.Category[sEntType].color = color
			end
		end
		
		return sEntType
	end
end

function EntSpy:HandleHarvest(unit)
	if unit:CanBeHarvestedBy(self.uPlayerUnit) and sEntType == nil and self:StringFind(unit:GetName(), L["TextActive"]) == nil and unit:GetMouseOverType() == "Simple" then -- 
		local sHarvestSkill = unit:GetHarvestRequiredTradeskillName()
		if sHarvestSkill == L["TradeskillMining"] then
			return self.cat.Mining
		elseif sHarvestSkill == L["TradeskillFarming"] then
			return self.cat.Farming
		elseif sHarvestSkill == L["TradeskillSurvivalist"] then
			return self.cat.Survivalist
		elseif sHarvestSkill == L["TradeskillRelicHunter"] then
			return self.cat.RelicHunting
		else
			return nil
		end
	end			
end

function EntSpy:HandleCollectible(unit)		
	return sEntType
end

function EntSpy:HandleSimple(unit)		
	return sEntType
end


function EntSpy:HandleNonPlayer(unit)

	local sEntType = nil
	if unit:GetRank() == 5 and 2 > unit:GetDispositionTo(self.uPlayerUnit) then
		if self.tPrefixList[split(unit:GetName(), " ")[1]] ~= nil and 1 > self.tPrefixList[split(unit:GetName(), " ")[1]]  then
			sEntType = self.cat.Primes
		end
	end
	
	return sEntType
end

function EntSpy:HandleLoot(unit)

	local tLootInfo = unit:GetLoot()
	if tLootInfo ~= nil and tLootInfo.eLootItemType and tLootInfo.eLootItemType == 6 then
		return self.cat.Questloot
	end
	
end

function EntSpy:HandlePickup(unit)

	if unit:GetType() == "Pickup" then
		local playerName = self.uPlayerUnit:GetName()
		if string.sub(unit:GetName(), 1, string.len(playerName)) == playerName then
			return self.cat.Subdue
		end
	end
	
end

function EntSpy:HandleModuleWOTW(unit)

	local worldid = GameLib.GetCurrentWorldId()
	if worldid == 1393 then
		if (unit:GetDifficulty() == 2 and 2 > unit:GetDispositionTo(self.uPlayerUnit)) and unit:GetHealth() < 150000 then
			return self.cat.WOTWChampion
		end
		local uname = unit:GetName()
		if self:StringFind(uname, L["ModuleWOTWEnergyNode"]) or self:StringFind(uname, L["ModuleWTMoodie"]) then
			return self.cat.WOTWEnergyNode
		end
	end
	
end

function EntSpy:HandleModuleWT(unit)
	
	local worldid = GameLib.GetCurrentWorldId()
	
	if worldid == 797 then
		local uname = unit:GetName()
		local ugt = unit:GetType()
		if self:StringFind(uname, L["ModuleWTMoodie"]) then
			return self.cat.WTWalatiki
		elseif ugt == "Player" then
			for _, buff in pairs(unit:GetBuffs().arHarmful) do
				if self:StringFind(buff.splEffect:GetName(), L["ModuleWTMoodie"]) then
					return self.cat.WTWalatiki
				end
			end
		end
	end
	
end

function EntSpy:HandleModuleMT(unit)
	
	local worldid = GameLib.GetCurrentWorldId()
	
	if worldid == 1181 then
		local uname = unit:GetName()
		if self:StringFind(L["ModuleMTCaravan"], uname) then
			return self.cat.MTCaravan
		elseif self:StringFind(L["ModuleMTChompacabras"], uname) then
			return self.cat.MTChompa
		elseif self:StringFind(L["ModuleMTWater"], uname) then
			return self.cat.MTWater
		elseif self:StringFind(L["ModuleMTFood"], uname) then
			return self.cat.MTFood
		elseif self:StringFind(L["ModuleMTFeed"], uname) then
			return self.cat.MTFeed
		end
	end
	
end

function EntSpy:SetEntType(sEntType, var)

	if var ~= nil and sEntType ~= self.cat.Challenge and (not self.Category[var].parentopt or self.tUserSettings.Cat[self.Category[var].parentopt] == true) then
		return var
	else
		return sEntType
	end
end

----------------------------------------------------------------------------------
-- Category Generators
----------------------------------------------------------------------------------


function EntSpy:GenRewardData(unit)
	local tRewardInfo = unit:GetRewardInfo()
	local utype = unit:GetType()
	
	if tRewardInfo ~= nil and type(tRewardInfo) == "table" then
		local tempEntType = nil
		local nRewardCount = #tRewardInfo
		if nRewardCount > 0 then
			for idx = 1, nRewardCount do
				local strType = tRewardInfo[idx].strType
				if strType == self.cat.Quest then
					self.tQuestList[tRewardInfo[idx].idQuest] = 1
					if unit:GetDispositionTo(self.uPlayerUnit) > 0 then
						tempEntType = self:SetEntType(tempEntType, self.cat.QuestSimple)
					else
						tempEntType = self:SetEntType(tempEntType, self.cat.Quest)
					end
				elseif strType == self.cat.Challenge then 
					if tRewardInfo[idx].idChallenge == self.uPlayerChallenge and unit:IsElite() ~= true then
						tempEntType = self:SetEntType(tempEntType, self.cat.Challenge)
					end
				elseif strType == "PublicEvent" then
						if tRewardInfo[idx].peObjective then 
							self.tEventList[tRewardInfo[idx].peObjective:GetEvent():GetName()] = 1
							if tRewardInfo[idx].peObjective:GetEvent():GetMyStats() == nil and GameLib.GetWorldDifficulty == 0 then
								break
							end
						end
						if unit:GetDispositionTo(self.uPlayerUnit) > 0 then
							tempEntType = self:SetEntType(tempEntType, self.cat.EventSimple)
						else
							tempEntType = self:SetEntType(tempEntType, self.cat.Event)
						end
				elseif strType == self.uPlayerPath then
					if tRewardInfo[idx].pmMission then
							tempEntType = self:SetEntType(tempEntType, self.uPlayerPath)
					end
				end
			end
			return tempEntType
		end
	end
	
end

function EntSpy:GenPathData(unit)

	local tActivation = unit:GetActivationState()
	local pUnitPath = self.uPlayerUnit:GetPlayerPathType()
	if ((tActivation.ScientistScannable ~= nil or tActivation.Datacube ~= nil) and pUnitPath == PlayerPathLib.PlayerPathType_Scientist) then
		return self.cat.Scientist
	elseif ((tActivation.ExplorerInterest ~= nil or tActivation.ExplorerActivate ~= nil or tActivation.ExplorerDoor ~= nil) and pUnitPath == PlayerPathLib.PlayerPathType_Explorer) then
		return self.cat.explorer
	elseif (tActivation.SettlerActivate  ~= nil and pUnitPath == PlayerPathLib.PlayerPathType_Settler) then
		return self.cat.Settler
	elseif ((tActivation.SoldierActivate  ~= nil or tActivation.SoldierKill ~= nil) and pUnitPath == PlayerPathLib.PlayerPathType_Soldier) then
		return self.cat.Soldier
	elseif (tActivation.Collect ~= nil and tActivation.Collect.bUsePlayerPath and tActivation.Collect.bCanInteract and tActivation.Collect.bIsActive) then
		return self.uPlayerPath
	elseif (tActivation.Interact ~= nil and tActivation.Interact.bUsePlayerPath and tActivation.Interact.bCanInteract and tActivation.Interact.bIsActive) then
		return self.uPlayerPath
	end

end

function EntSpy:GenQuestData(unit)

	local tActivation = unit:GetActivationState()
	local worldDif = GameLib.GetWorldDifficulty()
	if tActivation.QuestReward ~= nil and tActivation.QuestReward.bIsActive then
		return self.cat.QuestReward
	elseif (tActivation.QuestNewMain ~= nil and tActivation.QuestNewMain.bIsActive) then
		return self.cat.QuestNewMain
	elseif (tActivation.QuestNew ~= nil and tActivation.QuestNew.bIsActive) then
		return self.cat.QuestNew
	elseif (tActivation.QuestNewRepeatable ~= nil and tActivation.QuestNewRepeatable.bIsActive) then
		return self.cat.QuestNew
	elseif (tActivation.QuestNewTradeskill ~= nil and tActivation.QuestNewTradeskill.bIsActive) then
		return self.cat.QuestNew
	elseif (tActivation.TalkTo ~= nil and tActivation.TalkTo.bIsActive) then
		return self.cat.QuestTalkTo
	end
		
end

function EntSpy:GenEventData(unit)
	--this distinction is only made so we can show quest boards and shit in the above function
	local tActivation = unit:GetActivationState()
	local worldDif = GameLib.GetWorldDifficulty()
	if worldDif > 0 then
		if (tActivation.PublicEventTarget and tActivation.PublicEventTarget.bIsActive) or
		   (tActivation.PublicEventKill and tActivation.PublicEventKill.bIsActive) or
		   (tActivation["Public Event"] and tActivation["Public Event"].bIsActive) then		
			if unit:GetDispositionTo(self.uPlayerUnit) > 0 then
				return self.cat.EventSimple
			else
				return self.cat.Event
			end
		end
	end
end

function EntSpy:GenLoreData(unit)
	local uact = unit:GetActivationState()
	if uact and uact.Datacube ~= nil and uact.Datacube.bCanInteract == true  then
		return self.cat.Lore
	end
end

function EntSpy:GenUsefulness(unit)
	--function name is pretty accurate
	--just tries to hide useless crap that the game still has tagged as relevant
	--like quest objectives you already clicked on
	local uact = unit:GetActivationState()
	local ugt = unit:GetType()
	if uact and unit:GetMouseOverType() ~= "Normal" then
		if uact.Interact ~= nil then
			if uact.Interact.bIsActive ~= true then
				return 1
			end
		elseif uact.Spell ~= nil then
			if uact.Spell.bIsActive ~= true then
				return 1
			end
		elseif ugt == "Simple" or ugt == "SimpleCollidable" then
			return 1
		end
	end
end

function EntSpy:GetPlayerPath()
	if self.uPlayerUnit then
		if (self.uPlayerUnit:GetPlayerPathType() == PlayerPathLib.PlayerPathType_Scientist) then
			return self.cat.Scientist
		elseif (self.uPlayerUnit:GetPlayerPathType() == PlayerPathLib.PlayerPathType_Explorer) then
			return self.cat.Explorer
		elseif (self.uPlayerUnit:GetPlayerPathType() == PlayerPathLib.PlayerPathType_Settler) then
			return self.cat.Settler
		elseif (self.uPlayerUnit:GetPlayerPathType() == PlayerPathLib.PlayerPathType_Soldier) then
			return self.cat.Soldier
		end
	end
end

function EntSpy:FindLocalUnits(loc, cat)
	local nIsClose = 0
	for _, tbl in pairs(self.tUnitListRel) do
		if self:StringFind(tbl.cat, cat) then
			nDTL = self:DistToLoc(loc, tbl.unit)
			if 100 > nDTL and nDTL ~= 0 then
				nIsClose = 1
			end
		end
	end
	if nIsClose == 0 then
		return false 
	end
	return true
end

function EntSpy:ClearMarker(table)
	if table then
		for _, formref in pairs(table) do
			if formref.marker then
				formref.marker:Destroy()
			else
				formref:Destroy()
			end
		end
	end
end

function EntSpy:StringFind(var1, var2)
	local rtnvar = string.find(string.lower(var1), string.lower(var2))
	return rtnvar
end

function EntSpy:CreatePathMarkers()
	if self.tUserSettings.OptEnableMarkerPath == true then
		local pepisode = PlayerPathLib.GetPathEpisodeForZone()
		if pepisode then 
			for key, mission in pairs(pepisode:GetMissions()) do
				if mission:GetMissionState() == 3 then
					if (mission:GetMapLocations() and mission:GetMapLocations()[1]) then
						for i=1,#mission:GetMapLocations() do 
							if not self:FindLocalUnits(mission:GetMapLocations()[i], self:GetPlayerPath()) then
								if not self.tPosList[tostring(mission:GetMapLocations()[i].x)] then
									self.tPosList[tostring(mission:GetMapLocations()[i].x)] = 0
								else
									self.tPosList[tostring(mission:GetMapLocations()[i].x)] = self.tPosList[tostring(mission:GetMapLocations()[i].x)] + 1
								end
								local modPos = mission:GetMapLocations()[i]
								modPos.y = modPos.y + (10 * self.tPosList[tostring(mission:GetMapLocations()[i].x)])
								self:CreateMarker(modPos, mission:GetId() .. "-" .. i, "[" .. i .. "] " .. self:StringHandle(mission:GetName()), self.colors.CatPath, "Path")
							end
						end
					end
				end
			end
		end
	end
end

function EntSpy:CreateEventMarkers()
	if self.tUserSettings.OptEnableMarkerEvent == true then
		for _, event in pairs(PublicEventsLib.GetActivePublicEventList()) do
			if event:GetMyStats() == nil and GameLib.GetWorldDifficulty == 0 then
				return 
			end
			for _, obj in pairs(event:GetObjectives()) do
				if not self.tEventList[event:GetName()] and obj:GetMapRegions()[1] and obj:GetMapRegions()[1].tIndicator then
					for i=1,#obj:GetMapRegions() do 
						if not self:FindLocalUnits(obj:GetMapRegions()[i].tIndicator, self.cat.Quest) then
							if not self.tPosList[tostring(obj:GetMapRegions()[i].tIndicator)] then
								self.tPosList[tostring(obj:GetMapRegions()[i].tIndicator.x)] = 0
							else
								self.tPosList[tostring(obj:GetMapRegions()[i].tIndicator.x)] = self.tPosList[tostring(obj:GetMapRegions()[i].tIndicator.x)] + 1
							end
							local modPos = obj:GetMapRegions()[i].tIndicator
							modPos.y = modPos.y + (10 * self.tPosList[tostring(obj:GetMapRegions()[i].tIndicator.x)])
							self:CreateMarker(modPos, event:GetName() .. "-" .. i, "[" .. i .. "] " .. self:StringHandle(event:GetName()), self.colors.CatEvent, "Event", obj:GetEvent():GetName())
						end
					end
				end
			end
		end
	end	
end

function EntSpy:CreateQuestMarkers()
	if self.tUserSettings.OptEnableMarkerQuest == true then
		for key, epiEpisode in pairs(QuestLib.GetTrackedEpisodes()) do
			for key, queQuest in pairs(epiEpisode:GetVisibleQuests()) do
				local eState = queQuest:GetState()	
				if eState ~= Quest.CatQuestState_Completed and eState ~= Quest.CatQuestState_Abandoned and eState ~= Quest.CatQuestState_Ignored and eState ~= Quest.CatQuestState_Botched and eState ~= 2 then
					if not self.tQuestList[queQuest:GetId()] and queQuest:GetMapRegions()[1] and queQuest:GetMapRegions()[1].tIndicator then
						for i=1,#queQuest:GetMapRegions() do 
							if not self.tPosList[tostring(queQuest:GetMapRegions()[i].tIndicator.x)] then
								self.tPosList[tostring(queQuest:GetMapRegions()[i].tIndicator.x)] = 0
							else
								self.tPosList[tostring(queQuest:GetMapRegions()[i].tIndicator.x)] = self.tPosList[tostring(queQuest:GetMapRegions()[i].tIndicator.x)] + 1
							end
							local modPos = queQuest:GetMapRegions()[i].tIndicator
							modPos.y = modPos.y + (10 * self.tPosList[tostring(queQuest:GetMapRegions()[i].tIndicator.x)])
							if #queQuest:GetMapRegions() == 1 then
								self:CreateMarker(modPos, queQuest:GetId() .. "-" .. i, self:StringHandle(queQuest:GetTitle()), self.colors.CatQuest, "Quest", queQuest:GetId())
							else
								self:CreateMarker(modPos, queQuest:GetId() .. "-" .. i, "[" .. i .. "] " ..self:StringHandle(queQuest:GetTitle()), self.colors.CatQuest, "Quest", queQuest:GetId())
							end
						end
					end
				end
			end
		end
	end
end

function EntSpy:CreateChallengeMarkers()
	if self.tUserSettings.OptEnableMarkerChallenge == true then
		for _, challenge in pairs(ChallengesLib.GetActiveChallengeList()) do
			if challenge:GetZoneInfo() and challenge:GetZoneInfo().idZone ~= GameLib.GetCurrentZoneId() then
				if challenge:GetMapLocation() and not challenge:IsInCooldown() and not challenge:IsActivated() then
					self:CreateMarker(challenge:GetMapLocation(), challenge:GetName(), challenge:GetName(), self.colors.CatChallenge, "Challenge", challenge:GetId())
				end
			end
		end
	end
end

function EntSpy:RebuildChallengeMarkers()
	self:ClearMarker(self.tMarkers["Challenge"])
	self.tMarkers["Challenge"] = {}
	self:CreateChallengeMarkers()
	self:OnMarkerTimer()
end

function EntSpy:RebuildPathMarkers()
	self:ClearMarker(self.tMarkers["Path"])
	self.tMarkers["Path"] = {}
	self:CreatePathMarkers()
	self:OnMarkerTimer()
end

function EntSpy:RebuildQuestMarkers()
	self:ClearMarker(self.tMarkers["Quest"])
	self.tMarkers["Quest"] = {}
	self:CreateQuestMarkers()
	self:OnMarkerTimer()
end

function EntSpy:RebuildEventMarkers()
	self:ClearMarker(self.tMarkers["Event"])
	self.tMarkers["Event"] = {}
	self:CreateEventMarkers()
	self:OnMarkerTimer()
end
----------------------------------------------------------------------------------
-- Event Handlers
----------------------------------------------------------------------

function EntSpy:OnZoneChanged()
	self:RebuildAllMarkers()
end

function EntSpy:RebuildAllMarkers()
	
	self:RebuildChallengeMarkers()
	self:RebuildPathMarkers()
	self:RebuildQuestMarkers()
	self:RebuildEventMarkers()
end

function EntSpy:OnPathUpdate()
	self:RebuildPathMarkers()
end

function EntSpy:OnQuestUpdate()
	self:RebuildQuestMarkers()
end

function EntSpy:OnEventUpdate()
	self:RebuildEventMarkers()
end

--unit created
function EntSpy:OnUnitCreated(unit)
	self.tUnitList[unit:GetId()] = unit	
	self:ParseUnit(unit)
end

function EntSpy:OnUnitChanged(unit)
	self.tUnitListRel[unit:GetId()] = nil
	self:ParseUnit(unit)
end

--unit destroyed
function EntSpy:OnUnitDestroyed(unit)
	self.tUnitList[unit:GetId()] = nil
	self.tUnitListRel[unit:GetId()] = nil
end

--challenge created
function EntSpy:OnChallengeCreate(challengeid)
	--set player as in a challenge
	self.uPlayerChallenge = challengeid
	--self:RebuildChallengeMarkers()
end

function EntSpy:OnChallengeUpdate(challengeid)
	--update can start up a challenge after it has ended
	--therefore only useful when challenge is currently nil
	if self.uPlayerChallenge ~= nil then
		self.uPlayerChallenge = challengeid
	end

	self:RebuildChallengeMarkers()
end

function EntSpy:OnChallengeRemoved(challengeid)
	--reliable method for challenge termination
	self.uPlayerChallenge = nil
	--self:RebuildChallengeMarkers()
end


----------------------------------------------------------------------------------
-- EntSpyForm Functions
-----------------------------------------------------------------------------------------------
--user has typed /es
function EntSpy:OnEntSpyOpt()
	self.EntSpyForm:Invoke() -- show the options window
end

function EntSpy:OnEntSpyEnable()
	if self.gui.radio.OptEnabled:IsChecked() == true then
		self.gui.radio.OptEnabled:SetCheck(false)
	else
		self.gui.radio.OptEnabled:SetCheck(true)
	end
	self:CheckBoxRefresh()
end


function EntSpy:HideForm()
	self.EntSpyForm:Show(false, true)
end

function EntSpy:HideItemForm()
	self.ItemSpyForm:Show(false, true)
end

function EntSpy:HideAllTabs()
	self.EntSpyForm:FindChild("frameScope"):Show(false)
	self.EntSpyForm:FindChild("frameControl"):Show(false)
	self.EntSpyForm:FindChild("frameSettings"):Show(false)
	self.EntSpyForm:FindChild("frameLines"):Show(false)
end
function EntSpy:TabScopePressed()
	self:HideAllTabs()
	self.EntSpyForm:FindChild("frameScope"):Show(true)
end

function EntSpy:TabControlPressed()
	self:HideAllTabs()
	self.EntSpyForm:FindChild("frameControl"):Show(true)
end

function EntSpy:TabSettingsPressed()
	self:HideAllTabs()
	self.EntSpyForm:FindChild("frameSettings"):Show(true)
end

function EntSpy:TabLinePressed()
	self:HideAllTabs()
	self.EntSpyForm:FindChild("frameLines"):Show(true)
end

--user has attempted to search
function EntSpy:OnSearchClicked()
	if self.EntSpyForm:FindChild("searchTarget"):GetText() ~= nil and self.EntSpyForm:FindChild("searchTarget"):GetText() ~= "" then
		self.sPlayerSearch = self.EntSpyForm:FindChild("searchTarget"):GetText()
	end
	self:OnParseTimer()
end	

--user has attempted to cancel search
function EntSpy:OnCancelClicked()
	self.sPlayerSearch = nil
end

function EntSpy:CheckBoxRefresh()

	--categories
	self.tUserSettings.Cat["Farming"] = self.gui.radio.CatFarming:IsChecked()
	self.tUserSettings.Cat["Mining"] = self.gui.radio.CatMining:IsChecked()
	self.tUserSettings.Cat["RelicHunting"] = self.gui.radio.CatRelicHunting:IsChecked()
	self.tUserSettings.Cat["Survivalist"] = self.gui.radio.CatSurvivalist:IsChecked()
	self.tUserSettings.Cat["QuestNPC"] = self.gui.radio.CatQuest:IsChecked()
	self.tUserSettings.Cat["QuestUnit"] = self.gui.radio.CatQuestUnits:IsChecked()
	self.tUserSettings.Cat["Challenge"] = self.gui.radio.CatChallenge:IsChecked()
	self.tUserSettings.Cat["Path"] = self.gui.radio.CatPath:IsChecked()
	self.tUserSettings.Cat["PVP"] = self.gui.radio.CatPVP:IsChecked()
	self.tUserSettings.Cat["Prime"] = self.gui.radio.CatPrimes:IsChecked()
	self.tUserSettings.Cat["Group"] = self.gui.radio.CatGroup:IsChecked()
	self.tUserSettings.Cat["Subdue"] = self.gui.radio.CatSubdue:IsChecked()
	self.tUserSettings.Cat["Event"] = self.gui.radio.CatEvent:IsChecked()
	self.tUserSettings.Cat["Guild"] = self.gui.radio.CatGuild:IsChecked()
	self.tUserSettings.Cat["MODA"] = self.gui.radio.CatModPVE:IsChecked()
	self.tUserSettings.Cat["MODP"] = self.gui.radio.CatModPVP:IsChecked()
	self.tUserSettings.Cat["Trail"] = self.gui.radio.CatTrail:IsChecked()
	self.tUserSettings.Cat["Lore"] = self.gui.radio.CatLore:IsChecked()
	
	--line categories
	self.tUserSettings.Line["Farming"] = self.gui.radio.LineFarming:IsChecked()
	self.tUserSettings.Line["Mining"] = self.gui.radio.LineMining:IsChecked()
	self.tUserSettings.Line["RelicHunting"] = self.gui.radio.LineRelicHunting:IsChecked()
	self.tUserSettings.Line["Survivalist"] = self.gui.radio.LineSurvivalist:IsChecked()
	self.tUserSettings.Line["QuestNPC"] = self.gui.radio.LineQuest:IsChecked()
	self.tUserSettings.Line["QuestUnit"] = self.gui.radio.LineQuestUnits:IsChecked()
	self.tUserSettings.Line["Challenge"] = self.gui.radio.LineChallenge:IsChecked()
	self.tUserSettings.Line["Path"] = self.gui.radio.LinePath:IsChecked()
	self.tUserSettings.Line["PVP"] = self.gui.radio.LinePVP:IsChecked()
	self.tUserSettings.Line["Prime"] = self.gui.radio.LinePrimes:IsChecked()
	self.tUserSettings.Line["Group"] = self.gui.radio.LineGroup:IsChecked()
	self.tUserSettings.Line["Subdue"] = self.gui.radio.LineSubdue:IsChecked()
	self.tUserSettings.Line["Event"] = self.gui.radio.LineEvent:IsChecked()
	self.tUserSettings.Line["Guild"] = self.gui.radio.LineGuild:IsChecked()
	self.tUserSettings.Line["MODA"] = self.gui.radio.LineModPVE:IsChecked()
	self.tUserSettings.Line["MODP"] = self.gui.radio.LineModPVP:IsChecked()
	self.tUserSettings.Line["Trail"] = self.gui.radio.LineTrail:IsChecked()
	self.tUserSettings.Line["Lore"] = self.gui.radio.LineLore:IsChecked()
	
	--line opt
	self.tUserSettings.OptEnableLines = self.gui.radio.OptEnableLines:IsChecked()
		
	--general options
	self.tUserSettings.OptEnableBG = self.gui.radio.OptEnableBG:IsChecked()
	self.tUserSettings.OptEnableInst = self.gui.radio.OptEnableInst:IsChecked()
	self.tUserSettings.OptEnabled = self.gui.radio.OptEnabled:IsChecked()
	self.tUserSettings.OptEnableInstCombat = self.gui.radio.OptEnableInstCombat:IsChecked()
	
	--unit options
	self.tUserSettings.OptEnableUnitName = self.gui.radio.OptEnableUnitName:IsChecked()
	self.tUserSettings.OptEnableUnitPVPColors = self.gui.radio.OptEnableUnitPVPColors:IsChecked()
	self.tUserSettings.OptEnableUnitHideTarget = self.gui.radio.OptEnableUnitHideTarget:IsChecked()
	self.tUserSettings.OptEnableUnitIcons = self.gui.radio.OptEnableUnitIcons:IsChecked()
	self.tUserSettings.OptEnableUnitDist = self.gui.radio.OptEnableUnitDist:IsChecked()
	
	--unit settings
	self.tUserSettings.OptUnitMaxCat = tonumber(self.gui.txt.OptUnitMaxCat:GetText())
	self.tUserSettings.OptUnitMaxTotal = tonumber(self.gui.txt.OptUnitMaxTotal:GetText())
	self.tUserSettings.OptUnitMergeDist = tonumber(self.gui.txt.OptUnitMergeDist:GetText())
	self.tUserSettings.OptUnitIconScale = tonumber(self.gui.txt.OptUnitIconScale:GetText())
	self.tUserSettings.OptUnitDistText = tonumber(self.gui.txt.OptUnitDistText:GetText())
	
	--marker options
	self.tUserSettings.OptEnableMarkerPath = self.gui.radio.OptEnableMarkerPath:IsChecked()
	self.tUserSettings.OptEnableMarkerEvent = self.gui.radio.OptEnableMarkerEvent:IsChecked()
	self.tUserSettings.OptEnableMarkerQuest = self.gui.radio.OptEnableMarkerQuest:IsChecked()
	self.tUserSettings.OptEnableMarkerChallenge = self.gui.radio.OptEnableMarkerChallenge:IsChecked()
	self.tUserSettings.OptEnableMarkerName = self.gui.radio.OptEnableMarkerName:IsChecked()
	self.tUserSettings.OptEnableMarkerDist = self.gui.radio.OptEnableMarkerDist:IsChecked()
	self.tUserSettings.OptEnableMarkers = self.gui.radio.OptEnableMarkers:IsChecked()
	self.tUserSettings.OptEnableMarkerAutoChallenge = self.gui.radio.OptEnableMarkerAutoChallenge:IsChecked()

	--marker settings
	self.tUserSettings.OptMarkerMinDist = tonumber(self.gui.txt.OptMarkerMinDist:GetText())
	self.tUserSettings.OptMarkerMaxDist = tonumber(self.gui.txt.OptMarkerMaxDist:GetText())
	self.tUserSettings.OptMarkerScale = tonumber(self.gui.txt.OptMarkerScale:GetText())
	
	--line settings
	self.tUserSettings.OptLineMaximum = tonumber(self.gui.txt.OptLineMaximum:GetText())
	self.tUserSettings.OptLineScale = tonumber(self.gui.txt.OptLineScale:GetText())
	self.tUserSettings.OptLineDots = tonumber(self.gui.txt.OptLineDots:GetText())

	self:RebuildAllMarkers()
	self:OnParseTimer()

end

function EntSpy:RestoreDefaultSettings()

	for _, radio in pairs(self.gui.radio) do
			radio:SetCheck(true)
	end
	
	--scope
	self.gui.radio.CatFarming:SetCheck(false)
	self.gui.radio.CatMining:SetCheck(false)
	self.gui.radio.CatRelicHunting:SetCheck(false)
	self.gui.radio.CatSurvivalist:SetCheck(false)
	self.gui.radio.CatPath:SetCheck(false)
	self.gui.radio.CatTrail:SetCheck(false)
	self.gui.radio.CatLore:SetCheck(false)

	--values
	self.gui.txt.OptUnitMaxCat:SetText("5")
	self.gui.txt.OptUnitMaxTotal:SetText("20")
	self.gui.txt.OptUnitMergeDist:SetText("60")
	self.gui.txt.OptUnitIconScale:SetText("1")
	self.gui.txt.OptUnitDistText:SetText("150")
	
	--markers
	self.gui.txt.OptMarkerMinDist:SetText("10")
	self.gui.txt.OptMarkerMaxDist:SetText("300")
	self.gui.txt.OptMarkerScale:SetText("1")
	
	--lines
	self.gui.txt.OptLineMaximum:SetText("3")
	self.gui.txt.OptLineDots:SetText("7")
	self.gui.txt.OptLineScale:SetText("1")
end

function EntSpy:RegisterCats()
	--main cats
	self.cat.PVPStalker = "HostilePlayerStalker"
	self.cat.PVPEngineer = "HostilePlayerEngineer"
	self.cat.PVPWarrior = "HostilePlayerWarrior"
	self.cat.PVPMedic = "HostilePlayerMedic"
	self.cat.PVPSpellslinger = "HostilePlayerSpellslinger"
	self.cat.PVPEsper = "HostilePlayerEsper"
	self.cat.PVPMount = "PVPMount"
	
	self.cat.Quest = "Quest"
	self.cat.Event = "Event"
	self.cat.Challenge = "Challenge"
	self.cat.QuestNewMain = "QuestNewMain"
	self.cat.QuestNew = "QuestNew"
	self.cat.QuestReward = "QuestReward"
	self.cat.QuestSimple = "QuestSimple"
	self.cat.EventSimple = "EventSimple"
	self.cat.QuestTalkTo = "QuestTalkTo"
	self.cat.Explorer = "Explorer"
	self.cat.Soldier = "Soldier"
	self.cat.Scientist = "Scientist"
	self.cat.Settler = "Settler"
	self.cat.Spell = "Spell"
	self.cat.Search = "Search"
	self.cat.Questloot = "QuestLoot"
	self.cat.Primes = "Prime"
	self.cat.Group = "Group"
	self.cat.Pending = "Pending"
	self.cat.Subdue = "Subdue"
	self.cat.Guild = "Guild"
	self.cat.Trail = "Trail"
	self.cat.WTWalatiki = "Walatiki"
	self.cat.WOTWChampion = "Champion"
	self.cat.WOTWEnergyNode = "Energy Node"
	self.cat.MTWater = "Water"
	self.cat.MTFeed = "Feed"
	self.cat.MTFood = "Food"
	self.cat.MTCaravan = "Caravan"
	self.cat.MTChompa = "Chompacabra"
	self.cat.Lore = "Lore"
	self.cat.Stash = "Stash"
		
	self.cat.Mining = L["TradeskillMining"]
	self.cat.RelicHunting = L["TradeskillRelicHunter"]
	self.cat.Survivalist = L["TradeskillSurvivalist"]
	self.cat.Farming = L["TradeskillFarming"]
end

function EntSpy:RegisterGUIElements()

	--search and restore defaults
	self.gui.txt.OptSearch = self.EntSpyForm:FindChild("searchTarget")
	self.gui.lbl.ButtonDefaults = self.EntSpyForm:FindChild("restoreDefaults")
	
	--categories
	self.gui.radio.CatFarming = self.EntSpyForm:FindChild("chkFarming")
	self.gui.radio.CatMining = self.EntSpyForm:FindChild("chkMining")
	self.gui.radio.CatRelicHunting = self.EntSpyForm:FindChild("chkRelic Hunter")
	self.gui.radio.CatSurvivalist = self.EntSpyForm:FindChild("chkSurvivalist")
	self.gui.radio.CatQuest = self.EntSpyForm:FindChild("chkQuest")
	self.gui.radio.CatQuestUnits = self.EntSpyForm:FindChild("chkQuestUnits")
	self.gui.radio.CatChallenge = self.EntSpyForm:FindChild("chkChallenge")
	self.gui.radio.CatPath = self.EntSpyForm:FindChild("chkPath")
	self.gui.radio.CatPrimes = self.EntSpyForm:FindChild("chkPrimes")
	self.gui.radio.CatPVP = self.EntSpyForm:FindChild("chkPVP")
	self.gui.radio.CatGroup = self.EntSpyForm:FindChild("chkGroup")
	self.gui.radio.CatSubdue = self.EntSpyForm:FindChild("chkSubdue")
	self.gui.radio.CatEvent = self.EntSpyForm:FindChild("chkEvent")
	self.gui.radio.CatGuild = self.EntSpyForm:FindChild("chkGuild")
	self.gui.radio.CatModPVE = self.EntSpyForm:FindChild("chkModulesPVE")
	self.gui.radio.CatModPVP = self.EntSpyForm:FindChild("chkModulesPVP")
	self.gui.radio.CatTrail = self.EntSpyForm:FindChild("chkTrail")
	self.gui.radio.CatLore = self.EntSpyForm:FindChild("chkLore")
	
	--line categories
	self.gui.radio.LineFarming = self.EntSpyForm:FindChild("chkFarmingLines")
	self.gui.radio.LineMining = self.EntSpyForm:FindChild("chkMiningLines")
	self.gui.radio.LineRelicHunting = self.EntSpyForm:FindChild("chkRelic HunterLines")
	self.gui.radio.LineSurvivalist = self.EntSpyForm:FindChild("chkSurvivalistLines")
	self.gui.radio.LineQuest = self.EntSpyForm:FindChild("chkQuestLines")
	self.gui.radio.LineQuestUnits = self.EntSpyForm:FindChild("chkQuestUnitsLines")
	self.gui.radio.LineChallenge = self.EntSpyForm:FindChild("chkChallengeLines")
	self.gui.radio.LinePath = self.EntSpyForm:FindChild("chkPathLines")
	self.gui.radio.LinePrimes = self.EntSpyForm:FindChild("chkPrimesLines")
	self.gui.radio.LinePVP = self.EntSpyForm:FindChild("chkPVPLines")
	self.gui.radio.LineGroup = self.EntSpyForm:FindChild("chkGroupLines")
	self.gui.radio.LineSubdue = self.EntSpyForm:FindChild("chkSubdueLines")
	self.gui.radio.LineEvent = self.EntSpyForm:FindChild("chkEventLines")
	self.gui.radio.LineGuild = self.EntSpyForm:FindChild("chkGuildLines")
	self.gui.radio.LineModPVE = self.EntSpyForm:FindChild("chkModulesPVELines")
	self.gui.radio.LineModPVP = self.EntSpyForm:FindChild("chkModulesPVPLines")
	self.gui.radio.LineTrail = self.EntSpyForm:FindChild("chkTrailLines")
	self.gui.radio.LineLore = self.EntSpyForm:FindChild("chkLoreLines")
	
	--line opt
	self.gui.radio.OptEnableLines = self.EntSpyForm:FindChild("chkEnableLines")
	
	--general options (checkbox settings)
	self.gui.radio.OptEnabled = self.EntSpyForm:FindChild("chkEnabled")
	self.gui.radio.OptEnableBG = self.EntSpyForm:FindChild("chkEnableBattleground")
	self.gui.radio.OptEnableInstCombat = self.EntSpyForm:FindChild("chkEnableInstCombat")
	self.gui.radio.OptEnableInst = self.EntSpyForm:FindChild("chkEnableInst")
	
	--unit options
	self.gui.radio.OptEnableUnitName = self.EntSpyForm:FindChild("chkEnableUnitName")
	self.gui.radio.OptEnableUnitIcons = self.EntSpyForm:FindChild("chkEnableUnitIcons")
	self.gui.radio.OptEnableUnitDist = self.EntSpyForm:FindChild("chkEnableUnitDist")
	self.gui.radio.OptEnableUnitName = self.EntSpyForm:FindChild("chkEnableUnitName")
	self.gui.radio.OptEnableUnitPVPColors = self.EntSpyForm:FindChild("chkEnableUnitPVPColors")
	self.gui.radio.OptEnableUnitHideTarget = self.EntSpyForm:FindChild("chkEnableUnitHideTarget")
	
	--marker control types
	self.gui.radio.OptEnableMarkers = self.EntSpyForm:FindChild("chkEnableMarkers")
	self.gui.radio.OptEnableMarkerAutoChallenge= self.EntSpyForm:FindChild("chkEnableMarkerAutoChallenge")	
	self.gui.radio.OptEnableMarkerDist = self.EntSpyForm:FindChild("chkEnableMarkerDist")
	self.gui.radio.OptEnableMarkerName = self.EntSpyForm:FindChild("chkEnableMarkerName")
	self.gui.radio.OptEnableMarkerPath = self.EntSpyForm:FindChild("chkEnableMarkerPath")
	self.gui.radio.OptEnableMarkerQuest = self.EntSpyForm:FindChild("chkEnableMarkerQuest")
	self.gui.radio.OptEnableMarkerEvent = self.EntSpyForm:FindChild("chkEnableMarkerEvent")
	self.gui.radio.OptEnableMarkerChallenge = self.EntSpyForm:FindChild("chkEnableMarkerChallenge")
	
	--settings labels and values
	--unit txt opts
	self.gui.txt.OptUnitMaxCat = self.EntSpyForm:FindChild("txtUnitMaxCat")
	self.gui.txt.OptUnitMaxTotal = self.EntSpyForm:FindChild("txtUnitMaxTotal")
	self.gui.txt.OptUnitMergeDist = self.EntSpyForm:FindChild("txtUnitMergeDist")
	self.gui.txt.OptUnitDistText = self.EntSpyForm:FindChild("txtUnitDistanceText")	
	self.gui.txt.OptUnitIconScale = self.EntSpyForm:FindChild("txtUnitIconScale")	

	--marker txt opts
	self.gui.txt.OptMarkerMinDist = self.EntSpyForm:FindChild("txtMarkerMinDist")
	self.gui.txt.OptMarkerMaxDist = self.EntSpyForm:FindChild("txtMarkerMaxDist")
	self.gui.txt.OptMarkerScale = self.EntSpyForm:FindChild("txtMarkerScale")
		
	--line txt opts
	self.gui.txt.OptLineDots = self.EntSpyForm:FindChild("txtLineDots")
	self.gui.txt.OptLineMaximum = self.EntSpyForm:FindChild("txtLineMaximum")
	self.gui.txt.OptLineScale = self.EntSpyForm:FindChild("txtLineScale")

end

-------------------------------------------------------
-- EntSpy Instance
-----------------------------------------------------------------------------------------------
local EntSpyInst = EntSpy:new()
EntSpyInst:Init()

-----------------------------------------------------------------------------------------------
-- Table Functions (WILDSTAR API LIFE) - Just functions for managing tables and strings and shit
-- Entirely stolen code off stackoverflow or whatever
-----------------------------------------------------------------------------------------------
function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "   =   " .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function compare(a,b)
		return a.dist < b.dist
end
