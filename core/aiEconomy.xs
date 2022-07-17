//==============================================================================
/* aiEconomy.xs

	This file is intended for economy related stuffs, such as gatherer
	management and resource building construction.

*/
//==============================================================================

//==============================================================================
//==============================================================================
// Economy
//==============================================================================
//==============================================================================

//==============================================================================
// updateResourceDistribution
/*
	Predict our resource needs based on plan costs and resource crates we are going
	to ship.
*/
//==============================================================================
void updateResourceDistribution()
{
	float planFoodNeeded = 0.0;
	float planWoodNeeded = 0.0;
	float planGoldNeeded = 0.0;
	float totalPlanFoodNeeded = 0.0;
	float totalPlanWoodNeeded = 0.0;
	float totalPlanGoldNeeded = 0.0;
	float foodAmount = 0.0;
	float woodAmount = 0.0;
	float goldAmount = 0.0;
	float foodNeeded = 0.0;
	float woodNeeded = 0.0;
	float goldNeeded = 0.0;
	float totalNeeded = 0.0;
	int planID = -1;
	int trainUnitType = -1;
	int trainCount = 0;
	int numPlans = aiPlanGetActiveCount();
	int planType = -1;
	float foodGatherRate = 0.0;
	float woodGatherRate = 0.0;
	float goldGatherRate = 0.0;
	float goldPercentage = 0.0;
	float woodPercentage = 0.0;
	float foodPercentage = 0.0;
	float lastGoldPercentage = aiGetResourcePercentage(cResourceGold);
	float lastWoodPercentage = aiGetResourcePercentage(cResourceWood);
	float lastFoodPercentage = aiGetResourcePercentage(cResourceFood);
	int planPri = 50;
	int highestPri = 50;
	int highestPriPlanID = -1;
	float highestPriPlanGoldNeeded = 0.0;
	float highestPriPlanWoodNeeded = 0.0;
	float highestPriPlanFoodNeeded = 0.0;
	int ageUpPolitician = -1;
	int numberSendingCards = aiHCGetNumberSendingCards();
	int cardIndex = -1;
	int cardFlags = 0;
	int crateQuery = createSimpleUnitQuery(cUnitTypeAbstractResourceCrate, cMyID, cUnitStateAlive);
	int numberCrates = kbUnitQueryExecute(crateQuery);
	int crateID = -1;
	float handicap = kbGetPlayerHandicap(cMyID);
	float cost = 0.0;
	float trainPoints = 0.0;
	int numberBuildingsWanted = 0;
	float villagerCost = 0;
	int villagerTrainTime = 0;

	aiSetResourceGathererPercentageWeight(cRGPScript, 1.0);
	aiSetResourceGathererPercentageWeight(cRGPCost, 0.0);

	debugEconomy("updateResourceDistribution(): number plans="+numPlans);
	for (i = 0; < numPlans)
	{
		planID = aiPlanGetIDByActiveIndex(i);
		planType = aiPlanGetType(planID);
		planPri = aiPlanGetDesiredResourcePriority(planID);
		if (planType == cPlanTrain ||
			planType == cPlanBuild ||
			planType == cPlanBuildWall ||
			planType == cPlanResearch ||
			planType == cPlanRepair)
		{
			if (planID == aiPlanGetIDByTypeAndVariableType(cPlanTrain, cTrainPlanUnitType, gEconUnit))
				continue;
			else
			{
				planFoodNeeded = aiPlanGetFutureNeedsCostPerResource(planID, cResourceFood);
				planWoodNeeded = aiPlanGetFutureNeedsCostPerResource(planID, cResourceWood);
				planGoldNeeded = aiPlanGetFutureNeedsCostPerResource(planID, cResourceGold);
			}
			totalPlanFoodNeeded = totalPlanFoodNeeded + planFoodNeeded;
			totalPlanWoodNeeded = totalPlanWoodNeeded + planWoodNeeded;
			totalPlanGoldNeeded = totalPlanGoldNeeded + planGoldNeeded;
			if (planPri > highestPri)
			{
				highestPri = planPri;
				highestPriPlanID = planID;
				highestPriPlanFoodNeeded = planFoodNeeded;
				highestPriPlanWoodNeeded = planWoodNeeded;
				highestPriPlanGoldNeeded = planGoldNeeded;
			}
			debugEconomy("updateResourceDistribution(): name="+aiPlanGetName(planID)+", needed=("+planGoldNeeded+", "+planWoodNeeded+", "+planFoodNeeded+")");
		}
	}

	foodAmount = kbResourceGet(cResourceFood);
	woodAmount = kbResourceGet(cResourceWood);
	goldAmount = kbResourceGet(cResourceGold);

	if (kbGetAge() < cAge4)
	{
		// ----- Food Gather Rate -----
		if (cMyCiv == cCivJapanese)
			foodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeypBerryBuilding) * handicap;
		else
			foodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeHuntable) * handicap;
		// ----- Wood Gather Rate -----
		woodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeTree) * handicap;
		// ----- Gold Gather Rate -----
		if (cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux)
			goldGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypedeFurTrade) * handicap;
		else
			goldGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeAbstractMine) * handicap;
	}
	else
	{
		// ----- Food Gather Rate -----
		if (civIsAsian() || civIsAfrican())
			foodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, gFarmUnit, cResourceFood) * handicap;
		else
			foodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, gFarmUnit) * handicap;
		// ----- Wood Gather Rate -----
		woodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeTree) * handicap;
		// ----- Gold Gather Rate -----
		if (civIsAsian() || civIsAfrican())
			foodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, gPlantationUnit, cResourceGold) * handicap;
		else
			foodGatherRate = kbProtoUnitGetGatherRate(gEconUnit, gPlantationUnit) * handicap;
	}

	// Failsafe.
	if (foodGatherRate < 0.1)
		foodGatherRate = 0.84 * handicap;
	if (woodGatherRate < 0.1)
		woodGatherRate = 0.5 * handicap;
	if (goldGatherRate < 0.1)
		goldGatherRate = 0.6 * handicap;

	// Set reserved villagers for more villager training.
	gReservedFoodVillagers = 0;
	gReservedWoodVillagers = 0;
	gReservedGoldVillagers = 0;
	if (cMyCiv != cCivOttomans)
	{
		villagerCost = kbUnitCostPerResource(gEconUnit, cResourceFood);
		villagerTrainTime = kbUnitGetTrainPoints(gEconUnit);
		switch (cMyCiv)
		{
			case cCivDutch:
			{
				villagerCost = kbUnitCostPerResource(gEconUnit, cResourceGold);
				if (goldAmount < villagerCost * 1.25)
					gReservedGoldVillagers = getCeiling((villagerCost) / (goldGatherRate * villagerTrainTime));
				if (gReservedGoldVillagers < 2)
					gReservedGoldVillagers = 2;
				break;
			}
			case cCivIndians:
			{
				villagerCost = kbUnitCostPerResource(gEconUnit, cResourceWood);
				if (woodAmount < villagerCost * 1.25)
					gReservedWoodVillagers = getCeiling((villagerCost) / (woodGatherRate * villagerTrainTime));
				if (gReservedWoodVillagers < 2)
					gReservedWoodVillagers = 2;
				break;
			}
			default:
			{
				if (foodAmount < villagerCost * 1.25)
					gReservedFoodVillagers = getCeiling((villagerCost) / (foodGatherRate * villagerTrainTime));
				if (gReservedFoodVillagers < 2)
					gReservedFoodVillagers = 2;
				break;
			}
		}
	}

	// Add incoming resources from aging up.
	if (agingUp() == true)
	{
		if (aiPlanGetType(gAgeUpResearchPlan) == cPlanBuild)
		{
			ageUpPolitician = aiPlanGetVariableInt(gAgeUpResearchPlan, cBuildPlanBuildingTypeID, 0);
			ageUpPolitician = kbProtoUnitGetAssociatedTech(ageUpPolitician);
		}
		else
		{
			ageUpPolitician = aiPlanGetVariableInt(gAgeUpResearchPlan, cResearchPlanTechID, 0);
		}
		
		foodAmount = foodAmount + kbTechGetHCCardValuePerResource(ageUpPolitician, cResourceFood) * handicap;
		woodAmount = woodAmount + kbTechGetHCCardValuePerResource(ageUpPolitician, cResourceWood) * handicap;
		goldAmount = goldAmount + kbTechGetHCCardValuePerResource(ageUpPolitician, cResourceGold) * handicap;
	}

	// Add incoming resources from HC shipments.
	for (i = 0; < numberSendingCards)
	{
		cardIndex = aiHCGetSendingCardIndex(i);
		cardFlags = aiHCDeckGetCardFlags(gDefaultDeck, cardIndex);
		if ((cardFlags & cHCCardFlagResourceCrate) == cHCCardFlagResourceCrate)
		{
			foodAmount = foodAmount + aiHCDeckGetCardValuePerResource(gDefaultDeck, cardIndex, cResourceFood) * handicap;
			woodAmount = woodAmount + aiHCDeckGetCardValuePerResource(gDefaultDeck, cardIndex, cResourceWood) * handicap;
			goldAmount = goldAmount + aiHCDeckGetCardValuePerResource(gDefaultDeck, cardIndex, cResourceGold) * handicap;
		}
	}

	// Add resources from crates we currently haven't collected.
	for (i = 0; < numberCrates)
	{
		crateID = kbUnitQueryGetResult(crateQuery, i);
		foodAmount = foodAmount + kbUnitGetResourceAmount(crateID, cResourceFood) * handicap;
		woodAmount = woodAmount + kbUnitGetResourceAmount(crateID, cResourceWood) * handicap;
		goldAmount = goldAmount + kbUnitGetResourceAmount(crateID, cResourceGold) * handicap;
	}

	// Give our respective resource totals some oomph the highest priority plan that we cannot yet afford.
	if (foodAmount < highestPriPlanFoodNeeded)
		totalPlanFoodNeeded = totalPlanFoodNeeded + highestPriPlanFoodNeeded; // Add the plan again.
	if (woodAmount < highestPriPlanWoodNeeded)
		totalPlanWoodNeeded = totalPlanWoodNeeded + highestPriPlanWoodNeeded; // Add the plan again.
	if (goldAmount < highestPriPlanGoldNeeded)
		totalPlanGoldNeeded = totalPlanGoldNeeded + highestPriPlanGoldNeeded; // Add the plan again.

	// Check to see if the next shipment that we want to send has a cost. If so, account for it.
	// Be prepared to ship in 60 seconds.
	// if (kbTechCostPerResource(gNextShipmentTechID, cResourceFood) > 1.0)
	// 	totalPlanFoodNeeded = totalPlanFoodNeeded + kbTechCostPerResource(gNextShipmentTechID, cResourceFood) * (10.0 - 2 * kbGetAge());
	// if (kbTechCostPerResource(gNextShipmentTechID, cResourceWood) > 1.0)
	// 	totalPlanWoodNeeded = totalPlanWoodNeeded + kbTechCostPerResource(gNextShipmentTechID, cResourceWood) * (10.0 - 2 * kbGetAge());
	// if (kbTechCostPerResource(gNextShipmentTechID, cResourceGold) > 1.0)
	// 	totalPlanGoldNeeded = totalPlanGoldNeeded + kbTechCostPerResource(gNextShipmentTechID, cResourceGold) * (10.0 - 2 * kbGetAge());

	foodNeeded = totalPlanFoodNeeded - foodAmount;
	woodNeeded = totalPlanWoodNeeded - woodAmount;
	goldNeeded = totalPlanGoldNeeded - goldAmount;

	// For market trading.
	xsArraySetFloat(gResourceNeeds, cResourceFood, foodNeeded);
	xsArraySetFloat(gResourceNeeds, cResourceWood, woodNeeded);
	xsArraySetFloat(gResourceNeeds, cResourceGold, goldNeeded);

	if (foodNeeded < 0.0)
		foodNeeded = 0.0;
	if (woodNeeded < 0.0)
		woodNeeded = 0.0;
	if (goldNeeded < 0.0)
		goldNeeded = 0.0;

	// By using ratios, we will use the food as a baseline to adjust the percentages according to gather rate.
	woodNeeded = woodNeeded * (foodGatherRate / woodGatherRate);
	goldNeeded = goldNeeded * (foodGatherRate / goldGatherRate);
	totalNeeded = foodNeeded + woodNeeded + goldNeeded;

	// We have enough resource for our plans
	if (totalNeeded <= 0.0)
	{
		foodNeeded = 1.0;
		woodNeeded = foodGatherRate / woodGatherRate;
		goldNeeded = foodGatherRate / goldGatherRate;
		if (agingUp() && getAgingUpAge() == cAge2)
		{	// Force wood gathering when aging to Age 2 if we have nothing to do.
			foodNeeded = 0.1;
			woodNeeded = 0.8;
			goldNeeded = 0.1;
		}
		totalNeeded = foodNeeded + woodNeeded + goldNeeded;
	}

	foodPercentage = foodNeeded / totalNeeded;
	woodPercentage = woodNeeded / totalNeeded;
	goldPercentage = goldNeeded / totalNeeded;

	aiSetResourcePercentage(cResourceGold, false, goldPercentage);
	aiSetResourcePercentage(cResourceWood, false, woodPercentage);
	aiSetResourcePercentage(cResourceFood, false, foodPercentage);
	aiNormalizeResourcePercentages();   // Set them to 1.0 total, just in case these don't add up.
}

//==============================================================================
// getDedicatedGatherers
//
// For a specific resource, fetch the number of dedicated gatherers (i.e. static
// income from factories/banks/etc.), so that we will be able to account for
// this income in our villager rule.
//==============================================================================
int getDedicatedGatherers(int resourceType = -1)
{
	float temp = 0.0;
	int dedicatedVillagerValue = 0;
	int numBuildings = 0;
	float villagerGatherRate = 0.5;
	float dedicatedGatherRate = 0.0;
	float totalGatherRate = 0.0;
	float handicap = kbGetPlayerHandicap(cMyID);

	// TODO (James): Account for torps? Will likely disregard these and let the algorithm handle deficits.
	switch (resourceType)
	{
		case cResourceFood:
		{
			if (cMyCiv == cCivJapanese)
				villagerGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeypBerryBuilding) * handicap;
			else
				villagerGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeHuntable) * handicap;

			// Kancha Houses.
			if (cMyCiv == cCivDEInca)
			{
				numBuildings = kbUnitCount(cMyID, cUnitTypedeHouseInca, cUnitStateAlive);
				dedicatedGatherRate = 0.6 * numBuildings * handicap;
				if (kbTechGetStatus(cTechDEHCChichaBrewing) == cTechStatusActive)
					dedicatedGatherRate = dedicatedGatherRate * 1.5;
				totalGatherRate = totalGatherRate + dedicatedGatherRate;
			}

			break;
		}
		case cResourceWood:
		{
			villagerGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeTree) * handicap;

			// Factories (should be on wood).
			numBuildings = kbUnitCount(cMyID, cUnitTypeFactory, cUnitStateAlive);
			dedicatedGatherRate = 5.5 * numBuildings * handicap;
			if (kbTechGetStatus(cTechFactoryWaterPower) == cTechStatusActive)
				dedicatedGatherRate = dedicatedGatherRate * 1.3;
			totalGatherRate = totalGatherRate + dedicatedGatherRate;

			// TODO (James): Account for animals on the shrines.
			// Shrines (should be on wood starting in Age 2; Age 1 food is negligible).
			if (cMyCiv == cCivJapanese && kbGetAge() >= cAge2)
			{
				numBuildings = kbUnitCount(cMyID, cUnitTypeypShrineJapanese, cUnitStateAlive);
				dedicatedGatherRate = 0.1 * numBuildings * handicap;
				if (kbTechGetStatus(cTechYPHCIncreasedTribute) == cTechStatusActive)
					dedicatedGatherRate = dedicatedGatherRate * 1.5;
				if (kbTechGetStatus(cTechypShrineFortressUpgrade) == cTechStatusActive)
					dedicatedGatherRate = dedicatedGatherRate * 4.0;
				totalGatherRate = totalGatherRate + dedicatedGatherRate;
			}

			break;
		}
		case cResourceGold:
		{
			if (cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux)
				villagerGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypedeFurTrade) * handicap;
			else
				villagerGatherRate = kbProtoUnitGetGatherRate(gEconUnit, cUnitTypeAbstractMine) * handicap;

			// Banks.
			if (cMyCiv == cCivDutch || cMyCiv == cCivDEAmericans || cMyCiv == cCivJapanese)
			{
				numBuildings = kbUnitCount(cMyID, cUnitTypeBank, cUnitStateAlive);
				dedicatedGatherRate = 2.75 * numBuildings * handicap;
				if (kbTechGetStatus(cTechHCBetterBanks) == cTechStatusActive)
					dedicatedGatherRate = dedicatedGatherRate * 1.2;
				totalGatherRate = totalGatherRate + dedicatedGatherRate;
			}

			break;
		}
	}

	temp = totalGatherRate / villagerGatherRate;
	dedicatedVillagerValue = temp;

	return(dedicatedVillagerValue);
}

//==============================================================================
// findTradingLodge
//
// Find trading lodges to work for Haudenosaunee and Lakota. If we are lacking,
// build one.
//==============================================================================
int findTradingLodge(int resourceID = -1)
{
	vector location = kbUnitGetPosition(resourceID);
	int tradingLodge = getClosestUnit(cUnitTypedeFurTrade, cMyID, cUnitStateABQ, location, 15.0);
	if (tradingLodge >= 0)
	{
		return (tradingLodge);
	}

	if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeFurTrade) >= 0 ||
		((kbUnitCount(cMyID, cUnitTypedeFurTrade, cUnitStateABQ) * 10) > (gNumGoldVills + 1)))
	{
		return (-1);
	}

	// If we got here, tradingLodge < 0, so let's build one ASAP.
	int planID = aiPlanCreate("Trading Lodge Build Plan", cPlanBuild);
	aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypedeFurTrade);
	aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 6.0);
	aiPlanSetDesiredPriority(planID, 99);
	aiPlanSetDesiredResourcePriority(planID, 99);
	aiPlanSetEconomy(planID, true);
	aiPlanSetMilitary(planID, false);
	aiPlanSetEscrowID(planID, cRootEscrowID);
	aiPlanAddUnitType(planID, cUnitTypeLogicalTypeSettlerBuildLimit, 1, 1, 1);

	aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, location);
	aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 30.0);
	aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 100.0);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 200.0);
	aiPlanSetVariableInt(planID, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);
	
	aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypedeFurTrade);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, 0, 10.0);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, 0, -20.0);
	aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);

	aiPlanSetActive(planID);

	return (-1); // Should be -1.
}

//==============================================================================
// updateFoodBreakdown
//
// Populate an array with food resources that should be gathered.
//==============================================================================
void updateFoodBreakdown(void)
{
	arrayResetSelf(gFoodResources);
	arrayResetSelf(gDecayingAnimals);
	arrayResetSelf(gFoodNumWorkers);
	arrayResetSelf(gDecayingNumWorkers);
	arrayResetSelf(gMaxFoodWorkers);

	int numberResults = 0;
	// Get a rough estimate on our food supply in terms of how many villagers
	// I allow to gather from the particular resource multiplied by 0.8.
	// If by the end totalResourceWorth is not enough, then we should prepare
	// to build a Mill type. Made a float for certain calculations.
	float resourceWorth = 0.0;
	float totalResourceWorth = 0.0;
	int resourceID = -1;
	int planID = -1;
	int numWorkers = -1;
	int temp = -1;

	// Search for food.
	if (gFoodQuery < 0)
	{
		gFoodQuery = kbUnitQueryCreate("Food Resources Query");
		kbUnitQuerySetIgnoreKnockedOutUnits(gFoodQuery, true);
		kbUnitQuerySetSeeableOnly(gFoodQuery, false);
		kbUnitQuerySetPosition(gFoodQuery, gHomeBase);
		kbUnitQuerySetAreaGroupID(gFoodQuery, kbAreaGroupGetIDByPosition(gHomeBase));
	}
	kbUnitQuerySetMaximumDistance(gFoodQuery, 120.0);
	kbUnitQueryResetResults(gFoodQuery);

	// Herdables.
	if (cMyCiv != cCivJapanese && cMyCiv != cCivIndians &&
		civIsAfrican() == false && totalResourceWorth < gNumFoodVills)
	{	// Decaying.
		kbUnitQuerySetUnitType(gFoodQuery, cUnitTypeHerdable);
		kbUnitQuerySetPlayerID(gFoodQuery, 0, false);
		kbUnitQuerySetSeeableOnly(gFoodQuery, true);
		kbUnitQuerySetActionType(gFoodQuery, cActionTypeDeath);
		numberResults = kbUnitQueryExecute(gFoodQuery);

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gFoodQuery, i);

			if (resourceCloserToAlly(resourceID))
				continue;

			xsSetContextPlayer(0);
			numWorkers = kbUnitGetNumberWorkers(resourceID);
			xsSetContextPlayer(cMyID);
			// Too many current gatherers.
			if (numWorkers >= 4)
			{
				// Still count it because we are gathering it.
				resourceWorth = resourceWorth + 1;
				continue;
			}

			arrayPushInt(gDecayingAnimals, resourceID);
			arrayPushInt(gDecayingNumWorkers, numWorkers);
			resourceWorth = resourceWorth + 1;
		}

		kbUnitQueryResetResults(gFoodQuery);

		// Live.
		kbUnitQuerySetPlayerID(gFoodQuery, cMyID, false);
		kbUnitQuerySetActionType(gFoodQuery, -1);
		kbUnitQuerySetSeeableOnly(gFoodQuery, false);
		kbUnitQuerySetState(gFoodQuery, cUnitStateAlive);
		numberResults = kbUnitQueryExecute(gFoodQuery);
		numWorkers = 0; // If they are alive, there should be 0 workers.

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gFoodQuery, i);

			// Avoid unfattened animals.
			if (kbUnitGetResourceAmount(resourceID, cResourceFood) <
				kbUnitGetCarryCapacity(resourceID, cResourceFood))
				continue;

			// Avoid animals on shrines. Probably will always be false as
			// since they are our herdables, they must be on our shrines, which would
			// make us Japanese -- not even in this conditional statement.
			xsSetContextPlayer(0);
			temp = kbUnitGetTargetUnitID(resourceID);
			xsSetContextPlayer(cMyID);
			if (kbUnitIsType(temp, cUnitTypeypShrineJapanese) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine2) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine3) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine4) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine5) == true)
			{
				continue;
			}

			arrayPushInt(gFoodResources, resourceID);
			arrayPushInt(gFoodNumWorkers, numWorkers);
			arrayPushInt(gMaxFoodWorkers, 5);
			resourceWorth = resourceWorth + 1;
		}

		totalResourceWorth += resourceWorth;
		// Reset for other queries.
		resourceWorth = 0.0;
		kbUnitQueryResetResults(gFoodQuery);
	}

	// Huntables.
	if (cMyCiv != cCivJapanese && totalResourceWorth < gNumFoodVills)
	{	// Decaying
		kbUnitQuerySetUnitType(gFoodQuery, cUnitTypeHuntable);
		kbUnitQuerySetPlayerID(gFoodQuery, 0, false);
		kbUnitQuerySetActionType(gFoodQuery, cActionTypeDeath);
		kbUnitQuerySetSeeableOnly(gFoodQuery, true);
		kbUnitQuerySetState(gFoodQuery, cUnitStateAny);
		numberResults = kbUnitQueryExecute(gFoodQuery);

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gFoodQuery, i);

			if (resourceCloserToAlly(resourceID))
				continue;

			xsSetContextPlayer(0);
			numWorkers = kbUnitGetNumberWorkers(resourceID);
			xsSetContextPlayer(cMyID);
			// Too many current gatherers.
			if (numWorkers >= 5)
			{
				// Still count it because we are gathering it.
				resourceWorth = resourceWorth + 1;
				continue;
			}

			if (getDistance(kbUnitGetPosition(resourceID), gHomeBase) > 45)
			{
				if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
					cUnitStateAlive, kbUnitGetPosition(resourceID), 45.0) > 2)
					continue;
			}

			arrayPushInt(gDecayingAnimals, resourceID);
			arrayPushInt(gDecayingNumWorkers, numWorkers);
			resourceWorth = resourceWorth + 1;
		}

		kbUnitQueryResetResults(gFoodQuery);

		// Live
		kbUnitQuerySetActionType(gFoodQuery, -1);
		kbUnitQuerySetState(gFoodQuery, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(gFoodQuery, false);
		numberResults = kbUnitQueryExecute(gFoodQuery);
		numWorkers = 0; // If they are alive, there should be 0 workers.

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gFoodQuery, i);

			if (resourceCloserToAlly(resourceID))
				continue;

			// Avoid animals on shrines.
			xsSetContextPlayer(0);
			temp = kbUnitGetTargetUnitID(resourceID);
			xsSetContextPlayer(cMyID);
			if (kbUnitIsType(temp, cUnitTypeypShrineJapanese) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine2) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine3) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine4) == true ||
				kbUnitIsType(temp, cUnitTypeypWJToshoguShrine5) == true)
			{
				continue;
			}

			if (getDistance(kbUnitGetPosition(resourceID), gHomeBase) > 45)
			{
				if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
					cUnitStateAlive, kbUnitGetPosition(resourceID), 45.0) > 2)
					continue;
			}

			arrayPushInt(gFoodResources, resourceID);
			arrayPushInt(gFoodNumWorkers, numWorkers);
			arrayPushInt(gMaxFoodWorkers, 5);
			resourceWorth = resourceWorth + 1;
		}

		resourceWorth = resourceWorth * 4; // Count a Huntable as 4 villagers.
		totalResourceWorth += resourceWorth;
		// Reset for other queries.
		resourceWorth = 0.0;
		kbUnitQueryResetResults(gFoodQuery);
	}

	// Cherry Orchards.
	if (totalResourceWorth < gNumFoodVills)
	{
		kbUnitQuerySetMaximumDistance(gFoodQuery, -1);
		kbUnitQuerySetPlayerID(gFoodQuery, cMyID, false);
		kbUnitQuerySetState(gFoodQuery, cUnitStateAlive);
		kbUnitQuerySetUnitType(gFoodQuery, cUnitTypeypBerryBuilding);
		numberResults = kbUnitQueryExecute(gFoodQuery);

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gFoodQuery, i);

			// Too many current gatherers on an Orchard.
			numWorkers = kbUnitGetNumberWorkers(resourceID);
			if (numWorkers == 28)
			{	// Still count it because we are gathering it.
				resourceWorth = resourceWorth + 1;
				continue;
			}

			arrayPushInt(gFoodResources, resourceID);
			arrayPushInt(gFoodNumWorkers, numWorkers);
			arrayPushInt(gMaxFoodWorkers, 28);
			resourceWorth = resourceWorth + 1;
		}
		resourceWorth = resourceWorth * 21; // Count a cherry orchard as 21 villagers.
		totalResourceWorth += resourceWorth;
		// Reset for other queries.
		resourceWorth = 0.0;
		kbUnitQueryResetResults(gFoodQuery);
	}

	// Berry types.
	if (totalResourceWorth < gNumFoodVills)
	{
		kbUnitQuerySetMaximumDistance(gFoodQuery, 120.0);
		kbUnitQuerySetPlayerID(gFoodQuery, 0, false);
		kbUnitQuerySetState(gFoodQuery, cUnitStateAny);
		kbUnitQuerySetUnitType(gFoodQuery, cUnitTypeAbstractFruit);
		kbUnitQueryExecute(gFoodQuery);
		numberResults = kbUnitQueryNumberResults(gFoodQuery);

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gFoodQuery, i);

			// Mango Groves are listed as 'AbstractFruit' in protoy.xml.
			if (kbUnitIsType(resourceID, cUnitTypeypGroveBuilding) == true)
				continue;

			if (resourceCloserToAlly(resourceID))
				continue;

			// Too many current gatherers on Berry Bushes.
			xsSetContextPlayer(0);
			numWorkers = kbUnitGetNumberWorkers(resourceID);
			xsSetContextPlayer(cMyID);
			if (numWorkers >= 5)
			{
				// Still count it because we are gathering it.
				resourceWorth = resourceWorth + 1;
				continue;
			}

			if (getDistance(kbUnitGetPosition(resourceID), gHomeBase) > 45)
			{
				if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
					cUnitStateAlive, kbUnitGetPosition(resourceID), 45.0) > 2)
					continue;
			}

			arrayPushInt(gFoodResources, resourceID);
			arrayPushInt(gFoodNumWorkers, numWorkers);
			arrayPushInt(gMaxFoodWorkers, 5);
			resourceWorth = resourceWorth + 1;
		}

		resourceWorth = resourceWorth * 4; // Count a cherry orchard as 21 villagers.
		totalResourceWorth += resourceWorth;
		// Reset for other queries.
		resourceWorth = 0.0;
		kbUnitQueryResetResults(gFoodQuery);
	}

	// Mills/Farms/Paddies/Fields.
	if (totalResourceWorth < gNumFoodVills || kbGetAge() >= cAge4)
	{
		kbUnitQuerySetMaximumDistance(gFoodQuery, -1);
		kbUnitQuerySetPlayerID(gFoodQuery, cMyID, false);
		kbUnitQuerySetState(gFoodQuery, cUnitStateABQ);
		kbUnitQuerySetUnitType(gFoodQuery, gFarmUnit);
		kbUnitQueryExecute(gFoodQuery);
		numberResults = kbUnitQueryNumberResults(gFoodQuery);
		int maxNumWorkers = 10;

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gFoodQuery, i);
			numWorkers = kbUnitGetNumberWorkers(resourceID);

			// Field on Gold or maxed out.
			if (kbUnitIsType(resourceID, cUnitTypedeField))
			{
				if (aiUnitGetTactic(resourceID) == cTacticFieldCoin)
					continue;
				else if (numWorkers == 3)
				{	// Still count it because we are gathering it.
					resourceWorth = resourceWorth + 1;
					continue;
				}
				maxNumWorkers = 3;
			}
			// Paddy on Gold or maxed out.
			else if (kbUnitIsType(resourceID, cUnitTypeypRicePaddy))
			{
				if (aiUnitGetTactic(resourceID) == cTacticPaddyCoin)
					continue;
				else if (numWorkers == 10)
				{	// Still count it because we are gathering it.
					resourceWorth = resourceWorth + 1;
					continue;
				}
			}
			// Hacienda on Gold or maxed out.
			else if (kbUnitIsType(resourceID, cUnitTypedeHacienda))
			{
				if (aiUnitGetTactic(resourceID) == cTacticHaciendaCoin)
					continue;
				else if (numWorkers == 20)
				{	// Still count it because we are gathering it.
					resourceWorth = resourceWorth + 1;
					continue;
				}
				maxNumWorkers = 20;
			}
			// Mill/Farm maxed out.
			else if (numWorkers == 10)
			{	// Still count it because we are gathering it.
				resourceWorth = resourceWorth + 1;
				continue;
			}

			arrayPushInt(gFoodResources, resourceID);
			arrayPushInt(gFoodNumWorkers, numWorkers);
			arrayPushInt(gMaxFoodWorkers, maxNumWorkers);
			resourceWorth = resourceWorth + 1;
		}

		if (civIsAfrican() == true)
			resourceWorth = resourceWorth * 2.7; // Count a Food Field as 2.7 villagers.
		else if (cMyCiv == cCivDEMexicans)
			resourceWorth = resourceWorth * 18; // Count a Food Hacienda as 18 villagers.
		else
			resourceWorth = resourceWorth * 9; // Count a Mill/Farm/Food Paddy as 9 villagers.

		totalResourceWorth += resourceWorth;
		// Reset of the query is unecessary as the rule will reset it when it runs again.
	}

	// Basically, if we have reached this point, we should probably build a food-producing
	// building because we do not want to run out of gold resources.
	int millWorth = 10;
	int maxPlans = 4;
	if (cMyCiv == cCivDEMexicans)
	{
		millWorth = 20;
		maxPlans = 2;
	}
	else if (civIsAfrican() == true)
	{
		millWorth = 3;
		maxPlans = 8;
	}

	if (totalResourceWorth < gNumFoodVills && kbGetAge() >= cAge3)
	{
		arrayRemoveDonePlans(gMillTypePlans);
		if (arrayGetSize(gMillTypePlans) < maxPlans)
		{
			if (gNumFoodVills - totalResourceWorth > millWorth * arrayGetSize(gMillTypePlans))
			{
				planID = addMillBuildPlan();
				if (planID >= 0)
				{
					arrayPushInt(gMillTypePlans, planID);
					aiPlanSetDesiredPriority(planID, 99);
					aiPlanSetDesiredResourcePriority(planID, 99);
				}
			}
		}
	}
}

//==============================================================================
// updateWoodBreakdown
//
// Populate an array with wood resources that should be gathered.
//==============================================================================
void updateWoodBreakdown(void)
{
	arrayResetSelf(gWoodResources);
	arrayResetSelf(gWoodNumWorkers);

	int numberResults = 0;
	int resourceID = -1;
	int planID = -1;
	int numWorkers = -1;

	if (gWoodQuery < 0)
	{
		gWoodQuery = kbUnitQueryCreate("Wood Resources Query");
		kbUnitQuerySetPlayerID(gWoodQuery, -1, false);
		kbUnitQuerySetPlayerRelation(gWoodQuery, cPlayerRelationAny);
		kbUnitQuerySetIgnoreKnockedOutUnits(gWoodQuery, true);
		kbUnitQuerySetPosition(gWoodQuery, gHomeBase);
		kbUnitQuerySetAreaGroupID(gWoodQuery, kbAreaGroupGetIDByPosition(gHomeBase));
		kbUnitQuerySetAscendingSort(gWoodQuery, true);
		kbUnitQuerySetMaximumDistance(gWoodQuery, 200.0);
	}
	kbUnitQueryResetResults(gWoodQuery);

	if (numberResults < gNumWoodVills)
	{
		kbUnitQuerySetPlayerID(gWoodQuery, 0, false);
		kbUnitQuerySetUnitType(gWoodQuery, cUnitTypeWood);
		kbUnitQuerySetState(gWoodQuery, cUnitStateAlive);
		kbUnitQuerySetSeeableOnly(gWoodQuery, false);
		kbUnitQueryExecute(gWoodQuery);

		kbUnitQuerySetUnitType(gWoodQuery, cUnitTypeTree);
		kbUnitQuerySetState(gWoodQuery, cUnitStateDead);
		kbUnitQuerySetSeeableOnly(gWoodQuery, true);
		kbUnitQueryExecute(gWoodQuery);
		numberResults = kbUnitQueryNumberResults(gWoodQuery);

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gWoodQuery, i);

			xsSetContextPlayer(0);
			numWorkers = kbUnitGetNumberWorkers(resourceID);
			xsSetContextPlayer(cMyID);

			// Too many current gatherers.
			if (numWorkers >= 5)
				continue;

			if (getDistance(kbUnitGetPosition(resourceID), gHomeBase) > 45)
			{
				if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
					cUnitStateAlive, kbUnitGetPosition(resourceID), 45.0) > 2)
					continue;
			}

			arrayPushInt(gWoodResources, resourceID);
			arrayPushInt(gWoodNumWorkers, numWorkers);
		}
		// Reset of the query is unecessary as the rule will reset it when it runs again.
	}
}

//==============================================================================
// updateGoldBreakdown
//
// Populate an array with gold resources that should be gathered.
//==============================================================================
void updateGoldBreakdown(void)
{
	arrayResetSelf(gGoldResources);
	arrayResetSelf(gGoldNumWorkers);
	arrayResetSelf(gMaxGoldWorkers);

	int numberResults = 0;
	float resourceWorth = 0.0;
	float totalResourceWorth = 0.0;
	int resourceID = -1;
	int tradingLodge = -1;
	int planID = -1;
	int numWorkers = -1;

	if (gGoldQuery < 0)
	{
		gGoldQuery = kbUnitQueryCreate("Gold Resources Query");
		kbUnitQuerySetPlayerID(gGoldQuery, -1, false);
		kbUnitQuerySetPlayerRelation(gGoldQuery, cPlayerRelationAny);
		kbUnitQuerySetIgnoreKnockedOutUnits(gGoldQuery, true);
		kbUnitQuerySetSeeableOnly(gGoldQuery, true);
		kbUnitQuerySetPosition(gGoldQuery, gHomeBase);
		kbUnitQuerySetAreaGroupID(gGoldQuery, kbAreaGroupGetIDByPosition(gHomeBase));
		kbUnitQuerySetAscendingSort(gGoldQuery, true);
	}
	kbUnitQuerySetMaximumDistance(gGoldQuery, 100.0);
	if (kbGetAge() >= cAge4)
		kbUnitQuerySetMaximumDistance(gGoldQuery, 75.0);
	kbUnitQueryResetResults(gGoldQuery);

	// Mountain Monasteries. (Note: Allies of Ethiopia can gather, but it is not enhanced)
	if (totalResourceWorth < gNumGoldVills)
	{
		kbUnitQuerySetPlayerID(gGoldQuery, -1, false);
		kbUnitQuerySetPlayerRelation(gGoldQuery, cPlayerRelationAlly);
		kbUnitQuerySetUnitType(gGoldQuery, cUnitTypedeMountainMonastery);
		kbUnitQuerySetState(gGoldQuery, cUnitStateAlive);
		kbUnitQueryExecute(gGoldQuery);
		numberResults = kbUnitQueryNumberResults(gGoldQuery);

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gGoldQuery, i);

			if (kbUnitGetResourceAmount(resourceID, cResourceGold) < 1.0)
				continue;

			numWorkers = kbUnitGetNumberWorkers(resourceID);
			if (numWorkers == 20)
			{	// Still count it because we are gathering it.
				resourceWorth = resourceWorth + 1;
				continue;
			}

			if (getDistance(kbUnitGetPosition(resourceID), gHomeBase) > 45)
			{
				if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
					cUnitStateAlive, kbUnitGetPosition(resourceID), 45.0) > 2)
					continue;
			}

			arrayPushInt(gGoldResources, resourceID);
			arrayPushInt(gGoldNumWorkers, numWorkers);
			arrayPushInt(gMaxGoldWorkers, 20);
			resourceWorth = resourceWorth + 1;
		}

		if (cMyCiv == cCivDEEthiopians)
			resourceWorth = resourceWorth * 18; // Count a Mountain Monastery as 18 Villagers for Ethiopians.
		else
			resourceWorth = resourceWorth * 9; // Count it less since Ethiopia will primarily reap its benefit.
		totalResourceWorth += resourceWorth;
		// Reset for other queries.
		resourceWorth = 0.0;
		kbUnitQueryResetResults(gGoldQuery);
	}

	// Mines.
	//
	// Ethiopians should only check this if we do not have a suitable monastery to work
	// or are almost maxed out working them. Otherwise all civs should check this as the
	// Mountain Monastery poses no benefit to their gathering rates.
	//
	if ((totalResourceWorth < gNumGoldVills) || (cMyCiv != cCivDEEthiopians))
	{
		kbUnitQuerySetPlayerID(gGoldQuery, 0, false);
		kbUnitQuerySetPlayerRelation(gGoldQuery, cPlayerRelationAny);
		kbUnitQuerySetUnitType(gGoldQuery, cUnitTypeAbstractMine);
		kbUnitQuerySetState(gGoldQuery, cUnitStateAlive);
		kbUnitQueryExecute(gGoldQuery);
		numberResults = kbUnitQueryNumberResults(gGoldQuery);

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gGoldQuery, i);

			if (resourceCloserToAlly(resourceID))
				continue;

			// We should not consider the mine here as its monastery will have been added
			// from the previous query section.
			if (getUnitCountByLocation(cUnitTypedeMountainMonastery, cPlayerRelationAny,
				cUnitStateABQ, kbUnitGetPosition(resourceID), 5.0) > 0)
				continue;

			// Trading Lodge not in the query since PlayerID is set to 0.
			// Anyways, this works better for building one.
			if (cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux)
			{
				tradingLodge = findTradingLodge(resourceID);
				if (tradingLodge < 0)
					continue;
				else
				{
					resourceID = tradingLodge;
					numWorkers = kbUnitGetNumberWorkers(resourceID);
					// Too many current gatherers.
					if (numWorkers == 10)
					{	// Still count it because we are gathering it.
						resourceWorth = resourceWorth + 1;
						continue;
					}
				}
			}
			else
			{
				xsSetContextPlayer(0);
				numWorkers = kbUnitGetNumberWorkers(resourceID);
				xsSetContextPlayer(cMyID);
				// Too many current gatherers.
				if (numWorkers == 20)
				{	// Still count it because we are gathering it.
					resourceWorth = resourceWorth + 1;
					continue;
				}
			}

			if (getDistance(kbUnitGetPosition(resourceID), gHomeBase) > 45)
			{
				if (getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
					cUnitStateAlive, kbUnitGetPosition(resourceID), 45.0) > 2)
					continue;
			}

			arrayPushInt(gGoldResources, resourceID);
			arrayPushInt(gGoldNumWorkers, numWorkers);
			arrayPushInt(gMaxGoldWorkers, 20);
			resourceWorth = resourceWorth + 1;
		}

		if (cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux)
			resourceWorth = resourceWorth * 9; // Count a Tribal Marketplace as 9 villagers.
		else
			resourceWorth = resourceWorth * 18; // Count a Mine as 18 villagers.
		totalResourceWorth += resourceWorth;
		// Reset for other queries.
		resourceWorth = 0.0;
		kbUnitQueryResetResults(gGoldQuery);
	}

	// Estates/Paddies/Fields.
	if (totalResourceWorth < gNumGoldVills || kbGetAge() >= cAge4)
	{
		kbUnitQuerySetMaximumDistance(gGoldQuery, -1);
		kbUnitQuerySetPlayerID(gGoldQuery, cMyID, false);
		kbUnitQuerySetUnitType(gGoldQuery, gPlantationUnit);
		kbUnitQuerySetState(gGoldQuery, cUnitStateAlive);
		kbUnitQueryExecute(gGoldQuery);
		numberResults = kbUnitQueryNumberResults(gGoldQuery);
		int maxNumWorkers = 10;

		for (i = 0; < numberResults)
		{
			resourceID = kbUnitQueryGetResult(gGoldQuery, i);
			numWorkers = kbUnitGetNumberWorkers(resourceID);

			// Field on Food or maxed out.
			if (kbUnitIsType(resourceID, cUnitTypedeField))
			{
				if (aiUnitGetTactic(resourceID) == cTacticFieldFood)
					continue;
				else if (numWorkers == 3)
				{	// Still count it because we are gathering it.
					resourceWorth = resourceWorth + 1;
					continue;
				}
				maxNumWorkers = 3;
			}
			// Paddy on Food or maxed out.
			else if (kbUnitIsType(resourceID, cUnitTypeypRicePaddy))
			{
				if (aiUnitGetTactic(resourceID) == cTacticPaddyFood)
					continue;
				else if (numWorkers == 10)
				{	// Still count it because we are gathering it.
					resourceWorth = resourceWorth + 1;
					continue;
				}
			}
			// Hacienda on Food or maxed out.
			else if (kbUnitIsType(resourceID, cUnitTypedeHacienda))
			{
				if (aiUnitGetTactic(resourceID) == cTacticHaciendaFood)
					continue;
				else if (numWorkers == 20)
				{	// Still count it because we are gathering it.
					resourceWorth = resourceWorth + 1;
					continue;
				}
				maxNumWorkers = 20;
			}
			// Estate maxed out.
			else if (numWorkers == 10)
			{	// Still count it because we are gathering it.
				resourceWorth = resourceWorth + 1;
				continue;
			}

			arrayPushInt(gGoldResources, resourceID);
			arrayPushInt(gGoldNumWorkers, numWorkers);
			arrayPushInt(gMaxGoldWorkers, maxNumWorkers);
			resourceWorth = resourceWorth + 1;
		}

		if (civIsAfrican() == true)
			resourceWorth = resourceWorth * 2.9; // Count a Gold Field as 2.9 villagers.
		else if (cMyCiv == cCivDEMexicans)
			resourceWorth = resourceWorth * 18; // Count a Gold Hacienda as 18 villagers.
		else
			resourceWorth = resourceWorth * 9; // Count an Estate/GoldPaddy as 9 villagers.
		
		totalResourceWorth += resourceWorth;
		// Reset of the query is unecessary as the rule will reset it when it runs again.
	}

	// Basically, if we have reached this point, we should probably build a gold-producing
	// building because we do not want to run out of gold resources.
	int plantationWorth = 10;
	int maxPlans = 4;
	if (cMyCiv == cCivDEMexicans)
	{
		plantationWorth = 20;
		maxPlans = 2;
	}
	else if (civIsAfrican())
	{
		plantationWorth = 3;
		maxPlans = 8;
	}
	if (totalResourceWorth < gNumGoldVills && kbGetAge() >= cAge3)
	{
		arrayRemoveDonePlans(gPlantationTypePlans);
		if (arrayGetSize(gPlantationTypePlans) < maxPlans)
		{
			if (gNumGoldVills - totalResourceWorth > plantationWorth * arrayGetSize(gPlantationTypePlans))
			{
				planID = addPlantationBuildPlan();
				if (planID >= 0)
				{
					arrayPushInt(gPlantationTypePlans, planID);
					aiPlanSetDesiredPriority(planID, 99);
					aiPlanSetDesiredResourcePriority(planID, 99);
				}
			}
		}
	}
}

void updateFoodFishBreakdown(void)
{
	arrayResetSelf(gFoodFishResources);

	int numberResults = 0;
	int resourceID = -1;
	static int foodFishQuery = -1;

	// Search for food.
	if (foodFishQuery < 0)
	{
		foodFishQuery = kbUnitQueryCreate("Food Fish Resources Query");
		kbUnitQuerySetUnitType(foodFishQuery, cUnitTypeAbstractFish);
		kbUnitQuerySetState(foodFishQuery, cUnitStateAlive);
		kbUnitQuerySetPlayerID(foodFishQuery, -1, false);
		kbUnitQuerySetPlayerRelation(foodFishQuery, cPlayerRelationAny);
		kbUnitQuerySetIgnoreKnockedOutUnits(foodFishQuery, true);
		kbUnitQuerySetSeeableOnly(foodFishQuery, true);
	}
	kbUnitQueryResetResults(foodFishQuery);
	numberResults = kbUnitQueryExecute(foodFishQuery);

	for (i = 0; < numberResults)
	{
		resourceID = kbUnitQueryGetResult(foodFishQuery, i);

		// Too many current gatherers.
		xsSetContextPlayer(0);
		if (kbUnitGetNumberWorkers(resourceID) >= 5)
		{
			xsSetContextPlayer(cMyID);
			continue;
		}
		xsSetContextPlayer(cMyID);

		if (getUnitCountByLocation(cUnitTypeLogicalTypeNavalMilitary, cPlayerRelationEnemyNotGaia,
			cUnitStateAlive, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		if (getUnitCountByLocation(cUnitTypeOutpost, cPlayerRelationEnemyNotGaia,
			cUnitStateABQ, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		if (getUnitCountByLocation(cUnitTypeAbstractCallMinutemen, cPlayerRelationEnemyNotGaia,
			cUnitStateABQ, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		if (getUnitCountByLocation(cUnitTypeAbstractDock, cPlayerRelationEnemyNotGaia,
			cUnitStateABQ, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		arrayPushInt(gFoodFishResources, resourceID);
	}
}

void updateGoldFishBreakdown(void)
{
	arrayResetSelf(gGoldFishResources);

	int numberResults = 0;
	int resourceID = -1;
	static int goldFishQuery = -1;

	// Search for gold.
	if (goldFishQuery < 0)
	{
		goldFishQuery = kbUnitQueryCreate("Gold Fish Resources Query");
		kbUnitQuerySetUnitType(goldFishQuery, cUnitTypeAbstractWhale);
		kbUnitQuerySetState(goldFishQuery, cUnitStateAlive);
		kbUnitQuerySetPlayerID(goldFishQuery, -1, false);
		kbUnitQuerySetPlayerRelation(goldFishQuery, cPlayerRelationAny);
		kbUnitQuerySetIgnoreKnockedOutUnits(goldFishQuery, true);
		kbUnitQuerySetSeeableOnly(goldFishQuery, true);
	}
	kbUnitQueryResetResults(goldFishQuery);
	numberResults = kbUnitQueryExecute(goldFishQuery);

	for (i = 0; < numberResults)
	{
		resourceID = kbUnitQueryGetResult(goldFishQuery, i);

		// Too many current gatherers.
		xsSetContextPlayer(0);
		if (kbUnitGetNumberWorkers(resourceID) == 4)
		{
			xsSetContextPlayer(cMyID);
			continue;
		}
		xsSetContextPlayer(cMyID);

		if (getUnitCountByLocation(cUnitTypeLogicalTypeNavalMilitary, cPlayerRelationEnemyNotGaia,
			cUnitStateAlive, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		if (getUnitCountByLocation(cUnitTypeOutpost, cPlayerRelationEnemyNotGaia,
			cUnitStateABQ, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		if (getUnitCountByLocation(cUnitTypeAbstractCallMinutemen, cPlayerRelationEnemyNotGaia,
			cUnitStateABQ, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		if (getUnitCountByLocation(cUnitTypeAbstractDock, cPlayerRelationEnemyNotGaia,
			cUnitStateABQ, kbUnitGetPosition(resourceID), 30.0) > 0)
			continue;

		arrayPushInt(gGoldFishResources, resourceID);
	}
}

//==============================================================================
//
// taskVillagers
//
// - Control villager gathering assignments.
//
//==============================================================================
rule taskVillagers
inactive
minInterval 2
{
	if (gVillagerQuery < 0)
	{
		gVillagerQuery = kbUnitQueryCreate("Villager Query");
		kbUnitQuerySetPlayerID(gVillagerQuery, cMyID);
		kbUnitQuerySetPlayerRelation(gVillagerQuery, -1);
		kbUnitQuerySetState(gVillagerQuery, cUnitStateAlive);
		kbUnitQuerySetPosition(gVillagerQuery, gHomeBase);
		kbUnitQuerySetAscendingSort(gVillagerQuery, true);
		kbUnitQuerySetIgnoreKnockedOutUnits(gVillagerQuery, true);
	}
	kbUnitQueryResetResults(gVillagerQuery);
	kbUnitQuerySetUnitType(gVillagerQuery, cUnitTypeLogicalTypeSettlerBuildLimit);
	kbUnitQueryExecute(gVillagerQuery);
	kbUnitQuerySetUnitType(gVillagerQuery, cUnitTypeSettlerWagon);
	kbUnitQueryExecute(gVillagerQuery);

	if (xsIsRuleEnabled("villagerRetreat") == false)
	{
		xsEnableRule("villagerRetreat");
	}

	// Used throughout the rule to manage the villagers.
	int villagerPop = kbGetPopulationSlotsByQueryID(gVillagerQuery) +
		getDedicatedGatherers(cResourceFood) +
		getDedicatedGatherers(cResourceWood) +
		getDedicatedGatherers(cResourceGold);
	int numFoodVills = 0;
	int numWoodVills = 0;
	int numGoldVills = 0;
	int pop = 1;
	int unitID = -1;
	int actionID = -1;
	int resourceID = -1;
	int planID = -1;

	// Used to compare resources within each resource type, to select the
	// "best" one relative to the villager under consideration.
	vector location = cInvalidVector;
	int tempIndex = -1;
	int closestResourceID = -1;
	int closestResourceIndex = -1;
	float closestDistance = 0.0;
	float tempDistance = 0.0;

	// Used to keep track of the "best" resource of each type, in the sense
	// of their relative location to the current villager being considered.
	// The villager is then tasked to the closest one of these resources.
	int foodID = -1;
	int foodIndex = -1;
	float foodDistance = 0.0;
	int woodID = -1;
	int woodIndex = -1;
	float woodDistance = 0.0;
	int goldID = -1;
	int goldIndex = -1;
	float goldDistance = 0.0;

	// Used to task a villager to shoot hunts toward a particular location.
	vector targetLocation = cInvalidVector;

	// Subtract from our total count villagers that are assigned to a plan,
	// as well as those on crates. Also, make sure crates are gathered.
	for (i = 0; < kbUnitQueryNumberResults(gVillagerQuery))
	{
		unitID = kbUnitQueryGetResult(gVillagerQuery, i);
		if (kbUnitIsType(unitID, cUnitTypeSettlerWagon))
			pop = 2;
		else
			pop = 1;

		if (kbUnitGetPlanID(unitID) >= 0)
			villagerPop = villagerPop - pop;
	}
	/* villagerPop = villagerPop - gReservedFoodVillagers -
		gReservedWoodVillagers - gReservedGoldVillagers;
	if (villagerPop < 0)
		villagerPop = 0; */

	numFoodVills = (villagerPop - gReservedFoodVillagers - gReservedWoodVillagers - gReservedGoldVillagers) * 
					aiGetResourcePercentage(cResourceFood) + gReservedFoodVillagers;
	numGoldVills = (villagerPop - gReservedFoodVillagers - gReservedWoodVillagers - gReservedGoldVillagers) *
					aiGetResourcePercentage(cResourceGold) + gReservedGoldVillagers;
	// villagerPop = villagerPop + gReservedFoodVillagers + gReservedGoldVillagers;
	numWoodVills = (villagerPop - gReservedFoodVillagers - gReservedWoodVillagers - gReservedGoldVillagers) *
					aiGetResourcePercentage(cResourceWood) + gReservedWoodVillagers;

	numFoodVills = numFoodVills - getDedicatedGatherers(cResourceFood);
	if (numFoodVills < 0)
		numFoodVills = 0;
	numGoldVills = numGoldVills - getDedicatedGatherers(cResourceGold);
	if (numGoldVills < 0)
		numGoldVills = 0;
	numWoodVills = numWoodVills - getDedicatedGatherers(cResourceWood);
	if (numWoodVills < 0)
		numWoodVills = 0;

	// Set the global gatherer data.
	gNumFoodVills = numFoodVills;
	gNumWoodVills = numWoodVills;
	gNumGoldVills = numGoldVills;

	// Search for food.
	updateFoodBreakdown();

	// Search for wood.
	updateWoodBreakdown();

	// Search for gold.
	updateGoldBreakdown();

	if (arrayGetSize(gWoodResources) < 2) // Until I configure arrayGetSize to return 0.
	{
		numFoodVills = numFoodVills + (numWoodVills / 2);
		numGoldVills = numGoldVills + (numWoodVills / 2) + (numWoodVills % 2);
		numWoodVills = 0;
	}

	// ============================================================ //

	// Loop through the villagers (from the query) to give them assignments.
	for (i = 0; < kbUnitQueryNumberResults(gVillagerQuery))
	{
		unitID = kbUnitQueryGetResult(gVillagerQuery, i);
		actionID = kbUnitGetActionType(unitID);
		targetLocation = cInvalidVector;
		switch (actionID)
		{
			case cActionTypeMove: // Currently moving.
			case cActionTypeMoveByGroup: // Currently moving.
			case cActionTypeSocialise: // Currently on Community Plaza.
				continue;
			case cActionTypeBuild: // Currently building in a plan.
			{
				if (kbUnitGetPlanID(unitID) >= 0)
					continue;
			}
			default: // Units assigned to a plan.
			{
				if (kbUnitGetPlanID(unitID) >= 0)
					continue;
			}
		}

		if (kbUnitIsType(unitID, cUnitTypeSettlerWagon))
			pop = 2;
		else
			pop = 1;

		resourceID = kbUnitGetTargetUnitID(unitID);
		if (resourceID >= 0)
		{
			// Currently on crates/berries/mines/mill units/estate units.
			// and *not* assigned to a plan.
			if (actionID == cActionTypeGather)
			{
				// 'deHacienda' is listed as '<unittype>Gold</unittype>', so we need to account for this first.
				if (kbUnitIsType(resourceID, cUnitTypedeHacienda))
				{
					if (aiUnitGetTactic(resourceID) == cTacticHaciendaCoin)
					{
						if (numGoldVills > 0)
						{
							numGoldVills = numGoldVills - pop;
							continue;
						}
					}
					else if (numFoodVills > 0) // Then it must be food tactic.
					{
						numFoodVills = numFoodVills - pop;
						continue;
					}
				}
				else if (kbUnitIsType(resourceID, cUnitTypeGold))
				{
					if (numGoldVills > 0)
					{
						numGoldVills = numGoldVills - pop;
						continue;
					}
				}
				// 'ypRicePaddy' and 'deField' are listed as '<unittype>Food</unittype>' in protoy.xml
				else if (kbUnitIsType(resourceID, cUnitTypeypRicePaddy) || kbUnitIsType(resourceID, cUnitTypedeField))
				{	// NOTE: I do not think there are 'team' rice paddy or field cards, unlike the Hacienda.
					// Otherwise I should distinguish paddy from field tactics by their constant ID in the odd case 
					// that some civ gets a one of these from an ally shipment and cannot evaluate this.
					if (aiUnitGetTactic(resourceID) == gFarmGoldTactic)
					{
						if (numGoldVills > 0)
						{
							numGoldVills = numGoldVills - pop;
							continue;
						}
					}
					else if (numFoodVills > 0) // Then it must be food tactic.
					{
						numFoodVills = numFoodVills - pop;
						continue;
					}
				}
				// Mills and Farms.
				else if (kbUnitIsType(resourceID, cUnitTypeFood))
				{
					if (numFoodVills > 0)
					{
						numFoodVills = numFoodVills - pop;
						continue;
					}
				}
			}
			// Currently hunting/chopping.
			else if (actionID == cActionTypeHunting)
			{
				if (kbUnitIsType(resourceID, cUnitTypeTree))
				{
					if (numWoodVills > 0)
					{
						numWoodVills = numWoodVills - pop;
						continue;
					}
				}
				else if (kbUnitIsType(resourceID, cUnitTypeHuntable) ||
					kbUnitIsType(resourceID, cUnitTypeHerdable))
				{
					if (numFoodVills > 0)
					{
						numFoodVills = numFoodVills - pop;
						continue;	
					}
				}
			}
		}

		location = kbUnitGetPosition(unitID);
		foodDistance = 9999.0;
		woodDistance = 9999.0;
		goldDistance = 9999.0;

		// ========================================
		// Food Resources.
		//
		if (numFoodVills > 0)
		{
			// ========================================
			// Check for decaying huntables first.
			resourceID = -1;
			// Find a starting comparison that does not have too
			// many workers.
			for (tempIndex = 0; < arrayGetSize(gDecayingAnimals))
			{	// Should not matter for Japanese as resourceID will always be -1.
				if (arrayGetInt(gDecayingNumWorkers, tempIndex) >= 5)
					continue;

				resourceID = arrayGetInt(gDecayingAnimals, tempIndex);
				break;
			}

			if (resourceID >= 0)
			{
				closestResourceID = resourceID;
				closestResourceIndex = tempIndex;
				closestDistance = getDistance(
					location,
					kbUnitGetPosition(closestResourceID)
				);

				for (j = tempIndex + 1; < arrayGetSize(gDecayingAnimals))
				{
					resourceID = arrayGetInt(gDecayingAnimals, j);

					if (arrayGetInt(gDecayingNumWorkers, j) >= 5)
						continue;

					tempDistance = getDistance(location, kbUnitGetPosition(resourceID));
					if (tempDistance < closestDistance)
					{
						closestResourceID = resourceID;
						closestResourceIndex = j;
						closestDistance = tempDistance;
					}

					if (closestDistance < 12.0)
						break;	// This one is close enough.
				}
				foodID = closestResourceID;
				foodIndex = closestResourceIndex;
				foodDistance = closestDistance;
				goto PrioritizeDecayingAnimal;
			}
			//
			// End of check for decaying huntables.
			// ========================================

			// ========================================
			// All other land food resources.
			//
			resourceID = -1;
			// Find a starting comparison that does not have too
			// many workers.
			for (tempIndex = 0; < arrayGetSize(gFoodResources))
			{
				if (arrayGetInt(gFoodNumWorkers, tempIndex) >= arrayGetInt(gMaxFoodWorkers, tempIndex))
					continue;

				resourceID = arrayGetInt(gFoodResources, tempIndex);
				break;
			}

			if (resourceID >= 0)
			{
				closestResourceID = resourceID;
				closestResourceIndex = tempIndex;
				closestDistance = getDistance(
					location,
					kbUnitGetPosition(closestResourceID)
				);

				for (j = tempIndex + 1; < arrayGetSize(gFoodResources))
				{
					resourceID = arrayGetInt(gFoodResources, j);

					if (arrayGetInt(gFoodNumWorkers, j) >= arrayGetInt(gMaxFoodWorkers, j))
						continue;

					tempDistance = getDistance(location, kbUnitGetPosition(resourceID));
					if (tempDistance < closestDistance)
					{
						closestResourceID = resourceID;
						closestResourceIndex = j;
						closestDistance = tempDistance;
					}

					if (closestDistance < 12.0)
						break;	// This one is close enough.
				}
				foodID = closestResourceID;
				foodIndex = closestResourceIndex;
				foodDistance = closestDistance;
			}
			//
			// End of check for all other land food resources.
			// ========================================
		}
		//
		// End Food Resources.
		// ========================================

		// If we found a decaying huntable to work, we jump to this point from "goto",
		// bypassing the live huntable check.
		label PrioritizeDecayingAnimal;

		// ========================================
		// Wood Resources.
		//
		if (numWoodVills > 0)
		{
			resourceID = -1;
			// Find a starting comparison that does not have too
			// many workers.
			for (tempIndex = 0; < arrayGetSize(gWoodResources))
			{
				if (kbUnitIsType(resourceID, cUnitTypeypGroveBuilding) == true &&
					arrayGetInt(gWoodNumWorkers, tempIndex) == 25)
					continue;
				else if (arrayGetInt(gWoodNumWorkers, tempIndex) >= 5)
					continue;

				resourceID = arrayGetInt(gWoodResources, tempIndex);
				break;
			}

			if (resourceID >= 0)
			{
				closestResourceID = resourceID;
				closestResourceIndex = tempIndex;
				closestDistance = getDistance(
					location,
					kbUnitGetPosition(closestResourceID)
				);

				for (j = tempIndex + 1; < arrayGetSize(gWoodResources))
				{
					resourceID = arrayGetInt(gWoodResources, j);

					if (kbUnitIsType(resourceID, cUnitTypeypGroveBuilding) == true &&
						arrayGetInt(gWoodNumWorkers, j) == 25)
						continue;
					else if (arrayGetInt(gWoodNumWorkers, j) >= 5)
						continue;

					tempDistance = getDistance(location, kbUnitGetPosition(resourceID));
					if (tempDistance < closestDistance)
					{
						closestResourceID = resourceID;
						closestResourceIndex = j;
						closestDistance = tempDistance;
					}

					if (closestDistance < 12.0)
						break;	// This one is close enough.
				}
				woodID = closestResourceID;
				woodIndex = closestResourceIndex;
				woodDistance = closestDistance;
			}
		}
		//
		// End Wood Resources.
		// ========================================

		// ========================================
		// Gold Resources.
		//
		if (numGoldVills > 0)
		{
			resourceID = -1;
			// Find a starting comparison that does not have too
			// many workers.
			for (tempIndex = 0; < arrayGetSize(gGoldResources))
			{
				if (arrayGetInt(gGoldNumWorkers, tempIndex) >= arrayGetInt(gMaxGoldWorkers, tempIndex))
					continue;

				resourceID = arrayGetInt(gGoldResources, tempIndex);
				break;
			}

			if (resourceID >= 0)
			{
				closestResourceID = resourceID;
				closestResourceIndex = tempIndex;
				closestDistance = getDistance(
					location,
					kbUnitGetPosition(closestResourceID)
				);

				for (j = tempIndex + 1; < arrayGetSize(gGoldResources))
				{
					resourceID = arrayGetInt(gGoldResources, j);

					if (arrayGetInt(gGoldNumWorkers, j) >= arrayGetInt(gMaxGoldWorkers, j))
						continue;

					tempDistance = getDistance(location, kbUnitGetPosition(resourceID));
					if (tempDistance < closestDistance)
					{
						closestResourceID = resourceID;
						closestResourceIndex = j;
						closestDistance = tempDistance;
					}

					if (closestDistance < 12.0)
						break;	// This one is close enough.
				}
				goldID = closestResourceID;
				goldIndex = closestResourceIndex;
				goldDistance = closestDistance;
			}
		}
		//
		// End Gold Resources.
		// ========================================

		if (foodDistance < woodDistance) // Food is closer than Wood.
		{
			if (foodDistance < goldDistance) // Food is closer than Gold.
			{
				if (kbUnitIsType(foodID, cUnitTypeHuntable) && /* arrayGetInt(gFoodNumWorkers, foodIndex) == 0 && */
					kbUnitGetCurrentHitpoints(foodID) >= kbUnitGetMaximumHitpoints(foodID))
				{
					// Swedish should try to herd huntables toward nearby Torps.
					if (cMyCiv == cCivDESwedish)
						targetLocation = kbUnitGetPosition(
							getClosestUnit(cUnitTypedeTorp, cMyID,
							cUnitStateABQ, kbUnitGetPosition(foodID), 45.0)
						);
					// African civs should try to herd huntables toward nearby Granaries.
					else if (civIsAfrican())
						targetLocation = kbUnitGetPosition(
							getClosestUnit(cUnitTypedeGranary, cMyID,
							cUnitStateABQ, kbUnitGetPosition(foodID), 45.0)
						);

					if (targetLocation == cInvalidVector)
						targetLocation = gHomeBase;
					aiTaskUnitMove(unitID, (targetLocation + (kbUnitGetPosition(foodID) - targetLocation) +
						xsVectorNormalize(kbUnitGetPosition(foodID) - targetLocation) * 16.0));
					aiTaskUnitWork(unitID, foodID, true);

					// Update the number of workers on the food unit.
					arraySetInt(gFoodNumWorkers, foodIndex, (arrayGetInt(gFoodNumWorkers, foodIndex) + 1));
				}
				else
				{
					aiTaskUnitWork(unitID, foodID);

					// Update the number of workers on the food unit.
					arraySetInt(gDecayingNumWorkers, foodIndex, (arrayGetInt(gDecayingNumWorkers, foodIndex) + 1));
				}
				numFoodVills = numFoodVills - pop;
			}
			else // Gold is closer than Food.
			{
				aiTaskUnitWork(unitID, goldID);
				// Update the number of workers on the gold unit.
				arraySetInt(gGoldNumWorkers, goldIndex, (arrayGetInt(gGoldNumWorkers, goldIndex) + 1));
				numGoldVills = numGoldVills - pop;
			}
		}
		else if (woodDistance < goldDistance) // Wood is closer than both Food and Gold.
		{
			numWoodVills = numWoodVills - pop;
			aiTaskUnitWork(unitID, woodID);
			// Help vills that sometimes get stuck.
			aiTaskUnitMove(unitID, kbUnitGetPosition(woodID) + gDirection_UP, true);

			// Update the number of workers on the wood unit.
			arraySetInt(gWoodNumWorkers, woodIndex, (arrayGetInt(gWoodNumWorkers, woodIndex) + 1));
		}
		else // Gold is closer than both Food and Wood.
		{
			numGoldVills = numGoldVills - pop;
			aiTaskUnitWork(unitID, goldID);

			// Update the number of workers on the gold unit.
			arraySetInt(gGoldNumWorkers, goldIndex, (arrayGetInt(gGoldNumWorkers, goldIndex) + 1));
		}
	}
}

rule taskFishingBoats
inactive
minInterval 5
{
	static int fishingBoatQuery = -1;
	if (fishingBoatQuery < 0)
	{
		fishingBoatQuery = kbUnitQueryCreate("Fishing Boat Query");
		kbUnitQuerySetPlayerID(fishingBoatQuery, cMyID);
		kbUnitQuerySetPlayerRelation(fishingBoatQuery, -1);
		kbUnitQuerySetState(fishingBoatQuery, cUnitStateAlive);
		kbUnitQuerySetIgnoreKnockedOutUnits(fishingBoatQuery, true);
		kbUnitQuerySetUnitType(fishingBoatQuery, cUnitTypeAbstractFishingBoat);
	}
	kbUnitQueryResetResults(fishingBoatQuery);
	int numResults = kbUnitQueryExecute(fishingBoatQuery);

	int numFoodBoats = 0;
	int numGoldBoats = 0;
	int unitID = -1;
	int actionID = -1;
	int resourceID = -1;
	int planID = -1;
	vector location = cInvalidVector;
	int closestResourceID = -1;
	float foodDistance = 0.0;
	float goldDistance = 0.0;
	int foodID = -1;
	int goldID = -1;
	vector targetLocation = cInvalidVector;

	numFoodBoats = numResults * (aiGetResourcePercentage(cResourceFood) / 
		(aiGetResourcePercentage(cResourceFood) + aiGetResourcePercentage(cResourceGold)));
	numGoldBoats = numResults - numFoodBoats;

	if (numFoodBoats > 0)
		updateFoodFishBreakdown();
	if (numGoldBoats > 0)
		updateGoldFishBreakdown();

	for (i = 0; < numResults)
	{
		unitID = kbUnitQueryGetResult(fishingBoatQuery, i);
		actionID = kbUnitGetActionType(unitID);
		switch (actionID)
		{
			case cActionTypeMove: // Currently moving.
			case cActionTypeMoveByGroup: // Currently moving.
				continue;
			default: // Boats assigned to a plan.
			{
				if (kbUnitGetPlanID(unitID) >= 0)
					continue;
			}
		}
		resourceID = kbUnitGetTargetUnitID(unitID);
		if (resourceID >= 0)
		{
			if (actionID == cActionTypeGather)
			{
				if (kbUnitIsType(resourceID, cUnitTypeAbstractFish))
				{
					if (numFoodBoats > 0)
					{
						numFoodBoats--;
						continue;
					}
				}
				else if (kbUnitIsType(resourceID, cUnitTypeAbstractWhale))
				{
					if (numGoldBoats > 0)
					{
						numGoldBoats--;
						continue;
					}
				}
			}
		}

		location = kbUnitGetPosition(unitID);
		foodDistance = 9999.0;
		goldDistance = 9999.0;

		if (numFoodBoats > 0)
		{
			resourceID = arrayGetInt(gFoodFishResources, 0);
			if (resourceID >= 0)
			{
				closestResourceID = resourceID;
				for (j = 1; < arrayGetSize(gFoodFishResources))
				{
					resourceID = arrayGetInt(gFoodFishResources, j);
					if (getDistance(location, kbUnitGetPosition(resourceID)) < getDistance(location, kbUnitGetPosition(closestResourceID)))
						closestResourceID = resourceID;
				}
				foodDistance = getDistance(location, kbUnitGetPosition(closestResourceID));
				foodID = closestResourceID;
			}
		}

		if (numGoldBoats > 0)
		{
			resourceID = arrayGetInt(gGoldFishResources, 0);
			if (resourceID >= 0)
			{
				closestResourceID = resourceID;
				for (j = 1; < arrayGetSize(gGoldFishResources))
				{
					resourceID = arrayGetInt(gGoldFishResources, j);
					if (getDistance(location, kbUnitGetPosition(resourceID)) < getDistance(location, kbUnitGetPosition(closestResourceID)))
						closestResourceID = resourceID;
				}
				goldDistance = getDistance(location, kbUnitGetPosition(closestResourceID));
				goldID = closestResourceID;
			}
		}

		if (foodDistance < goldDistance) // Food is closer than Gold.
		{
			aiTaskUnitWork(unitID, foodID);
			numFoodBoats--;
		}
		else
		{
			aiTaskUnitWork(unitID, goldID);
			numGoldBoats--;
		}
	}
}

int getClosestTreeID(vector location = cInvalidVector)
{
	int treeQuery = createSimpleUnitQuery(cUnitTypeTree, cPlayerRelationAny, cUnitStateAny, location, 45.0);
	kbUnitQuerySetAscendingSort(treeQuery, true);
	kbUnitQueryResetResults(treeQuery);
	if (kbUnitQueryExecute(treeQuery) > 0)
		return(kbUnitQueryGetResult(treeQuery, 0));

	return(-1);
}

rule architectManager
inactive
minInterval 2
{
	int numArchitects = kbUnitCount(cMyID, cUnitTypedeArchitect, cUnitStateAlive);

	if (cMyCiv == cCivDEItalians && kbGetAge() >= cAge2)
	{
		static int architectMaintainPlan = -1;
		int numWanted = (kbGetAge() >= cAge3) ? kbGetBuildLimit(cMyID, cUnitTypedeArchitect) : 2;
		if (architectMaintainPlan < 0)
			architectMaintainPlan = createSimpleMaintainPlan(cUnitTypedeArchitect, numWanted, true);
		else
			aiPlanSetVariableInt(architectMaintainPlan, cTrainPlanNumberToMaintain, 0, numWanted);
	}

	if (numArchitects == 0)
		return;

	int architectID = -1;
	int architectQuery = createSimpleUnitQuery(cUnitTypedeArchitect, cMyID, cUnitStateAlive);
	numArchitects = kbUnitQueryExecute(architectQuery);
	int previousIndex = 0;
	int planID = -1;
	int bestPlanID = -1;
	int bestPlanPrio = -1;

	for (i = 0; < numArchitects)
	{
		architectID = kbUnitQueryGetResult(architectQuery, i);
		if (kbUnitGetPlanID(architectID) >= 0)
		{
			architectID = -1;
			continue;
		}
	}

	if (architectID >= 0)
	{
		for (index = 0; < aiPlanGetNumber(cPlanBuild, cPlanStateNone, false))
		{
			planID = aiPlanGetIDByIndex(cPlanBuild, cPlanStateNone, false, index);

			if (aiPlanGetUserVariableInt(planID, cBuildPlanBuilderTypeID, 0) != cUnitTypedeArchitect)
			{
				continue;
			}

			debugBuildings("Considering for architect: " + aiPlanGetName(planID));

			int prio = aiPlanGetDesiredPriority(planID);
			if (prio > bestPlanPrio)
			{
				bestPlanID = planID;
				bestPlanPrio = prio;
			}
		}

		if (bestPlanID >= 0)
		{
			aiPlanAddUnitType(bestPlanID, cUnitTypedeArchitect, 1, 1, 1);
			aiPlanAddUnit(bestPlanID, architectID);
			aiPlanSetActive(bestPlanID, true);
			debugBuildings("Activating " + aiPlanGetName(planID) + " for architect construction.");
		}
		else
		{
			if (kbUnitCount(cMyID, gTowerUnit, cUnitStateABQ) < kbGetBuildLimit(cMyID, gTowerUnit))
			{
				debugBuildings("Queueing tower build plan for architect construction.");
				createArchitectBuildPlan(gTowerUnit, 45, gHomeBase);
			}
			else
			{
				debugBuildings("Nothing to build, looking for tree.");
				int treeID = getClosestTreeID(gHomeBase);
				if (treeID >= 0)
					aiTaskUnitWork(architectID, treeID);
				else
					aiTaskUnitMove(architectID, gHomeBase + gDirection_DOWN * 5.0);
			}
		}
	}
}

rule taskAbuns
inactive
minInterval 10
{
	int mode = 0;
	int numAbuns = -1;
	static int abunDefendPlan = -1;
	if (getHomeBaseThreatened())
		mode = 1;
	switch (mode)
	{
		case 0:
		{
			if (kbUnitCount(cMyID, cUnitTypedeMountainMonastery, cUnitStateAlive) < 0)
				break;
			if (abunDefendPlan >= 0)
			{
				aiPlanDestroy(abunDefendPlan);
				abunDefendPlan = -1;
			}
			int abunQuery = createSimpleUnitQuery(cUnitTypedeAbun);
			numAbuns = kbUnitQueryExecute(abunQuery);
			int abunID = -1;
			int mountainMonasteryID = -1;
			vector location = cInvalidVector;
			for (i = 0; < numAbuns)
			{
				abunID = kbUnitQueryGetResult(abunQuery, i);
				location = kbUnitGetPosition(abunID);
				for (j = 0; < kbUnitCount(cMyID, cUnitTypedeMountainMonastery, cUnitStateAlive))
				{
					mountainMonasteryID = getUnitByLocation(cUnitTypedeMountainMonastery, cMyID,
						cUnitStateAlive, location, -1, j);
					if (kbUnitGetResourceAmount(mountainMonasteryID, cResourceGold) < 1.0)
					{
						mountainMonasteryID = -1;
						continue;
					}
					if (kbUnitGetNumberWorkers(mountainMonasteryID) == 20)
					{
						mountainMonasteryID = -1;
						continue;
					}
					break;
				}
				if (mountainMonasteryID >= 0)
					aiTaskUnitWork(abunID, mountainMonasteryID);
			}
			break;
		}
		case 1:
		{
			numAbuns = kbUnitCount(cMyID, cUnitTypedeAbun, cUnitStateAlive);
			if (abunDefendPlan < 0)
			{
				abunDefendPlan = aiPlanCreate("Abun Defend Plan", cPlanDefend);
				aiPlanSetVariableVector(abunDefendPlan, cDefendPlanDefendPoint, 0, gHomeBase);
				aiPlanSetVariableFloat(abunDefendPlan, cDefendPlanEngageRange, 0, cvDefenseReflexRadiusActive);
				aiPlanSetVariableInt(abunDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
				aiPlanSetVariableInt(abunDefendPlan, cDefendPlanRefreshFrequency, 0, 10);
				aiPlanAddUnitType(abunDefendPlan, cUnitTypedeAbun, numAbuns, numAbuns, numAbuns);
				aiPlanSetDesiredPriority(abunDefendPlan, 99);
				aiPlanSetActive(abunDefendPlan);
			}
			else
				aiPlanAddUnitType(abunDefendPlan, cUnitTypedeAbun, numAbuns, numAbuns, numAbuns);

			break;
		}
	}

}

rule crateMonitor
inactive
minInterval 5
{
	static int cratePlanID = -1;
	int numCrates = -1;
	int numUnits = -1;
	int unitID = -1;

	int crateQuery = createSimpleUnitQuery(cUnitTypeAbstractResourceCrate, cPlayerRelationAny, cUnitStateAlive, gHomeBase, 25.0);
	kbUnitQuerySetAscendingSort(crateQuery, true);
	kbUnitQueryExecute(crateQuery);
	numCrates = kbUnitQueryNumberResults(crateQuery);

	if (numCrates < 1)
	{
		aiPlanDestroy(cratePlanID);
		cratePlanID = -1;
		return;
	}

	if (cratePlanID < 0)
	{	// Initialize the plan
		cratePlanID = aiPlanCreate("Main Base Crate", cPlanReserve);
		aiPlanSetDesiredPriority(cratePlanID, 99);
		aiPlanSetActive(cratePlanID, true);
	}
	aiPlanAddUnitType(cratePlanID, cUnitTypeLogicalTypeSettlerBuildLimit, 1, numCrates, numCrates);
	if (cMyCiv == cCivGermans && kbGetAge() == cAge1)
		aiPlanAddUnitType(cratePlanID, cUnitTypeLogicalTypeSettlerBuildLimit, 1, numCrates / 2, numCrates / 2);


	numUnits = aiPlanGetNumberUnits(cratePlanID, cUnitTypeLogicalTypeSettlerBuildLimit);
	for (i = 0; < numUnits)
	{
		if (kbUnitQueryNumberResults(crateQuery) > i) // This should always be the case.
		{
			unitID = aiPlanGetUnitByIndex(cratePlanID, i);
			aiTaskUnitWork(unitID, kbUnitQueryGetResult(crateQuery, i));
		}
	}
}

rule startingCrates
inactive
minInterval 1
{
	// Don't check for starting crates/herdables until our Town Center is built.
	if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateAlive) == 0)
	{
		if (kbUnitCount(cMyID, cUnitTypeCoveredWagon, cUnitStateAlive) > 0 ||
			kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) > 0)
			return;
	}
	// Let villagers auto-gather their starting crates. For Africans, let them auto-gather the first herdable.
	int numCrates = -1;
	static bool wait = true;

	int crateQuery = createSimpleUnitQuery(cUnitTypeAbstractResourceCrate, cMyID, cUnitStateAlive, gHomeBase, 25.0);
	kbUnitQuerySetAscendingSort(crateQuery, true);
	numCrates = kbUnitQueryExecute(crateQuery);

	// Vills will be autogathering our crates. Let them finish.
	if (numCrates > 0)
		return;

	if (civIsAfrican() == true)
	{	// Wait until the first slain cattle is fully gathered, then proceed.
		if (wait == true)
		{
			xsSetRuleMinIntervalSelf(5);
			wait = false;
			return;
		}
		xsSetRuleMinIntervalSelf(1);
		int slainCattleID = getClosestUnit(cUnitTypeHerdable, 0, cUnitStateDead, gHomeBase, 10.0);
		if (slainCattleID >= 0)
		{
			if (kbUnitGetResourceAmount(slainCattleID, cResourceFood) > 1.0)
				return;
		}
	}

	xsEnableRule("crateMonitor");
	xsEnableRule("taskVillagers");
	taskVillagers();
	if (gGoodFishingMap == true)
	{
		xsEnableRule("taskFishingBoats");
	}

	xsDisableSelf();
}

//==============================================================================
// updategGarrisonableBuilding
//==============================================================================
void updategGarrisonableBuilding(void)
{
	int numberResults = 0;
	arrayResetSelf(gGarrisonableBuilding);
	if (gGarrisonableBuildingQuery < 0)
	{
		gGarrisonableBuildingQuery = kbUnitQueryCreate("Garrison Buildings Query");
		kbUnitQuerySetPlayerID(gGarrisonableBuildingQuery, cMyID);
		kbUnitQuerySetPlayerRelation(gGarrisonableBuildingQuery, -1);
		kbUnitQuerySetState(gGarrisonableBuildingQuery, cUnitStateAlive);
		kbUnitQuerySetIgnoreKnockedOutUnits(gGarrisonableBuildingQuery, true);
	}
	kbUnitQueryResetResults(gGarrisonableBuildingQuery);
	kbUnitQuerySetUnitType(gGarrisonableBuildingQuery, cUnitTypeTownCenter);
	kbUnitQueryExecute(gGarrisonableBuildingQuery);
	kbUnitQuerySetUnitType(gGarrisonableBuildingQuery, cUnitTypeOutpost);
	kbUnitQueryExecute(gGarrisonableBuildingQuery);
	if (cMyCiv == cCivChinese)
	{
		kbUnitQuerySetUnitType(gGarrisonableBuildingQuery, cUnitTypeypVillage);
		kbUnitQueryExecute(gGarrisonableBuildingQuery);
	}
	numberResults = kbUnitQueryNumberResults(gGarrisonableBuildingQuery);

	for (i = 0; < numberResults)
		arrayPushInt(gGarrisonableBuilding, kbUnitQueryGetResult(gGarrisonableBuildingQuery, i));
}

//==============================================================================
//
// villagerRetreat
//
// - Send threatened villagers to a garrisonable building.
//
//==============================================================================
rule villagerRetreat
active
minInterval 10
{
	if (gVillagerQuery < 0)
		return;

	int unitID = -1;
	int actionID = -1;
	bool nextVillager = false;
	vector location = cInvalidVector;
	int buildingID = -1;
	int closestBuildingID = -1;
	int count = 0;
	updategGarrisonableBuilding();

	for (i = 0; < kbUnitQueryNumberResults(gVillagerQuery))
	{
		unitID = kbUnitQueryGetResult(gVillagerQuery, i);
		actionID = kbUnitGetActionType(unitID);
		location = kbUnitGetPosition(unitID);
		count = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
			cUnitStateAlive, location, 30.0);

		if (actionID < 0) // Should signify a villager who is garrisoned inside a building.
		{
			continue;
		}

		if (count <= 4)
			continue;

		buildingID = arrayGetInt(gGarrisonableBuilding, 0);
		if (buildingID >= 0)
		{
			closestBuildingID = buildingID;
			for (j = 1; < arrayGetSize(gGarrisonableBuilding))
			{
				buildingID = arrayGetInt(gGarrisonableBuilding, j);
				if (getDistance(location, kbUnitGetPosition(buildingID)) <
					getDistance(location, kbUnitGetPosition(closestBuildingID)))
					closestBuildingID = buildingID;
			}
			aiTaskUnitWork(unitID, closestBuildingID);
			if (xsIsRuleEnabled("ungarrisonVillagers") == false)
				xsEnableRule("ungarrisonVillagers");
		}
	}
}

rule ungarrisonVillagers
inactive
minInterval 5
{
	if (gGarrisonableBuilding < 0)
		return;

	int buildingID = -1;
	int enemyCount = -1;
	int allyCount = -1;
	vector location = cInvalidVector;
	bool disable = true;
	for (i = 0; < arrayGetSize(gGarrisonableBuilding))
	{
		buildingID = arrayGetInt(gGarrisonableBuilding, i);
		location = kbUnitGetPosition(buildingID);
		enemyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
			cUnitStateAlive, location, 45.0);
		allyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationAlly,
			cUnitStateAlive, location, 45.0);
		if (enemyCount > 4)
		{
			continue;
		}
		aiTaskUnitEject(buildingID, location + gDirection_DOWN * 5.0);
	}

	// if (disable == true)
	// 	xsDisableSelf();
}

//==============================================================================
// addMillBuildPlan
//==============================================================================
int addMillBuildPlan(void)
{
	if (gTimeToFarm == false)
		gTimeToFarm = true;

	// We are already maxed out.
	if (kbUnitCount(cMyID, gFarmUnit, cUnitStateABQ) + arrayGetSize(gMillTypePlans) >=
		kbGetBuildLimit(cMyID, gFarmUnit) && kbGetBuildLimit(cMyID, gFarmUnit) > 0)
		return(-1);

	int buildPlanID = createBuildPlan(gFarmUnit, 1, 70, gHomeBase + gDirection_DOWN * 40.0);

	aiPlanSetDesiredResourcePriority(buildPlanID, 60); // above average but below villager production (indian villagers cost wood)

	return (buildPlanID);
}

//==============================================================================
// addPlantationBuildPlan
//==============================================================================
int addPlantationBuildPlan(void)
{
	if (gTimeForPlantations == false)
		gTimeForPlantations = true;

	// We are already maxed out.
	if (kbUnitCount(cMyID, gPlantationUnit, cUnitStateABQ) + arrayGetSize(gPlantationTypePlans) >=
		kbGetBuildLimit(cMyID, gPlantationUnit) && kbGetBuildLimit(cMyID, gPlantationUnit) > 0)
		return(-1);

	int buildPlanID = createBuildPlan(gPlantationUnit, 1, 70, gHomeBase + gDirection_DOWN * 40.0);
	aiPlanSetDesiredResourcePriority(buildPlanID, 60); // above average but below villager production (indian villagers cost wood)

	return (buildPlanID);
}

//==============================================================================
// tacticFarmMonitor
//==============================================================================
rule tacticFarmMonitor
inactive
group tcComplete
minInterval 10
{
	if (civIsAsian() == false && civIsAfrican() == false && cMyCiv != cCivDEMexicans)
	{
		xsDisableSelf();
		return;
	}

	static int paddyQueryID = -1;
	if (paddyQueryID < 0)
	{
		paddyQueryID = kbUnitQueryCreate("paddyGetUnitQuery");
		kbUnitQuerySetIgnoreKnockedOutUnits(paddyQueryID, true);
	}

	if (paddyQueryID != -1)
	{
		kbUnitQuerySetPlayerRelation(paddyQueryID, -1);
		kbUnitQuerySetPlayerID(paddyQueryID, cMyID);
		kbUnitQuerySetUnitType(paddyQueryID, gFarmUnit);
		kbUnitQuerySetState(paddyQueryID, cUnitStateAlive);
	}
	else
		return;

	kbUnitQueryResetResults(paddyQueryID);
	int numberFound = kbUnitQueryExecute(paddyQueryID);
	// Calculate a crude estimate.
	int numberFoodWanted = getRoundedNumber(aiGetResourcePercentage(cResourceFood) * numberFound);
	int numberGoldWanted = numberFound - numberFoodWanted;
	int numberOnFood = 0;
	int numberOnGold = 0;
	int unitID = -1;
	int index = 0;

	for (i = 0; < numberFound)
	{
		unitID = kbUnitQueryGetResult(paddyQueryID, i);
		if (aiUnitGetTactic(unitID) == gFarmFoodTactic)
			numberOnFood++;
		else
			numberOnGold++;
	}
	while (numberOnGold < numberGoldWanted)
	{
		if (index >= numberFound)
			break;	// ensure no infinite loop
		unitID = kbUnitQueryGetResult(paddyQueryID, index);
		if (aiUnitGetTactic(unitID) == gFarmFoodTactic)
		{
			aiUnitSetTactic(unitID, gFarmGoldTactic);
			numberOnFood--;
			numberOnGold++;
		}
		index++;
	}
	index = 0;
	while (numberOnFood < numberFoodWanted)
	{
		if (index >= numberFound)
			break;	// ensure no infinite loop
		unitID = kbUnitQueryGetResult(paddyQueryID, index);
		if (aiUnitGetTactic(unitID) == gFarmGoldTactic)
		{
			aiUnitSetTactic(unitID, gFarmFoodTactic);
			numberOnGold--;
			numberOnFood++;
		}
		index++;
	}
}

//==============================================================================
// rule econMasterRule
/*
	This rule calls the updateResourceDistribution() function on a regular basis.
*/
//==============================================================================
rule econMasterRule
inactive
group postStartup
minInterval 20
{
	updateResourceDistribution();

	int limit = kbGetBuildLimit(cMyID, gEconUnit);
	if (kbGetAge() == cAge1 && agingUp() == false)
	{
		aiPlanSetVariableInt(gSettlerMaintainPlan, cTrainPlanNumberToMaintain, 0, 16);
	}
	else
	{
		// Update regularly as the limit can change due to various factors.
		aiPlanSetVariableInt(gSettlerMaintainPlan, cTrainPlanNumberToMaintain, 0, limit);
	}

	// Account for Architects that may be acquired outside of Italians.
	// (Not sure if possible yet).
	if (xsIsRuleEnabled("architectManager") == false)
	{
		if (kbUnitCount(cMyID, cUnitTypedeArchitect, cUnitStateABQ) > 0)
			xsEnableRule("architectManager");
	}
}

bool isLivestockPenTracked(int buildingID = -1)
{
	return(aiPlanGetIDSubStr("TrackLivestockPen" + buildingID) >= 0);
}

void trackLivestockPen(int buildingID = -1)
{
	int trackPlan = aiPlanCreate("TrackLivestockPen" + buildingID, cPlanData);
	aiPlanAddUserVariableInt(trackPlan, 0, "Number of tasked herdables", 1);
	aiPlanSetUserVariableInt(trackPlan, 0, 0, 0);
}

void untrackLivestockPen(int buildingID = -1)
{
	aiPlanDestroy(aiPlanGetIDSubStr("TrackLivestockPen" + buildingID));
}

int getNumberTaskedHerdables(int buildingID = -1)
{
	int trackPlan = aiPlanGetIDSubStr("TrackLivestockPen" + buildingID);
	return(aiPlanGetUserVariableInt(trackPlan, 0, 0));
}

void updateNumberTaskedHerdables(int buildingID = -1, int newNumber = 0)
{
	int trackPlan = aiPlanGetIDSubStr("TrackLivestockPen" + buildingID);
	if (trackPlan == -1)
		return;
	if (newNumber < 0)
		newNumber = 0;
	aiPlanSetUserVariableInt(trackPlan, 0, 0, newNumber);
}


rule herdMonitor
inactive
minInterval 10
{
	int mainBase = kbBaseGetMainID(cMyID);
	vector mainBaseLoc = kbBaseGetLocation(cMyID, mainBase);

	int herdableID = -1;
	vector herdablePos = cInvalidVector;
	int buildingID = -1;
	vector buildingPos = cInvalidVector;
	vector normalVec = cInvalidVector;

	static int trackedLivestockPensArray = -1;
	int arrayIndex = 0;
	static int herdableQuery = -1;
	static int buildingQuery = -1;

	// Initialize
	if (trackedLivestockPensArray == -1)
	{
		trackedLivestockPensArray = xsArrayCreateInt(100, -1, "herdMonitor tracked buildings");

		herdableQuery = kbUnitQueryCreate("herdMonitor herdable query");
		kbUnitQuerySetUnitType(herdableQuery, cUnitTypeHerdable);
		kbUnitQuerySetPlayerRelation(herdableQuery, -1);
		kbUnitQuerySetPlayerID(herdableQuery, cMyID, false);
		kbUnitQuerySetState(herdableQuery, cUnitStateAlive);
		kbUnitQuerySetIgnoreKnockedOutUnits(herdableQuery, true);

		buildingQuery = kbUnitQueryCreate("herdMonitor building query");
		kbUnitQuerySetUnitType(buildingQuery, cUnitTypeLogicalTypeBuildingsNotWalls);
		kbUnitQuerySetPlayerRelation(buildingQuery, -1);
		kbUnitQuerySetPlayerID(buildingQuery, cMyID, false);
		kbUnitQuerySetState(buildingQuery, cUnitStateAlive);
		kbUnitQuerySetIgnoreKnockedOutUnits(buildingQuery, true);
		kbUnitQuerySetMaximumDistance(buildingQuery, 5000.0);
		kbUnitQuerySetAscendingSort(buildingQuery, true);
	}
	
	kbUnitQueryResetResults(herdableQuery);
	for(i = 0; < kbUnitQueryExecute(herdableQuery))
	{
		herdableID = kbUnitQueryGetResult(herdableQuery, i);
		herdablePos = kbUnitGetPosition(herdableID);

		if (kbUnitGetTargetUnitID(herdableID) >= 0)
			continue;
	  
		bool skip = civIsAfrican() || kbUnitGetResourceAmount(herdableID, cResourceFood) >= kbUnitGetCarryCapacity(herdableID, cResourceFood);

		bool assigned = false;

		kbUnitQueryResetResults(buildingQuery);
		kbUnitQuerySetPosition(buildingQuery, herdablePos);
		for(j = 0; < kbUnitQueryExecute(buildingQuery))
		{
			if (skip)
				break;

			buildingID = kbUnitQueryGetResult(buildingQuery, j);
			buildingPos = kbUnitGetPosition(buildingID);

			if (kbUnitIsType(buildingID, gLivestockPenUnit) == false)
				continue;
			
			if (kbCanPath2(herdablePos, buildingPos, kbUnitGetProtoUnitID(herdableID)) == false)
				continue;
			
			if (isLivestockPenTracked(buildingID) == false)
			{
				trackLivestockPen(buildingID);
				updateNumberTaskedHerdables(buildingID, kbUnitGetNumberWorkers(buildingID));
				xsArraySetInt(trackedLivestockPensArray, arrayIndex, buildingID);
				arrayIndex++;
			}

			// assume that all gLivestockPenUnit can house 10 herdables.
			if (getNumberTaskedHerdables(buildingID) >= 10)
				continue;
			
			aiTaskUnitWork(herdableID, buildingID);
			updateNumberTaskedHerdables(buildingID, getNumberTaskedHerdables(buildingID) + 1);
			assigned = true;
			break;
		}

		if (assigned)
			continue;
		
		kbUnitQueryResetResults(buildingQuery);
		kbUnitQuerySetPosition(buildingQuery, herdablePos);
		for(j = 0; < kbUnitQueryExecute(buildingQuery))
		{
			buildingID = kbUnitQueryGetResult(buildingQuery, j);
			buildingPos = kbUnitGetPosition(buildingID);

			if (kbCanPath2(herdablePos, buildingPos, kbUnitGetProtoUnitID(herdableID)) == false)
				continue;
			
			if (mainBase >= 0 && xsVectorLength(buildingPos - mainBaseLoc) > 60.0)
				continue;
			
			if (xsVectorLength(herdablePos - buildingPos) < 6.0 || xsVectorLength(herdablePos - buildingPos) > 16.0)
			{
				normalVec = xsVectorNormalize(herdablePos - buildingPos);
				aiTaskUnitMove(herdableID, buildingPos + normalVec * 8.0);
			}

			break;
		}
	}

	for(i = 0; < arrayIndex)
		untrackLivestockPen(xsArrayGetInt(trackedLivestockPensArray, i));
}

rule maintainCreeCoureurs
inactive
minInterval 30
{
	static int creePlan = -1;
	int limit = 0;

	// Check build limit
	limit = kbGetBuildLimit(cMyID, cUnitTypeCoureurCree);

	if (kbUnitCount(cMyID, cUnitTypeTradingPost, cUnitStateAlive) < 1)
		limit = 0;

	// Create/update maintain plan
	if ((creePlan < 0) && (limit >= 1))
	{
		creePlan = createSimpleMaintainPlan(cUnitTypeCoureurCree, limit, true, kbBaseGetMainID(cMyID), 1);
	}
	else
	{
		aiPlanSetVariableInt(creePlan, cTrainPlanNumberToMaintain, 0, limit);
	}
}

rule maintainBerberNomads
inactive
minInterval 30
{
	static int nomadPlan = -1;
	int limit = 0;

	if (kbUnitCount(0, cUnitTypedeSocketBerbers, cUnitStateAny) == 0)
		return;

	// Check build limit
	limit = kbGetBuildLimit(cMyID, cUnitTypedeNatNomad);

	if (kbUnitCount(cMyID, cUnitTypeTradingPost, cUnitStateAlive) < 1)
		limit = 0;

	// Create/update maintain plan
	if ((nomadPlan < 0) && (limit >= 1))
	{
		nomadPlan = createSimpleMaintainPlan(cUnitTypedeNatNomad, limit, true, kbBaseGetMainID(cMyID), 1);
	}
	else
	{
		aiPlanSetVariableInt(nomadPlan, cUnitTypedeNatNomad, 0, limit);
	}
}

//==============================================================================
// monitorFeeding
// This rule gets activated by the commHandler when a player requests we feed him resources.
// We can only feed resources to one player at a time, so if 2 humans ask us to feed 
// we will only feed the last player who requested it.
// This monitor doesn't send any AI chats because they can get quite spammy in here.
//==============================================================================
rule monitorFeeding
inactive
minInterval 60
{
	// Ignore already eliminated players and reset the global.
	if (kbHasPlayerLost(gFeedGoldTo) == true)
	{
		gFeedGoldTo = 0;
	}
	if (kbHasPlayerLost(gFeedWoodTo) == true)
	{
		gFeedWoodTo = 0;
	}
	if (kbHasPlayerLost(gFeedFoodTo) == true)
	{
		gFeedFoodTo = 0;
	}
	
	// We have no active feeds anymore so disable.
	if ((gFeedGoldTo < 1) && (gFeedWoodTo < 1) && (gFeedFoodTo < 1))
	{
		xsDisableSelf();
	}

	if (gFeedGoldTo > 0)
	{
		if (handleTributeRequest(cResourceGold, gFeedGoldTo) == false)
		{
			debugEconomy("We don't have enough spare Gold to feed player: " + gFeedGoldTo);
		}
	}
	if (gFeedWoodTo > 0)
	{
		if (handleTributeRequest(cResourceWood, gFeedWoodTo) == false)
		{
			debugEconomy("We don't have enough spare Wood to feed player: " + gFeedWoodTo);
		}
	}
	if (gFeedFoodTo > 0)
	{
		if (handleTributeRequest(cResourceFood, gFeedFoodTo) == false)
		{
			debugEconomy("We don't have enough spare Food to feed player: " + gFeedFoodTo);
		}
	}
}

//==============================================================================
/*	
	Resource Trickle Monitors
*/
//==============================================================================
rule tradeRouteTacticMonitor
inactive
minInterval 60
{
	int numberTradingPostsOnRoute = 0;
	int tradingPostID = -1;
	int tradingPostTactic = -1;
	const int crateTypeInfluence = 3;

	for (routeIndex = 0; < gNumberTradeRoutes)
	{
		numberTradingPostsOnRoute = kbTradeRouteGetNumberTradingPosts(routeIndex);
		for (tradingPostIndex = 0; < numberTradingPostsOnRoute)
		{
			tradingPostID = kbTradeRouteGetTradingPostID(routeIndex, tradingPostIndex);
			if (kbUnitGetPlayerID(tradingPostID) == cMyID)
			{
				// Check if the TR is capable of generating resources.
				if ((kbBuildingTechGetStatus(xsArrayGetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade +
					(routeIndex * 2)), tradingPostID) == cTechStatusActive) ||
					(xsArrayGetInt(gTradeRouteIndexAndType, routeIndex) == cTradeRouteCapturableAfrica) ||
					(xsArrayGetInt(gTradeRouteIndexAndType, routeIndex) == cTradeRouteCapturableAsia))
				{
					if (tradingPostTactic == -1) // If we didn't calculate a tactic yet do so, this carries over for all routes/tps.
					{
						// Get which resource type should be generated.
						tradingPostTactic = cResourceWood;
						// 20% Chance for African civs to just set it to Influence when we're below 500 Influence.
						// Don't do this when we absolutely need wood though.
						if (civIsAfrican() == true)
						{
							if ((aiRandInt(5) < 1) &&
								(kbResourceGet(cResourceInfluence) < 500)) 
							{
								tradingPostTactic = crateTypeInfluence;
							}
						}
						debugEconomy("Setting all Trading Posts to collect: " +
							kbGetProtoUnitName(xsArrayGetInt(gTradeRouteCrates, tradingPostTactic + (routeIndex * 4))));
						aiSetTradingPostUnitType(
							tradingPostID, xsArrayGetInt(gTradeRouteCrates, tradingPostTactic + (routeIndex * 4)));
					}
					else
					{
						aiSetTradingPostUnitType(
							tradingPostID, xsArrayGetInt(gTradeRouteCrates, tradingPostTactic + (routeIndex * 4)));
					}
				}
				else
				{
					break; // This route doesn't have the first upgrade active yet so continue on to the next route.
				}
			}
		}
	}
}

void factoryTacticMonitor()
{
	int factoryQueryID = createSimpleUnitQuery(cUnitTypeFactory, cMyID, cUnitStateAlive);
	kbUnitQuerySetIgnoreKnockedOutUnits(factoryQueryID, true);
	int numberFound = kbUnitQueryExecute(factoryQueryID);
	if (numberFound <= 0)
		return;

	if (numberFound == 1)
	{
		researchSimpleTech(cTechFactoryWaterPower, -1, cUnitTypeFactory, 99);
		aiUnitSetTactic(kbUnitQueryGetResult(factoryQueryID, 0), cTacticWood);
		return;
	}

	if (numberFound == 2)
	{
		researchSimpleTech(cTechFactoryMassProduction, -1, cUnitTypeFactory, 99);
		switch (cMyCiv)
		{
			case cCivBritish:
			{
				researchSimpleTech(cTechImperialRocket, -1, cUnitTypeFactory, 50);
				break;
			}
			case cCivOttomans:
			{
				researchSimpleTech(cTechImperialBombard, -1, cUnitTypeFactory, 50);
				break;
			}
			default:
			{
				researchSimpleTech(cTechImperialCannon, -1, cUnitTypeFactory, 50);
				break;
			}
		}
		aiUnitSetTactic(kbUnitQueryGetResult(factoryQueryID, 1), cTacticCannon);
		return;
	}

	if (numberFound == 3)
	{
		aiUnitSetTactic(kbUnitQueryGetResult(factoryQueryID, 2), cTacticWood);
	}
}

rule shrineTacticMonitor
inactive
minInterval 30
{
	if (cMyCiv != cCivJapanese)
	{
		xsDisableSelf();
		return;
	}

	int shrineID = getUnit(cUnitTypeypShrineJapanese, cMyID, cUnitStateAlive);
	if (shrineID != -1 && kbGetAge() >= cAge2)
	{
		aiUnitSetTactic(shrineID, cTacticShrineWood);
		xsDisableSelf();
	}
}

rule porcelainTowerTacticMonitor
inactive
mininterval 60
{
	// Check for the Porcelain Tower, if we don't find one we've lost it and we can disable this Rule.
	int porcelainTowerID = getUnit(gPorcelainTowerPUID);
	if (porcelainTowerID < 0)
	{
		xsDisableSelf();
		return;
	}

	int porcelainTowerTactic = cTacticWonderWood;
	/* switch (getMostNeededResource())
	{
	case cResourceGold:
	{
		porcelainTowerTactic = cTacticWonderCoin;
		break;
	}
	case cResourceWood:
	{
		porcelainTowerTactic = cTacticWonderWood;
		break;
	}
	default: // Food.
	{
		porcelainTowerTactic = cTacticWonderFood;
		break;
	}
	} */

	debugEconomy("Setting our Porcelain Tower to collect: " + porcelainTowerTactic);
	aiUnitSetTactic(porcelainTowerID, porcelainTowerTactic);
	xsDisableSelf();
}

rule sacredFieldMonitor
inactive
minInterval 60
{

	static int cowPlan = -1;
	int numHerdables = 0;
	int numCows = 0;


	// Build a sacred field if there is none and we're either in age2, have herdables or excess wood
	if ((kbUnitCount(cMyID, cUnitTypeypSacredField, cUnitStateAlive) < 1) &&
		((kbGetAge() >= cAge2) || (kbUnitCount(cMyID, cUnitTypeHerdable, cUnitStateAlive) + kbUnitCount(cMyID, cUnitTypeypSacredCow, cUnitStateAlive) > 0)) ||
		(kbResourceGet(cResourceWood) > 650))
	{	// Make sure we're not at the limit yet or are already trying to build one
		if ((kbGetBuildLimit(cMyID, cUnitTypeypSacredField) > kbUnitCount(cMyID, cUnitTypeypSacredField, cUnitStateAlive)) &&
			(aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypSacredField) < 0))
		{
			createBuildPlan(cUnitTypeypSacredField, 1, 50, gHomeBase);
			return;
		}
	}

	// Quit if there is no sacred field around or we're in age1 without excess food
	if ((kbUnitCount(cMyID, cUnitTypeypSacredField, cUnitStateAlive) < 1) &&
		 (kbGetAge() == cAge1) &&
		 (kbResourceGet(cResourceFood) < 925))
	{
		return;
	}

	// Check number of captured herdables, add sacred cows as necessary to bring total number to 10
	numHerdables = kbUnitCount(cMyID, cUnitTypeHerdable, cUnitStateAlive) - kbUnitCount(cMyID, cUnitTypeypSacredCow, cUnitStateAlive);
	if (numHerdables < 0)
		numHerdables = 0;
	numCows = 10 - numHerdables;
	if (numCows > 0)
	{
		// Create/update maintain plan
		if (cowPlan < 0)
		{
			cowPlan = createSimpleMaintainPlan(cUnitTypeypSacredCow, numCows, true, kbBaseGetMainID(cMyID), 1);
		}
		else
		{
			aiPlanSetVariableInt(cowPlan, cTrainPlanNumberToMaintain, 0, numCows);
		}
	}

	if (numHerdables > 0)
	{
		int upgradePlanID = -1;

		// Get XP upgrade
		if (kbTechGetStatus(cTechypLivestockHoliness) == cTechStatusObtainable)
		{
			if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechypLivestockHoliness) >= 0)
				return;
			createSimpleResearchPlan(cTechypLivestockHoliness, getUnit(cUnitTypeypSacredField), cMilitaryEscrowID, 50);
			return;
		}
	}
}

//==============================================================================
// Livestock Market Functions
//==============================================================================
rule maintainLivestockAfricans
inactive
minInterval 45
{
	static int cattleTypeID = -1;
	if (cattleTypeID < 0)
	{
		if (cMyCiv == cCivDEEthiopians)
			cattleTypeID = cUnitTypedeZebuCattle;
		else if (cMyCiv == cCivDEHausa)
			cattleTypeID = cUnitTypedeSangaCattle;
	}
	static int uniqueCattleMaintainPlan = -1;
	// If we start this rule in cAge3, then that is 5 * 2 = 10, 15 for cAge4, 20 for cAge5
	// (which is the build limit).
	int numberUniqueCattleToMaintain = 5 * kbGetAge();
	if (uniqueCattleMaintainPlan < 0)
	{
		uniqueCattleMaintainPlan = createSimpleMaintainPlan(cattleTypeID,
			numberUniqueCattleToMaintain, true, kbBaseGetMainID(cMyID), 1);
	}
	else
	{
		aiPlanSetVariableInt(uniqueCattleMaintainPlan, cTrainPlanNumberToMaintain,
			0, numberUniqueCattleToMaintain);
	}

	if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeLivestockMarket) < 0)
	{
		int numHerdables = kbUnitCount(cMyID, cUnitTypeHerdable, cUnitStateAlive);
		int herdableCapacity = 10 * kbUnitCount(cMyID, cUnitTypedeLivestockMarket, cUnitStateABQ);
		if (numHerdables > herdableCapacity)
			createBuildPlan(cUnitTypedeLivestockMarket, 1, 50, gHomeBase + gDirection_DOWN * 20.0);
	}
}

int getBestResourceRateLivestockMarket(void)
{
	int retVal = -1;
	if (aiLivestockGetExchangeRate(cResourceGold) > aiLivestockGetExchangeRate(cResourceWood))
		retVal = cResourceGold;
	else
		retVal = cResourceWood;
	return(retVal);
}

rule livestockMarketSellMonitor
inactive
minInterval 30
{
	if (kbUnitCount(cMyID, cUnitTypedeLivestockMarket, cUnitStateAlive) == 0)
		return;

	static int herdableQuery = -1;
	static bool sellEarlyForWood = true;
	static bool wait = true;
	static int count = 0;

	if (herdableQuery < 0)
	{
		xsSetRuleMinIntervalSelf(3); // Will be updated once we sell for starting wood.
		herdableQuery = kbUnitQueryCreate("Herdable Query for Market Selling");
		kbUnitQuerySetPlayerID(herdableQuery, cMyID);
		kbUnitQuerySetUnitType(herdableQuery, cUnitTypeHerdable);
		kbUnitQuerySetState(herdableQuery, cUnitStateAlive);
		sellEarlyForWood = true;
	}

	kbUnitQueryResetResults(herdableQuery);
	int herdableCount = kbUnitQueryExecute(herdableQuery);
	if (herdableCount <= 0)
		return;

	int herdableID = -1;
	int bestHerdableID = -1;
	float amount = 0.0;
	float bestAmount = 0.0;
	int sellingResource = getBestResourceRateLivestockMarket();
	if (sellEarlyForWood == true)
		sellingResource = cResourceWood;
	float maxRate = aiLivestockGetMaximumRate();

	if (sellEarlyForWood == false)
	{
		// If we have cattle sitting at max capacity, sell if rate >= 50%.
		for (i = 0; < herdableCount)
		{
			if (aiLivestockGetExchangeRate(sellingResource) < maxRate * 0.5)
				break;
			herdableID = kbUnitQueryGetResult(herdableQuery, i);
			amount = kbUnitGetResourceAmount(herdableID, cResourceFood);
			if (amount >= kbUnitGetCarryCapacity(herdableID, cResourceFood))
			{
				aiLivestockSell(sellingResource, herdableID);
				// Update because the rates changed.
				sellingResource = getBestResourceRateLivestockMarket();
			}
		}

		if (aiLivestockGetExchangeRate(sellingResource) < maxRate)
			return;
	}

	for (i = 0; < herdableCount)
	{
		herdableID = kbUnitQueryGetResult(herdableQuery, i);
		amount = kbUnitGetResourceAmount(herdableID, cResourceFood);
		if (bestAmount < amount)
		{
			bestHerdableID = herdableID;
			bestAmount = amount;
		}
	}

	// If we are here we have reached maximum exchange rate,
	// so sell a herdable if one is at least 80% fattened.
	if (sellEarlyForWood == false)
	{
		if (bestAmount < 0.8 * kbUnitGetCarryCapacity(bestHerdableID, cResourceFood))
			return;
	}
	else
	{
		if ((aiLivestockGetExchangeRate(cResourceWood) * bestAmount) <
			kbUnitCostPerResource(gHouseUnit, cResourceWood))
		{
			return;
		}
	}

	aiLivestockSell(sellingResource, bestHerdableID);

	if (sellEarlyForWood == true)
	{
		xsSetRuleMinIntervalSelf(30);
		// Ensure we can get a house up ASAP.
		sellEarlyForWood = false;
		int planID = createBuildPlan(gHouseUnit, 1, 99, gHomeBase);
		aiPlanSetDesiredResourcePriority(planID, 99);
		arrayPushInt(gHouseBuildPlans, planID);
		xsEnableRule("houseMonitor");
	}
}
