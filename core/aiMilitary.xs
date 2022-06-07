//==============================================================================
/* aiMilitary.xs

	This file is intended for any military related stuffs, not limited to army
	training, researching upgrades and combat handling.

*/
//==============================================================================

//==============================================================================
// mostHatedEnemy
// Determine who we should attack, checking cvPlayerToAttack too
//==============================================================================
rule mostHatedEnemy
minInterval 60
inactive
{
	if (cvPlayerToAttack > 0)
	{
		debugMilitary("**** cv Changing most hated Player from " + aiGetMostHatedPlayerID() + " to " + cvPlayerToAttack);
		aiSetMostHatedPlayerID(cvPlayerToAttack);
		if (gLandUnitPicker >= 0)
		{
			kbUnitPickSetEnemyPlayerID(gLandUnitPicker, cvPlayerToAttack); // Update the unit picker.
		}
		xsDisableSelf(); // Most likely the cvPlayerToAttack will not be changed in the middle of the game so don't check again.
		return;
	}

	static bool treatyTargetingPerformed = false;
	int arrayIndex = 0;
	int arrayIndexOfSelectedEnemy = 0;
	gNumEnemies = 0;
	bool isTreatyActive = aiTreatyActive();
	
	if (isTreatyActive == true && treatyTargetingPerformed == false) // We only perform the targeting once during treaty.
	{
		// Add IDs of enemies to the array.
		for (i = 1; < cNumberPlayers)
		{
			if (kbGetPlayerTeam(i) != kbGetPlayerTeam(cMyID)) // Not on our team so must be an enemy.
			{
				if (kbHasPlayerLost(i) == false)
				{
					xsArraySetInt(gArrayEnemyPlayerIDs, arrayIndex, i);
					arrayIndex = arrayIndex +1;
					gNumEnemies = gNumEnemies + 1;
				}
			}
		}
		if (kbGetIsFFA()) // We pick a target that is adjacent to us in FFA.
		{
			if(gNumEnemies >= 3) // We only need to sort when we have more than 2 enemies, because if we only have 2 enemies we just chose either one anyway regardless of distance.
			{
				arraySortInt(gArrayEnemyPlayerIDs, 0, gNumEnemies, [](int playerA = 1, int playerB = 2) -> bool
				{
					return(xsArrayGetFloat(gStartingPosDistances, playerA) < xsArrayGetFloat(gStartingPosDistances, playerB));
				});
			}
			arrayIndexOfSelectedEnemy = gNumEnemies >= 2 ? aiRandInt(2) : 0;
		}
		else
		{
			arrayIndexOfSelectedEnemy = aiRandInt(gNumEnemies);
		}
		
		aiSetMostHatedPlayerID(xsArrayGetInt(gArrayEnemyPlayerIDs, arrayIndexOfSelectedEnemy));
		debugMilitary("*** Treaty targeting randomly selected Player " + xsArrayGetInt(gArrayEnemyPlayerIDs, arrayIndexOfSelectedEnemy) + " to be our most hated player");

		if (gLandUnitPicker >= 0)
		{
			kbUnitPickSetEnemyPlayerID(gLandUnitPicker, xsArrayGetInt(gArrayEnemyPlayerIDs, arrayIndexOfSelectedEnemy)); // Update the unit picker.
		}
		
		treatyTargetingPerformed = true;
		return;
	}
	
	if (isTreatyActive == false)
	{
		// Add IDs of enemies who are still alive to the array.
		for (i = 1; < cNumberPlayers)
		{
			if (kbIsPlayerEnemy(i)) 
			{
				if (kbHasPlayerLost(i) == false)
				{
					xsArraySetInt(gArrayEnemyPlayerIDs, arrayIndex, i);
					arrayIndex = arrayIndex +1;
					gNumEnemies = gNumEnemies + 1;
				}
			}
		}

		if (kbGetIsFFA()) // We pick a target that is adjacent to us in FFA.
		{
			if(gNumEnemies >= 3) // We only need to sort when we have more than 2 enemies, because if we only have 2 enemies we just chose either one anyway regardless of distance.
			{
				arraySortInt(gArrayEnemyPlayerIDs, 0, gNumEnemies, [](int playerA = 1, int playerB = 2) -> bool
				{
					return(xsArrayGetFloat(gStartingPosDistances, playerA) < xsArrayGetFloat(gStartingPosDistances, playerB));
				});
			}
			arrayIndexOfSelectedEnemy = gNumEnemies >= 2 ? aiRandInt(2) : 0;
		}
		else
		{
			arrayIndexOfSelectedEnemy = aiRandInt(gNumEnemies);
		}

		aiSetMostHatedPlayerID(xsArrayGetInt(gArrayEnemyPlayerIDs, arrayIndexOfSelectedEnemy));
		debugMilitary("*** Randomly selected Player " + xsArrayGetInt(gArrayEnemyPlayerIDs, arrayIndexOfSelectedEnemy) + " to be our most hated player");
		
		if (gLandUnitPicker >= 0)
		{
			kbUnitPickSetEnemyPlayerID(gLandUnitPicker, xsArrayGetInt(gArrayEnemyPlayerIDs, arrayIndexOfSelectedEnemy)); // Update the unit picker.
		}
	}
}

//==============================================================================
// addUnitsToMilitaryPlan
//==============================================================================
void addUnitsToMilitaryPlan(int planID = -1)
{
	//int numberLandMilitaryUnits = aiPlanGetNumberUnits(gLandReservePlan, cUnitTypeLogicalTypeLandMilitary);

	// TODO: don't always task the full army, leave some behind if the enemy is weak or we need more defense   
	if ((gRevolutionType & cRevolutionFinland) == 0)
	{
		aiPlanAddUnitType(planID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 200);
		aiPlanAddUnitType(planID, cUnitTypeMinuteman, 0, 0, 0, true, true);
		aiPlanAddUnitType(planID, cUnitTypeypIrregular, 0, 0, 0, true, true);
		aiPlanAddUnitType(planID, cUnitTypeypPeasant, 0, 0, 0, true, true);
		aiPlanAddUnitType(planID, cUnitTypexpWarrior, 0, 0, 0, true, true);
		aiPlanAddUnitType(planID, cUnitTypedeSpearmanLevy, 0, 0, 0, true, true);
		aiPlanAddUnitType(planID, cUnitTypedeBowmanLevy, 0, 0, 0, true, true);
		aiPlanAddUnitType(planID, cUnitTypedeGunnerLevy, 0, 0, 0, true, true);
		return;
	}

	// For the finland revolution, keep some karelian jaegers around to sustain the economy
	int numberAvailableEconUnits = 0;
	int queryID = createSimpleUnitQuery(cUnitTypeLogicalTypeLandMilitary, cMyID, cUnitStateAlive);
	int numberFound = kbUnitQueryExecute(queryID);

	aiPlanAddUnitType(planID, cUnitTypeLogicalTypeLandMilitary, 0, 0, 0);

	// Add each unit type individually
	for (i = 0; < numberFound)
	{
		int unitID = kbUnitQueryGetResult(queryID, i);
		int puid = kbUnitGetProtoUnitID(unitID);
		if (puid == gEconUnit)
		{
			int unitPlanType = aiPlanGetType(kbUnitGetPlanID(unitID));
			if (unitPlanType == cPlanGather || unitPlanType == cPlanBuild)
				numberAvailableEconUnits = numberAvailableEconUnits + 1;
			continue;
		}
		aiPlanAddUnitType(planID, puid, 0, 0, 200);
	}

	// Keep at least 30 karelian jaegers around or the equivalent wood amount
	float numberEconUnits = (0.0 - xsArrayGetFloat(gResourceNeeds, cResourceWood) - 3000.0) / 100.0;
	if (numberEconUnits < 0.0)
	{
		numberEconUnits = numberAvailableEconUnits + numberEconUnits;
		if (numberEconUnits < 0.0)
			numberEconUnits = 0.0;
	}
	else
	{
		numberEconUnits = numberAvailableEconUnits;
	}
	aiPlanAddUnitType(planID, gEconUnit, 0, numberEconUnits, numberEconUnits);
}


//==============================================================================
// updateMilitaryTrainPlanBuildings
//==============================================================================
// void updateMilitaryTrainPlanBuildings(int baseID = -1) {} TODO (James)


//==============================================================================
/*
	Military Manager

	Create maintain plans for military unit lines.  Control 'maintain' levels,
	buy upgrades.
*/
//==============================================================================
rule militaryManager
inactive
minInterval 28
{
	static bool firstRun = false; // Flag to indicate vars, plans are initialized
	static int unitsNotMaintained = -1;
	static int unitsNotMaintainedValue = -1;
	static int unitsNotMaintainedUpgrade = -1;
	if (firstRun == false)
	{
		// Need to initialize, if we're allowed to.
		firstRun = true;
		if (cvNumArmyUnitTypes >= 0)
			gNumArmyUnitTypes = cvNumArmyUnitTypes;
		else
			gNumArmyUnitTypes = 3;
		gLandUnitPicker = initUnitPicker("Land military units", gNumArmyUnitTypes, 1, 30, -1, -1, 1, true);
			aiSetMinArmySize(10);
			unitsNotMaintained = xsArrayCreateInt(3, -1, "Units not maintained");
			unitsNotMaintainedValue = xsArrayCreateFloat(3, -1, "Units not maintained value");
			unitsNotMaintainedUpgrade = xsArrayCreateInt(3, -1, "Units not maintained upgrade");
	}

	if (gLandUnitPicker != -1)
	{
		int age = getAgingUpAge();
		int targetPlayer = aiGetMostHatedPlayerID();

		setUnitPickerPreference(gLandUnitPicker);

		kbUnitPickSetMinimumPop(gLandUnitPicker, 1);
		kbUnitPickSetMaximumPop(gLandUnitPicker, aiGetMilitaryPop());

		if (cvNumArmyUnitTypes < 0)
		{
			if (age < cAge3)
				gNumArmyUnitTypes = 2;
			else
				gNumArmyUnitTypes = 3;
			kbUnitPickSetDesiredNumberUnitTypes(gLandUnitPicker, gNumArmyUnitTypes, 1, true);
		}
		setUnitPickerCommon(gLandUnitPicker);
		kbUnitPickRun(gLandUnitPicker, age);

		int numMilitaryBuildings = xsArrayGetSize(gMilitaryBuildings);
		int planID = -1;
		int upgradePlanID = -1;
		float totalFactor = 0.0;
		int baseID = kbBaseGetMainID(cMyID);
		vector gatherPoint = kbBaseGetMilitaryGatherPoint(cMyID, baseID);
		int puid = -1;
		int buildingPUID = -1;
		int trainBuildingPUID = -1;
		int numberToMaintain = 0;
		int popCount = 0;
		int upgradeTechID = -1;
		float totalValue = 0.0;

		for (i = 0; < gNumArmyUnitTypes)
			totalFactor = totalFactor + kbUnitPickGetResultFactor(gLandUnitPicker, i);

		for (i = 0; < gNumArmyUnitTypes)
		{
			puid = kbUnitPickGetResult(gLandUnitPicker, i);
			trainBuildingPUID = -1;
			numberToMaintain = 0;
			popCount = kbGetProtoUnitPopCount(puid);

			// update maintain plan.
			planID = xsArrayGetInt(gArmyUnitMaintainPlans, i);
			if (planID >= 0 && puid != aiPlanGetVariableInt(planID, cTrainPlanUnitType, 0))
			{
				int otherPlanID = -1;

				for (j = i + 1; < gNumArmyUnitTypes)
				{
					otherPlanID = xsArrayGetInt(gArmyUnitMaintainPlans, j);
					if (otherPlanID >= 0 && puid == aiPlanGetVariableInt(otherPlanID, cTrainPlanUnitType, 0))
					{
						xsArraySetInt(gArmyUnitMaintainPlans, j, planID);
						break;
					}
					otherPlanID = -1;
				}
				
				if (otherPlanID < 0)
				{
					aiPlanDestroy(planID);
					planID = -1;
				}
				else
				{
					planID = otherPlanID;
					xsArraySetInt(gArmyUnitMaintainPlans, i, planID);
				}
			}

			if (planID < 0 && puid >= 0)
			{
				planID = aiPlanCreate("Land military " + kbGetUnitTypeName(puid) + " maintain", cPlanTrain);
				aiPlanSetMilitary(planID, true);
				// Unit type.
				aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
				aiPlanSetBaseID(planID, baseID);
				aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, gatherPoint);
				aiPlanSetActive(planID);
				xsArraySetInt(gArmyUnitMaintainPlans, i, planID);
				debugMilitary("*** Creating maintain plan for " + kbGetUnitTypeName(puid));
			}

			if (popCount > 0)
				numberToMaintain = (kbUnitPickGetResultFactor(gLandUnitPicker, i) / totalFactor) * aiGetMilitaryPop() / popCount;
			else
			{
				numberToMaintain =
					(kbUnitPickGetResultFactor(gLandUnitPicker, i) / totalFactor) * aiGetMilitaryPop() /
					(kbUnitCostPerResource(puid, cResourceFood) +
					 kbUnitCostPerResource(puid, cResourceWood) +
					 kbUnitCostPerResource(puid, cResourceGold));
			}
			aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, numberToMaintain);
			if (aiGetMilitaryPop() != 0)
			{
				aiPlanSetDesiredResourcePriority(planID, 50);
				switch (kbGetAge())
				{
					case cAge1:
					{
						break;
					}
					case cAge2:
					{
						if (getCurrentMilitaryPop() < 12)
							aiPlanSetDesiredResourcePriority(planID, 60);
						break;
					}
					case cAge3:
					{
						if (getCurrentMilitaryPop() < 30)
							aiPlanSetDesiredResourcePriority(planID, 60);
						break;
					}
					default:
					{
						if (getCurrentMilitaryPop() < 50)
							aiPlanSetDesiredResourcePriority(planID, 60);
						break;
					}
				}
			}
			
			for (j = 0; < numMilitaryBuildings)
			{
				buildingPUID = xsArrayGetInt(gMilitaryBuildings, j);
				if (kbProtoUnitCanTrain(buildingPUID, puid) == true)
				{
					trainBuildingPUID = buildingPUID;
					break;
				}
			}

			// Unit upgrades.
			if (trainBuildingPUID >= 0 && age >= cAge3)
			{
				upgradeTechID = kbTechTreeGetCheapestUnitUpgrade(puid, trainBuildingPUID);
				if (upgradeTechID >= 0)
				{
					upgradePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, upgradeTechID);
					
					if (upgradePlanID < 0)
					{
						upgradePlanID = aiPlanCreate("Research "+kbGetTechName(upgradeTechID), cPlanResearch);
						aiPlanSetVariableInt(upgradePlanID, cResearchPlanTechID, 0, upgradeTechID);
						aiPlanSetVariableInt(upgradePlanID, cResearchPlanBuildingTypeID, 0, trainBuildingPUID);
						aiPlanSetActive(upgradePlanID);
						debugMilitary("*** Creating research plan for "+kbGetTechName(upgradeTechID));
					}
				
					aiPlanSetParentID(upgradePlanID, planID);
					
					totalValue = kbUnitCostPerResource(puid, cResourceFood)
						+ kbUnitCostPerResource(puid, cResourceWood)
						+ kbUnitCostPerResource(puid, cResourceGold);
					totalValue = totalValue * kbUnitCount(cMyID, puid, cUnitStateABQ);

					aiPlanSetDesiredResourcePriority(upgradePlanID, 55);
				}
			}
			xsArraySetInt(gArmyUnitBuildings, i, trainBuildingPUID);
		}

		// Also research upgrades for units not maintained.
		if (cDifficultyCurrent >= cDifficultyModerate && age >= cAge3)
		{
			// Remove any units in the unit picker.
			for (i = 0; < 3)
			{
				puid = xsArrayGetInt(unitsNotMaintained, i);
				if (puid < 0)
					continue;
				for (j = 0; < gNumArmyUnitTypes)
				{
					if (puid == kbUnitPickGetResult(gLandUnitPicker, j))
					{
						xsArraySetInt(unitsNotMaintained, i, -1);
						upgradePlanID = xsArrayGetInt(unitsNotMaintainedUpgrade, i);
						if (upgradePlanID >= 0)
						{
							if (aiPlanGetParentID(upgradePlanID) < 0)
								aiPlanDestroy(upgradePlanID);
							xsArraySetInt(unitsNotMaintainedUpgrade, i, -1);
						}
						puid = -1;
						break;
					}
				}
				if (puid >= 0)
				{
					totalValue = kbUnitCostPerResource(puid, cResourceFood)
						+ kbUnitCostPerResource(puid, cResourceWood)
						+ kbUnitCostPerResource(puid, cResourceGold);
					totalValue = totalValue * kbUnitCount(cMyID, puid, cUnitStateAlive);
					xsArraySetFloat(unitsNotMaintainedValue, i, totalValue);
				}
				else
				{
					xsArraySetFloat(unitsNotMaintainedValue, i, 0.0);
				}
			}

			int militaryQuery = createSimpleUnitQuery(cUnitTypeLogicalTypeLandMilitary, cMyID, cUnitStateAlive);
			int numberFound = kbUnitQueryExecute(militaryQuery);
			int unitID = -1;
			int militaryPUID = -1;
			float lowestTotalValue = 0.0;
			int lowestTotalValueIndex = 0;

			// Query all units, pick unit types with the highest total value.
			for (i = 0; < numberFound)
			{
				unitID = kbUnitQueryGetResult(militaryQuery, i);
				puid = kbUnitGetProtoUnitID(unitID);
				
				// avoid unit types in the unit picker.
				for (j = 0; < gNumArmyUnitTypes)
				{
					if (puid == kbUnitPickGetResult(gLandUnitPicker, j))
					{
						puid = -1;
						break;
					}
				}
				if (puid < 0)
					break;

				// ignore unit types already in the array.
				for (j = 0; < 3)
				{
					if (puid == xsArrayGetInt(unitsNotMaintained, j))
					{
						puid = -1;
						break;
					}
				}
				if (puid < 0)
					break;

				// pick unit type in the array with the lowest value and replace it.
				lowestTotalValue = 99999.0;
				lowestTotalValueIndex = 0;

				for (j = 0; < 3)
				{
					militaryPUID = xsArrayGetInt(unitsNotMaintained, j);
					totalValue = xsArrayGetFloat(unitsNotMaintainedValue, j);
					if (militaryPUID < 0 || lowestTotalValue > totalValue)
					{
						lowestTotalValue = totalValue;
						lowestTotalValueIndex = j;
						break;
					}
				}

				totalValue = kbUnitCostPerResource(puid, cResourceFood)
					+ kbUnitCostPerResource(puid, cResourceWood)
					+ kbUnitCostPerResource(puid, cResourceGold);
				totalValue = totalValue * kbUnitCount(cMyID, puid, cUnitStateAlive);

				if (totalValue > lowestTotalValue)
				{
					xsArraySetInt(unitsNotMaintained, lowestTotalValueIndex, puid);
					xsArraySetFloat(unitsNotMaintainedValue, lowestTotalValueIndex, totalValue);
					upgradePlanID = xsArrayGetInt(unitsNotMaintainedUpgrade, lowestTotalValueIndex);
					if (upgradePlanID >= 0)
						aiPlanDestroy(upgradePlanID);
					xsArraySetInt(unitsNotMaintainedUpgrade, lowestTotalValueIndex, -1);
				}
			}
			
			// Research upgrades when available.
			for (i = 0; < 3)
			{
				puid = xsArrayGetInt(unitsNotMaintained, i);
				for (j = 0; < numMilitaryBuildings)
				{
					buildingPUID = xsArrayGetInt(gMilitaryBuildings, j);
					if (kbProtoUnitCanTrain(buildingPUID, puid) == true)
					{
						trainBuildingPUID = buildingPUID;
						break;
					}
				}
				if (trainBuildingPUID >= 0)
				{
					upgradeTechID = kbTechTreeGetCheapestUnitUpgrade(puid, trainBuildingPUID);
					if (upgradeTechID >= 0)
					{
						upgradePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, upgradeTechID);

						if (upgradePlanID < 0)
						{
							upgradePlanID = aiPlanCreate("Research "+kbGetTechName(upgradeTechID), cPlanResearch);
							aiPlanSetVariableInt(upgradePlanID, cResearchPlanTechID, 0, upgradeTechID);
							aiPlanSetVariableInt(upgradePlanID, cResearchPlanBuildingTypeID, 0, trainBuildingPUID);
							aiPlanSetActive(upgradePlanID);
							debugMilitary("*** Creating research plan for "+kbGetTechName(upgradeTechID));               
						}

						totalValue = xsArrayGetFloat(unitsNotMaintainedValue, i);

						// below default priority if we do not have enough units.
						if (totalValue < 1000.0)
							aiPlanSetDesiredResourcePriority(upgradePlanID, 45 - (5 - totalValue / 200));
						else
							aiPlanSetDesiredResourcePriority(upgradePlanID, 50);
						xsArraySetInt(unitsNotMaintainedUpgrade, i, upgradePlanID);
					}
				}
			}
		}
		// TODO (James): Military production at forward base.
/* 		if (cDifficultyCurrent >= cDifficultyHard)
		{
			planID = aiPlanGetIDByTypeAndVariableType(cPlanAttack, cAttackPlanBaseAttackMode, cAttackPlanBaseAttackModeExplicit);
			if (planID >= 0 && aiPlanGetVariableBool(planID, cAttackPlanAllowMoreUnitsDuringAttack, 0) == true)
				baseID = gForwardBaseID;
			else
				baseID = -1;
		} */
	}
}


//==============================================================================
// delayAttackMonitor
// We're on cDifficultyEasy aka Standard difficulty.
// It means we can't attack until AFTER someone has attacked us, or until we've reached age 4.
// It can also be that the loader file has set gDelayAttacks to false for this difficulty directly.
//==============================================================================
rule delayAttackMonitor
inactive
minInterval 10
{
	if (gDelayAttacks == false ||
		kbGetAge() >= cAge4 ||
		gDefenseReflexBaseID == kbBaseGetMainID(cMyID))
	{
		xsEnableRule("mostHatedEnemy"); // Picks a target for us to attack.
		mostHatedEnemy(); // Instantly get a target so our managers have something to work with.
		xsEnableRule("attackManager"); // Land attacking / defending allies.
		if (gNavyMap == true)
		{
			xsEnableRule("waterAttack"); // Water attacking.
		}
		xsDisableSelf();
	}
}


//==============================================================================
// attackManager
// This rule analyzes the current situation in the game and decides if we should 
// attack an enemy OR defend an ally in need.
//==============================================================================
rule attackManager
inactive
minInterval 15
{
	int mainBaseID = kbBaseGetMainID(cMyID);

	// Don't attack under treaty or main base is under attack or we want to focus on aging up or if we already have an attack /
	// "real" defend plan.
	if (aiTreatyActive() == true || gDefenseReflexBaseID == mainBaseID || /* aiPlanGetActualResourcePriority(gAgeUpResearchPlan) >= 52 || */
		isDefendingOrAttacking() == true)	// TODO (James): Test the difference between "actual" and standard resource prio.
	{
		debugMilitary("Quiting attackManager early because we're not allowed to make a plan");
		debugMilitary("gDefenseReflexBaseID: " + gDefenseReflexBaseID + ", mainBaseID: " + mainBaseID);
		debugMilitary("gAgeUpResearchPlan prio: " + aiPlanGetActualResourcePriority(gAgeUpResearchPlan));
		debugMilitary("isDefendingOrAttacking: " + isDefendingOrAttacking());
		return;
	}

	static int baseQuery = -1;
	static int baseEnemyQuery = -1;
	static int tradingPostQuery = -1;
	bool defendingMonopoly = false;
	bool attackingMonopoly = false;
	bool defendingKOTH = false;
	bool attackingKOTH = false;
	int currentTime = xsGetTime();
	int numberUnits = 0;
	int numberFound = 0;
	int numberEnemyFound = 0;
	int numberBases = 0;
	int baseID = -1;
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	int mainAreaGroup = kbAreaGroupGetIDByPosition(mainBaseLocation);
	int baseAreaGroup = -1;
	vector baseLocation = cInvalidVector;
	vector location = cInvalidVector;
	float baseDistance = 0.0;
	float armyPower = 0.0;
	float buildingPower = 0.0;
	float militaryPower = 0.0;
	float enemyMilitaryPower = 0.0;
	float affordable = 0.0;
	float baseAssets = 0.0;
	float distancePenalty = 0.0;
	float score = 0.0;
	bool isEnemy = false;
	bool isKOTH = false;
	bool isTradingPost = false;
	bool shouldAttack = false;
	int availableMilitaryPop = aiGetAvailableMilitaryPop();
	int unitID = -1;
	int puid = -1;
	float unitPower = 0.0;
	int targetBaseID = -1;
	vector targetBaseLocation = cInvalidVector;
	int targetPlayer = 2;
	bool targetIsEnemy = true;
	bool targetShouldAttack = false;
	float targetAffordable = 0.0;
	float targetBaseAssets = 0.0;
	float targetDistancePenalty = 0.0;
	float targetScore = 0.0;
	float maxBaseAssets = 100.0;
	int planID = -1;
	int difficulty = cDifficultyCurrent;
	bool isItalianWars = (cRandomMapName == "euItalianWars");
	int cityStateQuery = -1;
	bool isCityState = false;
	int numberControlledCityStates = 0;

	if (baseQuery < 0)
	{
		baseQuery = kbUnitQueryCreate("attackBaseQuery");
		kbUnitQuerySetIgnoreKnockedOutUnits(baseQuery, true);

		baseEnemyQuery = kbUnitQueryCreate("attackBaseEnemyQuery");
		kbUnitQuerySetIgnoreKnockedOutUnits(baseEnemyQuery, true);

		tradingPostQuery = kbUnitQueryCreate("tradingPostQuery for Monopoly Targeting");
		kbUnitQuerySetIgnoreKnockedOutUnits(tradingPostQuery, true);
		kbUnitQuerySetPlayerRelation(tradingPostQuery, cPlayerRelationEnemyNotGaia);
		kbUnitQuerySetState(tradingPostQuery, cUnitStateAlive);
		kbUnitQuerySetPosition(tradingPostQuery, mainBaseLocation);
		kbUnitQuerySetUnitType(tradingPostQuery, cUnitTypeTradingPost);
		kbUnitQuerySetAscendingSort(tradingPostQuery, true);
	}

	if (gIsMonopolyRunning == true)
	{
		if (gMonopolyTeam == kbGetPlayerTeam(cMyID))
			defendingMonopoly = true;  // We're defending, let's not go launching any attacks
		else
			attackingMonopoly = true;  // We're attacking, focus on trade posts
	}
	else if (isItalianWars == true && kbCounterGetCurrentValue("leagueVictoryTimer") < 600)
	{
		// Italian Wars League Victory as Trade Monopoly.
		cityStateQuery = createSimpleUnitQuery(cUnitTypedeSPCSocketCityState, cPlayerRelationAny, cUnitStateAny);
		numberFound = kbUnitQueryExecute(cityStateQuery);

		for (i = 0; i < numberFound; i++)
		{
			unitID = kbUnitQueryGetResult(cityStateQuery, i);
			if (kbIsPlayerAlly(kbUnitGetPlayerID(unitID)) == true)
			{
				numberControlledCityStates++;
			}
		}

		if (numberControlledCityStates > (numberFound / 2))
		{
			attackingMonopoly = true;
		}
		else
		{
			defendingMonopoly = true;
		}
	}

	if (gIsKOTHRunning == true || aiIsKOTHAllowed() == true)
	{
		if (gKOTHTeam == kbGetPlayerTeam(cMyID))
			defendingKOTH = true;  // We're defending, let's not go launching any attacks
		else
			attackingKOTH = true;  // We're attacking, focus on the hill
	}

	numberUnits = aiPlanGetNumberUnits(gLandReservePlan, cUnitTypeLogicalTypeLandMilitary);

	for (i = 0; < numberUnits)
	{
		unitID = aiPlanGetUnitByIndex(gLandReservePlan, i);
		puid = kbUnitGetProtoUnitID(unitID);
		armyPower = armyPower + getMilitaryUnitStrength(puid);
	}

	// Go through all players' bases and calculate values for comparison.
	for (player = 0; < cNumberPlayers)
	{
		cityStateQuery = -1;

		if (player == 0)
		{
			if (isItalianWars == true)
			{
				cityStateQuery = createSimpleUnitQuery(cUnitTypedeSPCSocketCityState, 0, cUnitStateAny);
			}
			else
			{
				continue;
			}
		}

		if (cityStateQuery < 0)
		{
			if (player == cMyID || kbHasPlayerLost(player) == true)
			{
				continue;
			}

			numberBases = kbBaseGetNumber(player);
			isEnemy = kbIsPlayerEnemy(player);


			if (isEnemy == true && (cvPlayerToAttack > 0 && cvPlayerToAttack != player && kbHasPlayerLost(cvPlayerToAttack) == false))
			{
				continue;
			}
		}
		else
		{
			numberBases = kbUnitQueryExecute(cityStateQuery);
			isEnemy = true;
		}

		for (baseIndex = 0; < numberBases)
		{
			int cityStateID = -1;

			if (cityStateQuery < 0)
			{
				baseID = kbBaseGetIDByIndex(player, baseIndex);
				baseLocation = kbBaseGetLocation(player, baseID);
				baseDistance = kbBaseGetDistance(player, baseID);
			}
			else // city state, treat the gaia controlled city state as an enemy base.
			{
				baseID = -1;
				cityStateID = kbUnitQueryGetResult(cityStateQuery, baseIndex);
				baseLocation = kbUnitGetPosition(cityStateID);
				baseDistance = 30.0;
			}

			kbUnitQuerySetPlayerID(baseQuery, player);
			kbUnitQuerySetState(baseQuery, cUnitStateABQ);
			kbUnitQuerySetPosition(baseQuery, baseLocation);
			kbUnitQuerySetMaximumDistance(baseQuery, baseDistance);

			kbUnitQuerySetUnitType(baseQuery, cUnitTypeHasBountyValue);
			kbUnitQueryResetResults(baseQuery);
			numberFound = kbUnitQueryExecute(baseQuery);

			buildingPower = 0.0;
			militaryPower = 0.0;
			enemyMilitaryPower = 0.0;
			// Gaia city states, prioritize them over everything.
			baseAssets = cityStateQuery < 0 ? 0.0 : 99999.0;
			isKOTH = false;
			isTradingPost = false;
			shouldAttack = true;
			isCityState = false;

			if (isEnemy == true)
			{
				if (currentTime - gLastAttackMissionTime < gAttackMissionInterval)
				{
					shouldAttack = false;
				}
			}
			else
			{
				if (currentTime - gLastDefendMissionTime < gDefendMissionInterval)
				{
					shouldAttack = false;
				}
			}

			for (i = 0; < numberFound)
			{
				unitID = kbUnitQueryGetResult(baseQuery, i);
				puid = kbUnitGetProtoUnitID(unitID);
				switch (puid)
				{
				case cUnitTypeypKingsHill:
				{
					baseAssets = baseAssets + 1600.0;
					isKOTH = true;
					break;
				}
				case cUnitTypeTownCenter:
				case cUnitTypedeSPCCommandPost:
				{
					baseAssets = baseAssets + 1000.0;
					break;
				}
				// Buildings generating resources.
				case cUnitTypeBank:
				{
					baseAssets = baseAssets + 800.0;
					break;
				}
				case cUnitTypeFactory:
				{
					baseAssets = baseAssets + 1600.0;
					break;
				}
				case cUnitTypeypWCPorcelainTower2:
				{
					baseAssets = baseAssets + 800.0;
					break;
				}
				case cUnitTypeypWCPorcelainTower3:
				{
					baseAssets = baseAssets + 1200.0;
					break;
				}
				case cUnitTypeypWCPorcelainTower4:
				case cUnitTypeypWCPorcelainTower5:
				{
					baseAssets = baseAssets + 1600.0;
					break;
				}
				case cUnitTypeypShrineJapanese:
				{
					baseAssets = baseAssets + 200.0;
					break;
				}
				case cUnitTypeypWJToshoguShrine2:
				case cUnitTypeypWJToshoguShrine3:
				case cUnitTypeypWJToshoguShrine4:
				case cUnitTypeypWJToshoguShrine5:
				{
					baseAssets = baseAssets + 400.0;
					break;
				}
				case cUnitTypedeHouseInca:
				case cUnitTypedeTorp:
				{
					baseAssets = baseAssets + 200.0;
					break;
				}
				case cUnitTypedeMountainMonastery:
				case cUnitTypedeUniversity:
				{
					baseAssets = baseAssets + 300.0;
					break;
				}
				// Buildings automatically creating military units.
				case cUnitTypeypWCSummerPalace2:
				case cUnitTypeypWCSummerPalace3:
				case cUnitTypeypWCSummerPalace4:
				case cUnitTypeypWCSummerPalace5:
				case cUnitTypeypDojo:
				{
					baseAssets = baseAssets + 1200.0;
					break;
				}
				// Buildings with HC drop off point.
				case cUnitTypeFortFrontier:
				case cUnitTypeOutpost:
				case cUnitTypeBlockhouse:
				case cUnitTypeNoblesHut:
				case cUnitTypeypWIAgraFort2:
				case cUnitTypeypWIAgraFort3:
				case cUnitTypeypWIAgraFort4:
				case cUnitTypeypWIAgraFort5:
				case cUnitTypeypCastle:
				case cUnitTypeYPOutpostAsian:
				case cUnitTypedeIncaStronghold:
				case cUnitTypedeTower:
				// Military buildings.
				case cUnitTypeBarracks:
				case cUnitTypeStable:
				case cUnitTypeArtilleryDepot:
				case cUnitTypeCorral:
				case cUnitTypeypWarAcademy:
				case cUnitTypeYPBarracksIndian:
				case cUnitTypeypCaravanserai:
				case cUnitTypeypBarracksJapanese:
				case cUnitTypeypStableJapanese:
				case cUnitTypedeKallanka:
				case cUnitTypedeWarCamp:
				case cUnitTypedeHospital:
				case cUnitTypedeCommandery:
				{
					baseAssets = baseAssets + 100.0;
					break;
				}
				case cUnitTypedePalace:
				{
					baseAssets = baseAssets + 200.0;
					break;
				}
				// Villagers.
				case cUnitTypeSettlerWagon:
				{
					baseAssets = baseAssets + 400.0;
					break;
				}
				case cUnitTypeSettler:
				case cUnitTypeCoureur:
				case cUnitTypeCoureurCree:
				case cUnitTypeSettlerNative:
				case cUnitTypeypSettlerAsian:
				case cUnitTypeypSettlerIndian:
				case cUnitTypeypSettlerJapanese:
				case cUnitTypedeSettlerAfrican:
				{
					baseAssets = baseAssets + 200.0;
					break;
				}
				default:
				{
					if (kbUnitIsType(unitID, cUnitTypeTradingPost) == true)
					{
						if (isItalianWars == true && kbUnitGetSubCiv(unitID) == cCivSPCCityState)
						{
							baseAssets += 2000.0;
							isCityState = true;
						}
						else if (kbUnitGetSubCiv(unitID) >= 0)
						{
							baseAssets += 400.0;
						}
						else // Trade route trading post.
						{
							baseAssets += 1600.0;
						}
						isTradingPost = true;
					}
					break;
				}
				}
			}

			// Ignore base when we have no good targets to attack.
			if (baseAssets == 0.0)
			{
				continue;
			}

			// Prioritize trade monopoly and king's hill when active.
			if ((attackingMonopoly == true || defendingMonopoly == true) && isTradingPost == false)
			{
				// When Italian Wars League Victory is active, only attack those TPs.
				if (isItalianWars == false || isCityState == true)
				{
				shouldAttack = false;
				}
			}
			if ((attackingKOTH == true || defendingKOTH == true) && isKOTH == false)
			{
				shouldAttack = false;
			}

			if (isEnemy == false)
			{
				kbUnitQuerySetPlayerRelation(baseEnemyQuery, cPlayerRelationEnemyNotGaia);
				kbUnitQuerySetState(baseEnemyQuery, cUnitStateABQ);
				kbUnitQuerySetPosition(baseEnemyQuery, baseLocation);
				kbUnitQuerySetMaximumDistance(baseEnemyQuery, baseDistance + 10.0);

				kbUnitQuerySetUnitType(baseEnemyQuery, cUnitTypeLogicalTypeLandMilitary);
				kbUnitQueryResetResults(baseEnemyQuery);
				numberEnemyFound = kbUnitQueryExecute(baseEnemyQuery);

				for (i = 0; < numberEnemyFound)
				{
				unitID = kbUnitQueryGetResult(baseQuery, i);
				puid = kbUnitGetProtoUnitID(unitID);
				enemyMilitaryPower = enemyMilitaryPower + getMilitaryUnitStrength(puid);
				}

				if (enemyMilitaryPower == 0.0)
				{
				continue;
			}
			}

			for (i = 0; < numberFound)
			{
				unitID = kbUnitQueryGetResult(baseQuery, i);
				puid = kbUnitGetProtoUnitID(unitID);

				switch (puid)
				{
					case cUnitTypeFortFrontier:
					{
						buildingPower = buildingPower + 10.0;
						break;
					}
					case cUnitTypeYPOutpostAsian:
					case cUnitTypeOutpost:
					case cUnitTypeBlockhouse:
					{
						buildingPower = buildingPower + 3.0;
						break;
					}
					case cUnitTypeNoblesHut:
					case cUnitTypeypWIAgraFort2:
					case cUnitTypeypWIAgraFort3:
					case cUnitTypeypWIAgraFort4:
					case cUnitTypeypWIAgraFort5:
					case cUnitTypedeIncaStronghold:
					case cUnitTypeTownCenter:
					case cUnitTypedeSPCCommandPost:
					{
						buildingPower = buildingPower + 4.0;
						break;
					}
					case cUnitTypeypCastle:
					{
						buildingPower = buildingPower + 3.5;
						break;
					}
				}

				if (kbProtoUnitIsType(cMyID, puid, cUnitTypeLogicalTypeLandMilitary) == true)
				{
					militaryPower = militaryPower + getMilitaryUnitStrength(puid);
				}
			}

			// Avoid division by 0.
			if ((militaryPower + buildingPower) < 1.0)
			{
				militaryPower = 1.0;
				buildingPower = 0.0;
			}

			if (isEnemy == true)
			{
				// Do we have enough power to defeat the target base?
				if (armyPower < militaryPower && availableMilitaryPop > 0)
				{
					shouldAttack = false;
				}
			}
			else
			{
				// Is my ally really in trouble and can I handle the attack?
				if ((militaryPower + buildingPower > enemyMilitaryPower) ||
					(armyPower + militaryPower + buildingPower < enemyMilitaryPower * 0.8))
				{
					shouldAttack = false;
				}
			}

			// Prioritize defending allies.
			if (isEnemy == true && targetIsEnemy == false)
			{
				shouldAttack = false;
			}

			if (baseAssets > maxBaseAssets)
			{
				maxBaseAssets = baseAssets;
				targetScore = (targetBaseAssets / maxBaseAssets) * targetAffordable * targetDistancePenalty;
			}

			if (isEnemy == true)
			{
				affordable = armyPower / (militaryPower + buildingPower);
			}
			else
			{
				affordable = (armyPower + militaryPower + buildingPower) / enemyMilitaryPower;
			}

			// Adjust for distance. If < 100m, leave as is.  Over 100m to 400m, penalize 10% per 100m.
			distancePenalty = getDistance(mainBaseLocation, baseLocation) / 1000.0;
			if (distancePenalty > 0.4)
			{
				distancePenalty = 0.4;
			}
			// Increase penalty by 40% if transporting is required.
			baseAreaGroup = kbAreaGroupGetIDByPosition(baseLocation);
			if (mainAreaGroup != baseAreaGroup)
			{
				distancePenalty = distancePenalty + 0.4;
			}
			distancePenalty = 1.0 - distancePenalty;

			score = (baseAssets / maxBaseAssets) * affordable * distancePenalty;
			if (score > targetScore || (shouldAttack == true && targetShouldAttack == false))
			{
				targetBaseID = baseID;
				targetBaseLocation = baseLocation;
				targetPlayer = player;
				targetIsEnemy = isEnemy;
				targetBaseAssets = baseAssets;
				targetAffordable = affordable;
				targetDistancePenalty = distancePenalty;
				targetScore = score;
				targetShouldAttack = shouldAttack;
			}
		}

		// If we found a city state target, break now.
		if (isItalianWars == true && cityStateQuery >= 0 && targetShouldAttack == true)
		{
			break;
		}
	}

	// Update target player.
	if (targetIsEnemy == true)
	{
		aiSetMostHatedPlayerID(targetPlayer);
	}

	if (targetBaseID < 0 || targetShouldAttack == false)
	{
		// If we got nothing, and KOTH is active, grab the KOTH location.
		if (defendingKOTH == true || attackingKOTH == true)
		{
			targetIsEnemy = attackingKOTH;
			int kothID = getUnit(cUnitTypeypKingsHill, cPlayerRelationAny, cUnitStateAlive);
			targetPlayer = kbUnitGetPlayerID(kothID);
			targetBaseLocation = kbUnitGetPosition(kothID);
		}
		// Exclude city state, which doesn't have a base ID.
		else if (targetPlayer > 0)
		{
			return;
		}
	}

	vector gatherPoint = kbBaseGetMilitaryGatherPoint(cMyID, mainBaseID);
	if (targetIsEnemy == true)
	{
		planID = aiPlanCreate("Attack Player " + targetPlayer + " Base " + targetBaseID, cPlanCombat);

		aiPlanSetVariableInt(planID, cCombatPlanCombatType, 0, cCombatPlanCombatTypeAttack);
		if (targetBaseID >= 0)
		{
			aiPlanSetVariableInt(planID, cCombatPlanTargetMode, 0, cCombatPlanTargetModeBase);
			aiPlanSetVariableInt(planID, cCombatPlanTargetBaseID, 0, targetBaseID);
		}
		else
		{
			aiPlanSetVariableInt(planID, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
		}
		aiPlanSetVariableInt(planID, cCombatPlanTargetPlayerID, 0, targetPlayer);
		aiPlanSetVariableVector(planID, cCombatPlanTargetPoint, 0, baseLocation);
		aiPlanSetVariableVector(planID, cCombatPlanGatherPoint, 0, gatherPoint);
		aiPlanSetVariableFloat(planID, cCombatPlanGatherDistance, 0, 40.0);

		aiPlanSetVariableInt(planID, cCombatPlanAttackRoutePattern, 0, cCombatPlanAttackRoutePatternRandom);

		// override the route when it is valid.
		int routeID = cvCreateBaseAttackRoute(targetPlayer, targetBaseID);
		if (routeID >= 0)
		{
			aiPlanSetVariableInt(planID, cCombatPlanAttackRouteID, 0, routeID);
			// aiPlanSetVariableBool(planID, cCombatPlanRefreshAttackRoute, 0, false);
		}

		if (difficulty >= cDifficultyHard)
		{
			aiPlanSetVariableBool(planID, cCombatPlanAllowMoreUnitsDuringAttack, 0, true);
			aiPlanSetVariableInt(planID, cCombatPlanRefreshFrequency, 0, 300);
			aiPlanSetVariableInt(planID, cCombatPlanRetreatMode, 0, cCombatPlanRetreatModeNone);
			// updateMilitaryTrainPlanBuildings(gForwardBaseID); TODO (James)
		}
		else
		{
			aiPlanSetVariableInt(planID, cCombatPlanRefreshFrequency, 0, 1000);
		}
		aiPlanSetVariableInt(planID, cCombatPlanDoneMode, 0, cCombatPlanDoneModeBaseGone);
		// If we do not have a base, destroy the plan when we have no targets.
		if (targetBaseID < 0)
		{
			aiPlanSetVariableInt(planID, cCombatPlanDoneMode, 0, cCombatPlanDoneModeNoTarget | aiPlanGetVariableInt(planID, cCombatPlanDoneMode, 0));
			aiPlanSetVariableInt(planID, cCombatPlanNoTargetTimeout, 0, 30000);
		}
		aiPlanSetBaseID(planID, mainBaseID);
		aiPlanSetInitialPosition(planID, gatherPoint);

		addUnitsToMilitaryPlan(planID);

		aiPlanSetActive(planID);

		gLastAttackMissionTime = xsGetTime();
		debugMilitary("***** LAUNCHING ATTACK on player " + targetPlayer + " base " + targetBaseID);
	}
	else
	{
		planID = aiPlanCreate("Defend Player " + targetPlayer + " Base " + targetBaseID, cPlanCombat);

		aiPlanSetVariableInt(planID, cCombatPlanCombatType, 0, cCombatPlanCombatTypeDefend);
		if (targetBaseID >= 0)
		{
			aiPlanSetVariableInt(planID, cCombatPlanTargetMode, 0, cCombatPlanTargetModeBase);
			aiPlanSetVariableInt(planID, cCombatPlanTargetBaseID, 0, targetBaseID);
		}
		else
		{
			aiPlanSetVariableInt(planID, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
		}
		aiPlanSetVariableInt(planID, cCombatPlanTargetPlayerID, 0, targetPlayer);
		aiPlanSetVariableVector(planID, cCombatPlanTargetPoint, 0, baseLocation);
		aiPlanSetVariableInt(planID, cCombatPlanRefreshFrequency, 0, difficulty >= cDifficultyHard ? 300 : 1000);
		aiPlanSetVariableInt(planID, cCombatPlanDoneMode, 0, cCombatPlanDoneModeNoTarget);
		aiPlanSetVariableInt(planID, cCombatPlanNoTargetTimeout, 0, 30000);
		aiPlanSetVariableInt(planID, cCombatPlanRetreatMode, 0, cCombatPlanRetreatModeNone);
		aiPlanSetOrphan(planID, true);

		addUnitsToMilitaryPlan(planID);

		aiPlanSetActive(planID);

		gLastDefendMissionTime = xsGetTime();
		debugMilitary("***** DEFENDING player " + targetPlayer + " base " + targetBaseID);
	}
}

void navalAttackPlanHandler(int planID = -1)
{
	if (aiPlanGetState(planID) == -1)
	{
		// Done so reset the global.
		gNavyAttackPlan = -1;
	}
}

/* Naval Priorities explained:
	Defending = 15 when not under attack so war ships that can fish will do so.
	Fishing = 19.
	Exploring = 20 so fishing ships can be used for it.
	Repairing = 22 so the war ships do defend but will chose repairing over fishing.
	Defending = 25 when under attack so war ships that can fish will actually fight.
	Attacking = 60 so all war ships will go on the attack.
	Transport = 100 so the ships will actually deliver the units reliably.
*/
//==============================================================================
// waterAttack
// Creates the attack plans for our naval units.
//==============================================================================
rule waterAttack
inactive
minInterval 30
{
	int time = xsGetTime();
	if ((gLastNavalAttackTime > time - gAttackMissionInterval) || (aiTreatyActive() == true))
	{
		return;
	}
	
	if (gNavyAttackPlan >= 0)
	{
		return; // We don't want multiple attack plans.
	}
	
	if (kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateAlive) < 3)
	{
		return; // We don't attack with fewer than 3 war ships.
	}
	
	int targetDockID = getClosestUnit(cUnitTypeAbstractDock, cPlayerRelationEnemyNotGaia, cUnitStateAlive,
		gNavyVec, 400.0); // Get any enemy Dock within 400 range of our gNavyVec to attack.
	
	if (targetDockID >= 0) // There's something to attack.
	{
		vector targetDockPosition = kbUnitGetPosition(targetDockID);
		int navalTargetPlayer = kbUnitGetPlayerID(targetDockID);
		
		gNavyAttackPlan = aiPlanCreate("NAVAL Attack Player: " + navalTargetPlayer + ", targetDockID: " + targetDockID, cPlanCombat);
		
		aiPlanAddUnitType(gNavyAttackPlan, cUnitTypeAbstractWarShip, 3, 200, 200);
		aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanCombatType, 0, cCombatPlanCombatTypeAttack);
		aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
		aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanTargetPlayerID, 0, navalTargetPlayer);
		aiPlanSetVariableVector(gNavyAttackPlan, cCombatPlanTargetPoint, 0, targetDockPosition);
		aiPlanSetVariableVector(gNavyAttackPlan, cCombatPlanGatherPoint, 0, gNavyVec);
		aiPlanSetVariableFloat(gNavyAttackPlan, cCombatPlanGatherDistance, 0, 40.0);
		aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanAttackRoutePattern, 0, cCombatPlanAttackRoutePatternRandom);

		if (cDifficultyCurrent >= cDifficultyHard)
		{
			aiPlanSetVariableBool(gNavyAttackPlan, cCombatPlanAllowMoreUnitsDuringAttack, 0, true);
			aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanRefreshFrequency, 0, 300);
		}
		else
		{
			aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanRefreshFrequency, 0, 1000);
			
		}
		aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanDoneMode, 0, cCombatPlanDoneModeRetreat | cCombatPlanDoneModeNoTarget);
		aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanRetreatMode, 0, cCombatPlanRetreatModeOutnumbered);
		aiPlanSetVariableInt(gNavyAttackPlan, cCombatPlanNoTargetTimeout, 0, 30000);
		aiPlanSetBaseID(gNavyAttackPlan, kbUnitGetBaseID(getUnit(gDockUnit, cMyID, cUnitStateAlive)));
		aiPlanSetInitialPosition(gNavyAttackPlan, gNavyVec);

		aiPlanSetActive(gNavyAttackPlan);
		gLastNavalAttackTime = time;
		debugMilitary("***** LAUNCHING NAVAL ATTACK on player: " + navalTargetPlayer + ", targetDockID: " + targetDockID);
		aiPlanSetEventHandler(gNavyAttackPlan, cPlanEventStateChange, "navalAttackPlanHandler");
	}
}

//==============================================================================
// waterDefend
// Creates and manages the persistent defend plan for our naval units.
//==============================================================================
rule waterDefend
inactive
minInterval 10
{
	if (gNavyDefendPlan < 0) // First run, create a persistent defend plan.
	{
		gNavyDefendPlan = aiPlanCreate("Water Defend", cPlanCombat);

		aiPlanSetVariableInt(gNavyDefendPlan, cCombatPlanCombatType, 0, cCombatPlanCombatTypeDefend);
		aiPlanSetVariableInt(gNavyDefendPlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
		aiPlanSetVariableInt(gNavyDefendPlan, cCombatPlanTargetPlayerID, 0, cMyID);
		aiPlanSetVariableVector(gNavyDefendPlan, cCombatPlanTargetPoint, 0, gNavyVec);
		aiPlanSetInitialPosition(gNavyDefendPlan, gNavyVec);
		aiPlanSetVariableVector(gNavyDefendPlan, cCombatPlanGatherPoint, 0, gNavyVec);
		aiPlanSetVariableFloat(gNavyDefendPlan, cCombatPlanGatherDistance, 0, 40.0);
		aiPlanSetVariableInt(gNavyDefendPlan, cCombatPlanRefreshFrequency, 0, cDifficultyCurrent >= cDifficultyHard ? 300 : 1000);
		aiPlanAddUnitType(gNavyDefendPlan, cUnitTypeAbstractWarShip, 0, 200, 200);
		
		debugMilitary("Creating primary navy defend plan at: " + gNavyVec);
		aiPlanSetActive(gNavyDefendPlan);
	}
	
	int enemyQuery = createSimpleUnitQuery(cUnitTypeAbstractWarShip, cPlayerRelationEnemyNotGaia, cUnitStateAlive);
	kbUnitQuerySetSeeableOnly(enemyQuery, true); // Only stop fishing when the enemy is actually near us.
	int numberFound = kbUnitQueryExecute(enemyQuery);

	if (numberFound > 0)
	{
		aiPlanSetDesiredPriority(gNavyDefendPlan, 25); // Above fishing when there are enemies around.
	}
	else
	{
		aiPlanSetDesiredPriority(gNavyDefendPlan, 15); // Below fishing when there are no enemies around.
	}
}

//==============================================================================
/* navyManager
   Create enough Docks for our age and difficulty.
   Create maintain plans for navy unit lines. Control 'maintain' levels.
   Monitor if we need to repair ships.
*/
//==============================================================================
rule navyManager
inactive
minInterval 30
{
	int age = kbGetAge();
	
	/////////////////
	// Maintain war ships part.
	/////////////////
	int ownDockID = getUnit(gDockUnit, cMyID, cUnitStateAlive);
	vector ownDockPosition = kbUnitGetPosition(ownDockID);

	if (gCaravelMaintain < 0) // First run, initiliaze plans.
	{
		// Don't fire up maintain plans until we have a base ID, and repairing is no use either.
		// Only start training war ships when we're 5 minutes away from treaty ending.
		if ((ownDockID < 0) || (aiTreatyGetEnd() > xsGetTime() + 5 * 60 * 1000))
		{
			return; 
		}
		int baseID = kbUnitGetBaseID(ownDockID);
		
		// These initial maintain amounts mean nothing and get instantly overwritten.
		if (cMyCiv == cCivXPAztec)
		{
			gCaravelMaintain = createSimpleMaintainPlan(gCaravelUnit, 10, false, baseID, 1); // xpWarCanoe
			gFrigateMaintain = createSimpleMaintainPlan(gGalleonUnit, 5, false, baseID, 1);  // xpTlalocCanoe
		}
		else if (cMyCiv == cCivDEInca)
		{
			gCaravelMaintain = createSimpleMaintainPlan(gCaravelUnit, 8, false, baseID, 1); // deChinchaRaft
		}
		else if (civIsNative() == true)
		{
			gCaravelMaintain = createSimpleMaintainPlan(gCaravelUnit, 10, false, baseID, 1); // xpWarCanoe
			gGalleonMaintain = createSimpleMaintainPlan(gGalleonUnit, 20, false, baseID, 1); // Canoe
		}
		else if ((cMyCiv == cCivChinese) || (cMyCiv == cCivSPCChinese))
		{
			gCaravelMaintain = createSimpleMaintainPlan(gCaravelUnit, 5, false, baseID, 1); // War Junk
			gFrigateMaintain = createSimpleMaintainPlan(gFrigateUnit, 3, false, baseID, 1); // Fuchuan
			gMonitorMaintain = createSimpleMaintainPlan(gMonitorUnit, 2, false, baseID, 1);
		}
		else if (civIsAfrican() == true)
		{
			gCaravelMaintain = createSimpleMaintainPlan(gCaravelUnit, 5, false, baseID, 1); // Battle Canoe
			gFrigateMaintain = createSimpleMaintainPlan(gFrigateUnit, 2, false, baseID, 1); // Dhow/Xebec
			gMonitorMaintain = createSimpleMaintainPlan(gMonitorUnit, 2, false, baseID, 1); // Cannon Boat
		}
		else // Europeans.
		{
			gCaravelMaintain = createSimpleMaintainPlan(gCaravelUnit, 5, false, baseID, 1);
			gGalleonMaintain = createSimpleMaintainPlan(gGalleonUnit, 3, false, baseID, 1);
			gFrigateMaintain = createSimpleMaintainPlan(gFrigateUnit, 3, false, baseID, 1);
			gMonitorMaintain = createSimpleMaintainPlan(gMonitorUnit, 2, false, baseID, 1);
		}
	}

	int numberCaravels = 0;
	int numberGalleons = 0;
	int numberFrigates = 0;
	int numberMonitors = 0;

	if ((gStartOnDifferentIslands == true) ||
		(gTimeToFish == true) ||
		(age >= cAge3))
	{
		int navyQuery = -1;
		int navySize = 0;
		int unitID = -1;
		int puid = -1;
		
		// We either focus on an enemy player which we find by searching for a Dock.
		// Or if we don't find a Dock we see if we're being "attacked" and focus on some of those ships.
		int navyEnemyPlayer = kbUnitGetPlayerID(getClosestUnit(cUnitTypeAbstractDock, cPlayerRelationEnemyNotGaia,
			cUnitStateAlive, gNavyVec, 400.0));
		if (navyEnemyPlayer < 0)
		{
			navyEnemyPlayer = kbUnitGetPlayerID(getUnitByLocation(cUnitTypeAbstractWarShip, cPlayerRelationEnemyNotGaia,
				cUnitStateAlive, ownDockPosition, 100)); // If enemey ships are within 100 meters we still need to train ships to defend ourselves.
		}
		navyQuery = createSimpleUnitQuery(cUnitTypeAbstractWarShip, navyEnemyPlayer, cUnitStateAlive);
		navySize = kbUnitQueryExecute(navyQuery);

		for (i = 0; < navySize)
		{
			unitID = kbUnitQueryGetResult(navyQuery, i);
			puid = kbUnitGetProtoUnitID(unitID);
			gNetNavyValue += (kbUnitCostPerResource(puid, cResourceWood) + kbUnitCostPerResource(puid, cResourceGold) +
							kbUnitCostPerResource(puid, cResourceInfluence));
		}

		navyQuery = createSimpleUnitQuery(cUnitTypeAbstractWarShip, cMyID, cUnitStateABQ);
		navySize = kbUnitQueryExecute(navyQuery);

		int caravelLimit = 0;
		int galleonLimit = 0;
		int frigateLimit = 0;
		int monitorLimit = 0;

		caravelLimit = kbGetBuildLimit(cMyID, gCaravelUnit);
		if (cMyCiv == cCivXPAztec || cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux)
		{
			galleonLimit = kbGetBuildLimit(cMyID, gGalleonUnit);
		}
		if (cMyCiv != cCivXPIroquois && cMyCiv != cCivXPSioux && cMyCiv != cCivDEInca && age >= cAge3)
		{
			frigateLimit = kbGetBuildLimit(cMyID, gFrigateUnit);
		}
		if (civIsNative() == false && age >= cAge4)
		{
			monitorLimit = kbGetBuildLimit(cMyID, gMonitorUnit);
		}

		for (i = 0; < navySize)
		{
			unitID = kbUnitQueryGetResult(navyQuery, i);
			puid = kbUnitGetProtoUnitID(unitID);
			gNetNavyValue -= (kbUnitCostPerResource(puid, cResourceWood) + kbUnitCostPerResource(puid, cResourceGold) +
							kbUnitCostPerResource(puid, cResourceInfluence));

			switch (puid)
			{
				case gCaravelUnit:
				{
				numberCaravels++;
				break;
				}
				case gGalleonUnit:
				{
				numberGalleons++;
				break;
				}
				case gFrigateUnit:
				{
				numberFrigates++;
				break;
				}
				case gMonitorUnit:
				{
				numberMonitors++;
				break;
				}
			}
		}

		// 1 More Caravel or equivalent amount of war ships than enemy.
		gNetNavyValue += 400.0;
		debugMilitary("Navy enemy player is " + navyEnemyPlayer + ", net navy value is " + gNetNavyValue);

		int caravelValue = kbUnitCostPerResource(gCaravelUnit, cResourceWood) +
							kbUnitCostPerResource(gCaravelUnit, cResourceGold);
		int galleonValue = kbUnitCostPerResource(gGalleonUnit, cResourceWood) +
							kbUnitCostPerResource(gGalleonUnit, cResourceGold);
		// African Dhows/Xebecs cost influence.
		int frigateValue = kbUnitCostPerResource(gFrigateUnit, cResourceWood) +
							kbUnitCostPerResource(gFrigateUnit, cResourceGold) +
							kbUnitCostPerResource(gFrigateUnit, cResourceInfluence);
		int monitorValue = kbUnitCostPerResource(gMonitorUnit, cResourceWood) +
							kbUnitCostPerResource(gMonitorUnit, cResourceGold);

		// Prioritize ships in the following order - Frigate, Caravel, Monitor, Galleon.
		while (gNetNavyValue > 0.0)
		{
			if (numberFrigates < frigateLimit)
			{
				numberFrigates++;
				gNetNavyValue -= frigateValue;
				continue;
			}
			if (numberCaravels < caravelLimit)
			{
				numberCaravels++;
				gNetNavyValue -= caravelValue;
				continue;
			}
			if (numberMonitors < monitorLimit)
			{
				numberMonitors++;
				gNetNavyValue -= monitorValue;
				continue;
			}
			if (numberGalleons < galleonLimit)
			{
				numberGalleons++;
				gNetNavyValue -= galleonValue;
				continue;
			}
			break;
		}
	}
	else
	{
		gNetNavyValue = 0;
	}

	if (gCaravelMaintain >= 0)
	{
		aiPlanSetVariableInt(gCaravelMaintain, cTrainPlanNumberToMaintain, 0, numberCaravels);
	}
	if (gGalleonMaintain >= 0)
	{
		aiPlanSetVariableInt(gGalleonMaintain, cTrainPlanNumberToMaintain, 0, numberGalleons);
	}
	if (gMonitorMaintain >= 0)
	{
		aiPlanSetVariableInt(gMonitorMaintain, cTrainPlanNumberToMaintain, 0, numberMonitors);
	}
	if (gFrigateMaintain >= 0)
	{
		aiPlanSetVariableInt(gFrigateMaintain, cTrainPlanNumberToMaintain, 0, numberFrigates);
	}
		
	/////////////////
	// Repair part.
	// We repurpose a combat defend plan to function as a repair plan by basically forcing a unit next to a Dock.
	/////////////////
	if (ownDockID < 0) // Destroy the repair plan as soon as we have no Docks left.
	{
		if (gNavyRepairPlan >= 0)
		{
			aiPlanDestroy(gNavyRepairPlan);
			gNavyRepairPlan = -1;
		}
	}
	else
	{
		if (gNavyRepairPlan < 0)
		{
			gNavyRepairPlan = aiPlanCreate("Navy Repair", cPlanCombat);

			aiPlanSetVariableInt(gNavyRepairPlan, cCombatPlanCombatType, 0, cCombatPlanCombatTypeDefend);
			aiPlanSetVariableInt(gNavyRepairPlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
			aiPlanSetVariableInt(gNavyRepairPlan, cCombatPlanTargetPlayerID, 0, cMyID);
			aiPlanSetVariableFloat(gNavyRepairPlan, cCombatPlanGatherDistance, 0, 10.0);
			aiPlanSetVariableInt(gNavyRepairPlan, cCombatPlanRefreshFrequency, 0, cDifficultyCurrent >= cDifficultyHard ? 300 : 1000);
			aiPlanAddUnitType(gNavyRepairPlan, cUnitTypeAbstractWarShip, 0, 0, 0); // Up later.
			
			debugMilitary("Creating primary navy repair plan at: " + ownDockPosition);
			aiPlanSetActive(gNavyRepairPlan);
		}
		aiPlanSetVariableVector(gNavyRepairPlan, cCombatPlanTargetPoint, 0, ownDockPosition);
		aiPlanSetInitialPosition(gNavyRepairPlan, ownDockPosition);
		aiPlanSetVariableVector(gNavyRepairPlan, cCombatPlanGatherPoint, 0, ownDockPosition);

		int bestUnitID = -1;
		unitID = aiPlanGetUnitByIndex(gNavyRepairPlan, 0);
		if (kbUnitGetHealth(unitID) > 0.95)
		{
			aiTaskUnitMove(unitID, gNavyVec);
			aiPlanAddUnit(gNavyDefendPlan, unitID);
		}

		// Look for a ship to repair.
		float unitHitpoints = 0.0;
		int unitPlanID = -1;
		float bestUnitHitpoints = 9999.0;
		int shipQueryID = createSimpleUnitQuery(cUnitTypeAbstractWarShip, cMyID, cUnitStateAlive);
		int numberFound = kbUnitQueryExecute(shipQueryID);
		for (i = 0; < numberFound)
		{
			unitID = kbUnitQueryGetResult(shipQueryID, i);
			unitPlanID = kbUnitGetPlanID(unitID);
			if ((aiPlanGetDesiredPriority(unitPlanID) > 22) || 
				(aiPlanGetType(unitPlanID) == cPlanTransport) ||
				(kbUnitGetHealth(unitID) > 0.95))
			{
				continue;
			}
			unitHitpoints = kbUnitGetCurrentHitpoints(unitID);
			if (unitHitpoints < bestUnitHitpoints)
			{
				bestUnitID = unitID;
				bestUnitHitpoints = unitHitpoints;
			}
		}

		if (bestUnitID >= 0)
		{
			aiPlanAddUnitType(gNavyRepairPlan, cUnitTypeAbstractWarShip, 1, 1, 1);
			aiPlanAddUnit(gNavyRepairPlan, bestUnitID);
		}
		else
		{
			aiPlanAddUnitType(gNavyRepairPlan, cUnitTypeAbstractWarShip, 0, 0, 0);
		}
	}
}


//==============================================================================
// Unit Picker Functions
//==============================================================================
void setUnitPickerCommon(int upID = -1)
{
	int targetPlayer = aiGetMostHatedPlayerID();

	kbUnitPickSetPreferenceWeight(upID, 1.0);
	kbUnitPickSetCombatEfficiencyWeight(upID, 2.0);
	// Late in game, less focus on taking down buildings.
	if (xsGetTime() < 900000 || kbUnitCount(targetPlayer, cUnitTypeBuilding, cUnitStateAlive | cUnitStateBuilding) >= 70)
		kbUnitPickSetBuildingCombatEfficiencyWeight(upID, 0.5);
	else
		kbUnitPickSetBuildingCombatEfficiencyWeight(upID, 0.0);
	kbUnitPickSetCostWeight(upID, 0.0);

	// Default to land units.
	kbUnitPickSetEnemyPlayerID(upID, targetPlayer);
	kbUnitPickSetAttackUnitType(upID, cUnitTypeLogicalTypeLandMilitary);

	// Set the default target types and weights, for use until we've seen enough actual units.
	kbUnitPickAddCombatEfficiencyType(upID, cUnitTypeLogicalTypeLandMilitary, 1.0);
	kbUnitPickAddBuildingCombatEfficiencyType(upID, cUnitTypeMilitaryBuilding, 1.0);
	kbUnitPickAddBuildingCombatEfficiencyType(upID, cUnitTypeAbstractTownCenter, 1.0);

	if (civIsAsian() == true && upID == gLandUnitPicker)
	{
		// Remove consulate units.
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateSiegeFortress, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateSiegeIndustrial, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateUnit, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateUnitColonial, 0.0);
	}
}

void setUnitPickerDisabledUnits(int upID = -1)
{
	kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractNativeWarrior, 0.0);
	kbUnitPickSetPreferenceFactor(upID, cUnitTypexpSpy, 0.0);
	kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractOutlaw, 0.0);
	kbUnitPickSetPreferenceFactor(upID, cUnitTypeGrenadier, 0.0);

	if (kbGetAge() < cAge3)
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeMercenary, 0.0);
	else
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeMercenary, 0.2);

	if (cMyCiv == cCivFrench)
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeCoureur, 0.0);
	}

	if (cMyCiv == cCivDEItalians)
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractBasilicaUnit, 0.0);
	}

	if (cMyCiv == cCivDEMaltese)
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypedeMalteseGun, 0.0);
	}

	if (civIsNative() == true)
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypexpWarrior, 0.0);
	}

	if (cMyCiv == cCivXPSioux)
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypexpDogSoldier, 0.0);
	}

	if (cMyCiv == cCivXPAztec)
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypexpMedicineManAztec, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypexpSkullKnight, 0.0);
	}

	kbUnitPickSetPreferenceFactor(upID, cUnitTypeypMercFlailiphant, 0.0);

	if ((cMyCiv == cCivIndians) || (cMyCiv == cCivSPCIndians))
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypSowarMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypRajputMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypSepoyMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypUrumiMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypZamburakMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypNatMercGurkhaJemadar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypMercFlailiphantMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypHowdahMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypMahoutMansabdar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypSiegeElephantMansabdar, 0.0);
	}

	if (cMyCiv == cCivDEInca)
	{
		kbUnitPickSetPreferenceFactor(upID, cUnitTypedeChasqui, 0.0);
	}

	if (civIsAsian() == true && upID == gLandUnitPicker)
	{
		// Remove Consulate units.
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateSiegeFortress, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateSiegeIndustrial, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateUnit, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractConsulateUnitColonial, 0.0);
	}

	if (civIsAfrican() == true)
	{
		// Exclude units costing influence, they are handled in influenceManager.
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeMercenary, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypedeBowmanLevy, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypedeSpearmanLevy, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypedeGunnerLevy, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypedeMaigadi, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypedeSebastopolMortar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeFalconet, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeOrganGun, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeCulverin, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeMortar, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypMahout, 0.0);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeypHowdah, 0.0);
	}
}

void setUnitPickerPreference(int upID = -1)
{
	// Add the main unit lines
	if (upID < 0)
		return;

	if (kbGetAge() >= cAge3)
		kbUnitPickSetMinimumCounterModePop(upID, 20);

	kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);   // Range 0.0 to 1.0
	kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArtillery, 0.2);
	kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);
	if (cMyCiv == cCivXPAztec)
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractLightInfantry, 0.5);
	if (cMyCiv == cCivDEEthiopians || cMyCiv == cCivDEInca)
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCoyoteMan, 0.5);

	kbUnitPickRemovePreferenceFactor(upID, cUnitTypeAbstractBannerArmy);
	setUnitPickerDisabledUnits(upID);
}

//==============================================================================
// initUnitPicker
//==============================================================================
int initUnitPicker(string name = "BUG", int numberTypes = 1, int minUnits = 10, int maxUnits = 20, int minPop = -1, int maxPop = -1,
	int numberBuildings = 1, bool guessEnemyUnitType = false)
{
	// Create it.
	int upID = kbUnitPickCreate(name);
	if (upID < 0)
	{
		return (-1);
	}

	// Default init.
	kbUnitPickResetAll(upID);

	kbUnitPickSetPreferenceWeight(upID, 1.0);
	kbUnitPickSetCombatEfficiencyWeight(upID, 1.0); // Leave it at 1.0 to avoid messing up SPC balance
	kbUnitPickSetBuildingCombatEfficiencyWeight(upID, 0.25);
	kbUnitPickSetCostWeight(upID, 0.0);
	// Desired number units types, buildings.
	kbUnitPickSetDesiredNumberUnitTypes(upID, numberTypes, numberBuildings, true);
	// Min/Max units and Min/Max pop.
	kbUnitPickSetMinimumNumberUnits(upID, minUnits); // Sets "need" level on attack plans
	// Sets "max" level on attack plans, sets "numberToMaintain" on train.
	// plans for primary unit, half that for secondary, 1/4 for tertiary, etc.
	kbUnitPickSetMaximumNumberUnits(upID, maxUnits);

	// Default to land units.
	kbUnitPickSetEnemyPlayerID(upID, aiGetMostHatedPlayerID());
	kbUnitPickSetAttackUnitType(upID, cUnitTypeLogicalTypeLandMilitary);
	kbUnitPickSetGoalCombatEfficiencyType(upID, cUnitTypeLogicalTypeLandMilitary);

	// Set the default target types and weights, for use until we've seen enough actual units.
	// kbUnitPickAddCombatEfficiencyType(upID, cUnitTypeLogicalTypeLandMilitary, 1.0);
	kbUnitPickAddCombatEfficiencyType(upID, cUnitTypeSettler, 0.2);// We need to build units that can kill settlers efficiently.
	kbUnitPickAddCombatEfficiencyType(upID, cUnitTypeHussar, 0.2); // Major component.
	kbUnitPickAddCombatEfficiencyType(upID, cUnitTypeMusketeer, 0.4);   // Bigger component.
	kbUnitPickAddCombatEfficiencyType(upID, cUnitTypePikeman, 0.1);     // Minor component.
	kbUnitPickAddCombatEfficiencyType(upID, cUnitTypeCrossbowman, 0.1); // Minor component.

	kbUnitPickAddBuildingCombatEfficiencyType(upID, cUnitTypeMilitaryBuilding, 1.0);
	kbUnitPickAddBuildingCombatEfficiencyType(upID, cUnitTypeAbstractTownCenter, 1.0);

	setUnitPickerPreference(upID); // Set generic preferences for this civ.

	return (upID);
}

//==============================================================================
// Basilica Monitor
//
// The Basilica trains units via techs, so first run a unit pick then get
// corresponding techs.
//
//==============================================================================
int getBasilicaTechFromPapalUnitType(int unitTypeID = -1)
{
	int retVal = -1;

	switch (unitTypeID)
	{
		case cUnitTypedePapalGuard:
		{
			retVal = cTechDEBasilicaShipPapalGuards2;
			break;
		}
		case cUnitTypedeNMPandour:
		{
			retVal = cTechDEBasilicaShipPandours2;
			break;
		}
		case cUnitTypedeNMPapalElmetto:
		{
			retVal = cTechDEBasilicaShipPapalElmeti1;
			break;
		}
		case cUnitTypedeNMPapalZouave:
		{
			retVal = cTechDEBasilicaShipPapalZouave1;
			break;
		}
	}

	return (retVal);
}

int getPapalNumUnitsPerTech(int unitTypeID = -1)
{
	int retVal = -1;

	switch (unitTypeID)
	{
		case cUnitTypedePapalGuard:
		{
			retVal = 7;
			break;
		}
		case cUnitTypedeNMPandour:
		{
			retVal = 7;
			break;
		}
		case cUnitTypedeNMPapalElmetto:
		{
			retVal = 3;
			break;
		}
		case cUnitTypedeNMPapalZouave:
		{
			retVal = 4;
			break;
		}
	}

	return (retVal);
}

// AI refuses to train them via tech?
/* rule basilicaMonitor
inactive
minInterval 30
{
	// Maintain plans
	static int basilicaUPID = -1;
	static int basilicaUnitTypes = -1;
	static int basilicaResearchPlans = -1;

	if (cvOkToTrainArmy == false)
		return;

	if (basilicaUnitTypes < 0)
	{
		basilicaUnitTypes = arrayCreateInt(4, "Basilica Papal Unit Types");
		arrayPushInt(basilicaUnitTypes, cUnitTypedePapalGuard);
		arrayPushInt(basilicaUnitTypes, cUnitTypedeNMPandour);
		arrayPushInt(basilicaUnitTypes, cUnitTypedeNMPapalElmetto);
		arrayPushInt(basilicaUnitTypes, cUnitTypedeNMPapalZouave);
		basilicaResearchPlans = arrayCreateInt(1, "Basilica Papal Unit Research Plans.");
	}

	int temp = 4;
	if (kbGetAge() < cAge3)
		temp = 2;
	else if (kbGetAge() < cAge4)
		temp = 3;
	int trainUnitID = -1;
	int techID = -1;
	int papalUnitsPerTech = -1;
	int papalUnitCount = -1;
	int planID = -1;
	int basilicaID = -1;
	int numberToMaintain = 0;
	int popCount = 0;

	for (i = 0; < arrayGetSize(basilicaResearchPlans))
	{
		echoMessage("Basilica Plan " + i + " state: " + aiPlanGetState(arrayGetInt(basilicaResearchPlans, i)));
		echoMessage("Basilica Plan " + i + " active: " + aiPlanGetActive(arrayGetInt(basilicaResearchPlans, i)));
	}

	arrayRemoveDonePlans(basilicaResearchPlans);
	int basilicaQuery = createSimpleUnitQuery(cUnitTypedeBasilica, cMyID, cUnitStateAlive);
	int numberBasilicas = kbUnitQueryExecute(basilicaQuery);
	// Don't proceed until we have a Basilica from which we can train papal units.
	if (numberBasilicas == 0)
		return;

	// Our active research plans do not exceed the number of Basilicas.
	if (arrayGetSize(basilicaResearchPlans) < numberBasilicas)
	{
		// Search for a Basilica that is not being used for a Research plan.
		for (index = 0; < numberBasilicas)
		{
			trainUnitID = arrayGetInt(basilicaUnitTypes, aiRandInt(temp));
			if (trainUnitID < 0)
				continue;
			echoMessage("trainUnitID: " + kbGetUnitTypeName(trainUnitID));
			techID = getBasilicaTechFromPapalUnitType(trainUnitID);
			papalUnitsPerTech = getPapalNumUnitsPerTech(trainUnitID);
			papalUnitCount = kbUnitCount(cMyID, trainUnitID, cUnitStateAlive);

			popCount = kbGetProtoUnitPopCount(trainUnitID);
			numberToMaintain = (0.5 * (1.0 / (temp * 1.0))) * (aiGetMilitaryPop() / popCount);
			echoMessage("numberToMaintain:" + numberToMaintain);
			// We have enough already.
			if (papalUnitCount - numberToMaintain >= 0)
				continue;

			for (i = 0; < numberBasilicas)
			{
				basilicaID = kbUnitQueryGetResult(basilicaQuery, i);
				// Check all the current Papal Research plans.
				for (j = 0; < arrayGetSize(basilicaResearchPlans))
				{
					planID = arrayGetInt(basilicaResearchPlans, j);
					if (basilicaID == aiPlanGetVariableInt(planID, cResearchPlanBuildingID, 0))
					{	// This Basilica is already occupied with a plan.
						basilicaID = -1;
						break;
					}
				}
				if (basilicaID >= 0)
					break;
			}

			if (basilicaID < 0)
			{
				echoMessage("All Basilicas occupied with plans.");
				return;
			}

			echoMessage("Creating research plan.");
			arrayPushInt(basilicaResearchPlans, createResearchPlan(techID, cUnitTypedeBasilica));
		}
	}
} */


//==============================================================================
// Native Monitor
//==============================================================================
rule nativeMonitor
inactive
minInterval 30
{
	static int nativeUPID = -1;
	static int nativeMaintainPlans = -1;
	static int nativeBuildingIDs = -1;

	if (nativeUPID < 0)
	{
		// Create it.
		nativeUPID = kbUnitPickCreate("Native Warrior");
		if (nativeUPID < 0)
			return;

		nativeMaintainPlans = xsArrayCreateInt(3, -1, "Native warrior maintain plans");
		nativeBuildingIDs = xsArrayCreateInt(3, -1, "Native warrior buildings");
	}

	int trainUnitID = -1;
	int planID = -1;
	int numberToMaintain = 0;
	int militaryPopPercentage = 15;
	int buildLimit = 0;
	int upgradeTechID = -1;
	int upgradePlanID = -1;
	float totalValue = 0.0;
	int trainBuildingID = -2;
	int mainBaseID = kbBaseGetMainID(cMyID);
	vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
	float mainBaseDist = kbBaseGetDistance(cMyID, mainBaseID);
	int age = kbGetAge();

	// Default init.
	kbUnitPickResetAll(nativeUPID);
	kbUnitPickSetPreferenceWeight(nativeUPID, 1.0);
	kbUnitPickSetCombatEfficiencyWeight(nativeUPID, 0.0);
	kbUnitPickSetBuildingCombatEfficiencyWeight(nativeUPID, 0.0);
	kbUnitPickSetCostWeight(nativeUPID, 0.0);
	// Desired number units types, buildings.
	kbUnitPickSetDesiredNumberUnitTypes(nativeUPID, 3, 1, true);
	kbUnitPickSetEnemyPlayerID(nativeUPID, aiGetMostHatedPlayerID());
	kbUnitPickSetPreferenceFactor(nativeUPID, cUnitTypeAbstractNativeWarrior, 1.0);
	kbUnitPickRun(nativeUPID);

	int numberPlans = xsArrayGetSize(nativeMaintainPlans);
	int numberUnitTypes = kbUnitPickGetNumberResults(nativeUPID);

	if (numberUnitTypes > numberPlans)
	{
		xsArrayResizeInt(nativeMaintainPlans, numberUnitTypes);
		for (i = numberPlans; < numberUnitTypes)
			xsArraySetInt(nativeMaintainPlans, i, -1);
	}

	for (i = 0; < numberUnitTypes)
	{
		trainUnitID = kbUnitPickGetResult(nativeUPID, i);
		planID = xsArrayGetInt(nativeMaintainPlans, i);
		buildLimit = kbGetBuildLimit(cMyID, trainUnitID);
		if (buildLimit == 0)
			trainUnitID = -1;
			
		if (planID >= 0 && trainUnitID != aiPlanGetVariableInt(planID, cTrainPlanUnitType, 0))
		{
			aiPlanDestroy(planID);
			planID = -1;
		}

		if (trainUnitID < 0)
			continue;

		if (planID < 0)
		{
			planID = createSimpleMaintainPlan(trainUnitID, 0, false, mainBaseID, 1);
			xsArraySetInt(nativeMaintainPlans, i, planID);
		}

		if (age <= cAge4)
		{
			// resource equivalent to 0-20% of our military pop
			numberToMaintain = (aiGetMilitaryPop() * militaryPopPercentage) / 
				(kbUnitCostPerResource(trainUnitID, cResourceGold) + 
				 kbUnitCostPerResource(trainUnitID, cResourceWood) + 
				 kbUnitCostPerResource(trainUnitID, cResourceFood));
		}
		else
		{
			numberToMaintain = buildLimit;
		}

		aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, numberToMaintain);

		// Train from main base whenever possible.
		if (numberToMaintain > 0)
		{
			if (trainBuildingID == -2)
			{
				trainBuildingID = getUnitByLocation(cUnitTypeNativeEmbassy, cMyID, cUnitStateAlive, mainBaseLocation, mainBaseDist);
				if (trainBuildingID < 0 && civIsAfrican() == true)
					trainBuildingID = getUnitByLocation(cUnitTypedePalace, cMyID, cUnitStateAlive, mainBaseLocation, mainBaseDist);
			}
			aiPlanSetVariableInt(planID, cTrainPlanBuildingID, 0, trainBuildingID);
		}
		else
		{
			aiPlanSetVariableInt(planID, cTrainPlanBuildingID, 0, -1);
		}

		// create a research plan.
		if (age >= cAge3)
		{
			upgradeTechID = kbTechTreeGetCheapestUnitUpgrade(trainUnitID, cUnitTypeTradingPost);
			if (upgradeTechID >= 0)
			{
				upgradePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, upgradeTechID);

				if (upgradePlanID < 0)
				{
					upgradePlanID = aiPlanCreate("Research " + kbGetTechName(upgradeTechID), cPlanResearch);
					aiPlanSetVariableInt(upgradePlanID, cResearchPlanTechID, 0, upgradeTechID);
					aiPlanSetVariableInt(upgradePlanID, cResearchPlanBuildingTypeID, 0, cUnitTypeTradingPost);
					aiPlanSetActive(upgradePlanID);
					debugMilitary("*** Creating research plan for " + kbGetTechName(upgradeTechID));
				}

				aiPlanSetParentID(upgradePlanID, planID);

				totalValue = 
					kbUnitCostPerResource(trainUnitID, cResourceFood) +
					kbUnitCostPerResource(trainUnitID, cResourceWood) +
					kbUnitCostPerResource(trainUnitID, cResourceGold) +
					kbUnitCostPerResource(trainUnitID, cResourceInfluence);
				totalValue = totalValue * kbUnitCount(cMyID, trainUnitID, cUnitStateABQ);

				// below default priority if we do not have enough units.
				if (totalValue < 800.0)
					aiPlanSetDesiredResourcePriority(upgradePlanID, 45 - (5 - totalValue / 200));
				else
					aiPlanSetDesiredResourcePriority(upgradePlanID, 50);
			}
		}
	}

	for (i = numberUnitTypes; < numberPlans)
	{
		planID = xsArrayGetInt(nativeMaintainPlans, i);
		if (planID >= 0)
		{
			aiPlanDestroy(planID);
			xsArraySetInt(nativeMaintainPlans, i, -1);
		}
	}
}


//==============================================================================
/* Influence Manager
//
// Train units and research techs with influence resource.
*/
//==============================================================================
rule influenceManager
inactive
minInterval 45
{
	// Maintain plans
	static int influenceUPID = -1;
	static int influenceMaintainPlans = -1;

	researchSimpleTech(cTechDEImportedCannons, cUnitTypedePalace);

	if (cvOkToTrainArmy == false)
		return;

	if (influenceUPID < 0)
	{
		// Create it.
		influenceUPID = kbUnitPickCreate("Influence military units");
		if (influenceUPID < 0)
			return;

		influenceMaintainPlans = xsArrayCreateInt(3, -1, "Influence maintain plans");
	}

	int numberResults = 0;
	int i = 0;
	int trainUnitID = -1;
	int planID = -1;
	int numberToMaintain = 0;
	int popCount = 0;
	int buildLimit = 0;
	float totalFactor = 0.0;
	float unitCost = 0.0;

	// Default init.
	kbUnitPickResetAll(influenceUPID);

	// Desired number units types, buildings.
	kbUnitPickSetDesiredNumberUnitTypes(influenceUPID, 2, 1, true);

	setUnitPickerCommon(influenceUPID);

	kbUnitPickSetMinimumCounterModePop(influenceUPID, 15);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeMercenary, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeAbstractNativeWarrior, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypedeMaigadi, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypedeSebastopolMortar, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeFalconet, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeOrganGun, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeCulverin, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeMortar, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeypMahout, 1.0);
	kbUnitPickSetPreferenceFactor(influenceUPID, cUnitTypeypHowdah, 1.0);
	kbUnitPickRun(influenceUPID);

	for (i = 0; < 2)
		totalFactor = totalFactor + kbUnitPickGetResultFactor(influenceUPID, i);

	float influenceAmount = kbResourceGet(cResourceInfluence);

	for (i = 0; < 2)
	{
		trainUnitID = kbUnitPickGetResult(influenceUPID, i);
		planID = xsArrayGetInt(influenceMaintainPlans, i);

		if (planID >= 0)
		{
			if (trainUnitID != aiPlanGetVariableInt(planID, cTrainPlanUnitType, 0))
			{
				aiPlanDestroy(planID);
				planID = -1;
			}
		}
		if (trainUnitID < 0)
			continue;

		// if we do not have enough influence for this unit, don't plan training anymore.
		if (influenceAmount > 0.0)
		{
			popCount = kbGetProtoUnitPopCount(trainUnitID);
			unitCost = kbUnitCostPerResource(trainUnitID, cResourceInfluence);
			// hardcoded to at most 40% of our military pop.
			if (popCount > 0)
			{
				numberToMaintain =
					0.4 * (kbUnitPickGetResultFactor(influenceUPID, i) / totalFactor) * aiGetMilitaryPop() / popCount;
			}
			else
			{
				numberToMaintain = 0.4 * (kbUnitPickGetResultFactor(influenceUPID, i) / totalFactor) * aiGetMilitaryPop() /
					(unitCost * 0.01);
			}
			buildLimit = kbGetBuildLimit(cMyID, trainUnitID);
			if (buildLimit > 0 && numberToMaintain > buildLimit)
				numberToMaintain = buildLimit;
			influenceAmount =
				influenceAmount - ((numberToMaintain - kbUnitCount(cMyID, trainUnitID, cUnitStateABQ)) * unitCost);
		}
		else
		{
			numberToMaintain = 0;
		}

		if (planID >= 0)
		{
			aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, numberToMaintain);
		}
		else
		{
			planID = createSimpleMaintainPlan(trainUnitID, numberToMaintain, false, kbBaseGetMainID(cMyID), 1);
			aiPlanSetDesiredResourcePriority(planID, 45 - i); // below research plans
			xsArraySetInt(influenceMaintainPlans, i, planID);
		}
	}
}


//==============================================================================
/*
	moveDefenseReflex(vector, radius, baseID)

	Move the defend and reserve plans to the specified location
	Sets the gLandDefendPlan0 to a high pop count, so it steals units from the reserve plan,
	which will signal the AI to not start new attacks as no reserves are available.
*/
//==============================================================================
void moveDefenseReflex(vector location = cInvalidVector, float radius = -1.0, int baseID = -1)
{
	if (radius < 0.0)
		radius = cvDefenseReflexRadiusActive;
	if (location != cInvalidVector)
	{
		float desiredRadius = radius;

		// radius = calculateDefenseReflexEngageRange(location, radius, 15.0);

		if (baseID < 0 /* || radius < desiredRadius */)
		{
			aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
			aiPlanSetVariableVector(gLandDefendPlan0, cCombatPlanTargetPoint, 0, location);
			aiPlanSetVariableFloat(gLandDefendPlan0, cCombatPlanTargetEngageRange, 0, radius);
		}
		else
		{
			aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetMode, 0, cCombatPlanTargetModeBase);
			aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetPlayerID, 0, cMyID);
			aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetBaseID, 0, baseID);
			aiPlanSetVariableVector(gLandDefendPlan0, cCombatPlanTargetPoint, 0, location);
		}

		aiPlanSetVariableFloat(gLandDefendPlan0, cCombatPlanGatherDistance, 0, radius - 10.0);
		aiPlanAddUnitType(gLandDefendPlan0, cUnitTypeLogicalTypeLandMilitary, 0, 0, 200);

		if (baseID < 0)
		{
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
			aiPlanSetVariableVector(gLandReservePlan, cCombatPlanTargetPoint, 0, location);
			aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanTargetEngageRange, 0, radius);
		}
		else
		{
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModeBase);
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetPlayerID, 0, cMyID);
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetBaseID, 0, baseID);
			aiPlanSetVariableVector(gLandReservePlan, cCombatPlanTargetPoint, 0, location);
		}

		aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanGatherDistance, 0, radius - 10.0);
		aiPlanAddUnitType(gLandReservePlan, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);

		gDefenseReflex = true;
		gDefenseReflexBaseID = baseID;
		gDefenseReflexLocation = location;
		gDefenseReflexTimeout = xsGetTime() + aiRandInt(300) * 1000;
		gDefenseReflexPaused = false;
	}
	debugMilitary("******** Defense reflex moved to base " + baseID + " with radius " + radius + " and location " + location);
}


//==============================================================================
/*
	pauseDefenseReflex()

	The base (gDefenseReflexBaseID) is still under attack, but we don't have enough
	forces to engage.  Retreat to main base, set a small radius, and wait until we
	have enough troops to re-engage through a moveDefenseReflex() call.
	Sets gLandDefendPlan0 to high troop count to keep reserve plan empty.
	Leaves the base ID and location untouched, even though units will gather at home.
*/
//==============================================================================
void pauseDefenseReflex(void)
{
	// vector loc = kbBaseGetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID));
	vector loc = (gHomeBase + gDirection_UP * 30.0);
	if (gForwardBaseState != cForwardBaseStateNone)
		loc = gForwardBaseLocation;

	float radius = cvDefenseReflexRadiusActive;

	aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
	aiPlanSetVariableVector(gLandDefendPlan0, cCombatPlanTargetPoint, 0, loc);
	aiPlanSetVariableFloat(gLandDefendPlan0, cCombatPlanTargetEngageRange, 0, radius);
	aiPlanSetVariableFloat(gLandDefendPlan0, cCombatPlanGatherDistance, 0, radius - 10.0);

	aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
	aiPlanSetVariableVector(gLandReservePlan, cCombatPlanTargetPoint, 0, loc);
	aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanTargetEngageRange, 0, radius);
	aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanGatherDistance, 0, radius - 10.0);
	
	aiPlanAddUnitType(gLandDefendPlan0, cUnitTypeLogicalTypeLandMilitary, 0, 0, 200);
	aiPlanAddUnitType(gLandReservePlan, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1);

	gDefenseReflexPaused = true;

	debugMilitary("******** Defense reflex paused.");
}


//==============================================================================
/*
	endDefenseReflex()

	Move the defend and reserve plans to their default positions
*/
//==============================================================================
void endDefenseReflex(void)
{
	vector resLoc = kbBaseGetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID));
	int defBaseID = kbBaseGetMainID(cMyID);
	vector defLoc = kbBaseGetLocation(cMyID, defBaseID);

	if (gForwardBaseState != cForwardBaseStateNone && gForwardBaseShouldDefend == true)
	{
		resLoc = gForwardBaseLocation;
		defLoc = gForwardBaseLocation;
		defBaseID = gForwardBaseID;
	}
	// float radius = calculateDefenseReflexEngageRange(defLoc, cvDefenseReflexRadiusActive, 15.0);
	// radius = calculateDefenseReflexEngageRange(defLoc, radius, 15.0);

	float radius = cvDefenseReflexRadiusActive;

	if (radius < cvDefenseReflexRadiusActive)
	{
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
		aiPlanSetVariableVector(gLandDefendPlan0, cCombatPlanTargetPoint, 0, defLoc);
		aiPlanSetVariableFloat(gLandDefendPlan0, cCombatPlanTargetEngageRange, 0, radius);
	}
	else
	{
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetMode, 0, cCombatPlanTargetModeBase);
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetPlayerID, 0, cMyID);
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetBaseID, 0, defBaseID);
		aiPlanSetVariableVector(gLandDefendPlan0, cCombatPlanTargetPoint, 0, defLoc);
	}
	aiPlanAddUnitType(
		gLandDefendPlan0,
		cUnitTypeLogicalTypeLandMilitary,
		0,
		0,
		1); // Defend plan will use 1 unit to defend against stray snipers, etc.

	// radius = calculateDefenseReflexEngageRange(resLoc, cvDefenseReflexRadiusPassive, 15.0);

	aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModePoint);
	aiPlanSetVariableVector(gLandReservePlan, cCombatPlanTargetPoint, 0, resLoc);
	aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanTargetEngageRange, 0, radius);
	aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanGatherDistance, 0, radius - 10.0);
	aiPlanAddUnitType(gLandReservePlan, cUnitTypeLogicalTypeLandMilitary, 0, 0, 200);   // All unused troops

	debugMilitary("******** Defense reflex terminated for base " + gDefenseReflexBaseID + " at location " + gDefenseReflexLocation);
	debugMilitary("******** Returning to " + resLoc);
	debugMilitary(" Forward base ID is " + gForwardBaseID + ", location is " + gForwardBaseLocation);

	gDefenseReflex = false;
	gDefenseReflexPaused = false;
	gDefenseReflexBaseID = -1;
	gDefenseReflexLocation = cInvalidVector;
	gDefenseReflexTimeout = 0;
}


// Use this instead of calling endDefenseReflex in the createMainBase function,
// so that the new BaseID will be available.
rule endDefenseReflexDelay
inactive
minInterval 1
{
	xsDisableSelf();
	endDefenseReflex();
}


//==============================================================================
/* Defend0

	Create a defend plan, protect the main base.
*/
//==============================================================================
rule defend0
inactive
group postStartup
minInterval 13
{
	if (gLandDefendPlan0 < 0)
	{
		int mainBaseID = kbBaseGetMainID(cMyID);
		vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
		vector targetPoint = kbBaseGetMilitaryGatherPoint(cMyID, mainBaseID);
		int targetMode = cCombatPlanTargetModeBase;
		int difficulty = cDifficultyCurrent;

		gLandDefendPlan0 = aiPlanCreate("Primary Land Defend", cPlanCombat);
		aiPlanAddUnitType(gLandDefendPlan0, cUnitTypeLogicalTypeLandMilitary, 0, 0, 1); // Small, until defense reflex
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanCombatType, 0, cCombatPlanCombatTypeDefend);
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetMode, 0, targetMode);
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetPlayerID, 0, cMyID);
		aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanTargetBaseID, 0, mainBaseID);
		aiPlanSetVariableVector(gLandDefendPlan0, cCombatPlanTargetPoint, 0, targetPoint);
		aiPlanSetVariableFloat(gLandDefendPlan0, cCombatPlanGatherDistance, 0, 20.0);
		aiPlanSetInitialPosition(gLandDefendPlan0, mainBaseLocation);
		if (difficulty >= cDifficultyHard)
		{
			aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanRefreshFrequency, 0, 300);
			aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanRetreatMode, 0, cCombatPlanRetreatModeNone);
		}
		else
		{
			aiPlanSetVariableInt(gLandDefendPlan0, cCombatPlanRefreshFrequency, 0, 1000);
		}
		aiPlanSetDesiredPriority(gLandDefendPlan0, 10); // Very low priority, don't steal from attack plans
		aiPlanSetActive(gLandDefendPlan0);
		debugMilitary("Creating primary land defend plan");

		gLandReservePlan = aiPlanCreate("Land Reserve Units", cPlanCombat);
		aiPlanAddUnitType(
			gLandReservePlan,
			cUnitTypeLogicalTypeLandMilitary,
			0,
			5,
			200); // All mil units, high MAX value to suck up all excess
		aiPlanSetVariableInt(gLandReservePlan, cCombatPlanCombatType, 0, cCombatPlanCombatTypeDefend);
		if (targetPoint == cInvalidVector)
		{
			int aiStartID = getUnit(cUnitTypeAIStart, cMyID);
			if (aiStartID >= 0)
			{
				targetPoint = kbUnitGetPosition(aiStartID);
				targetMode = cCombatPlanTargetModePoint;
			}
		}
		if (targetPoint == cInvalidVector)
			targetPoint = mainBaseLocation;
		aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetMode, 0, targetMode);
		if (targetMode == cCombatPlanTargetModeBase)
		{
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetPlayerID, 0, cMyID);
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanTargetBaseID, 0, mainBaseID);
		}
		else
		{
			aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanTargetEngageRange, 0, 60.0);
		}
		aiPlanSetVariableVector(gLandReservePlan, cCombatPlanTargetPoint, 0, targetPoint);
		aiPlanSetVariableFloat(gLandReservePlan, cCombatPlanGatherDistance, 0, 20.0);
		aiPlanSetInitialPosition(gLandReservePlan, mainBaseLocation);
		if (difficulty >= cDifficultyHard)
		{
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanRefreshFrequency, 0, 300);
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanRetreatMode, 0, cCombatPlanRetreatModeNone);
		}
		else
		{
			aiPlanSetVariableInt(gLandReservePlan, cCombatPlanRefreshFrequency, 0, 1000);
		}
		aiPlanSetDesiredPriority(gLandReservePlan, 5); // Very very low priority, gather unused units.
		aiPlanSetActive(gLandReservePlan);
		debugMilitary("Creating reserve plan");
		xsEnableRule("endDefenseReflexDelay"); // Reset to relaxed stances after plans have a second to be created.
		xsDisableSelf();
	}
}


rule baseDefenseForce
inactive
minInterval 20
{
	int numMilitaryUnits = kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive);
	int numSpecificUnit = -1;
	if (gBaseDefendPlan < 0)
	{
		gBaseDefendPlan = aiPlanCreate("Main Base Combat (Defend) Plan", cPlanCombat);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypeAbstractInfantry, 1, numMilitaryUnits / 4, 20);
		aiPlanSetVariableInt(gBaseDefendPlan, cCombatPlanCombatType, 0, cCombatPlanCombatTypeDefend);
		aiPlanSetVariableInt(gBaseDefendPlan, cCombatPlanTargetMode, 0, cCombatPlanTargetModeBase);
		aiPlanSetVariableInt(gBaseDefendPlan, cCombatPlanTargetPlayerID, 0, cMyID);
		aiPlanSetVariableInt(gBaseDefendPlan, cCombatPlanTargetBaseID, 0, gMainBase);
		aiPlanSetVariableVector(gBaseDefendPlan, cCombatPlanTargetPoint, 0, gHomeBase + gDirection_UP * 20.0);
		aiPlanSetVariableFloat(gBaseDefendPlan, cCombatPlanGatherDistance, 0, 20.0);
		aiPlanSetInitialPosition(gBaseDefendPlan, gHomeBase);
		aiPlanSetVariableInt(gBaseDefendPlan, cCombatPlanRefreshFrequency, 0, 300);
		aiPlanSetVariableInt(gBaseDefendPlan, cCombatPlanRetreatMode, 0, cCombatPlanRetreatModeNone);
		aiPlanSetDesiredPriority(gBaseDefendPlan, 60);
		aiPlanSetActive(gBaseDefendPlan);

		/* aiPlanAddUnitType(gBaseDefendPlan, cUnitTypeAbstractInfantry, 1, numMilitaryUnits / 4, 20);
		aiPlanSetVariableVector(gBaseDefendPlan, cDefendPlanDefendPoint, 0, gHomeBase + gDirection_UP * 30.0);
		aiPlanSetVariableInt(gBaseDefendPlan, cDefendPlanDefendBaseID, 0, kbBaseGetMainID(cMyID));
		aiPlanSetVariableFloat(gBaseDefendPlan, cDefendPlanEngageRange, 0, 40.0);
		aiPlanSetInitialPosition(gBaseDefendPlan, gHomeBase);
		aiPlanSetVariableInt(gBaseDefendPlan, cDefendPlanRefreshFrequency, 0, 300);
		aiPlanSetVariableInt(gBaseDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit); // Only units
		aiPlanSetDesiredPriority(gBaseDefendPlan, 60);
		aiPlanSetActive(gBaseDefendPlan); */

		debugMilitary("Creating primary Land Combat (Defend) plan.");
	}
	else
	{
		// aiPlanSetVariableFloat(gBaseDefendPlan, cDefendPlanEngageRange, 0, 40.0 + 10.0 * kbGetAge());
		aiPlanSetVariableVector(gBaseDefendPlan, cCombatPlanTargetPoint, 0, gHomeBase + gDirection_UP * (10.0 + 8.0 * kbGetAge()));
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypeAbstractInfantry, 1, numMilitaryUnits / 4, 20);
		numSpecificUnit = kbUnitCount(cMyID, cUnitTypeMinuteman, cUnitStateAlive);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypeMinuteman, numSpecificUnit, numSpecificUnit, numSpecificUnit * 2, true, true);
		numSpecificUnit = kbUnitCount(cMyID, cUnitTypeypIrregular, cUnitStateAlive);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypeypIrregular, numSpecificUnit, numSpecificUnit, numSpecificUnit * 2, true, true);
		numSpecificUnit = kbUnitCount(cMyID, cUnitTypeypPeasant, cUnitStateAlive);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypeypPeasant, numSpecificUnit, numSpecificUnit, numSpecificUnit * 2, true, true);
		numSpecificUnit = kbUnitCount(cMyID, cUnitTypexpWarrior, cUnitStateAlive);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypexpWarrior, numSpecificUnit, numSpecificUnit, numSpecificUnit * 2, true, true);
		numSpecificUnit = kbUnitCount(cMyID, cUnitTypedeSpearmanLevy, cUnitStateAlive);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypedeSpearmanLevy, numSpecificUnit, numSpecificUnit, numSpecificUnit * 2, true, true);
		numSpecificUnit = kbUnitCount(cMyID, cUnitTypedeBowmanLevy, cUnitStateAlive);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypedeBowmanLevy, numSpecificUnit, numSpecificUnit, numSpecificUnit * 2, true, true);
		numSpecificUnit = kbUnitCount(cMyID, cUnitTypedeGunnerLevy, cUnitStateAlive);
		aiPlanAddUnitType(gBaseDefendPlan, cUnitTypedeGunnerLevy, numSpecificUnit, numSpecificUnit, numSpecificUnit * 2, true, true);
	}
}


//==============================================================================
/* rule defenseReflex

   Monitor each VP site that we own, plus our main base. Move and reconfigure
   the defense and reserve plans as needed.

   At rest, the defend plan has only one unit, is centered on the main base, and
   is used to send one unit after trivial invasions, typically a scouting unit.
   The reserve plan has a much larger MAX number, so it gets all the remaining units.
   It is centered on the military gather point with a conservative radius, to avoid
   engaging units far in front of the main base.

   When defending a base in a defense reflex, the defend plan gets a high MAX number
   so that it takes units from the reserve plan.  The low unit count in reserve
   acts as a signal to not launch new attacks, as troops aren't available.  The
   defend plan and reserve plan are relocated to the endangered base, with an aggressive
   engage radius.

   The search, active engage and passive engage radii are set by global
   control variables, cvDefenseReflexRadiusActive, cvDefenseReflexRadiusPassive, and
   cvDefenseReflexSearchRadius.

   Once in a defense reflex, the AI stays in it until that base is cleared, unless
   it's defending a non-main base, and the main base requires defense.  In that case,
   the defense reflex moves back to the main base.

   pauseDefenseReflex() can only be used when already in a defense reflex.  So valid
   state transitions are:

   none to defending       // start reflex with moveDefenseReflex(), sets all the base/location globals.
   defending to paused     // use pauseDefenseReflex(), takes no parms, uses vars set in prior moveDefenseReflex call.
   defending to end        // use endDefenseReflex(), clears global vars.
   paused to end           // use endDefenseReflex(), clears global vars.
   paused to defending     // use moveDefenseReflex(), set global vars again.

*/
//==============================================================================
rule defenseReflex
inactive
minInterval 10
{
	int armySize = aiPlanGetNumberUnits(gLandDefendPlan0, cUnitTypeLogicalTypeLandMilitary) +
					aiPlanGetNumberUnits(gLandReservePlan, cUnitTypeLogicalTypeLandMilitary);
	int enemyArmySize = -1;
	static int lastHelpTime = -60000;
	static int lastHelpBaseID = -1;
	int i = 0;
	int unitID = -1;
	int protoUnitID = -1;
	bool panic = false; // Indicates need for call for help.
	int planID = -1;
	int mainBaseID = kbBaseGetMainID(cMyID);
	int time = xsGetTime();

	static int enemyArmyQuery = -1;
	if (enemyArmyQuery < 0) // First run.
	{
		enemyArmyQuery = kbUnitQueryCreate("Enemy army query");
		kbUnitQuerySetIgnoreKnockedOutUnits(enemyArmyQuery, true);
		kbUnitQuerySetPlayerRelation(enemyArmyQuery, cPlayerRelationEnemyNotGaia);
		kbUnitQuerySetUnitType(enemyArmyQuery, cUnitTypeLogicalTypeLandMilitary);
		kbUnitQuerySetState(enemyArmyQuery, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(enemyArmyQuery, true); // Ignore units we think are under fog.
	}

	// Check main base first.
	kbUnitQuerySetPosition(enemyArmyQuery, kbBaseGetLocation(cMyID, mainBaseID));
	kbUnitQuerySetMaximumDistance(enemyArmyQuery, cvDefenseReflexSearchRadius);
	kbUnitQuerySetSeeableOnly(enemyArmyQuery, true);
	kbUnitQuerySetState(enemyArmyQuery, cUnitStateAlive);
	kbUnitQueryResetResults(enemyArmyQuery);
	enemyArmySize = kbUnitQueryExecute(enemyArmyQuery);
	// Bump up by 1 to just avoid running into this when the enemy explorer and its companion get in our base...
	if (enemyArmySize >= 3)
	{ // Main base is under attack.
		debugMilitary("******** Main base (" + mainBaseID + ") under attack.");
		debugMilitary("******** Enemy count " + enemyArmySize + ", my army count " + armySize);
		if (gDefenseReflexBaseID == mainBaseID)
		{ // We're already in a defense reflex for the main base.
			if (((armySize * 3.0) < enemyArmySize) &&
				(enemyArmySize > 6.0)) // Army at least 3x my size and more than 6 units total.
			{	// Too big to handle.
				if ((gDefenseReflexPaused == false) && (kbUnitCount(cMyID, cUnitTypeMinuteman, cUnitStateAlive) < 1) &&
					(kbUnitCount(cMyID, cUnitTypeypIrregular, cUnitStateAlive) < 1) &&
					(kbUnitCount(cMyID, cUnitTypeypPeasant, cUnitStateAlive) < 1) &&
					(kbUnitCount(cMyID, cUnitTypexpWarrior, cUnitStateAlive) < 2))
				{ // We weren't paused and don't have emergency soldiers with decaying health, do it.
					pauseDefenseReflex();
				}
				// Consider a call for help.
				panic = true;
				if (((time - lastHelpTime) < 300000) &&
					(lastHelpBaseID == gDefenseReflexBaseID)) // We called for help in the last five minutes, and it was this base.
				{
					panic = false;
				}
				if (((time - lastHelpTime) < 60000) &&
					(lastHelpBaseID != gDefenseReflexBaseID)) // We called for help anywhere in the last minute.
				{
					panic = false;
				}

				if (panic == true)
				{
					sendStatement(cPlayerRelationAllyExcludingSelf, cAICommPromptToAllyINeedHelpMyBase,
						kbBaseGetLocation(cMyID, gDefenseReflexBaseID));
					debugMilitary("I'm calling for help");
					lastHelpTime = time;
				}

				// Call back our attack if any.
				planID = aiPlanGetIDByTypeAndVariableType(cPlanCombat, cCombatPlanCombatType, cCombatPlanCombatTypeAttack);
				if (planID >= 0)
				{
					aiPlanDestroy(planID);
				}
			}
			else
			{	// Size is OK to handle, shouldn't be in paused mode.
				if (gDefenseReflexPaused == true) // Need to turn it active.
				{
					moveDefenseReflex(kbBaseGetLocation(cMyID, mainBaseID), cvDefenseReflexRadiusActive, mainBaseID);
				}
			}
		}
		else // Defense reflex wasn't set to main base.
		{	// Need to set the defense reflex to home base...doesn't matter if it was inactive or guarding another base,
			// home base trumps all.
			moveDefenseReflex(kbBaseGetLocation(cMyID, mainBaseID), cvDefenseReflexRadiusActive, mainBaseID);
			// This is a new defense reflex in the main base.  Consider making a chat about it.
			int enemyPlayerID = kbUnitGetPlayerID(kbUnitQueryGetResult(enemyArmyQuery, 0));
			if ((enemyPlayerID > 0) && (kbGetAge() > cAge1))
			{ // Consider sending a chat as long as we're out of age 1.
				int enemyPlayerUnitCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, enemyPlayerID,
				cUnitStateAlive, kbBaseGetLocation(cMyID, gDefenseReflexBaseID), 50.0);
				if (enemyPlayerUnitCount > (2 * gGoodArmyPop) && enemyPlayerUnitCount > (3 * armySize))
				{ // Enemy army is big, and we're badly outnumbered.
					sendStatement(enemyPlayerID, cAICommPromptToEnemyISpotHisArmyMyBaseOverrun, kbBaseGetLocation(cMyID, gDefenseReflexBaseID));
					debugMilitary("Sending OVERRUN prompt to player " + enemyPlayerID + ", he has " + enemyPlayerUnitCount + " units.");
					debugMilitary("I have " + armySize + " units, and " + gGoodArmyPop + " is a good army size.");
					return;
				}
				if (enemyPlayerUnitCount > (2 * gGoodArmyPop))
				{ // Big army, but I'm still in the fight.
					sendStatement(enemyPlayerID, cAICommPromptToEnemyISpotHisArmyMyBaseLarge, kbBaseGetLocation(cMyID, gDefenseReflexBaseID));
					debugMilitary("Sending LARGE ARMY prompt to player " + enemyPlayerID + ", he has " + enemyPlayerUnitCount + " units.");
					debugMilitary("I have " + armySize + " units, and " + gGoodArmyPop + " is a good army size.");
					return;
				}
				if (enemyPlayerUnitCount > gGoodArmyPop)
				{ // Moderate size.
					sendStatement(enemyPlayerID, cAICommPromptToEnemyISpotHisArmyMyBaseMedium, kbBaseGetLocation(cMyID, gDefenseReflexBaseID));
					debugMilitary("Sending MEDIUM ARMY prompt to player " + enemyPlayerID + ", he has " + enemyPlayerUnitCount + " units.");
					debugMilitary("I have " + armySize + " units, and " + gGoodArmyPop + " is a good army size.");
					return;
				}
				if ((enemyPlayerUnitCount < gGoodArmyPop) && (enemyPlayerUnitCount < armySize))
				{ // Small, and under control.
					sendStatement(enemyPlayerID, cAICommPromptToEnemyISpotHisArmyMyBaseSmall, kbBaseGetLocation(cMyID, gDefenseReflexBaseID));
					debugMilitary("Sending SMALL ARMY prompt to player " + enemyPlayerID + ", he has " + enemyPlayerUnitCount + " units.");
					debugMilitary("I have " + armySize + " units, and " + gGoodArmyPop + " is a good army size.");
					return;
				}
			}
		}
		return; // Do not check other bases.
	}

	// If we're this far, the main base is OK.  If we're in a defense reflex, see if we should stay in it, or change from
	// passive to active.

	if (gDefenseReflex == true) // Currently in a defense mode, let's see if it should remain
	{
		kbUnitQuerySetPosition(enemyArmyQuery, gDefenseReflexLocation);
		kbUnitQuerySetMaximumDistance(enemyArmyQuery, cvDefenseReflexSearchRadius);
		kbUnitQuerySetSeeableOnly(enemyArmyQuery, true);
		kbUnitQuerySetState(enemyArmyQuery, cUnitStateAlive);
		kbUnitQueryResetResults(enemyArmyQuery);
		enemyArmySize = kbUnitQueryExecute(enemyArmyQuery);
		debugMilitary("******** Defense reflex in base " + gDefenseReflexBaseID + " at " + gDefenseReflexLocation);
		debugMilitary("******** Enemy unit count: " + enemyArmySize + ", my unit count (defend+reserve) = " + armySize);
		for (i = 0; < enemyArmySize)
		{
			unitID = kbUnitQueryGetResult(enemyArmyQuery, i);
			protoUnitID = kbUnitGetProtoUnitID(unitID);
			if (i < 2)
			{
				debugMilitary("    " + unitID + " " + kbGetProtoUnitName(protoUnitID) + " " + kbUnitGetPosition(unitID));
			}
		}

		if (enemyArmySize < 2)
		{ // Abort, no enemies, or just one scouting unit.
			if (time >= gDefenseReflexTimeout || armySize >= gGoodArmyPop ||
				(gRevolutionType & cRevolutionFinland) == cRevolutionFinland)
			{ // Wait for a random period before moving to the forward base.
				debugMilitary("******** Ending defense reflex, no enemies remain.");
				endDefenseReflex();
			}
			return;
		}

		if (baseBuildingCount(gDefenseReflexBaseID, cPlayerRelationAlly, cUnitStateAlive) <= 0)
		{ // Abort, no alive ally buildings.
			debugMilitary("******** Ending defense reflex, base " + gDefenseReflexBaseID + " has no buildings.");
			endDefenseReflex();
			return;
		}

		if (kbBaseGetOwner(gDefenseReflexBaseID) <= 0)
		{ // Abort, base doesn't exist.
			debugMilitary("******** Ending defense reflex, base " + gDefenseReflexBaseID + " doesn't exist.");
			endDefenseReflex();
			return;
		}

		// The defense reflex for this base should remain in effect.
		// Check whether to start/end paused mode.
		int unitsNeeded = gGoodArmyPop;	// At least a credible army to fight them
		if (unitsNeeded > (enemyArmySize / 2))	// Or half their force, whichever is less.
		{
			unitsNeeded = enemyArmySize / 2;
		}
		bool shouldPause = false;
		if (((armySize < unitsNeeded) && ((armySize * 3.0) < enemyArmySize)) &&
			(kbUnitCount(cMyID, cUnitTypeMinuteman, cUnitStateAlive) < 1) &&
			(kbUnitCount(cMyID, cUnitTypeypIrregular, cUnitStateAlive) < 1) &&
			(kbUnitCount(cMyID, cUnitTypeypPeasant, cUnitStateAlive) < 1) &&
			(kbUnitCount(cMyID, cUnitTypexpWarrior, cUnitStateAlive) < 2))
		{
			shouldPause = true; // We should pause if not paused, or stay paused if we are.
		}

		if (gDefenseReflexPaused == false)
		{ // Not currently paused, do it.
			if (shouldPause == true)
			{
				pauseDefenseReflex();
				debugMilitary("******** Enemy count " + enemyArmySize + ", my army count " + armySize);
			}
		}
		else
		{ // Currently paused...should we remain paused, or go active?
			if (shouldPause == false)
			{
				moveDefenseReflex(gDefenseReflexLocation, cvDefenseReflexRadiusActive, gDefenseReflexBaseID); // Activate it
				debugMilitary("******** Enemy count " + enemyArmySize + ", my army count " + armySize);
			}
		}
		if (shouldPause == true)
		{ // Consider a call for help.
			panic = true;
			if (((time - lastHelpTime) < 300000) &&
				(lastHelpBaseID == gDefenseReflexBaseID)) // We called for help in the last five minutes, and it was this base.
			{
				panic = false;
			}
			if (((time - lastHelpTime) < 60000) &&
				(lastHelpBaseID != gDefenseReflexBaseID)) // We called for help anywhere in the last minute.
			{
				panic = false;
			}

			if (panic == true)
			{
				sendStatement(cPlayerRelationAlly, cAICommPromptToAllyINeedHelpMyBase, kbBaseGetLocation(cMyID, gDefenseReflexBaseID));
				debugMilitary("     I'm calling for help.");
				lastHelpTime = xsGetTime();
			}

			// Call back our attack if any.
			// TODO: Not main base, maybe not always worth defending?
			planID = aiPlanGetIDByTypeAndVariableType(cPlanCombat, cCombatPlanCombatType, cCombatPlanCombatTypeAttack);
			if (planID >= 0)
			{
				aiPlanDestroy(planID);
			}
		}
		return; // Done...we're staying in defense mode for this base, and have paused or gone active as needed.
	}

	// Not in a defense reflex, see if one is needed.

	// Check other bases
	int baseCount = -1;
	int baseIndex = -1;
	int baseID = -1;
	vector baseLoc = cInvalidVector;

	baseCount = kbBaseGetNumber(cMyID);
	unitsNeeded = gGoodArmyPop / 2;
	if (baseCount > 0)
	{
		for (baseIndex = 0; < baseCount)
		{
			baseID = kbBaseGetIDByIndex(cMyID, baseIndex);
			if (baseID == kbBaseGetMainID(cMyID))
			{
				continue; // Already checked main at top of function.
			}

			if (baseBuildingCount(baseID, cPlayerRelationAlly, cUnitStateAlive) <= 0)
			{
				debugMilitary("Base " + baseID + " has no alive buildings.");
				continue; // Skip bases that have no buildings.
			}

			// Check for overrun base.
			baseLoc = kbBaseGetLocation(cMyID, baseID);
			kbUnitQuerySetPosition(enemyArmyQuery, baseLoc);
			kbUnitQuerySetMaximumDistance(enemyArmyQuery, cvDefenseReflexSearchRadius);
			kbUnitQuerySetSeeableOnly(enemyArmyQuery, true);
			kbUnitQuerySetState(enemyArmyQuery, cUnitStateAlive);
			kbUnitQueryResetResults(enemyArmyQuery);
			enemyArmySize = kbUnitQueryExecute(enemyArmyQuery);
			// Do I need to call for help?

			if ((enemyArmySize >= 2))
			{ // More than just a scout...set defense reflex for this base.
				moveDefenseReflex(baseLoc, cvDefenseReflexRadiusActive, baseID);

				debugMilitary("******** Enemy count is " + enemyArmySize + ", my army size is " + armySize);

				if ((enemyArmySize > (armySize * 2.0)) && (enemyArmySize > 6)) // Double my size, get help...
				{
				panic = true;
				if (((time - lastHelpTime) < 300000) &&
					(lastHelpBaseID == baseID)) // We called for help in the last five minutes, and it was this base.
				{
					panic = false;
				}
				if (((time - lastHelpTime) < 60000) &&
					(lastHelpBaseID != baseID)) // We called for help anywhere in the last minute.
				{
					panic = false;
				}

				if (panic == true)
				{
					// Don't kill other missions, this isn't the main base. Just call for help.
					sendStatement(cPlayerRelationAllyExcludingSelf, cAICommPromptToAllyINeedHelpMyBase, kbBaseGetLocation(cMyID, baseID));
					debugMilitary("I'm calling for help.");
					lastHelpTime = time;
				}
				}
				else
				{
					moveDefenseReflex(baseLoc, cvDefenseReflexRadiusActive, baseID);
				}
				return; // If we're in trouble in any base, ignore the others.
			}
		} // For baseIndex...
	}
}

//==============================================================================
// Levy Functions
//==============================================================================
rule useLevy
inactive
minInterval 10
{
	static int arrayID = -1;
	if (arrayID == -1) // First run.
	{
		arrayID = arrayCreateInt(1, "Levy Plans");
	}

	int tcQueryID = createSimpleUnitQuery(cUnitTypeAgeUpBuilding, cMyID, cUnitStateAlive);
	int numberResults = kbUnitQueryExecute(tcQueryID);
	int townCenterID = -1;
	int techID = -1;

	arraySetNumElements(arrayID, numberResults, true);

	if (cMyCiv == cCivDEAmericans)
		techID = cTechDEUSLevy;
	else if (cMyCiv == cCivDEHausa)
	{
		if (kbResourceGet(cResourceInfluence) < 1000.0)
			return; // If we do not have excess influence then do not consider this.
		techID = cTechDEAllegianceSonghaiLevyRaiders;
	}
	else
		techID = cTechLevy;
	vector tcLocation = cInvalidVector;
	int allyCount = -1;
	int enemyCount = -1;
	int levyPlan = -1;
	int numberLevyPlans = aiPlanGetNumberByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID);
	for (i = 0; < numberLevyPlans)
	{
		levyPlan = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true, i);
		for (j = 0; < numberResults)
		{
			townCenterID = kbUnitQueryGetResult(tcQueryID, j);
			if (townCenterID == aiPlanGetVariableInt(levyPlan, cResearchPlanBuildingID, 0))
			{
				arraySetInt(arrayID, j, levyPlan);
			}
		}
	}
	
	for (i = 0; < numberResults)
	{
		townCenterID = kbUnitQueryGetResult(tcQueryID, i);
		levyPlan = arrayGetInt(arrayID, i);
		if (kbBuildingTechGetStatus(techID, townCenterID) == cTechStatusObtainable) // TC can still use Levy.
		{

			tcLocation = kbUnitGetPosition(townCenterID);
			enemyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary,
				cPlayerRelationEnemyNotGaia, cUnitStateAlive, tcLocation, 40.0);
			allyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary,
				cPlayerRelationAlly, cUnitStateAlive, tcLocation, 40.0);

			if (enemyCount >= allyCount + 5) // We're behind by 5 or more.
			{
				if ((levyPlan < 0) && ((cMyCiv != cCivDEAmericans) || (numberLevyPlans < 1)))
				{
					debugMilitary("Starting a levy plan, there are " + enemyCount +
						" enemy units in my base against " + allyCount + " friendlies");
					createSimpleResearchPlanSpecificBuilding(techID, townCenterID, cMilitaryEscrowID, 99, 99);
					if (cMyCiv == cCivDEAmericans || cMyCiv == cCivDEHausa)
					{
						return; // We made one plan and shouldn't make more because of the global cooldown.
					}
				}
			}
			else // No need to call levy.
			{
				if (levyPlan >= 0) // We have a plan we must maybe destroy.
				{
					if (townCenterID == aiPlanGetVariableInt(levyPlan, cResearchPlanBuildingID, 0))
					{
						debugMilitary("Destroying levy plan because we're not outnumbered anymore");
						aiPlanDestroy(levyPlan);
					}
				}
			}
		}
	}
}

//==============================================================================
// useWarParties
//==============================================================================
rule useWarParties
inactive
minInterval 10
{
	static int partyPlan = -1; // Save the ID of the plan so we can potentially cancel it.

	int scoutingPartyStatus = -1;
	int raidingPartyStatus = -1;
	int warPartyStatus = -1;
	if (cMyCiv == cCivXPAztec)
	{
		scoutingPartyStatus = kbTechGetStatus(cTechBigAztecScoutingParty);
		raidingPartyStatus = kbTechGetStatus(cTechBigAztecRaidingParty);
		warPartyStatus = kbTechGetStatus(cTechBigAztecWarParty);
	}
	else if (cMyCiv == cCivXPIroquois)
	{
		scoutingPartyStatus = kbTechGetStatus(cTechBigIroquoisScoutingParty);
		raidingPartyStatus = kbTechGetStatus(cTechBigIroquoisRaidingParty);
		warPartyStatus = kbTechGetStatus(cTechBigIroquoisWarParty);
	}
	else if (cMyCiv == cCivDEInca)
	{
		scoutingPartyStatus = kbTechGetStatus(cTechdeBigIncaScoutingParty);
		raidingPartyStatus = kbTechGetStatus(cTechdeBigIncaRaidingParty);
		warPartyStatus = kbTechGetStatus(cTechdeBigIncaWarParty);
	}

	if ((scoutingPartyStatus == cTechStatusActive) &&
		(raidingPartyStatus == cTechStatusActive) && 
		(warPartyStatus == cTechStatusActive))
	{
		xsDisableSelf();
	}

	vector mainBaseVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	int townCenterID = getClosestUnit(cUnitTypeTownCenter, cMyID, cUnitStateAlive, mainBaseVec, 40.0);
	if (townCenterID < 0)
	{
		return; // Can't use war parties if no Town Center alive in the area we're scanning for enemies.
	}
	int enemyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
		cUnitStateAlive, mainBaseVec, 40.0);
	int allyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationAlly,
		cUnitStateAlive, mainBaseVec, 40.0);
	

	if (partyPlan < 0) // No plan, see if we need one.
	{
		if (enemyCount >= allyCount + 5) // We're behind by 5 or more.
		{
			debugMilitary("Starting a WarParty plan, there are: " + enemyCount + " enemies in my base against: "
				+ allyCount + " friendlies");

			if (cMyCiv == cCivXPAztec)
			{
				if (scoutingPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechBigAztecScoutingParty, townCenterID,
						cMilitaryEscrowID, 99); 
				}
				else if (raidingPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechBigAztecRaidingParty, townCenterID,
						cMilitaryEscrowID, 99);
				}
				else if (warPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechBigAztecWarParty, townCenterID,
						cMilitaryEscrowID, 99);
				}
			}
			else if (cMyCiv == cCivXPIroquois)
			{
				if (scoutingPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechBigIroquoisScoutingParty, townCenterID,
						cMilitaryEscrowID, 99); 
				}
				else if (raidingPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechBigIroquoisRaidingParty, townCenterID,
						cMilitaryEscrowID, 99);
				}
				else if (warPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechBigIroquoisWarParty, townCenterID,
						cMilitaryEscrowID, 99);
				}
			}
			else if (cMyCiv == cCivDEInca)
			{
				if (scoutingPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechdeBigIncaScoutingParty, townCenterID,
						cMilitaryEscrowID, 99); 
				}
				else if (raidingPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechdeBigIncaRaidingParty, townCenterID,
						cMilitaryEscrowID, 99);
				}
				else if (warPartyStatus == cTechStatusObtainable)
				{
					partyPlan = createSimpleResearchPlanSpecificBuilding(cTechdeBigIncaWarParty, townCenterID,
						cMilitaryEscrowID, 99);
				}
			}
		}
	}
	else // Plan exists, make sure it's still needed.
	{
		if ((enemyCount >= allyCount + 2) && (aiPlanGetState(partyPlan) >= 0))
		{	// Do nothing.
			debugMilitary("We're still under attack and waiting for WarParty");
		}
		else
		{
			debugMilitary("Cancelling WarParty");
			aiPlanDestroy(partyPlan);
			partyPlan = -1;
		}
	}
}

//==============================================================================
/* useWarPartiesLakota
	Get the maximum amount of soldiers which is after 30 minutes.
	I'm going to assume we reach the second age after a maximum of 5 minutes
	and only then does this minInterval counter start.
*/
//==============================================================================
rule useWarPartiesLakota
inactive
minInterval 1500
{
	xsSetRuleMinIntervalSelf(60); // Keep this rule up to date more frequently now.
	if (xsGetTime() < 30 * 60 * 1000) // We haven't passed 30 minutes in game yet.
	{
		return;
	}
	
	bool canDisableSelf = researchSimpleTech(cTechBigSiouxDogSoldiers, -1, 
		getUnit(cUnitTypeAgeUpBuilding, cMyID, cUnitStateAlive), 50);
		
	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

//==============================================================================
// useAsianLevy
// TODO this can't handle multiple Town Centers yet.
//==============================================================================
rule useAsianLevy
inactive
minInterval 10
{
	static int levyPlan = -1;
	vector mainBaseVec = cInvalidVector;

	mainBaseVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));

	int towncenterID = getUnitByLocation(cUnitTypeAgeUpBuilding, cMyID, cUnitStateAlive, mainBaseVec, 40.0);

	int levy1 = cTechypAssemble;
	int levy2 = cTechypMuster;
	if ((cMyCiv == cCivIndians) || (cMyCiv == cCivSPCIndians))
	{
		levy1 = cTechypAssembleIndians;
		levy2 = cTechypMusterIndians;
	}

	if ((towncenterID < 0) || ((kbBuildingTechGetStatus(levy1, towncenterID) != cTechStatusObtainable) &&
		(kbBuildingTechGetStatus(levy2, towncenterID) != cTechStatusObtainable)))
	{
		if (levyPlan >= 0)
		{
			debugMilitary("Destroying levy plan");
			aiPlanDestroy(levyPlan);
			levyPlan = -1;
		}
		return;
	}

	int enemyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
		cUnitStateAlive, mainBaseVec, 40.0);
	int enemyCavalryCount = getUnitCountByLocation(cUnitTypeAbstractCavalry, cPlayerRelationEnemyNotGaia,
		cUnitStateAlive, mainBaseVec, 40.0) +
		getUnitCountByLocation(cUnitTypeAbstractCoyoteMan, cPlayerRelationEnemyNotGaia, cUnitStateAlive, mainBaseVec, 40.0);
	int allyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationAlly, cUnitStateAlive, mainBaseVec, 40.0);

	if (levyPlan < 0)
	{ // Create a new plan.
		if (enemyCount >= (allyCount + 5))
		{ // We're behind by 5 or more.
			if (kbBuildingTechGetStatus(levy1, towncenterID) == cTechStatusObtainable && (enemyCavalryCount * 2 >= enemyCount))
			{
				levyPlan = createSimpleResearchPlanSpecificBuilding(levy1, towncenterID, cMilitaryEscrowID, 99); // Extreme priority
			}
			else if (kbBuildingTechGetStatus(levy2, towncenterID) == cTechStatusObtainable)
			{
				levyPlan = createSimpleResearchPlanSpecificBuilding(levy2, towncenterID, cMilitaryEscrowID, 99); // Extreme priority
			}
			if (levyPlan >= 0)
			{
				debugMilitary("Starting a levy plan, there are " + enemyCount + " enemy units in my base against " + allyCount + " friendlies");
				aiPlanSetDesiredResourcePriority(levyPlan, 85);
			}
		}
	}
	else // Plan exists, make sure it's still needed.
	{
		if ((enemyCount > (allyCount + 2)) && (aiPlanGetState(levyPlan) >= 0))
		{ // Do nothing
			debugMilitary("Still waiting for levy.");
		}
		else
		{
			debugMilitary("Destroying levy plan.");
			aiPlanDestroy(levyPlan);
			levyPlan = -1;
		}
	}
}

//==============================================================================
// consulateLevy
// We assume our Consulate is in our main base and we can only defend that base with this logic.
//==============================================================================
rule consulateLevy
inactive
minInterval 10
{
	// Disable this rule whenever we've used the Levy or we've changed relations.
	int techStatus = kbTechGetStatus(cTechypConsulateOttomansSettlerCombat);
	if ((techStatus == cTechStatusActive) ||
		(techStatus != cTechStatusObtainable))
	{
		xsDisableSelf();
		return;
	}
	
	int consulateID = getUnit(cUnitTypeypConsulate, cMyID, cUnitStateAlive);
	if (consulateID < 0)
	{
		return;
	}
	vector mainBaseVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));

	int enemyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, 
		cPlayerRelationEnemyNotGaia, cUnitStateAlive, mainBaseVec, 40.0);
	int allyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, 
		cPlayerRelationAlly, cUnitStateAlive, mainBaseVec, 40.0);
	
	int levyPlan = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechypConsulateOttomansSettlerCombat);
	if (levyPlan < 0) // No plan, see if we need one.
	{
		if (enemyCount >= allyCount + 5)
		{ // We're behind by 5 or more.
			debugMilitary("Starting Consulate levy plan, there are " + enemyCount + 
				" enemy units in my base against " + allyCount + " allies");
			createSimpleResearchPlanSpecificBuilding(cTechypConsulateOttomansSettlerCombat,
				consulateID, cMilitaryEscrowID, 99, 99);
		}
	}
	else // Plan exists, make sure it's still needed.
	{
		if ((enemyCount > allyCount + 2) && (aiPlanGetState(levyPlan) >= 0))
		{ // Do nothing
			debugMilitary("Still waiting for Consulate levy");
		}
		else
		{
			debugMilitary("Destroying Consulate levy plan");
			aiPlanDestroy(levyPlan);
		}
	}
}


//==============================================================================
// useAfricanLevy
// We can only defend our main base with this logic.
//==============================================================================
rule useAfricanLevy
inactive
minInterval 10
{
	static int levyMaintainPlan = -1;
	static float spearmanCost = -1.0;
	static float bowmanCost = -1.0;
	static float gunnerCost = -1.0;
	if (spearmanCost == -1.0) // First run.
	{
		spearmanCost = kbUnitCostPerResource(cUnitTypedeSpearmanLevy, cResourceInfluence);
		bowmanCost = kbUnitCostPerResource(cUnitTypedeBowmanLevy, cResourceInfluence);
		gunnerCost = kbUnitCostPerResource(cUnitTypedeGunnerLevy, cResourceInfluence);
	}
	vector mainBaseVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	int palaceID = getUnitByLocation(cUnitTypedePalace, cMyID, cUnitStateAlive, mainBaseVec, 40.0);
	int houseID = getUnitByLocation(gHouseUnit, cMyID, cUnitStateAlive, mainBaseVec, 40.0);
	float currentInfluenceAmount = kbResourceGet(cResourceInfluence);

	if (mainBaseVec == cInvalidVector || (houseID < 0 && palaceID < 0) ||
		currentInfluenceAmount < spearmanCost)
	{
		if (levyMaintainPlan >= 0)
		{
			aiPlanDestroy(levyMaintainPlan);
			levyMaintainPlan = -1;
		}
		return;
	}

	int enemyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia, cUnitStateAlive, mainBaseVec, 40.0);
	int enemyCavalryCount = getUnitCountByLocation(cUnitTypeAbstractCavalry, cPlayerRelationEnemyNotGaia, cUnitStateAlive, mainBaseVec, 40.0) +
		getUnitCountByLocation(cUnitTypeAbstractCoyoteMan, cPlayerRelationEnemyNotGaia, cUnitStateAlive, mainBaseVec, 40.0);
	int allyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationAlly, cUnitStateAlive, mainBaseVec, 40.0);

	if (enemyCount > allyCount + 5)
	{	// We're behind by 5 or more thus we need to get some levies.

		int levyPUID = -1;
		int numberToMaintain = 0;
		if (enemyCavalryCount * 2 >= enemyCount)
		{ // Counter a force consisting of mainly Cavalry with Spearman.
			levyPUID = cUnitTypedeSpearmanLevy;
			numberToMaintain = currentInfluenceAmount / spearmanCost;
		}
		else if (palaceID >= 0)
		{
			levyPUID = cUnitTypedeGunnerLevy;
			numberToMaintain = currentInfluenceAmount / gunnerCost;
		}
		else
		{
			levyPUID = cUnitTypedeBowmanLevy;
			numberToMaintain = currentInfluenceAmount / bowmanCost;
		}

		// Don't overtrain when we have a lot of Influence.
		if (numberToMaintain > 6)
		{
			numberToMaintain = 6;
		}

		debugMilitary("We have to use levies and decided we should make " + numberToMaintain + " " + kbGetProtoUnitName(levyPUID));
		// If we don't have a plan make one otherwise adjust how many to maintain for the existing plan.
		if (levyMaintainPlan < 0)
		{
			levyMaintainPlan = createSimpleMaintainPlan(levyPUID, numberToMaintain, false, kbBaseGetMainID(cMyID), 1);
			aiPlanSetDesiredResourcePriority(levyMaintainPlan, 99);
		}
		else
		{
			aiPlanSetVariableInt(levyMaintainPlan, cTrainPlanUnitType, 0, levyPUID);
			aiPlanSetVariableInt(levyMaintainPlan, cTrainPlanNumberToMaintain, 0, numberToMaintain);
		}
	}
	else if (levyMaintainPlan >= 0)
	{
		aiPlanDestroy(levyMaintainPlan);
		levyMaintainPlan = -1;
	}
}

//==============================================================================
// Explorer Rescue and Ransom
//==============================================================================
rule rescueExplorer
inactive
minInterval 120
{
	static int rescuePlan = -1;

	// Destroy old rescue plan (if any).
	if (rescuePlan >= 0)
	{
		aiPlanDestroy(rescuePlan);
		rescuePlan = -1;
		debugMilitary("Killing old rescue plan");
	}
	
	// Let the ransom rule take care of this if we have enough coin.
	if (kbResourceGet(cResourceGold) >= 1300)
	{
		debugMilitary("Ransom explorer instead of attempting to rescue");
		return;
	}

	int fallenExplorerID = aiGetFallenExplorerID();
	// We need a fallen Explorer for all of this to make sense right.
	if (fallenExplorerID < 0)
	{
		return;
	}
	
	// Only try to rescue an Explorer that can actually be revived.
	if (kbUnitGetHealth(fallenExplorerID) < 0.3)
	{
		debugMilitary("Explorer too weak to be rescued");
		return;
	}

	// Decide on which unit type to use for rescue attempt.
	int scoutType = findBestScoutType();
	
	// Get position of fallen explorer and send scout unit there.
	vector fallenExplorerLocation = kbUnitGetPosition(fallenExplorerID);
	rescuePlan = aiPlanCreate("Rescue Explorer", cPlanExplore);
	if (rescuePlan >= 0)
	{
		aiPlanAddUnitType(rescuePlan, scoutType, 1, 1, 1);
		aiPlanAddWaypoint(rescuePlan, fallenExplorerLocation);
		aiPlanSetVariableBool(rescuePlan, cExplorePlanDoLoops, 0, false);
		aiPlanSetVariableBool(rescuePlan, cExplorePlanAvoidingAttackedAreas, 0, false);
		aiPlanSetVariableInt(rescuePlan, cExplorePlanNumberOfLoops, 0, -1);
		aiPlanSetRequiresAllNeedUnits(rescuePlan, true);
		aiPlanSetDesiredPriority(rescuePlan, 42);
		aiPlanSetActive(rescuePlan);
		debugMilitary("Trying to rescue explorer");
	}
}


rule ransomExplorer
inactive
minInterval 120
{
	int fallenExplorerID = aiGetFallenExplorerID();
	// Use only when we have enough coin in the bank.
	if ((fallenExplorerID < 0) || (kbResourceGet(cResourceGold) < 1300))
	{
		return;
	}

	if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanProtoUnitCommandID, cProtoUnitCommandRansomExplorer) >= 0)
	{
		return;
	}

	int tcID = getUnit(cUnitTypeTownCenter, cMyID, cUnitStateAlive);

	if (tcID < 0)
	{
		return;
	}

	aiRansomExplorer(fallenExplorerID, cMilitaryEscrowID, getUnit(cUnitTypeTownCenter, cMyID, cUnitStateAlive));
	debugMilitary("Creating ransom explorer plan");
}

//==============================================================================
// Monopoly Functions
//==============================================================================
rule monopolyManager
minInterval 21
inactive
{
	if (aiTreatyActive() == true)
	{
		debugMilitary("Monopoly unavailable because treaty is active still");
		return;
	}
	
	if (kbUnitCount(cMyID, cUnitTypeTradingPost, cUnitStateAlive) < 1)
	{
		return;
	}
	
	// Check if we have enough Trading Posts to activate the Monopoly.
	if (aiReadyForTradeMonopoly() == true)
	{
		debugMilitary("We have enough Trading Posts to start a monopoly");
		if (kbResourceGet(cResourceGold) >= kbTechCostPerResource(cTechTradeMonopoly, cResourceGold) &&
			kbResourceGet(cResourceFood) >= kbTechCostPerResource(cTechTradeMonopoly, cResourceFood) &&
			kbResourceGet(cResourceWood) >= kbTechCostPerResource(cTechTradeMonopoly, cResourceWood))
		{
			debugMilitary("We have enough resources to activate the monopoly, so attempt it");
			if (aiDoTradeMonopoly() == true)
			{
				debugMilitary("We've started a trade monopoly");
			}
			else
			{
				debugMilitary("We've tried to start a monopoly but it somehow failed");
			}
		}
		else
		{
			debugMilitary("But we don't have the resources to activate it");
		}
	}
}

void KOTHVictoryStartHandler(int teamID = -1)
{
	// Sanity check, idk if needed at all.
	if (teamID < 0)
	{
		return;
	}
	debugMilitary("King of the Hill timer started by team: " + teamID);

	gIsKOTHRunning = true;
	gKOTHTeam = teamID;
}

void KOTHVictoryEndHandler(int teamID = -1)
{
	gIsKOTHRunning = false;
	gKOTHTeam = -1;
	debugMilitary("Team: " + teamID + " have not completed the King of the Hill timer");
}

rule summerPalaceTacticMonitor
inactive
mininterval 1
{
	// Check for the Summer Palace, if we don't find one we've lost it and we can disable this Rule.
	int summerPalaceID = getUnit(gSummerPalacePUID);
	if (summerPalaceID < 0)
	{
		xsDisableSelf();
		return;
	}

	for (i = 0; < 3)
	{
		int armyPUID = kbUnitPickGetResult(gLandUnitPicker, i);
		switch (armyPUID)
		{
			case cUnitTypeypTerritorialArmy:
			{
				aiUnitSetTactic(summerPalaceID, cTacticTerritorialArmy);
				xsSetRuleMinIntervalSelf(196);
				return;
			}
			case cUnitTypeypForbiddenArmy:
			{
				aiUnitSetTactic(summerPalaceID, cTacticForbiddenArmy);
				xsSetRuleMinIntervalSelf(295);
				return;
			}
			case cUnitTypeypImperialArmy:
			{
				aiUnitSetTactic(summerPalaceID, cTacticImperialArmy);
				xsSetRuleMinIntervalSelf(256);
				return;
			}
			case cUnitTypeypOldHanArmy:
			{
				aiUnitSetTactic(summerPalaceID, cTacticOldHanArmy);
				xsSetRuleMinIntervalSelf(154);
				return;
			}
			case cUnitTypeypStandardArmy:
			{
				aiUnitSetTactic(summerPalaceID, cTacticStandardArmy);
				xsSetRuleMinIntervalSelf(152);
				return;
			}
			case cUnitTypeypMingArmy:
			{
				aiUnitSetTactic(summerPalaceID, cTacticMingArmy); 
				xsSetRuleMinIntervalSelf(159);
				return;
			}
		}
	}

	// We didn't find any suitable armies in our unit picker, default to Standard Army.
	aiUnitSetTactic(summerPalaceID, cTacticStandardArmy);
	xsSetRuleMinIntervalSelf(152);
}

rule mansabdarMonitor
inactive
minInterval 30
{
	if ( (kbUnitCount(cMyID, cUnitTypeypWICharminarGate2, cUnitStateAlive) < 0) &&
		(kbUnitCount(cMyID, cUnitTypeypWICharminarGate3, cUnitStateAlive) < 0) &&
		(kbUnitCount(cMyID, cUnitTypeypWICharminarGate4, cUnitStateAlive) < 0) &&
		(kbUnitCount(cMyID, cUnitTypeypWICharminarGate5, cUnitStateAlive) < 0) )
	{
		return;
	}

	static int mansabdarRajputPlan = -1;
	static int mansabdarSepoyPlan = -1;
	static int mansabdarGurkhaPlan = -1;
	static int mansabdarSowarPlan = -1;
	static int mansabdarZamburakPlan = -1;
	static int mansabdarFlailElephantPlan = -1;
	static int mansabdarMahoutPlan = -1;
	static int mansabdarHowdahPlan = -1;
	static int mansabdarSiegeElephantPlan = -1;

	int numRajputs = -1;
	int numSepoys = -1;
	int numGurkhas = -1;
	int numSowars = -1;
	int numZamburaks = -1;
	int numFlailElephants = -1;
	int numMahouts = -1;
	int numHowdahs = -1;
	int numSiegeElephants = -1;

	// Check number of rajputs, maintain mansabdar rajput as long as there are at least 10
	numRajputs = kbUnitCount(cMyID, cUnitTypeypRajput, cUnitStateAlive);
	if (numRajputs >= 10)
	{
		// Create/update maintain plan
		if (mansabdarRajputPlan < 0)
		{
			mansabdarRajputPlan = createSimpleMaintainPlan(cUnitTypeypRajputMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarRajputPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarRajputPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarRajputPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of sepoys, maintain mansabdar sepoy as long as there are at least 10
	numSepoys = kbUnitCount(cMyID, cUnitTypeypSepoy, cUnitStateAlive);
	if (numSepoys >= 10)
	{
		// Create/update maintain plan
		if (mansabdarSepoyPlan < 0)
		{
			mansabdarSepoyPlan = createSimpleMaintainPlan(cUnitTypeypSepoyMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarSepoyPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarSepoyPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarSepoyPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of gurkhas, maintain mansabdar gurkha as long as there are at least 10
	numGurkhas = kbUnitCount(cMyID, cUnitTypeypNatMercGurkha, cUnitStateAlive);
	if (numGurkhas >= 10)
	{
		// Create/update maintain plan
		if (mansabdarGurkhaPlan < 0)
		{
			mansabdarGurkhaPlan = createSimpleMaintainPlan(cUnitTypeypNatMercGurkhaJemadar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarGurkhaPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarGurkhaPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarGurkhaPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of sowars, maintain mansabdar sowar as long as there are at least 7
	numSowars = kbUnitCount(cMyID, cUnitTypeypSowar, cUnitStateAlive);
	if (numSowars >= 7)
	{
		// Create/update maintain plan
		if (mansabdarSowarPlan < 0)
		{
			mansabdarSowarPlan = createSimpleMaintainPlan(cUnitTypeypSowarMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarSowarPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarSowarPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarSowarPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of zamburaks, maintain mansabdar zamburak as long as there are at least 10
	numZamburaks = kbUnitCount(cMyID, cUnitTypeypZamburak, cUnitStateAlive);
	if (numZamburaks >= 10)
	{
		// Create/update maintain plan
		if (mansabdarZamburakPlan < 0)
		{
			mansabdarZamburakPlan = createSimpleMaintainPlan(cUnitTypeypZamburakMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarZamburakPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarZamburakPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarZamburakPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of flail elephants, maintain mansabdar flail elephant as long as there are at least 6
	numFlailElephants = kbUnitCount(cMyID, cUnitTypeypMercFlailiphant, cUnitStateAlive);
	if (numFlailElephants >= 6)
	{
		// Create/update maintain plan
		if (mansabdarFlailElephantPlan < 0)
		{
			mansabdarFlailElephantPlan = createSimpleMaintainPlan(cUnitTypeypMercFlailiphantMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarFlailElephantPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarFlailElephantPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarFlailElephantPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of mahouts, maintain mansabdar mahout as long as there are at least 3
	numMahouts = kbUnitCount(cMyID, cUnitTypeypMahout, cUnitStateAlive);
	if (numMahouts >= 3)
	{
		// Create/update maintain plan
		if (mansabdarMahoutPlan < 0)
		{
			mansabdarMahoutPlan = createSimpleMaintainPlan(cUnitTypeypMahoutMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarMahoutPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarMahoutPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarMahoutPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of howdahs, maintain mansabdar howdah as long as there are at least 3
	numHowdahs = kbUnitCount(cMyID, cUnitTypeypHowdah, cUnitStateAlive);
	if (numHowdahs >= 3)
	{
		// Create/update maintain plan
		if (mansabdarHowdahPlan < 0)
		{
			mansabdarHowdahPlan = createSimpleMaintainPlan(cUnitTypeypHowdahMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarHowdahPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarHowdahPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarHowdahPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	// Check number of siege elephants, maintain mansabdar siege elephant as long as there are at least 3
	numSiegeElephants = kbUnitCount(cMyID, cUnitTypeypSiegeElephant, cUnitStateAlive);
	if (numSiegeElephants >= 3)
	{
		// Create/update maintain plan
		if (mansabdarSiegeElephantPlan < 0)
		{
			mansabdarSiegeElephantPlan = createSimpleMaintainPlan(cUnitTypeypSiegeElephantMansabdar, 1, false, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(mansabdarSiegeElephantPlan , cTrainPlanNumberToMaintain, 0, 1);
		}
	}
	else
	{
		// Update maintain plan, provided it exists
		if (mansabdarSiegeElephantPlan >= 0)
		{
			aiPlanSetVariableInt(mansabdarSiegeElephantPlan , cTrainPlanNumberToMaintain, 0, 0);
		}
	}
}


rule daimyoMonitor
inactive
minInterval 30
{
	static int daimyo1Plan = -1;
	static int daimyo2Plan = -1;
	static int daimyo3Plan = -1;
	static int shogunPlan = -1;

	int theShogunateID = getUnit(gTheShogunatePUID);
	// Check for The Shogunate, if we don't find one we've lost it and we can disable this Rule.
	if (theShogunateID < 0)
	{
		aiPlanDestroy(daimyo1Plan);
		aiPlanDestroy(daimyo2Plan);
		aiPlanDestroy(daimyo3Plan);
		aiPlanDestroy(shogunPlan);
		xsDisableSelf();
		return;
	}
	
	int mainBaseID = kbBaseGetMainID(cMyID);
	int numberToMaintain = 0;

	if ((daimyo1Plan < 0) && (kbTechGetStatus(cTechYPHCShipDaimyoAizu) == cTechStatusActive))
	{
		daimyo1Plan = createSimpleMaintainPlan(cUnitTypeypDaimyoKiyomasa, 1, false, mainBaseID, 1);
	}
	if (daimyo2Plan < 0)
	{
		daimyo2Plan = createSimpleMaintainPlan(cUnitTypeypDaimyoMasamune, 1, false, mainBaseID, 1);
	}
	if ((daimyo3Plan < 0) && (kbTechGetStatus(cTechYPHCShipDaimyoSatsuma) == cTechStatusActive))
	{
		daimyo3Plan = createSimpleMaintainPlan(cUnitTypeypDaimyoMototada, 1, false, mainBaseID, 1);
	}
	if ((shogunPlan < 0) && (kbTechGetStatus(cTechYPHCShipShogunate) == cTechStatusActive))
	{
		shogunPlan = createSimpleMaintainPlan(cUnitTypeypShogunTokugawa, 1, false, mainBaseID, 1);
	}

	if (aiGetMilitaryPop() >= 15)
	{
		numberToMaintain = 1;
	}

	// 1 Daimyo and 1 Shogun.
	if (daimyo1Plan >= 0)
	{
		aiPlanSetVariableInt(daimyo1Plan, cTrainPlanNumberToMaintain, 0, numberToMaintain);
	}
	if (daimyo2Plan >= 0)
	{
		if (daimyo1Plan < 0)
		{
			aiPlanSetVariableInt(daimyo2Plan, cTrainPlanNumberToMaintain, 0, numberToMaintain);
		}
		else
		{
			aiPlanSetVariableInt(daimyo2Plan, cTrainPlanNumberToMaintain, 0, 0);
		}
	}
	if (daimyo3Plan >= 0)
	{
		if ((daimyo1Plan < 0) && (daimyo2Plan < 0))
		{
			aiPlanSetVariableInt(daimyo3Plan, cTrainPlanNumberToMaintain, 0, numberToMaintain);
		}
		else
		{
			aiPlanSetVariableInt(daimyo3Plan, cTrainPlanNumberToMaintain, 0, 0);
		}
	}

	if (shogunPlan >= 0)
	{
		aiPlanSetVariableInt(shogunPlan, cTrainPlanNumberToMaintain, 0, numberToMaintain);
	}
}
