//==============================================================================
/* aiCore.xs

   This file includes all other files in the core folder, and will be included
   by aiMain.xs.

   This file also contains functions and rules that don't belong to other files.

*/
//==============================================================================

//==============================================================================
// Function forward declarations.
//==============================================================================
// Used in loader file to override default values, called at start of main()
mutable void preInit(void) {}

// Used in loader file to override initialization decisions, called at end of main()
mutable void postInit(void) {}

// Utilities.
mutable int arrayCreateInt(int numElements = 1, string description = "default") { return(-1); }
mutable int arrayGetInt(int arrayID = -1, int arrayIndex = -1) { return(-1); }
mutable void arraySetInt(int arrayID = -1, int arrayIndex = -1, int value = -1) {}
mutable int arrayGetSize(int arrayID = -1) { return(-1); }
mutable void arraySetSize(int arrayID = -1, int size = -1) {}
mutable int arrayGetNumElements(int arrayID = -1) { return(-1); }
mutable void arraySetNumElements(int arrayID = -1, int numElements = -1, bool clearValues = false) {}
mutable void arrayPushInt(int arrayID = -1, int value = -1) {}
mutable void arrayResetSelf(int arrayID = -1) {}
mutable void arrayDeleteInt(int arrayID = -1, int arrayIndex = -1) {}
mutable void arrayRemoveDonePlans(int arrayID = -1) {}
mutable void arrayShuffleInt(int arrayID = -1) {}

mutable vector getStartingLocation(void) { return (kbGetPlayerStartingPosition(cMyID)); }

// Buildings.
mutable void selectTowerBuildPlanPosition(int buildPlan = -1) {}
mutable void setTowerPosition(int buildPlan = -1, int buildingType = -1) {}
mutable bool shouldBuildTorp(vector position = cInvalidVector, float radius = 80.0) { return(false); }
mutable void selectTorpBuildPlanPosition(int planID = -1) {}
mutable bool shouldBuildShrine(vector position = cInvalidVector, float radius = 80.0) { return(false); }
mutable void selectShrineBuildPlanPosition(int planID = -1) {}
mutable bool shouldBuildGranaryHuntables(vector position = cInvalidVector, float radius = 100.0) { return(false); }
mutable bool shouldBuildGranaryFields(vector position = cInvalidVector, float radius = 100.0) { return(false); }
mutable void selectGranaryBuildPlanPosition(int planID = -1) {}
mutable void selectMountainMonasteryBuildPlanPosition(int planID = -1) {}
mutable void selectUniversityBuildPlanPosition(int planID = -1, vector position = cInvalidVector) {}
mutable void selectClosestBuildPlanPosition(int planID = -1, int baseID = -1) {}
mutable void selectBuildPlanPosition(int planID = -1, int puid = -1, vector position = cInvalidVector) {}
mutable int addMillBuildPlan(void) { return(-1); }
mutable int addPlantationBuildPlan(void) { return(-1); }

// Economy.
mutable void updateResourceDistribution(void) {}
mutable void econMaster(int mode = -1, int value = -1) {}

// Military.
mutable int initUnitPicker(
	string name = "BUG", int numberTypes = 1, int minUnits = 10, int maxUnits = 20, int minPop = -1, int maxPop = -1,
	int numberBuildings = 1, bool guessEnemyUnitType = false)
{
	return (-1);
}
mutable void setUnitPickerCommon(int upID = -1) {}
mutable void setUnitPickerPreference(int upID = -1) {}
mutable void endDefenseReflex(void) {}
mutable void addUnitsToMilitaryPlan(int planID = -1) {}
mutable float getMilitaryUnitStrength(int puid = -1) { return (0.0); }

// Home City cards.
mutable void shipGrantedHandler(int parm = -1) {}

// Chats.
mutable void sendStatement(int playerIDorRelation = -1, int commPromptID = -1, vector vec = cInvalidVector) {}

// Setup.
mutable void deathMatchStartupBegin(void) {}
mutable void economyModeMatchStartupBegin(void) {}
mutable void initCeylonNomadStart(void) {}

// Core.
mutable void transportShipmentArrive(int techID = -1) {}
mutable void revoltedHandler(int techID = -1) {}


//==============================================================================
// Includes.
//==============================================================================
include "core\aiGlobals.xs";
include "core\aiUtilities.xs";
include "core\aiBuildings.xs";
include "core\aiTechs.xs";
include "core\aiExploration.xs";
include "core\aiEconomy.xs";
include "core\aiMilitary.xs";
include "core\aiHCCards.xs";
include "core\aiChats.xs";
include "core\aiSetup.xs";


//==============================================================================
// setMilPopLimit
// Calculates how many military population we want in the current age.
//==============================================================================
void setMilPopLimit(int age1 = 10, int age2 = 30, int age3 = 80, int age4 = 120, int age5 = 130)
{
	int limit = 10;
	int age = kbGetAge();
	if (agingUp() == true)
		age = age + 1;
	if (age == cvMaxAge)
		age = cAge5;

	switch (age)
	{
		case cAge1:
		{
			limit = age1;
			break;
		}
		case cAge2:
		{
			limit = 30;
			break;
		}
		case cAge3:
		{
			limit = age3;
			if (aiGetWorldDifficulty() >= cDifficultyHard && limit < 75)
				limit = 75;
			break;
		}
		case cAge4:
		{
			limit = age4;
			if (aiGetWorldDifficulty() >= cDifficultyHard && limit < 100)
				limit = 100;
			break;
		}
		case cAge5:
		{
			limit = age5;
			if (aiGetWorldDifficulty() >= cDifficultyHard && limit < 125)
				limit = 125;
			break;
		}
	}
	aiSetMilitaryPop(limit);
}


//==============================================================================
/* rule popManager

	Set population limits based on age, difficulty and control variable settings
*/
//==============================================================================
rule popManager
active
minInterval 15
{
	float difficulty = aiGetWorldDifficulty();
	int intDifficulty = difficulty;

	int maxMil = -1;  // The full age-5 max military size...to be reduced in earlier ages to control runaway spending.

	int villBuildLimit = kbGetBuildLimit(cMyID, gEconUnit);
	float villWorthRatio = 99.0 / villBuildLimit;
	int economyPop = -1;

	if (intDifficulty <= cDifficultyEasy)
		gLowDifficulty = true;
	switch (intDifficulty)
	{
		case cDifficultySandbox: // "Easy"
		{	// Typically 40 econ, 40 military.
			gMaxPop = 80;
			economyPop = (gMaxPop / 2) / villWorthRatio;
			aiSetEconomyPop(economyPop);
			maxMil = gMaxPop - aiGetEconomyPop();
			setMilPopLimit(maxMil / 6, maxMil / 3, maxMil / 2, maxMil, maxMil);
			break;
		}
		case cDifficultyEasy: // "Standard"
		{	// Typically 60 econ, 60 military.
			gMaxPop = 120;
			economyPop = (gMaxPop / 2) / villWorthRatio;
			aiSetEconomyPop(economyPop);
			maxMil = gMaxPop - aiGetEconomyPop();
			setMilPopLimit(maxMil / 6, maxMil / 3, maxMil / 2, maxMil, maxMil);
			break;
		}
		case cDifficultyModerate: // "Moderate"
		{	// Typically 80 econ, 80 military.
			gMaxPop = 160;
			economyPop = (gMaxPop / 2) / villWorthRatio;
			aiSetEconomyPop(economyPop);
			gAttackMissionInterval = 2 * 60 * 1000;
			gDefendMissionInterval = 2 * 60 * 1000;
			maxMil = gMaxPop - aiGetEconomyPop();
			setMilPopLimit(maxMil / 6, maxMil / 3, maxMil / 2, maxMil, maxMil);
			break;
		}
		case cDifficultyHard: // "Hard"
		{
			gMaxPop = kbGetMaxPop();
			aiSetEconomyPop(villBuildLimit);
			gAttackMissionInterval = 1 * 60 * 1000;
			gDefendMissionInterval = 1 * 60 * 1000;
			maxMil = gMaxPop - aiGetEconomyPop();
			setMilPopLimit(maxMil / 6, maxMil / 3, maxMil / 2, maxMil, maxMil);
			break;
		}
		case cDifficultyExpert: // "Hardest"
		{
			gMaxPop = kbGetMaxPop();
			aiSetEconomyPop(villBuildLimit);
			gAttackMissionInterval = 1 * 60 * 1000;
			gDefendMissionInterval = 1 * 60 * 1000;
			maxMil = gMaxPop - aiGetEconomyPop();
			setMilPopLimit(maxMil / 6, maxMil / 3, maxMil / 2, maxMil, maxMil);
			break;
		}
		case cDifficultyExtreme: // "Extreme"
		{
			gMaxPop = kbGetMaxPop();
			aiSetEconomyPop(villBuildLimit);
			gAttackMissionInterval = 1 * 60 * 1000;
			gDefendMissionInterval = 1 * 60 * 1000;
			maxMil = gMaxPop - aiGetEconomyPop();
			setMilPopLimit(maxMil / 6, maxMil / 3, maxMil / 2, maxMil, maxMil);
			break;
		}
	}

	if (aiTreatyGetEnd() > xsGetTime() + 7 * 60 * 1000)
		aiSetMilitaryPop(0);

	gGoodArmyPop = aiGetMilitaryPop() / 3;
}


//==============================================================================
// transportShipmentArrive()
//==============================================================================
void transportShipmentArrive(int techID = -1)
{
	wagonMonitor();

	switch(techID)
	{
		case cTechHCGermantownFarmers:
		{
			createSimpleMaintainPlan(cUnitTypeSettlerWagon, kbGetBuildLimit(cMyID, cUnitTypeSettlerWagon), true, kbBaseGetMainID(cMyID), 1);
			break;
		}
		case cTechHCXPNewWaysSioux:  // Lakota New Ways card.
		{
			xsEnableRule("arsenalUpgradeMonitor");
			break;
		}
		case cTechHCXPNewWaysIroquois:  // Haudenosaunee New Ways card.
		{
			xsEnableRule("arsenalUpgradeMonitor");
			break;
		}
		case cTechHCAdvancedArsenalGerman:
		{
			xsEnableRule("advancedArsenalUpgradeMonitor");
			xsEnableRule("arsenalUpgradeMonitor"); // In case we get this card in Age2 we need to enable this rule now since otherwise it won't be enabled until Age 3.
			break;
		}
		case cTechHCAdvancedArsenal:
		{
			xsEnableRule("advancedArsenalUpgradeMonitor");
			xsEnableRule("arsenalUpgradeMonitor"); // In case we get this card in Age2 we need to enable this rule now since otherwise it won't be enabled until Age 3.
			break;
		}
	}
}

//==============================================================================
// Plaza Functions
//==============================================================================
int getNumberSocialisingVills(void)
{
	int plazaID = getUnit(cUnitTypeCommunityPlaza);
	int retVal = 0;
	int unitID = -1;
	int condition = getUnitCountByLocation(gEconUnit, cMyID, cUnitStateAlive, kbUnitGetPosition(plazaID), 20.0);
	for (i = 0; < condition)
	{
		unitID = getUnitByLocation(gEconUnit, cMyID, cUnitStateAlive, kbUnitGetPosition(plazaID), -1, i);
		if (kbUnitGetActionType(unitID) == cActionTypeSocialise)
			retVal++;
	}

	return(retVal);
}

rule plazaMonitor
inactive
minInterval 15
{
	int plazaID = getUnit(cUnitTypeCommunityPlaza);
	int numWarPriests = -1;
	int numPriestesses = -1;
	int bonusPriestDancers = -1;
	int numVillsWanted = -1;
	int villsOnPlaza = getNumberSocialisingVills();
	int i = 0;
	int numUnits = -1;
	int unitID = -1;
	int tacticID = -1;
	float totalResources = 
		kbResourceGet(cResourceFood) +
		kbResourceGet(cResourceWood) + 
		kbResourceGet(cResourceGold);


	if (gPlazaPlan < 0)
	{
		gPlazaPlan = aiPlanCreate("Community Plaza Plan", cPlanReserve);
		aiPlanSetDesiredPriority(gPlazaPlan, 99);
		aiPlanSetActive(gPlazaPlan, true);
	}

	if (plazaID < 1)
	{
		aiPlanAddUnitType(gPlazaPlan, cUnitTypexpMedicineManAztec, 0, 0, 0);
		aiPlanAddUnitType(gPlazaPlan, cUnitTypedePriestess, 0, 0, 0);
		return;
	}

	numWarPriests = kbUnitCount(cMyID, cUnitTypexpMedicineManAztec, cUnitStateAlive);
	numPriestesses = kbUnitCount(cMyID, cUnitTypedePriestess, cUnitStateAlive);
	numPriestesses = getMin(numPriestesses, 10); // It seems only 10 can be assigned.
	bonusPriestDancers = numWarPriests + numPriestesses;
	if (bonusPriestDancers > 25)
		bonusPriestDancers = 25;

	aiPlanAddUnitType(gPlazaPlan, cUnitTypexpMedicineManAztec, 1, numWarPriests, numWarPriests, true, true);
	aiPlanAddUnitType(gPlazaPlan, cUnitTypedePriestess, 1, numPriestesses, numPriestesses, true, true);

	numVillsWanted = kbUnitCount(cMyID, gEconUnit, cUnitStateAlive) / (9 - kbGetAge());
	if (kbGetAge() == cvMaxAge && kbUnitCount(cMyID, gEconUnit, cUnitStateAlive) > 75)
		numVillsWanted = 25;

	if (kbGetAge() == cAge1)
		numVillsWanted = 0;
	else if (kbGetAge() == cAge2 && gMyStrategy != cStrategyTreaty)
		numVillsWanted = 0;

	if (numVillsWanted + bonusPriestDancers > 25)
		numVillsWanted = 25 - bonusPriestDancers;

	numUnits = aiPlanGetNumberUnits(gPlazaPlan, cUnitTypexpMedicineManAztec) +
		aiPlanGetNumberUnits(gPlazaPlan, cUnitTypedePriestess);
	for (i = 0; < numUnits)
	{
		unitID = aiPlanGetUnitByIndex(gPlazaPlan, i);
		if (kbUnitGetActionType(unitID) != cActionTypeSocialise)
			aiTaskUnitWork(unitID, plazaID);
	}

	if (villsOnPlaza != numVillsWanted)
	{
		i = 0;
		if (villsOnPlaza < numVillsWanted)
		{
			while (numVillsWanted > 0)
			{
				unitID = getUnitByLocation(gEconUnit, cMyID, cUnitStateAlive, kbUnitGetPosition(plazaID), -1, i);
				if (unitID >= 0)
				{
					switch (kbUnitGetActionType(unitID))
					{
						case cActionTypeSocialise:
						{
							numVillsWanted--;
							i++;
							continue;
						}
						case cActionTypeBuild:
						case cActionTypeMove:
						case cActionTypeMoveByGroup:
						{
							i++;
							continue;
						}
						default:
						{
							if (kbUnitGetPlanID(unitID) < 0)
							{
								aiTaskUnitWork(unitID, plazaID);
								numVillsWanted--;
							}
							i++;
							continue;
						}
					}
				}
				else break; // reached end of villager query
			}
		}
		else // villsOnPlaza > numVillsWanted
		{
			while (villsOnPlaza > numVillsWanted)
			{
				unitID = getUnitByLocation(gEconUnit, cMyID, cUnitStateAlive, kbUnitGetPosition(plazaID), -1, i);
				if (unitID >= 0)
				{
					if (kbUnitGetActionType(unitID) == cActionTypeSocialise)
					{
						aiTaskUnitMove(unitID, kbUnitGetPosition(plazaID) + gDirection_UP * 10.0);
						villsOnPlaza--;
					}
					i++;
					continue;
				}
				else break; // reached end of villager query
			}
		}
	}

	// Defensive Option: Ideally Town Dance (Inca do not have it anymore).
	if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, cUnitStateAlive, gHomeBase, 85.0) >= 5)
	{
		if (kbTechGetStatus(cTechHCXPTownDance) == cTechStatusActive) // We have already sent HCXPTownDance.
			tacticID = cTacticCityDance;
		else
			tacticID = kbGetAge() >= cAge4 ? cTacticWarDance : cTacticAlarmDance;

		aiUnitSetTactic(plazaID, tacticID);
		return;
	}

	// War Dance for increased unit stats if we have units in combat. TODO (James): Account for multiple combat plans.
	int planID = aiPlanGetIDByTypeAndVariableType(cPlanCombat, cCombatPlanCombatType, cCombatPlanCombatTypeAttack);
	if (planID >= 0 && aiPlanGetVariableBool(planID, cCombatPlanInCombat, 0) == true)
	{
		aiUnitSetTactic(plazaID, cTacticWarDance);
		return;
	}

	// Recover War Chief.
	if (aiGetFallenExplorerID() >= 0 && kbGetAge() >= cAge3)
	{
		if (cMyCiv == cCivXPIroquois)
			tacticID = cTacticWarChiefDance;
		else if (cMyCiv == cCivXPSioux)
			tacticID = cTacticWarChiefDanceSioux;
		else if (cMyCiv == cCivXPAztec)
			tacticID = cTacticWarChiefDanceAztec;
		else if (cMyCiv == cCivDEInca)
			tacticID = cTacticdeWarChiefDanceInca;

		aiUnitSetTactic(plazaID, tacticID);
		return;
	}

	// Spawn Warrior Priests and Priestesses.
	if (cMyCiv == cCivXPAztec)
	{
		if (kbGetAge() >= cAge2 && kbGetPop() < kbGetPopCap() && 
			kbUnitCount(cMyID, cUnitTypexpMedicineManAztec, cUnitStateAlive) < 10)
		{
			aiUnitSetTactic(plazaID, cTacticHolyDanceAztec);
			return;
		}
	}
	if (cMyCiv == cCivDEInca)
	{
		if (kbGetAge() >= cAge2 && (kbGetPop() < kbGetPopCap()) && 
			kbUnitCount(cMyID, cUnitTypedePriestess, cUnitStateAlive) < 10)
		{
			aiUnitSetTactic(plazaID, cTacticdeHolyDanceInca);
			return;
		}
	}

	if (kbUnitCount(cMyID, gEconUnit, cUnitStateAlive) < 0.95 * aiGetEconomyPop())
	{
		aiUnitSetTactic(plazaID, cTacticFertilityDance);
		return;
	}

	// Dog Soldiers if we have more than 30 military pop room.
	if (cMyCiv == cCivXPSioux && kbGetAge() >= cAge4 &&
		(aiGetAvailableMilitaryPop() >= 30) &&
		(kbGetPopCap() - kbGetPop()) >= 30)
	{
		aiUnitSetTactic(plazaID, cTacticWarDanceSong);
		return;
	}

	// Wood for Inca.
	if (cMyCiv == cCivDEInca && kbGetAge() >= cAge4 &&
		(kbResourceGet(cResourceWood) < 2000 ||
		kbResourceGet(cResourceWood) < totalResources / 9.0))
	{
		aiUnitSetTactic(plazaID, cTacticdeMoonDance);
		return;
	}

	// Default XP Trickle.
	aiUnitSetTactic(plazaID, cTacticGiftDance);
}

//==============================================================================
// Game Over Functinos
//==============================================================================
void gameOverHandler(int nothing = 0)
{
	bool iWon = false;
	if (kbHasPlayerLost(cMyID) == false)
		iWon = true;

	debugCore("Game is over.");
	debugCore("Have I lost returns " + kbHasPlayerLost(cMyID));
	if (iWon == false)
		debugCore("I lost.");
	else
		debugCore("I won.");

	for (pid = 1; < cNumberPlayers)
	{
		//-- Skip ourself.
		if (pid == cMyID)
			continue;

		//-- get player name
		string playerName = kbGetPlayerName(pid);
		debugCore("PlayerName: " + playerName);

		//-- Does a record exist?
		int playerHistoryID = aiPersonalityGetPlayerHistoryIndex(playerName);
		if (playerHistoryID == -1)
		{
			debugCore("PlayerName: Never played against");
			//-- Lets make a new player history.
			playerHistoryID = aiPersonalityCreatePlayerHistory(playerName);
		}


		/* Store the following user vars:
				heBeatMeLastTime
				iBeatHimLastTime
				iCarriedHimLastTime
				heCarriedMeLastTime
				iWonLastGame
		*/
		if (iWon == true)
		{  // I won
			aiPersonalitySetPlayerUserVar(playerHistoryID, "iWonLastGame", 1.0);
			if (kbIsPlayerEnemy(pid) == true)
			{
				aiPersonalitySetPlayerUserVar(playerHistoryID, "iBeatHimLastTime", 1.0);
				aiPersonalitySetPlayerUserVar(playerHistoryID, "heBeatMeLastTime", 0.0);
				debugCore("This player was my enemy.");
			}
		}
		else
		{  // I lost
			aiPersonalitySetPlayerUserVar(playerHistoryID, "iWonLastGame", 0.0);
			if (kbIsPlayerEnemy(pid) == true)
			{
				aiPersonalitySetPlayerUserVar(playerHistoryID, "iBeatHimLastTime", 0.0);
				aiPersonalitySetPlayerUserVar(playerHistoryID, "heBeatMeLastTime", 1.0);
				debugCore("This player was my enemy.");
			}
		}
		if (kbIsPlayerAlly(pid) == true)
		{  // Was my ally
			if (aiGetScore(cMyID) > (2 * aiGetScore(pid)))
			{  // I outscored him badly
				aiPersonalitySetPlayerUserVar(playerHistoryID, "iCarriedHimLastTime", 1.0);
				debugCore("I carried my ally.");
			}
			else
				aiPersonalitySetPlayerUserVar(playerHistoryID, "iCarriedHimLastTime", 0.0);
			if (aiGetScore(pid) > (2 * aiGetScore(cMyID)))
			{  // My ally carried me.
				debugCore("My ally carried me.");
				aiPersonalitySetPlayerUserVar(playerHistoryID, "heCarriedMeLastTime", 1.0);
			}
			else
				aiPersonalitySetPlayerUserVar(playerHistoryID, "heCarriedMeLastTime", 0.0);
		}
		else
		{
			aiPersonalitySetPlayerUserVar(playerHistoryID, "iCarriedHimLastTime", 0.0);
			aiPersonalitySetPlayerUserVar(playerHistoryID, "heCarriedMeLastTime", 0.0);
		}

	}

}

rule ShouldIResign
minInterval 7
active
{
	static bool hadHumanAlly = false;

	if (cvOkToResign == false)
	{
		return;     // Early out if we're not allowed to think about this.
	}

	// Don't resign if you have a human ally that's still in the game
	int i = 0;
	bool humanAlly = false;    // Set true if we have a surviving human ally.
	int humanAllyID = -1;
	bool complained = false;   // Set flag true if I've already whined to my ally.
	bool wasHumanInGame = false;  // Set true if any human players were in the game
	bool isHumanInGame = false;   // Set true if a human survives.  If one existed but none survive, resign.

	// Look for humans
	for (i = 1; <= cNumberPlayers)
	{
		if (kbIsPlayerHuman(i) == true)
		{
			wasHumanInGame = true;
			if (kbHasPlayerLost(i) == false)
				isHumanInGame = true;
		}
		if ((kbIsPlayerAlly(i) == true) && (kbHasPlayerLost(i) == false) && (kbIsPlayerHuman(i) == true))
		{
			humanAlly = true; // Don't return just yet, let's see if we should chat.
			hadHumanAlly = true; // Set flag to indicate that we once had a human ally.
			humanAllyID = i;  // Player ID of lowest-numbered surviving human ally.
		}
	}

		// We do not have to resign when all of our human allies quit, there's still a chance...
	//   if ( (wasHumanInGame == true) && (isHumanInGame == false) )
		/*if ((hadHumanAlly == true) && (humanAlly == false)) // Resign if my human allies have quit.
		{
			//aiResign(); // If there are no humans left, and this wasn't a bot battle from the start, quit.
			debugCore("Resigning because I had a human ally, and he's gone...");
			aiResign(); // I had a human ally or allies, but do not any more.  Our team loses.
			return;  // Probably not necessary, but whatever...
		}
		// Check for MP with human allies gone.  This trumps the OkToResign setting, below.
		if ((aiIsMultiplayer() == true) && (hadHumanAlly == true) && (humanAlly == false))
		{  // In a multiplayer game...we had a human ally earlier, but none remain.  Resign immediately
			debugCore("Resign because my human ally is no longer in the game.");
			aiResign();    // Don't ask, just quit.
			xsEnableRule("resignRetry");
			xsDisableSelf();
			return;
		}*/




		//Don't resign too soon.
		if (xsGetTime() < 600000)     // 600K = 10 min
		  return;

		//Don't resign if we have over 30 active pop slots.
		if (kbGetPop() >= 30)
			return;

		// Resign if the known enemy pop is > 10x mine

		int enemyPopTotal = 0.0;
		int enemyCount = 0;
		int myPopTotal = 0.0;

		for (i = 1; < cNumberPlayers)
		{
			if (kbHasPlayerLost(i) == false)
			{
				if (i == cMyID)
					myPopTotal = myPopTotal + kbUnitCount(i, cUnitTypeUnit, cUnitStateAlive);
				if ((kbIsPlayerEnemy(i) == true) && (kbHasPlayerLost(i) == false))
				{
					enemyPopTotal = enemyPopTotal + kbUnitCount(i, cUnitTypeUnit, cUnitStateAlive);
					enemyCount = enemyCount + 1;
				}
			}
		}

		if (enemyCount < 1)
			enemyCount = 1;      // Avoid div 0

		float enemyRatio = (enemyPopTotal / enemyCount) / myPopTotal;

		if (enemyRatio > 10)       // My pop is 1/10 the average known pop of enemies
		{
			if (humanAlly == false)
			{
				debugCore("Resign at 10:1 pop: EP Total(" + enemyPopTotal + "), MP Total(" + myPopTotal + ")");
				aiAttemptResign(cAICommPromptToEnemyMayIResign);
				xsEnableRule("resignRetry");
				xsDisableSelf();
				return;
			}
			if ((humanAlly == true) && (complained == false))
			{  // Whine to your partner
				sendStatement(humanAllyID, cAICommPromptToAllyImReadyToQuit);
				xsEnableRule("resignRetry");
				xsDisableSelf();
				complained = true;
			}
		}
		if ((enemyRatio > 4) && (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateAlive) < 1))       // My pop is 1/4 the average known pop of enemies, and I have no TC
		{
			if (humanAlly == false)
			{
				debugCore("Resign with no 4:1 pop and no TC: EP Total(" + enemyPopTotal + "), MP Total(" + myPopTotal + ")");
				//sendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignActiveEnemies, -1);
				aiAttemptResign(cAICommPromptToEnemyMayIResign);
				//breakpoint;
				xsEnableRule("resignRetry");
				xsDisableSelf();
				return;
			}
		}
}

rule resignRetry
inactive
minInterval 240
{
	xsEnableRule("ShouldIResign");
	xsDisableSelf();
}

void resignHandler(int result = -1)
{
	debugCore("***************** Resign handler running with result " + result);
	if (result == 0)
	{

		xsEnableRule("resignRetry");
		return;
	}
	debugCore("Resign handler returned " + result);

	aiResign();
	return;
}


//==============================================================================
// Ability Manager
//==============================================================================
rule abilityManager
active
minInterval 12
{
	vector myBaseLocation = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	int closestBaseID = kbFindClosestBase(cPlayerRelationEnemyNotGaia, myBaseLocation);
	vector targetLocation = cInvalidVector;
	// Inspiration
	if (cMyCiv == cCivIndians)
	{
		// Do a cheap check to see if we have any military.
		int unitIDInspiration = getUnit(cUnitTypeLogicalTypeLandMilitary, cMyID, cUnitStateAlive);
		// If we do, check if we're under attack somewhere.
		if ((unitIDInspiration >= 0) && ((gDefenseReflexBaseID == kbBaseGetMainID(cMyID)) || (gDefenseReflexBaseID == gForwardBaseID)))
		{
			int towerOfVictoryType = -1;
			// Check if we have Tower of Victory.
			if (kbUnitCount(cMyID, cUnitTypeypWITowerOfVictory2, cUnitStateAlive) > 0)
			{
				towerOfVictoryType = cUnitTypeypWITowerOfVictory2;
			}
			else if (kbUnitCount(cMyID, cUnitTypeypWITowerOfVictory3, cUnitStateAlive) > 0)
			{
				towerOfVictoryType = cUnitTypeypWITowerOfVictory3;
			}
			else if (kbUnitCount(cMyID, cUnitTypeypWITowerOfVictory4, cUnitStateAlive) > 0)
			{
				towerOfVictoryType = cUnitTypeypWITowerOfVictory4;
			}
			else if (kbUnitCount(cMyID, cUnitTypeypWITowerOfVictory5, cUnitStateAlive) > 0)
			{
				towerOfVictoryType = cUnitTypeypWITowerOfVictory5;
			}
			if ((towerOfVictoryType >= 0) && aiCanUseAbility(getUnit(towerOfVictoryType), cProtoPowerypPowerAttackBlessing))
			{
				aiTaskUnitSpecialPower(getUnit(towerOfVictoryType), cProtoPowerypPowerAttackBlessing, -1, cInvalidVector);
			}
		}
	}
	// Cease Fire
	if (cMyCiv == cCivIndians)
	{
		// Check if we're under attack.
		if (gDefenseReflexBaseID == kbBaseGetMainID(cMyID))
		{
			int tajMahalType = -1;
			// Check if we have Taj Mahal.
			if (kbUnitCount(cMyID, cUnitTypeypWITajMahal2, cUnitStateAlive) > 0)
			{
				tajMahalType = cUnitTypeypWITajMahal2;
			}
			else if (kbUnitCount(cMyID, cUnitTypeypWITajMahal3, cUnitStateAlive) > 0)
			{
				tajMahalType = cUnitTypeypWITajMahal3;
			}
			else if (kbUnitCount(cMyID, cUnitTypeypWITajMahal4, cUnitStateAlive) > 0)
			{
				tajMahalType = cUnitTypeypWITajMahal4;
			}
			else if (kbUnitCount(cMyID, cUnitTypeypWITajMahal5, cUnitStateAlive) > 0)
			{
				tajMahalType = cUnitTypeypWITajMahal5;
			}
			if ((tajMahalType >= 0) && aiCanUseAbility(getUnit(tajMahalType), cProtoPowerypPowerCeaseFire))
			{
				aiTaskUnitSpecialPower(getUnit(tajMahalType), cProtoPowerypPowerCeaseFire, -1, cInvalidVector);
			}
		}
	}
	// Transcendence
	if (cMyCiv == cCivChinese)
	{
		int templeOfHeavenType = -1;
		// Check if we have Temple of Heaven.
		if (kbUnitCount(cMyID, cUnitTypeypWCTempleOfHeaven2, cUnitStateAlive) > 0)
		{
			templeOfHeavenType = cUnitTypeypWCTempleOfHeaven2;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWCTempleOfHeaven3, cUnitStateAlive) > 0)
		{
			templeOfHeavenType = cUnitTypeypWCTempleOfHeaven3;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWCTempleOfHeaven4, cUnitStateAlive) > 0)
		{
			templeOfHeavenType = cUnitTypeypWCTempleOfHeaven4;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWCTempleOfHeaven5, cUnitStateAlive) > 0)
		{
			templeOfHeavenType = cUnitTypeypWCTempleOfHeaven5;
		}
		if ((templeOfHeavenType >= 0) && aiCanUseAbility(getUnit(templeOfHeavenType), cProtoPowerypPowerGoodFortune))
		{	// Check if our land military is missing 20% of their HP or more.
			float armyMaxHP = getPlayerArmyHPs(cMyID, false);
			float armyCurrentHP = getPlayerArmyHPs(cMyID, true);
			float hpRatio = armyCurrentHP / armyMaxHP;
			if (hpRatio < 0.8)
			{
				aiTaskUnitSpecialPower(getUnit(templeOfHeavenType), cProtoPowerypPowerGoodFortune, -1, cInvalidVector);
			}
		}
	}
	// Informers
	if (cMyCiv == cCivJapanese)
	{
		int greatBuddhaType = -1;
		// Check if we have Great Buddha.
		if (kbUnitCount(cMyID, cUnitTypeypWJGiantBuddha2, cUnitStateAlive) > 0)
		{
			greatBuddhaType = cUnitTypeypWJGiantBuddha2;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWJGiantBuddha3, cUnitStateAlive) > 0)
		{
			greatBuddhaType = cUnitTypeypWJGiantBuddha3;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWJGiantBuddha4, cUnitStateAlive) > 0)
		{
			greatBuddhaType = cUnitTypeypWJGiantBuddha4;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWJGiantBuddha5, cUnitStateAlive) > 0)
		{
			greatBuddhaType = cUnitTypeypWJGiantBuddha5;
		}
		if ((greatBuddhaType >= 0) && aiCanUseAbility(getUnit(greatBuddhaType), cProtoPowerypPowerInformers))
		{
			aiTaskUnitSpecialPower(getUnit(greatBuddhaType), cProtoPowerypPowerInformers, -1, cInvalidVector);
		}
	}
	// Spyglass
	if (cMyCiv == cCivPortuguese)
	{
		int explorerIDSpyglass = -1;
		explorerIDSpyglass = getUnit(cUnitTypeExplorer, cMyID, cUnitStateAlive);
		if ((explorerIDSpyglass >= 0) && aiCanUseAbility(explorerIDSpyglass, cProtoPowerPowerLOS))
		{
			if (closestBaseID == -1)
			{  // If not yet visible, search for the enemy on the mirror position of my base.
				targetLocation = guessEnemyLocation();
			}
			if ((targetLocation == cInvalidVector) || (kbLocationVisible(targetLocation) == true) || (closestBaseID != -1))
			{  // Otherwise reveal the closest enemy base for new information.
				targetLocation = kbBaseGetLocation(kbBaseGetOwner(closestBaseID), closestBaseID);
			}
			if (targetLocation != cInvalidVector)
			{
				aiTaskUnitSpecialPower(explorerIDSpyglass, cProtoPowerPowerLOS, -1, targetLocation);
			}
		}
	}
	// Hot Air Balloon
	if (civIsEuropean() == true)
	{
		int explorerIDBalloon = -1;
		explorerIDBalloon = getUnit(cUnitTypeExplorer, cMyID, cUnitStateAlive);
		if ((explorerIDBalloon >= 0) && aiCanUseAbility(explorerIDBalloon, cProtoPowerPowerBalloon))
		{
			if (closestBaseID == -1)
			{  // If not yet visible, search for the enemy on the mirror position of my base.
				targetLocation = guessEnemyLocation();
			}
			if ((targetLocation == cInvalidVector) || (kbLocationVisible(targetLocation) == true) ||(closestBaseID != -1))
			{  // Otherwise reveal the closest enemy base for new information.
				targetLocation = kbBaseGetLocation(kbBaseGetOwner(closestBaseID), closestBaseID);
			}
			if (targetLocation != cInvalidVector)
			{
				aiTaskUnitSpecialPower(explorerIDBalloon, cProtoPowerPowerBalloon, -1, targetLocation);
				int balloonExplore = aiPlanCreate("Balloon Explore", cPlanExplore);
				aiPlanSetDesiredPriority(balloonExplore, 75);
				aiPlanAddUnitType(balloonExplore, cUnitTypeHotAirBalloon, 0, 1, 1);
				aiPlanSetEscrowID(balloonExplore, cEconomyEscrowID);
				aiPlanSetBaseID(balloonExplore, kbBaseGetMainID(cMyID));
				aiPlanSetVariableBool(balloonExplore, cExplorePlanDoLoops, 0, false);
				aiPlanSetActive(balloonExplore);
			}
		}
	}

	/* This upgrade is currently not being researched by the AI thus this logic below is unneeded.
	// Heal
	if ((cMyCiv == cCivXPIroquois) && (kbTechGetStatus(cTechBigFirepitSecretSociety) == cTechStatusActive))
	{
		int warchiefIDHeal = -1;
		warchiefIDHeal = getUnit(cUnitTypexpIroquoisWarChief, cMyID, cUnitStateAlive);
		if ((warchiefIDHeal >= 0) && aiCanUseAbility(warchiefIDHeal, cProtoPowerPowerHeal) == true &&
			(kbUnitGetHealth(warchiefIDHeal) < 0.8))
		{
			vector warchiefLocation = kbUnitGetPosition(warchiefIDHeal);
			aiTaskUnitSpecialPower(warchiefIDHeal, cProtoPowerPowerHeal, -1, warchiefLocation);
		}
	}
	*/
	// Minor native Somali Lighthouse ability.
	if (isMinorNativePresent(cCivSomali) == true)
	{
		if (kbTechGetStatus(cTechDENatSomaliLighthouses) == cTechStatusActive)
		{
			int tradingPostID = checkAliveSuitableTradingPost(cCivSomali);
			if (tradingPostID > -1)
			{ // Must target this ability on itself.
				aiTaskUnitSpecialPower(tradingPostID, cProtoPowerdeNatSomaliLighthouse, tradingPostID, cInvalidVector);
			}
		}
	}
}


//==============================================================================
// Transport Monitor
//==============================================================================
rule transportMonitor
active
minInterval 10
{
	if (gIslandMap == false)
	{
		xsDisableSelf();
		return;
	}
	
	if (aiPlanGetIDByIndex(cPlanTransport, -1, true, 0) >= 0)
		return;
	  
	// find idle units away from our base
	int baseAreaGroupID = kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	int areaGroupID = -1;
	int unitQueryID = createSimpleUnitQuery(cUnitTypeLogicalTypeGarrisonInShips, cMyID, cUnitStateAlive);
	int numberFound = kbUnitQueryExecute(unitQueryID);
	int unitID = -1;
	int planID = -1;
	vector position = cInvalidVector;
	bool transportRequired = false;
	for (i = 0; < numberFound)
	{
		unitID = kbUnitQueryGetResult(unitQueryID, i);
		// avoid transporting island explore scout back to our base
		if (unitID == gIslandExploreTransportScoutID)
			continue;
		position = kbUnitGetPosition(unitID);
		areaGroupID = kbAreaGroupGetIDByPosition(position);         
		if (areaGroupID == baseAreaGroupID)
			continue;
		if (kbAreaGroupGetType(areaGroupID) == cAreaGroupTypeWater)
		{
			// if units are inside a water area(likely on a shore), make sure it does not border our main base area group
			int areaID = kbAreaGetIDByPosition(position);
			int numberBorders = kbAreaGetNumberBorderAreas(areaID);
			bool inMainBase = false;
			for (j = 0; < numberBorders)
			{
				if (kbAreaGroupGetIDByPosition(kbAreaGetCenter(kbAreaGetBorderAreaID(areaID, j))) == baseAreaGroupID)
				{
					inMainBase = true;
					break;
				}
			}
			if (inMainBase == true)
				continue;
		}
		planID = kbUnitGetPlanID(unitID);
		if (planID >= 0 && aiPlanGetDesiredPriority(planID) >= 25)
			continue;
		transportRequired = true;
		debugCore("Tranporting "+kbGetUnitTypeName(kbUnitGetProtoUnitID(unitID))+" and its nearby units back to main base.");
		break;
	}
	
	if (transportRequired == false)
		return;
	
	// once we started transporting, make sure no one can steal units from us
	int transportPlanID = createTransportPlan(position, kbBaseGetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID)), 100);
	
	if (transportPlanID < 0)
		return;
		
	unitQueryID = createSimpleUnitQuery(cUnitTypeLogicalTypeGarrisonInShips, cMyID, cUnitStateAlive, position, 30.0);
	numberFound = kbUnitQueryExecute(unitQueryID);
	aiPlanAddUnitType(transportPlanID, cUnitTypeLogicalTypeGarrisonInShips, numberFound, numberFound, numberFound);
	for (i = 0; < numberFound)
	{
		unitID = kbUnitQueryGetResult(unitQueryID, i);
		if (aiPlanAddUnit(transportPlanID, unitID) == false)
		{
			aiPlanDestroy(transportPlanID);
			return;
		}
	}
	aiPlanSetNoMoreUnits(transportPlanID, true);
}


//==============================================================================
// revoltedHandler()
//==============================================================================
// void revoltedHandler(int techID = -1) {}


//==============================================================================
// Age Up Functions
//==============================================================================
void ageUpHandler(int playerID = -1)
{
	debugCore("ageUpHandler is called, player " + playerID + " aged up!");
	int age = kbGetAgeForPlayer(playerID);
	bool firstToAge = true; // Set true if this player is the first to reach that age, false otherwise
	bool lastToAge = true;  // Set true if this player is the last to reach this age, false otherwise
	int slowestPlayer = -1;
	int lowestAge = 100000;
	int lowestCount = 0; // How many players are still in the lowest age?
	static bool foundFirstInFortress = false;
	static bool foundFirstInIndustrial = false;
	static bool foundFirstInImperial = false;

	if (playerID == cMyID)
		aiPopulatePoliticianList(); // Update the list of possible age-up choices we have now.
	// debugCore("AGE HANDLER:  Player "+playerID+" is now in age "+age);

	for (index = 1; < cNumberPlayers)
	{
		if (index != playerID)
		{
			switch (age)
			{
			case cAge3:
			{
				if (foundFirstInFortress == false)
				{
				foundFirstInFortress = true;
				}
				else
				{
				firstToAge = false;
				}
				break;
			}
			case cAge4:
			{
				if (foundFirstInIndustrial == false)
				{
				foundFirstInIndustrial = true;
				}
				else
				{
				firstToAge = false;
				}
				break;
			}
			case cAge5:
			{
				if (foundFirstInImperial == false)
				{
				foundFirstInImperial = true;
				}
				else
				{
				firstToAge = false;
				}
				break;
			}
			}
			if (kbGetAgeForPlayer(index) < age)
				lastToAge = false; // Someone is still behind playerID.
		}
		if (kbGetAgeForPlayer(index) < lowestAge)
		{
			lowestAge = kbGetAgeForPlayer(index);
			slowestPlayer = index;
			lowestCount = 1;
		}
		else
		{
			if (kbGetAgeForPlayer(index) == lowestAge)
				lowestCount = lowestCount + 1;
		}
	}
	if (firstToAge == true)
	{
		switch (age)
		{
		case cAge3:
		{
			xsArraySetInt(gFirstAgeTime, cAge3, xsGetTime());
			debugCore("Time the first player reached the Fortress Age: " + xsArrayGetInt(gFirstAgeTime, cAge3));
		}
		case cAge4:
		{
			xsArraySetInt(gFirstAgeTime, cAge4, xsGetTime());
			debugCore("Time the first player reached the Industrial Age: " + xsArrayGetInt(gFirstAgeTime, cAge4));
		}
		case cAge5:
		{
			xsArraySetInt(gFirstAgeTime, cAge5, xsGetTime());
			debugCore("Time the first player reached the Imperial Age: " + xsArrayGetInt(gFirstAgeTime, cAge5));
		}
		}
	}

	if ((firstToAge == true) && (age == cAge2))
	{ // This player was first to age 2
		if ((kbIsPlayerAlly(playerID) == true) && (playerID != cMyID))
			sendStatement(playerID, cAICommPromptToAllyHeReachesAge2First);
		if ((kbIsPlayerEnemy(playerID) == true))
			sendStatement(playerID, cAICommPromptToEnemyHeReachesAge2First);
		return ();
	}
	if ((lastToAge == true) && (age == cAge2))
	{ // This player was last to age 2
		if ((kbIsPlayerAlly(playerID) == true) && (playerID != cMyID))
			sendStatement(playerID, cAICommPromptToAllyHeReachesAge2Last);
		if ((kbIsPlayerEnemy(playerID) == true))
			sendStatement(playerID, cAICommPromptToEnemyHeReachesAge2Last);
		return ();
	}

	// Check to see if there is a lone player that is behind everyone else
	if ((lowestCount == 1) && (slowestPlayer != cMyID))
	{
		// This player is slowest, nobody else is still in that age, and it's not me,
		// so set the globals and activate the rule...unless it's already active.
		// This will cause a chat to fire later (currently 120 sec mininterval) if
		// this player is still lagging technologically.
		if (gLateInAgePlayerID < 0)
		{
			if (xsIsRuleEnabled("lateInAge") == false)
			{
				gLateInAgePlayerID = slowestPlayer;
				gLateInAgeAge = lowestAge;
				xsEnableRule("lateInAge");
				return ();
			}
		}
	}

	// Check to see if ally advanced before me
	if ((kbIsPlayerAlly(playerID) == true) && (age > kbGetAgeForPlayer(cMyID)))
	{
		sendStatement(playerID, cAICommPromptToAllyHeAdvancesAhead);
		return ();
	}

	// Check to see if ally advanced before me
	if ((kbIsPlayerEnemy(playerID) == true) && (age > kbGetAgeForPlayer(cMyID)))
	{
		sendStatement(playerID, cAICommPromptToEnemyHeAdvancesAhead);
		return ();
	}
}

void ageUpEventHandler(int planID = -1)
{
	// force an update of resource distribution to prepare for stuffs after aging up
	if (aiGetWorldDifficulty() <= cDifficultyModerate)
		return;
	int state = aiPlanGetState(planID);
	if (state == cPlanStateResearch || state == cPlanStateBuild)
	{
		buildingMonitor();
		econMaster();
	}
	if (state == cPlanStateDone)
		echoMessage("Age up plan done.");

}

rule age2Monitor
inactive
group tcComplete
minInterval 5
{
	if (kbGetAge() >= cAge2)   // We're in age 2
	{
		xsDisableSelf();
		xsEnableRule("age3Monitor");
		if (xsIsRuleEnabled("militaryManager") == false)
		{
			xsEnableRule("militaryManager");
			debugCore("Enabling the military manager.");
			militaryManager();   // runImmediately doesn't work.
		}
		if (xsIsRuleEnabled("navyManager") == false)
		{
			xsEnableRule("navyManager");
			debugCore("Enabling the navy manager.");
		}

		if (gGoodFishingMap == true)
			gFishingBoatMaintainPlan = createSimpleMaintainPlan(gFishingUnit, 10, true, kbBaseGetMainID(cMyID), 1);

		if (cvOkToAttack == true)
		{
			if ((cDifficultyCurrent == cDifficultyEasy) &&
				(gDelayAttacks == true))
			{
				xsEnableRule("delayAttackMonitor"); // Wait until I am attacked or we've reached Age4, then let slip the hounds of war.
			}
			else if (cDifficultyCurrent != cDifficultySandbox) // We never attack on Easy.
			{
				xsEnableRule("mostHatedEnemy"); // Picks a target for us to attack.
				mostHatedEnemy(); // Instantly get a target so our managers have something to work with.
				xsEnableRule("attackManager"); // Land attacking / defending allies.
				if (gNavyMap == true)
				{
					xsEnableRule("waterAttack"); // Water attacking.
				}
			}
		}

		if (gNavyMap == true)
		{
			xsEnableRule("waterDefend");
		}

		if (gIslandMap == true)
		{
			xsEnableRule("transportMonitor");
		}
		xsEnableRule("islandExploreMonitor");

		xsEnableRule("baseDefenseForce");

		setupNativeUpgrades();
		if (getGaiaUnitCount(cUnitTypeSocketCree) > 0)
			xsEnableRule("maintainCreeCoureurs");
		if (getGaiaUnitCount(cUnitTypedeSocketBerbers) > 0)
			xsEnableRule("maintainBerberNomads");

		if (civIsAfrican() == false)
			xsEnableRule("nativeMonitor");
		if (gNumberTradeRoutes > 0)
		{
			xsEnableRule("tradeRouteUpgradeMonitor");
			if (aiGetWorldDifficulty() >= cDifficultyEasy)
				xsEnableRule("tradeRouteTacticMonitor");
		}

		 // Don't activate the big button monitors on easy(sandbox) since we won't have enough Villagers to pass the initial check.
		if (cMyCiv == cCivXPAztec && cDifficultyCurrent >= cDifficultyEasy)
			xsEnableRule("bigButtonAztecMonitor");

		if (cMyCiv == cCivXPSioux && cDifficultyCurrent >= cDifficultyEasy)
			xsEnableRule("bigButtonLakotaMonitor");

		if (cMyCiv == cCivXPIroquois && cDifficultyCurrent >= cDifficultyEasy)
			xsEnableRule("bigButtonHaudenosauneeMonitor");

		if (cMyCiv == cCivDESwedish)
		{
			xsEnableRule("arsenalUpgradeMonitor");
			xsEnableRule("advancedArsenalUpgradeMonitor");
		}

		if (civIsEuropean() == true)
			xsEnableRule("useLevy");
		else if (civIsNative() == true)
		{
			if (cMyCiv != cCivXPSioux)
				xsEnableRule("useWarParties");
			else
				xsEnableRule("useWarPartiesLakota");
		}
		else if (civIsAsian() == true)
		{
			xsEnableRule("useAsianLevy");
			xsEnableRule("consulateMonitor");
		}
		else
		{
			xsEnableRule("useAfricanLevy");
			if (cMyCiv == cCivDEHausa)
				xsEnableRule("useLevy"); // Songhai Raid Logic moved to this function.
		}

		// Enable Golden Pavilion upgrades for Japanese (these are part of the advanced Arsenal rule).
		if (cMyCiv == cCivJapanese && kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion2, cUnitStateAlive) > 0)
			xsEnableRule("advancedArsenalUpgradeMonitor");

		// Enable training units and researching techs with influence resource.
		if (civIsAfrican() == true)
			xsEnableRule("influenceManager");

		findEnemyBase();  // Create a one-off explore plan to probe the likely enemy base location.
		// updateResourceDistribution();
		//kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 80.0);

		gAgeUpTime = xsGetTime();

		kbEscrowAllocateCurrentResources();

		//-- Set the resource TargetSelector factors.
		gTSFactorDistance = -40.0;
		gTSFactorPoint = 5.0;
		gTSFactorTimeToDone = 0.0;
		gTSFactorBase = 100.0;
		gTSFactorDanger = -40.0;
		kbSetTargetSelectorFactor(cTSFactorDistance, gTSFactorDistance);
		kbSetTargetSelectorFactor(cTSFactorPoint, gTSFactorPoint);
		kbSetTargetSelectorFactor(cTSFactorTimeToDone, gTSFactorTimeToDone);
		kbSetTargetSelectorFactor(cTSFactorBase, gTSFactorBase);
		kbSetTargetSelectorFactor(cTSFactorDanger, gTSFactorDanger);

		setUnitPickerPreference(gLandUnitPicker);

		if (gLastAttackMissionTime < 0)
			gLastAttackMissionTime = xsGetTime() - 180000; // Pretend they all fired 3 minutes ago, even if that's a negative number.
		if (gLastDefendMissionTime < 0)
			gLastDefendMissionTime = xsGetTime() - 300000; // Actually, start defense ratings at 100% charge, i.e. 5 minutes since last one.

		debugCore("*** We're in age 2.");
	}
}

rule age3Monitor
inactive
minInterval 10
{
	if (kbGetAge() >= cAge3)
	{
		debugCore("*** We're in age 3.");

		xsDisableSelf();
		xsEnableRule("age4Monitor");
		gAgeUpTime = xsGetTime();

		//kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 80.0);

		// Increase number of towers to be built (even rushers start building now)
		if (civIsAsian() == false)
		{
			gNumTowers = gNumTowers + 3;
			if (gNumTowers > 7)
				gNumTowers = 7;
		}
		else
		{
			gNumTowers = gNumTowers + 2;
			if (gNumTowers > 5)
				gNumTowers = 5;
		}

		if (cMyCiv == cCivDEInca)
		{
			xsEnableRule("strongholdConstructionMonitor");
			xsEnableRule("strongholdUpgradeMonitor");
			if (cDifficultyCurrent >= cDifficultyEasy)
			{
				xsEnableRule("bigButtonIncaMonitor");
			}
		}

		// Enable arsenal upgrades
		if (civIsEuropean() == true || cMyCiv == cCivJapanese)
			xsEnableRule("arsenalUpgradeMonitor");

		// Enable agra fort upgrades for Indians
		if (cMyCiv == cCivIndians)
		  xsEnableRule("agraFortUpgradeMonitor");

		// Enable summer palace tactic monitor for Chinese
		if (cMyCiv == cCivChinese)
		  xsEnableRule("summerPalaceTacticMonitor");

		// Enable dojo tactic monitor for Japanese
		if (cMyCiv == cCivJapanese)
			xsEnableRule("dojoTacticMonitor");	  

		if (cMyCiv == cCivJapanese && kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion3, cUnitStateAlive) > 0)
			xsEnableRule("advancedArsenalUpgradeMonitor");

		// Enable the baseline Church (Cathedral) upgrade monitor.
		if (cMyCiv == cCivDEMexicans)
		{
			xsEnableRule("churchUpgradeMonitor");
		}

		// Enable unique church upgrades
		if (civIsEuropean() == true)
			xsEnableRule("royalDecreeMonitor");

		// Enable monastery techs
		xsEnableRule("monasteryMonitor");

		// Enable navy upgrades
		xsEnableRule("navyUpgradeMonitor");
		
		// Enable mansabdar maintain plans for Indians
		if (cMyCiv == cCivIndians)
			xsEnableRule("mansabdarMonitor");
			
		// prefer plantation over trading lodge
		if (cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux)
			gPlantationUnit = cUnitTypePlantation;

		// Switch from war hut to nobles hut.
		if (cMyCiv == cCivXPAztec)
			gTowerUnit = cUnitTypeNoblesHut;

		if (civIsAfrican())
			xsEnableRule("maintainLivestockAfricans");
	}
}

rule age4Monitor
inactive
minInterval 10
{
	if (kbGetAge() >= cAge4)
	{
		debugCore("*** We're in age 4.");

		xsDisableSelf();
		xsEnableRule("age5Monitor");
		gAgeUpTime = xsGetTime();

		//kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 80.0);

		// Increase number of towers to be built (even rushers build as many as possible late in the game)
		if (civIsAsian() == false)
		{
			gNumTowers = gNumTowers + 4;
			if (gNumTowers > 7)
				gNumTowers = 7;
		}
		else
		{
			gNumTowers = gNumTowers + 3;
			if (gNumTowers > 5)
				gNumTowers = 5;
		}

		// Enable the baseline Church upgrade monitor.
		if ((civIsEuropean() == true) && (cMyCiv != cCivDEMexicans))
		{
			xsEnableRule("churchUpgradeMonitor");
		}

		if (cMyCiv == cCivDEInca)
		{
			xsEnableRule("tamboUpgradeMonitor");
		}

		// Enable sacred field handling for Indians
		if (cMyCiv == cCivIndians)
			xsEnableRule("sacredFieldMonitor");

		if (cMyCiv == cCivJapanese && kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion4, cUnitStateAlive) > 0)
			xsEnableRule("advancedArsenalUpgradeMonitor");

		// Enable dojo upgrade for Japanese
		if (cMyCiv == cCivJapanese)
			xsEnableRule("dojoUpgradeMonitor");

		if (aiGetWorldDifficulty() >= cDifficultyModerate)
		{  // Don't max out on upgrades on lower difficulty levels.

			// Enable shrine upgrade for Japanese
			if (cMyCiv == cCivJapanese)
				xsEnableRule("shrineUpgradeMonitor");

			if (aiGetWorldDifficulty() >= cDifficultyModerate)
			{
				// Enable fort upgrade
				xsEnableRule("fortUpgradeMonitor");
			}
		}
	}
}

rule age5Monitor
inactive
minInterval 10
{
	if (kbGetAge() >= cAge5)
	{
		debugCore("*** We're in age 5.");
		// Bump up settler train plan

		xsDisableSelf();
		gAgeUpTime = xsGetTime();

		if (cMyCiv == cCivJapanese && kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion5, cUnitStateAlive) > 0)
			xsEnableRule("advancedArsenalUpgradeMonitor");
	}
}

//==============================================================================
// regicideMonitor
//==============================================================================
rule regicideMonitor
inactive
minInterval 10
{
	//if the castle is up, put the guy in it

	if (kbUnitCount(cMyID, cUnitTypeypCastleRegicide, cUnitStateAlive) > 0)
	{
		//gotta find the castle
		static int castleQueryID = -1;
		//If we don't have the query yet, create one.
		if (castleQueryID < 0)
		{
			castleQueryID = kbUnitQueryCreate("castleGetUnitQuery");
			kbUnitQuerySetIgnoreKnockedOutUnits(castleQueryID, true);
		}
		//Define a query to get all matching units
		if (castleQueryID != -1)
		{
			kbUnitQuerySetPlayerRelation(castleQueryID, -1);
			kbUnitQuerySetPlayerID(castleQueryID, cMyID);
			kbUnitQuerySetUnitType(castleQueryID, cUnitTypeypCastleRegicide);
			kbUnitQuerySetState(castleQueryID, cUnitStateAlive);
		}
		else
		{
			return;
		}

		//gotta find the regent
		static int regentQueryID = -1;
		//If we don't have the query yet, create one.
		if (regentQueryID < 0)
		{
			regentQueryID = kbUnitQueryCreate("regentGetUnitQuery");
			kbUnitQuerySetIgnoreKnockedOutUnits(regentQueryID, true);
		}
		//Define a query to get all matching units
		if (regentQueryID != -1)
		{
			kbUnitQuerySetPlayerRelation(regentQueryID, -1);
			kbUnitQuerySetPlayerID(regentQueryID, cMyID);
			kbUnitQuerySetUnitType(regentQueryID, cUnitTypeypDaimyoRegicide);
			kbUnitQuerySetState(regentQueryID, cUnitStateAlive);
		}
		else
		{
			return;
		}


		kbUnitQueryResetResults(castleQueryID);
		kbUnitQueryResetResults(regentQueryID);

		kbUnitQueryExecute(castleQueryID);
		kbUnitQueryExecute(regentQueryID);

		int index = 0;

		aiTaskUnitWork(kbUnitQueryGetResult(regentQueryID, index), kbUnitQueryGetResult(castleQueryID, index));
	}
	else
	{
		xsDisableSelf();
	}
}

//==============================================================================
// selfAgeUpHandler
//==============================================================================
void selfAgeUpHandler(int age = -1)
{
	// if (age >= cAge3)
	// 	gHomeBase = gHomeBase + gDirection_UP * 5.0; // Move our base up a bit.

	wagonMonitor();

	if (cMyCiv == cCivRussians)
	{
		if (age == cAge3)
			arrayPushInt(gPriorityCards, cTechHCRoyalDecreeRussian);
	}

	if (cMyCiv == cCivDEAmericans || cMyCiv == cCivDEMexicans)
		updateFederalCardIndices();

	if (civIsAfrican() == true)
	{
		if (xsIsRuleEnabled("granaryBuildPlanMonitor") == false)
		{
			xsEnableRule("granaryBuildPlanMonitor");
			granaryBuildPlanMonitor();
		}
		if (xsIsRuleEnabled("allegianceUpgradeMonitor") == false)
		{
			xsEnableRule("allegianceUpgradeMonitor");
			allegianceUpgradeMonitor();
		}
	}
}

//==============================================================================
// buildingConstructedHandler
//
// Called when a building finishes constructing.
// Listed in aiCore.xs since it includes several rules that need to be compiled
// from the included before they can be called.
//==============================================================================
void buildingConstructedHandler(int buildingPUID = -1)
{
	switch (buildingPUID)
	{
		case gMarketUnit:
		{
			if (xsIsRuleEnabled("marketUpgradeMonitor") == false)
			{
				xsEnableRule("marketUpgradeMonitor");
				marketUpgradeMonitor(); // Call it instantly.
			}
			if (civIsAfrican() && xsGetTime() < 60 * 1000) // beginning of the game only
			{
				if (kbUnitCount(cMyID, cUnitTypedeLivestockMarket, cUnitStateAlive) >= 1)
				{
					int cattleQuery = createSimpleUnitQuery(cUnitTypeHerdable);
					int cattleID = -1;
					int marketID = getUnit(cUnitTypedeLivestockMarket);
					int num = kbUnitQueryExecute(cattleQuery);
					for (i = 0; < num)
					{
						cattleID = kbUnitQueryGetResult(cattleQuery, i);
						aiTaskUnitWork(cattleID, marketID);
					}
				}
				// Only enable, but do not call instantly so the rates appreciate a bit first.
				xsEnableRule("livestockMarketSellMonitor");
			}
			break;
		}
		case cUnitTypeFactory:
		{
			factoryTacticMonitor();
			break;
		}
		case cUnitTypedeGranary:
		{
			if (xsIsRuleEnabled("granaryUpgradeMonitor") == false)
			{
				xsEnableRule("granaryUpgradeMonitor");
				granaryUpgradeMonitor(); // Call it instantly.
			}
			break;
		}
		case gFarmUnit:
		{
			if (civIsAfrican() == false)
			{	// Africans have the Granary.
				if (xsIsRuleEnabled("millTypeUpgradeMonitor") == false)
				{
					xsEnableRule("millTypeUpgradeMonitor");
					millTypeUpgradeMonitor(); // Call it instantly.
				}
			}
			break;
		}
		case gPlantationUnit:
		{
			if (civIsAsian() == false && civIsAfrican() == false && cMyCiv != cCivDEMexicans)
			{	// Asians and Mexicans just use the prior rule since their buildings are the same.
				// Africans research via the Granary.
				if (xsIsRuleEnabled("millTypeUpgradeMonitor") == false)
				{
					xsEnableRule("plantationTypeUpgradeMonitor");
					plantationTypeUpgradeMonitor(); // Call it instantly.
				}
			}
			break;
		}
		case cUnitTypeChurch:
		{
			if (cMyCiv == cCivOttomans)
			{
				if (xsIsRuleEnabled("mosqueUpgradeMonitor") == false)
				{
					xsEnableRule("mosqueUpgradeMonitor");
					mosqueUpgradeMonitor();
				}
			}
			break;
		}
		case cUnitTypeCommunityPlaza:
		{
			if (xsIsRuleEnabled("plazaMonitor") == false)
			{
				xsEnableRule("plazaMonitor");
				plazaMonitor();
			}
			break;
		}
		case cUnitTypeypConsulate:
		{
			// We want cheap buildings right off the bat.
			if (cMyCiv == cCivJapanese && kbGetAge() == cAge1)
				aiPlanSetDesiredResourcePriority(createResearchPlan(cTechypBigConsulatePortuguese, -1, 99, getUnit(cUnitTypeypConsulate)), 99);
			break;
		}
		// Japanese Wonders
		case cUnitTypeypWJGiantBuddha2:
		case cUnitTypeypWJGiantBuddha3:
		case cUnitTypeypWJGiantBuddha4:
		case cUnitTypeypWJGiantBuddha5:
		{
			gGreatBuddhaPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gGreatBuddhaPUID));
			break;
		}
		case cUnitTypeypWJGoldenPavillion2:
		case cUnitTypeypWJGoldenPavillion3:
		case cUnitTypeypWJGoldenPavillion4:
		case cUnitTypeypWJGoldenPavillion5:
		{
			gGoldenPavilionPUID = buildingPUID;
			// The default tactic of the Golden Pavilion is good otherwise (ranged damage).
			if (cDifficultyCurrent < gDifficultyExpert)
			{
				int goldenPavilionID = getUnit(gGoldenPavilionPUID, cMyID, cUnitStateAlive);
				// It's nearly impossible that this fails of course.
				if (goldenPavilionID >= 0)
				{
					aiUnitSetTactic(goldenPavilionID, cTacticUnitHitpoints);
				}
			}
			xsEnableRule("advancedArsenalUpgradeMonitor");
			advancedArsenalUpgradeMonitor();
			debugCore("Wonder I built: " + kbGetProtoUnitName(gGoldenPavilionPUID));
			break;
		}
		case cUnitTypeypWJShogunate2:
		case cUnitTypeypWJShogunate3:
		case cUnitTypeypWJShogunate4:
		case cUnitTypeypWJShogunate5:
		{
			gTheShogunatePUID = buildingPUID;
			xsEnableRule("daimyoMonitor");
			daimyoMonitor();
			debugCore("Wonder I built: " + kbGetProtoUnitName(gTheShogunatePUID));
			break;
		}
		case cUnitTypeypWJToriiGates2:
		case cUnitTypeypWJToriiGates3:
		case cUnitTypeypWJToriiGates4:
		case cUnitTypeypWJToriiGates5:
		{
			gToriiGatesPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gToriiGatesPUID));
			break;
		}
		case cUnitTypeypWJToshoguShrine2:
		case cUnitTypeypWJToshoguShrine3:
		case cUnitTypeypWJToshoguShrine4:
		case cUnitTypeypWJToshoguShrine5:
		{
			gToshoguShrinePUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gToshoguShrinePUID));
			break;
		}
		// Chinese Wonders
		case cUnitTypeypWCWhitePagoda2:
		case cUnitTypeypWCWhitePagoda3:
		case cUnitTypeypWCWhitePagoda4:
		case cUnitTypeypWCWhitePagoda5:
		{
			gWhitePagodaPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gWhitePagodaPUID));
			break;
		}
		case cUnitTypeypWCSummerPalace2:
		case cUnitTypeypWCSummerPalace3:
		case cUnitTypeypWCSummerPalace4:
		case cUnitTypeypWCSummerPalace5:
		{
			gSummerPalacePUID = buildingPUID;
			xsEnableRule("summerPalaceTacticMonitor");
			summerPalaceTacticMonitor();
			debugCore("Wonder I built: " + kbGetProtoUnitName(gSummerPalacePUID));
			break;
		}
		case cUnitTypeypWCConfucianAcademy2:
		case cUnitTypeypWCConfucianAcademy3:
		case cUnitTypeypWCConfucianAcademy4:
		case cUnitTypeypWCConfucianAcademy5:
		{
			gConfucianAcademyPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gConfucianAcademyPUID));
			break;
		}
		case cUnitTypeypWCTempleOfHeaven2:
		case cUnitTypeypWCTempleOfHeaven3:
		case cUnitTypeypWCTempleOfHeaven4:
		case cUnitTypeypWCTempleOfHeaven5:
		{
			gTempleOfHeavenPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gTempleOfHeavenPUID));
			break;
		}
		case cUnitTypeypWCPorcelainTower2:
		case cUnitTypeypWCPorcelainTower3:
		case cUnitTypeypWCPorcelainTower4:
		case cUnitTypeypWCPorcelainTower5:
		{
			gPorcelainTowerPUID = buildingPUID;
			xsEnableRule("porcelainTowerTacticMonitor");
			porcelainTowerTacticMonitor();
			debugCore("Wonder I built: " + kbGetProtoUnitName(gPorcelainTowerPUID));
			break;
		}
		// Indian Wonders
		case cUnitTypeypWIAgraFort2:
		case cUnitTypeypWIAgraFort3:
		case cUnitTypeypWIAgraFort4:
		case cUnitTypeypWIAgraFort5:
		{
			gAgraFortPUID = buildingPUID;
			xsEnableRule("agraFortUpgradeMonitor");
			agraFortUpgradeMonitor();
			debugCore("Wonder I built: " + kbGetProtoUnitName(gAgraFortPUID));
			break;
		}
		case cUnitTypeypWICharminarGate2:
		case cUnitTypeypWICharminarGate3:
		case cUnitTypeypWICharminarGate4:
		case cUnitTypeypWICharminarGate5:
		{
			gCharminarGatePUID = buildingPUID;
			xsEnableRule("mansabdarMonitor");
			mansabdarMonitor();
			debugCore("Wonder I built: " + kbGetProtoUnitName(gCharminarGatePUID));
			break;
		}
		case cUnitTypeypWIKarniMata2:
		case cUnitTypeypWIKarniMata3:
		case cUnitTypeypWIKarniMata4:
		case cUnitTypeypWIKarniMata5:
		{
			gKarniMataPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gKarniMataPUID));
			break;
		}
		case cUnitTypeypWITajMahal2:
		case cUnitTypeypWITajMahal3:
		case cUnitTypeypWITajMahal4:
		case cUnitTypeypWITajMahal5:
		{
			gTajMahalPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gTajMahalPUID));
			break;
		}
		case cUnitTypeypWITowerOfVictory2:
		case cUnitTypeypWITowerOfVictory3:
		case cUnitTypeypWITowerOfVictory4:
		case cUnitTypeypWITowerOfVictory5:
		{
			gTowerOfVictoryPUID = buildingPUID;
			debugCore("Wonder I built: " + kbGetProtoUnitName(gTowerOfVictoryPUID));
			break;
		}
	}
}

rule testActions
inactive
minInterval 10
{
	if (cMyID != 2)
	{
		xsDisableSelf();
		return;
	}
	int testQuery = createSimpleUnitQuery(cUnitTypeHuntable, 0, cUnitStateAny, kbGetPlayerStartingPosition(1), 30.0);
	kbUnitQueryResetResults(testQuery);
	int num = kbUnitQueryExecute(testQuery);
	int unitID = -1;
	int actionID = -1;
	int temp = -1;
	// echoMessage("Data before changing context to 0.");
	for (i = 0; < num)
	{
		unitID = kbUnitQueryGetResult(testQuery, i);
		echoMessage("Huntable: " + i);
		echoMessage("       kbUnitGetActionTypeByIndex(unitID, 0): " + kbUnitGetActionTypeByIndex(unitID, 0));
		temp = kbUnitGetTargetUnitID(unitID);
		echoMessage("       Target unit ID: " + temp);
		echoMessage("       Target unit ID Name: " + kbGetUnitTypeName(kbUnitGetProtoUnitID(temp)));
		echoMessage("       kbUnitIsType(unitID, cUnitTypedeGranary): " + kbUnitIsType(temp, cUnitTypedeGranary));
		echoMessage("SWITCH to player context 0.");
		xsSetContextPlayer(0);
		temp = kbUnitGetTargetUnitID(unitID);
		xsSetContextPlayer(cMyID);
		echoMessage("       Target unit ID: " + temp);
		echoMessage("       Target unit ID Name: " + kbGetUnitTypeName(kbUnitGetProtoUnitID(temp)));
		echoMessage("       kbUnitIsType(unitID, cUnitTypedeGranary): " + kbUnitIsType(temp, cUnitTypedeGranary));
		echoMessage("DONE WITH HUNTABLE " + i);
		echoMessage("       ");


	}

	/* echoMessage("Data after changing context to 0.");
	for (i = 0; < num)
	{
		unitID = kbUnitQueryGetResult(testQuery, i);

		echoMessage("Unit: " + unitID);
		xsSetContextPlayer(0);
		type = kbUnitGetActionID(unitID);
		loc = kbUnitGetPosition(unitID);
		xsSetContextPlayer(cMyID);
		echoMessage("       Action type is: " + type);
		echoMessage("       Location is: " + loc);
		echoMessage("       ");
	} */

}