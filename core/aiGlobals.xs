//==============================================================================
/* aiGlobals.xs

	This file contains all global constants and variables.

*/
//==============================================================================


//==============================================================================
// Utilities.
//==============================================================================

extern int gArrayPlan = -1;
extern int gArrayPlanIDs = -1;
// The following two variables are introduced to more efficiently (in terms of time complexity)
// resize a specific array. Our "array" is known by the Data Plan as a User Variable, which
// is represented by an integer.
extern int gArrayPlanSizes = -1;
extern int gArrayPlanNumElements = -1;

extern const float PI = 3.1415926;
extern const int cTileBlack = 1;
extern const int cTileFog = 2;
extern const int cTileVisible = 4;

extern int reQueryID = -1;

extern vector gHomeBase = cInvalidVector;
extern vector gDirection_UP = cInvalidVector;
extern vector gDirection_DOWN = cInvalidVector;
extern vector gDirection_RIGHT = cInvalidVector;
extern vector gDirection_LEFT = cInvalidVector;

extern int gAllyBaseArray = -1;
extern int gEnemyBaseArray = -1;
extern vector avgEnemyBaseLocation = cInvalidVector;


//==============================================================================
// Buildings.
//==============================================================================
extern const int cBuildPlanBuilderTypeID = 0;

extern int gTCBuildPlanID = -1;
extern vector gTCSearchVector = cInvalidVector; // Used to define the center of the TC building placement search.
extern int gTCStartTime = 10000;                // Used to define when the TC build plan can go active. In ms.
extern const int cForwardBaseStateNone = -1;    // None exists, none in progress
extern const int cForwardBaseStateBuilding = 0; // Fort wagon exists, but no fort yet.
extern const int cForwardBaseStateActive = 1;   // Base is active, defend and train plans there.
extern int gForwardBaseState = cForwardBaseStateNone;
extern int gForwardBaseID = -1;                      // Set when state goes to Active
extern vector gForwardBaseLocation = cInvalidVector; // Set when state goes to 'building' or earlier.
extern int gForwardBaseBuildPlan = -1;
extern int gForwardBaseUpTime = -600000;
extern bool gForwardBaseShouldDefend = false;
extern int gMainBase = -1;
extern bool gBuildWalls = false;         // Global indicating if we're walling up or not.
extern int gNumTowers = 0;               // How many towers do we want to build?
extern bool gTowerCommandActive = false; // This is set by commHandler and used to determine which Tower amount to build.
extern int gCommandNumTowers = 0;        // Set inside of commHandler and used when we build Towers based on a command.
extern vector gTorpPosition = cInvalidVector;
extern int gTorpPositionsToAvoid = -1;
extern int gMilitaryBuildings = -1;
extern int gArmyUnitBuildings = -1;
extern int gFullGranaries = -1;  // List of granaries surrounded by fields
extern int gFieldGranaryID = -1; // The current granary chosen to build a field nearby
extern vector gTorpBuildPlanPosition = cInvalidVector;
extern vector gShrineBuildPlanPosition = cInvalidVector;
extern vector gGranaryBuildPlanPosition = cInvalidVector;

extern int gHouseUnit = cUnitTypeHouse;
extern int gTowerUnit = cUnitTypeOutpost;
extern int gFarmUnit = cUnitTypeMill;
extern int gPlantationUnit = cUnitTypePlantation;
extern int gLivestockPenUnit = cUnitTypeLivestockPen;
extern int gMarketUnit = cUnitTypeMarket;
extern int gDockUnit = cUnitTypeDock;

extern int gMillTypePlans = -1;
extern int gPlantationTypePlans = -1;
extern int gHouseBuildPlans = -1;

extern int gGarrisonableBuildingQuery = -1;
extern int gGarrisonableBuilding = -1;

extern int gQueuedBuildingPriority = -1;

//==============================================================================
// Techs.
//==============================================================================

// These includes the Market/Granary and Mill/Plantation type units.
// There are other economic upgrades that will be accounted for elsewhere.
extern int gMarketTechs = -1;
extern int gMarketTechsAgeReq = -1;
extern int gMarketTechsPrio = -1;
extern int gGranaryTechs = -1;
extern int gGranaryTechsAgeReq = -1;
extern int gMillTechs = -1;
extern int gMillTechsAgeReq = -1;
extern int gPlantationTechs = -1;
extern int gPlantationTechsAgeReq = -1;
extern int gMosqueTechs = -1; // Techs that pertain to villager training.
extern int gMosqueTechsAgeReq = -1;

extern int gAllegianceTechs = -1;
extern int gAllegianceTechsAgeReq = -1;
extern int gAllegianceTechsPrio = -1;

extern int gConsulateFlagTechID = -1;     // the consulate flag tech we are going to research.
extern bool gConsulateFlagChosen = false; // need to make sure they only build one
extern int gAgeUpResearchPlan = -1; // Plan used to send politician from HC, used to detect if an age upgrade is in progress.
extern int gAgeUpTime = 0;          // Time we entered this age
extern int gAgeUpPlanTime = 0;      // Time to plan for next age up.

// Trade Route Array Constants.
extern const int cTradeRouteNorthAmerica = 0;
extern const int cTradeRouteSouthAmerica = 1;
extern const int cTradeRouteAsia = 2;
extern const int cTradeRouteAfrica = 3;
extern const int cTradeRouteNaval = 4;
extern const int cTradeRouteAll = 5; // This is used for maps where upgrading one route also upgrades others, textures default to NA ones.
extern const int cTradeRouteCapturableAsia = 6;
extern const int cTradeRouteCapturableAfrica = 7; // If ever more Capturable routes are added this needs to be updated.
extern const int cTradeRouteFirstUpgrade = 0;
extern const int cTradeRouteSecondUpgrade = 1;
extern int gNumberTradeRoutes = -1; // Saves how many Trade Routes there are on the map via kbGetNumberTradeRoutes(), this never
									// changes so can just be a global sort of constant.

// Trade Route Arrays
// This saves how many Trade Routes there are on the map (index in the array is also the index of the TR at the same time)
// and what type these TRs are (land(continent)/naval).
extern int gTradeRouteIndexAndType = -1;
// This will be a bool array and false means the specific TR isn't fully upgraded and true means it is.
extern int gTradeRouteIndexMaxUpgraded = -1;
// Here we store what crates are actually delivered by each trade route so we can correctly
// set the tactic in tradeRouteTacticMonitor.
extern int gTradeRouteCrates = -1;
// Index 0 will be the first upgrade on the Route and 1 the second upgrade on the Route.
extern int gTradeRouteUpgrades = -1;

// In these variables we save the IDs of the minor native civs that are present on the map.
// We use these in the setupNativeUpgrades logic.
// We have 3 of these variables because the maximum amount of minor native civs you can get on a regular map is 3.
// This means that if you for example have a map with 4 different natives the 4th native will be ignored.
extern int gNativeTribeCiv1 = -1;
extern int gNativeTribeCiv2 = -1;
extern int gNativeTribeCiv3 = -1;
// We use these function pointers to research minor native upgrades via setupNativeUpgrades.
bool nativeResearchTechsEmpty(int tradingPostID = -1) { return (false); }
extern bool(int) gNativeTribeResearchTechs1 = nativeResearchTechsEmpty;
extern bool(int) gNativeTribeResearchTechs2 = nativeResearchTechsEmpty;
extern bool(int) gNativeTribeResearchTechs3 = nativeResearchTechsEmpty;

extern int gRevolutionList = -1; // List of Revolutions

// We save at what time the first person in the game advanced to Fortress/Industrial/Imperial in this array.
// In ageUpgradeMonitor we determine how badly we need to age up taking this into account.
extern int gFirstAgeTime = -1;


//==============================================================================
// Exploration.
//==============================================================================

extern int gWaterExplorePlan = -1;    // Plan ID for ocean exploration plan
extern int gExplorerControlPlan = -1; // Defend plan set up to control the explorer's location
extern int gLandExplorePlan = -1;     // Primary land exploration
extern int gIslandExploreTransportScoutID = -1;
extern bool gIslandMap = false; // Does this map have lands with waters in between?


//==============================================================================
// Economy.
//==============================================================================
extern int gEconUnit = cUnitTypeSettler;

extern int cMaxSettlersPerFarm = 10;
extern int cMaxSettlersPerPlantation = 10;
extern bool gTimeToFarm = false;                // Set to true when we start to run out of cheap early food.
extern bool gTimeForPlantations = false;        // Set to true when we start to run out of mine-able gold.
extern bool gPrioritizeFarms = false;           // Set to true when we should prioritize farms.
extern bool gPrioritizeEstates = false;         // Set to true when we should prioritze estates.
extern bool gCountBerries = false;              // Set to true when we should count berries as calculating natural resources we have left.

extern int gVillagerQuery = -1;
extern int gFoodQuery = -1;
extern int gWoodQuery = -1;
extern int gGoldQuery = -1;
extern int gNumFoodVills = 0;
extern int gNumGoldVills = 0;
extern int gNumWoodVills = 0;
extern int gReservedFoodVillagers = 0;
extern int gReservedWoodVillagers = 0;
extern int gReservedGoldVillagers = 0;

extern int gFoodResources = -1;
extern int gDecayingAnimals = -1;
extern int gWoodResources = -1;
extern int gGoldResources = -1;
extern int gFoodNumWorkers = -1;
extern int gDecayingNumWorkers = -1;
extern int gMaxFoodWorkers = -1;
extern int gWoodNumWorkers = -1;
extern int gGoldNumWorkers = -1;
extern int gMaxGoldWorkers = -1;
extern int gFoodFishResources = -1;
extern int gGoldFishResources = -1;

extern bool gGoodFishingMap = false;      // Set in init(), can be overridden in postInit() if desired.  True indicates that
										  // fishing is a good idea on this map.
extern int gFishingPlan = -1;             // Plan ID for main fishing plan.
extern int gFishingBoatMaintainPlan = -1; // Fishing boats to maintain
extern bool gTimeToFish = false;          // Set to true when we want to start fishing.
extern int gHerdPlanID = -1;
extern int gResourceNeeds = -1;
extern int gExtraResourceNeeds = -1;
extern bool gLowOnResources = false;

extern float gGoldPercentageToBuyForWood = 0.0; // Percentage of gold to buy for wood.
extern int gFarmFoodTactic = -1;
extern int gFarmGoldTactic = -1;

extern int gFishingUnit = cUnitTypeFishingBoat;

extern float gTSFactorDistance = -200.0; // negative is good
extern float gTSFactorPoint = 10.0; // positive is good
extern float gTSFactorTimeToDone = 0.0; // positive is good
extern float gTSFactorBase = 100.0; // positive is good
extern float gTSFactorDanger = -10.0; // negative is good

//==============================================================================
// Military.
//==============================================================================

extern int gBarracksUnit = cUnitTypeBarracks;
extern int gStableUnit = cUnitTypeStable;
extern int gArtilleryDepotUnit = cUnitTypeArtilleryDepot;

extern int gLastTribSentTime = 0;

extern int gLandDefendPlan0 = -1; // Primary land defend plan
extern int gLandReservePlan = -1; // Reserve defend plan, gathers units for use in the next military mission
extern int gBaseDefendPlan = -1;
extern int gHealerPlan = -1;      // Defend plan that controls our healers in our base.

extern bool gDefenseReflex = false; // Set true when a defense reflex is overriding normal ops.
extern bool gDefenseReflexPaused = false; // Set true when we're in a defense reflex, but overwhelmed, so we're hiding to rebuild an army.
extern int gDefenseReflexBaseID = -1; // Set to the base ID that we're defending in this emergency
extern vector gDefenseReflexLocation = cInvalidVector; // Location we're defending in this emergency
extern int gDefenseReflexTimeout = 0;

extern int gLandUnitPicker = -1; // Picks the best land military units to train.

extern float gNetNavyValue = -1; // Saves the power balance on the water.
extern int gNavyRepairPlan = -1; // Saves the ID of the naval defend combat (hijacked for repair) plan to manage land/navy interactions. 
extern int gNavyDefendPlan = -1; // Persistent naval defend plan.
extern int gNavyAttackPlan = -1; // Saves the ID of the naval attack combat plan to manage land/navy interactions.
extern vector gNavyVec = cInvalidVector; // The center of the navy's operations.
extern bool gHaveWaterSpawnFlag = false;
extern int gWaterSpawnFlagID = -1;
extern bool gNavyMap = false; // Setting this false prevents navies

extern int gCaravelMaintain = -1; // Maintain plans for naval units.
extern int gGalleonMaintain = -1;
extern int gFrigateMaintain = -1;
extern int gMonitorMaintain = -1;
extern int gWaterExploreMaintain = -1;

extern int gNumArmyUnitTypes = 3; // How many land unit types do we want to train?

extern int gGoodArmyPop = -1; // This number is updated by the pop manager, only used to calculate stuff in the defence reflex logic.

extern int gUnitPickSource = cOpportunitySourceAutoGenerated; // Indicates who decides which units are being trained...self, trigger, or ally player.

extern int gLastClaimTradeMissionTime = -1;
extern int gLastAttackMissionTime = -1;
extern int gLastNavalAttackTime = -1;
extern int gLastDefendMissionTime = -1;
extern int gAttackMissionInterval =
	180000; // 2-3 minutes depending on difficulty level.  Suppresses attack scores (linearly) for 2-3 minutes after one
			// launches.  Attacks will usually happen before this period is over.
extern int gDefendMissionInterval = 300000; // 5 minutes.   Makes the AI less likely to do another defend right after doing one.
extern int gClaimTradeMissionInterval = 300000;  // 5 minutes.
extern int gClaimNativeMissionInterval = 600000; // 10 minutes.
extern int gLastClaimNativeMissionTime = -1;

extern int gNumEnemies = -1;             // Used to pick a target to attack.
extern int gArrayEnemyPlayerIDs = -1;    // Used to pick a target to attack.
extern int gStartingPosDistances = -1;   // Used to sort enemies from closest to furthest away for target picking in FFA.

extern bool gIAmCaptain = false;
extern int gCaptainPlayerNumber = -1;

extern bool gIsMonopolyRunning = false; // Set true while a monopoly countdown is in effect.
extern int gMonopolyTeam = -1;          // TeamID of team that will win if the monopoly timer completes.
extern int gMonopolyEndTime = -1;       // Gametime when current monopoly should end

extern bool gIsKOTHRunning = false; // Set true while a KOTH countdown is in effect.
extern int gKOTHTeam = -1;          // TeamID of team that will win if the KOTH timer completes.

extern int gArmyUnitMaintainPlans = -1;

extern int gCaravelUnit = cUnitTypeCaravel;
extern int gGalleonUnit = cUnitTypeGalleon;
extern int gFrigateUnit = cUnitTypeFrigate;
extern int gMonitorUnit = cUnitTypeMonitor;


//==============================================================================
// Home City cards.
//==============================================================================

extern int gDefaultDeck = -1; // Home city deck used by each AI
extern int gCardList = -1; // List of cards to include in our deck.
extern int gCardListIsMilitaryUnit = -1;
extern int gCardListIsMilitaryUpgrade = -1;
extern int gCardListIsExtended = -1;
extern int gCardListIndexInDeck = -1;
extern int gCardListSentCount = -1;
extern int gNumberShipmentsSent = 0;
extern int gNextShipmentTechID = -1;
extern int gNextShipmentIndexInArray = -1; // The index of gNextShipmentTechID in our storage array.
extern int gSentCardList = -1;
extern int gPriorityCards = -1;


//==============================================================================
// Chats.
//==============================================================================

extern int gFeedGoldTo = -1; // If set, this indicates which player we need to be supplying with regular gold shipments.
extern int gFeedWoodTo = -1; // See commHandler and monitorFeeding rule.
extern int gFeedFoodTo = -1;
extern int gMapNames = -1; // An array of random map names, so we can store ID numbers in player histories

extern int gLateInAgePlayerID = -1;
extern int gLateInAgeAge = -1;


//==============================================================================
// Setup.
//==============================================================================
// Start mode constants.
extern int gStartMode = -1;					  // See start mode constants, above.  This variable is set
											  // in main() and is used to decide which cascades of rules
											  // should be used to start the AI.
extern const int cStartModeScenarioNoTC = 0;  // Scenario, wait for aiStart unit, then play without a TC
extern const int cStartModeScenarioTC = 1;    // Scenario, wait for aiStart unit, then play with starting TC
extern const int cStartModeScenarioWagon = 2; // Scenario, wait for aiStart unit, then start TC build plan.
extern const int cStartModeLandTC = 3;        // RM or GC game, starting with a TC...just go.
extern const int cStartModeLandWagon = 4;     // RM or GC game, starting with a wagon.  Explore, start TC build plan.
extern const int cStartModeLandResources = 5; // RM or GC game, starting with enough resources to build a TC.

extern vector gStartingLocationOverride = cInvalidVector;
extern bool gStartOnDifferentIslands = false; // Does this map have players starting on different islands?


//==============================================================================
// All other stuffs.
//==============================================================================

extern int gMaxPop = 200; // Absolute hard limit pop cap for game...will be set lower on some difficulty levels
extern int gPlazaPlan = -1;

extern int  gAgeUpList = -1; // General array that will be referenced to age up.

extern int gMyStrategy = -1;
extern const int cStrategyStandard = 0;
extern const int cStrategyTreaty = 2;
extern bool gTreatyGame = false; // To help with various strategies.

extern const int cRevolutionMilitary = 1;
extern const int cRevolutionEconomic = 2;
extern const int cRevolutionFinland = 4;
extern int gRevolutionType = 0;

// Save which age variant of Asian Wonder we aged up with to be used instead of kbUnitCount checks.
// Chinese.
extern int gWhitePagodaPUID = -1;
extern int gSummerPalacePUID = -1;
extern int gConfucianAcademyPUID = -1;
extern int gTempleOfHeavenPUID = -1;
extern int gPorcelainTowerPUID = -1;

// Indians.
extern int gAgraFortPUID = -1;
extern int gCharminarGatePUID = -1;
extern int gKarniMataPUID = -1;
extern int gTajMahalPUID = -1;
extern int gTowerOfVictoryPUID = -1;

// Japanese.
extern int gGreatBuddhaPUID = -1;
extern int gGoldenPavilionPUID = -1;
extern int gTheShogunatePUID = -1;
extern int gToriiGatesPUID = -1;
extern int gToshoguShrinePUID = -1;

// Ethiopian Age Ups
extern int gAllegianceSomali = -1;
extern int gAllegianceHabesha = -1;
extern int gAllegianceJesuit = -1;
extern int gAllegiancePortuguese = -1;
extern int gAllegianceSudanese = -1;
extern int gAllegianceIndian = -1;
extern int gAllegianceOromo = -1;
extern int gAllegianceArab = -1;
// Hausa Age Ups
extern int gAllegianceBerbers = -1;
extern int gAllegianceHausa = -1;
extern int gAllegianceMoraccan = -1;
extern int gAllegianceSonghai = -1;
extern int gAllegianceAkan = -1;
extern int gAllegianceFulani = -1;
extern int gAllegianceYoruba = -1;
extern int gAllegianceBritish = -1;

extern int gSettlerMaintainPlan = -1; // Main plan to control settler population

extern int gDifficultyExpert = cDifficultyExpert; // Equivalent of expert difficulty, hard for SPC content.
extern bool gLowDifficulty = false;


//==============================================================================
// Debug variables.
//==============================================================================
extern const bool cDebugUtilities = false;
extern const bool cDebugBuildings = false;
extern const bool cDebugTechs = false;
extern const bool cDebugExploration = false;
extern const bool cDebugEconomy = false;
extern const bool cDebugMilitary = false;
extern const bool cDebugHCCards = false;
extern const bool cDebugChats = false;
extern const bool cDebugSetup = false;
extern const bool cDebugCore = false;
