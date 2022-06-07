//==============================================================================
/* aiBuildings.xs

	This file is intended for any base building logic, including choosing
	appropriate builders(wagons) for construction.

*/
//==============================================================================

//==============================================================================
// buildingPlacementFailedHandler
//
// Called when a build plan cannot fails to find a location to build.
//==============================================================================
void buildingPlacementFailedHandler(int baseID = -1, int puid = -1)
{
	if (puid == gDockUnit)
		return;
	if (puid == cUnitTypedeTorp && cMyCiv == cCivDESwedish)
	{
		int last = xsArrayGetSize(gTorpPositionsToAvoid);
		xsArrayResizeVector(gTorpPositionsToAvoid, last + 1);
		xsArraySetVector(gTorpPositionsToAvoid, last - 1, gTorpPosition);
		return;
	}

	if (puid == cUnitTypedeField)
	{
		int numberFullGranaries = xsArrayGetSize(gFullGranaries);
		for (i = 0; < numberFullGranaries)
		{
			int granaryID = xsArrayGetInt(gFullGranaries, i);
			if (granaryID == gFieldGranaryID)
				break;
			if (granaryID >= 0 && kbUnitGetPlayerID(granaryID) == cMyID)
				continue;
			xsArraySetInt(gFullGranaries, i, gFieldGranaryID);
			break;
		}
	}

	if (baseID < 0)
	{
		// assuming main base
		baseID = kbBaseGetMainID(cMyID);
	}
	
	static int basesToAvoid = -1;
	static int lastExpansionTime = 0;
	bool expand = true;
	
	if (basesToAvoid < 0)
		basesToAvoid = xsArrayCreateInt(5, -1, "Bases to avoid expanding");
		
	for (i = 0; < 5)
	{
		if (xsArrayGetInt(basesToAvoid, i) == baseID)
		{
			expand = false;
			break;
		}
	}
	
	float newDistance = 0.0;
	if (expand == true)
	{
		vector baseLocation = kbBaseGetLocation(cMyID, baseID);
		int baseAreaGroup = kbAreaGroupGetIDByPosition(baseLocation);
		int numberAreas = kbAreaGetNumber();
		newDistance = kbBaseGetDistance(cMyID, baseID) + 10.0;
		// make sure new areas we cover are in the same area group
		for (i = 0; < numberAreas)
		{
			vector location = kbAreaGetCenter(i);
			if (getDistance(location, baseLocation) > newDistance)
				continue;
			if (kbAreaGroupGetIDByPosition(location) == baseAreaGroup)
				continue;
			for (j = 0; < 5)
			{
				if (xsArrayGetInt(basesToAvoid, j) == -1)
				{
					xsArraySetInt(basesToAvoid, baseID);
					break;
				}
			}
			expand = false;
			break;
		}
	}
	
	if (expand == false)
	{
		/*if (xsIsRuleEnabled("findNewBase") == false)
		{
			xsEnableRule("findNewBase");
			debugBuildings("Started searching for a new base location because of not enough build space.");
		}
		int mainBaseID = kbBaseGetMainID(cMyID);
		if (baseID == mainBaseID && kbBaseGetSettlement(cMyID, baseID) == true)
		{
			// find a new base to set as main
			int numberBases = kbBaseGetNumber(cMyID);
			for (i = 0; < numberBases)
			{
				 int newBaseID = kbBaseGetIDByIndex(cMyID, i);
				 if (newBaseID == mainBaseID)
					 continue;
				 if (kbBaseGetSettlement(cMyID, newBaseID) == false)
					 continue;
				 kbBaseSetMain(cMyID, newBaseID, true);
				 kbBaseSetMain(cMyID, mainBaseID, false);
				 debugBuildings("Setting base "+newBaseID+" to main.");
				 break;
			}
		}*/
		return;
	}
	
	if ((xsGetTime() - lastExpansionTime) > 60000)
	{
		debugBuildings("Expanding base "+baseID+" to "+newDistance);
		kbBaseSetPositionAndDistance(cMyID, baseID, baseLocation, newDistance);
		lastExpansionTime = xsGetTime();
	}
}

//==============================================================================
// houseMonitor
//==============================================================================
rule houseMonitor
inactive
minInterval 5
{
	int numHouses = kbUnitCount(cMyID, gHouseUnit, cUnitStateAlive);
	int buildLimit = kbGetBuildLimit(cMyID, gHouseUnit);
	int planID = -1;
	int popRoom = kbGetPopCap() - kbGetPop();

	if (numHouses >= buildLimit)
	{
		xsSetRuleMinIntervalSelf(20);
		return;
	}
	xsSetRuleMinIntervalSelf(5);

	arrayRemoveDonePlans(gHouseBuildPlans);
	if (popRoom < (2 + 11 * kbGetAge()) && arrayGetSize(gHouseBuildPlans) < 1)
	{
		if (cMyCiv == cCivDESwedish) // Just want to update gTorpBuildPlanPosition.
			shouldBuildTorp(gHomeBase, 50.0 + kbGetAge() * 5.0);
		else if (cMyCiv == cCivJapanese) // Just want to update gShrineBuildPlanPosition.
			shouldBuildShrine(gHomeBase, 50.0 + kbGetAge() * 5.0);
		planID = createBuildPlan(gHouseUnit, 1, 95, gHomeBase);
		arrayPushInt(gHouseBuildPlans, planID);
		aiPlanSetDesiredResourcePriority(planID, 65);
	}

	if (gLowDifficulty == false && arrayGetSize(gHouseBuildPlans) < 3 && getAgingUpAge() >= cAge2)
	{
		if (cMyCiv == cCivBritish || cMyCiv == cCivDEInca)
		{
			planID = createBuildPlan(gHouseUnit, 1, 75, gHomeBase);
			arrayPushInt(gHouseBuildPlans, planID);
			aiPlanSetDesiredResourcePriority(planID, 50);
		}
		else if (cMyCiv == cCivDESwedish)
		{
			if (shouldBuildTorp(gHomeBase, 50.0 + kbGetAge() * 5.0))
			{
				planID = createBuildPlan(gHouseUnit, 1, 75, gHomeBase);
				arrayPushInt(gHouseBuildPlans, planID);
				aiPlanSetDesiredResourcePriority(planID, 50);
			}
		}
		else if (cMyCiv == cCivJapanese)
		{
			if (shouldBuildShrine(gHomeBase, 50.0 + kbGetAge() * 5.0))
			{
				planID = createBuildPlan(gHouseUnit, 1, 75, gHomeBase);
				arrayPushInt(gHouseBuildPlans, planID);
				aiPlanSetDesiredResourcePriority(planID, 50);
			}
		}
	}
}

//==============================================================================
// buildPlanAddPositionInfluence
//==============================================================================
void buildPlanAddPositionInfluence(int planID = -1, vector position = cInvalidVector, float influenceDistance = 60.0,
	float influenceValue = 100.0, int influenceFalloffType = cBPIFalloffLinear, bool init = false)
{
	int variableValueIndex = 0;
	// The init bool need only be used as true when it is the first time we are adding
	// a position influence to a plan (likely just created). This makes sure that we
	// initialize the 0th indexed (which would be the first one) variable before we
	// start adding others.
	if (init == false)
	{	// All these Variable Values should have the same number, so we
		// only need to check one of them. However, we will have to update
		// each variable manually.
		int numVariableValues = aiPlanGetNumberVariableValues(planID, cBuildPlanInfluencePosition);
		// May look confusing here, but we are adding a variable value, so if
		// we have 10 variable values, they will be stored as 0...9 like an array.
		// Since we haven't updated numVariableValues yet, its value already aligns
		// with the array index of the variable we want to add.
		variableValueIndex = numVariableValues;
		numVariableValues++;
		// The last boolean parameter, when set to true, would clear all our previous
		// variable data, which we don't want to do.
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluencePosition, numVariableValues, false);
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluencePositionDistance, numVariableValues, false);
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluencePositionValue, numVariableValues, false);
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluencePositionFalloff, numVariableValues, false);
	}
	// Now comes the time to add the new influences which we passed through.
	aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, variableValueIndex, position);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, variableValueIndex, influenceDistance);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, variableValueIndex, influenceValue);
	aiPlanSetVariableInt(planID, cBuildPlanInfluencePositionFalloff, variableValueIndex, influenceFalloffType);
}

//==============================================================================
// buildPlanAddUnitInfluence
//==============================================================================
void buildPlanAddUnitInfluence(int planID = -1, int unitTypeID = -1, float influenceDistance = 60.0,
	float influenceValue = 100.0, int influenceFalloffType = cBPIFalloffLinear, bool init = false)
{	// Same logic as the previous function, so I removed the explanations here to
	// avoid redundancy.
	int variableValueIndex = 0;
	if (init == false)
	{
		int numVariableValues = aiPlanGetNumberVariableValues(planID, cBuildPlanInfluenceUnitTypeID);
		variableValueIndex = numVariableValues;
		numVariableValues++;
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluenceUnitTypeID, numVariableValues, false);
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluenceUnitDistance, numVariableValues, false);
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluenceUnitValue, numVariableValues, false);
		aiPlanSetNumberVariableValues(planID, cBuildPlanInfluenceUnitFalloff, numVariableValues, false);
	}
	aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, variableValueIndex, unitTypeID);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, variableValueIndex, influenceDistance);
	aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, variableValueIndex, influenceValue);
	aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitFalloff, variableValueIndex, influenceFalloffType);
}

//==============================================================================
// selectBuildPlanPosition
//==============================================================================
void selectBuildPlanPosition(int planID = -1, int puid = -1, vector position = cInvalidVector)
{
	static float edgeOfMapDistance = -1;
	vector tempVector = cInvalidVector;
	if (edgeOfMapDistance < 0)
	{
		if (kbGetMapXSize() != kbGetMapZSize())
			edgeOfMapDistance = getMax(kbGetMapXSize(), kbGetMapZSize());
		else
			edgeOfMapDistance = kbGetMapXSize();
	}
	// Position.
	switch (puid)
	{
		case cUnitTypeOutpost:
		case cUnitTypeBlockhouse:
		case cUnitTypedeCathedral: // Repairs Buildings.
		case cUnitTypedeBasilica: // Boosts Building Work Rate.
		case cUnitTypedeCommandery: // Boosts Villager Work Rate, Acts as Tower.
		case cUnitTypeWarHut:
		case cUnitTypeTeepee:
		case cUnitTypeNoblesHut:
		case cUnitTypedeKallanka:
		case cUnitTypedeIncaStronghold:
		case cUnitTypeypCastle:
		case cUnitTypedeTower:
		case cUnitTypedePalace:
		{
			setTowerPosition(planID, puid);
			break;
		}
		case cUnitTypeFortFrontier:
		case cUnitTypedeMalteseGun:
		{
			if (position == gHomeBase)
				tempVector = position + gDirection_UP * 20.0;
			else
				tempVector = position;
			aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, tempVector);
			aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 60.0);
			buildPlanAddPositionInfluence(planID, tempVector, 60.0, 100.0, cBPIFalloffLinear, true);
			break;
		}
		case cUnitTypeFactory:
		{
			aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, gHomeBase + gDirection_DOWN * 30.0);
			aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 60.0);

			aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, gHomeBase + gDirection_DOWN * 30.0);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 60.0);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 200.0);
			aiPlanSetVariableInt(planID, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);
		}
		case cUnitTypeypShrineJapanese:
		{
			selectShrineBuildPlanPosition(planID);
			break;
		}
		case cUnitTypeypWJToshoguShrine2:
		case cUnitTypeypWJToshoguShrine3:
		case cUnitTypeypWJToshoguShrine4:
		case cUnitTypeypWJToshoguShrine5:
		{	// Just want to update gShrineBuildPlanPosition.
			shouldBuildShrine(gHomeBase, 45.0);
			selectShrineBuildPlanPosition(planID);
			break;
		}
		case cUnitTypedeTorp:
		case cUnitTypedeTorpGeneric:
		{
			selectTorpBuildPlanPosition(planID);
			break;
		}
		// Needs to be after Shrine and Torp so we don't take precedence for those civs.
		case gHouseUnit:
		{
			aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, position);
			aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 50.0);
			aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, position);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 50.0);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 100.0);
			aiPlanSetVariableInt(planID, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);

			aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 30.0);
			aiPlanSetVariableInt(planID, cBuildPlanInfluenceBuilderPositionFalloff, 0, cBPIFalloffLinear);
			break;
		}
		case gDockUnit:
		{
			aiPlanSetVariableVector(planID, cBuildPlanDockPlacementPoint, 0,
				kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))); // One point at main base
			aiPlanSetVariableVector(planID, cBuildPlanDockPlacementPoint, 1, gNavyVec); // One point at water flag
			break;
		}
		case cUnitTypedeMountainMonastery:
		{
			selectMountainMonasteryBuildPlanPosition(planID);
			break;
		}
		case cUnitTypedeUniversity:
		{
			selectUniversityBuildPlanPosition(planID, position);
			break;
		}
		case cUnitTypedeGranary:
		{
			selectGranaryBuildPlanPosition(planID);
			break;
		}
		case gFarmUnit:
		case gPlantationUnit:
		{
			aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, position);
			aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 60.0);
			buildPlanAddPositionInfluence(planID, position, 60.0, 100.0, cBPIFalloffLinear, true);

			// Make ring around edge of map unsuitable to place fields.
			buildPlanAddPositionInfluence(planID, kbGetMapCenter(), edgeOfMapDistance, -1000.0, cBPIFalloffNone);
			buildPlanAddPositionInfluence(planID, kbGetMapCenter(), (edgeOfMapDistance - 10.0), 1000.0, cBPIFalloffNone);

			break;
		}
		case cUnitTypedeField:
		{
			aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 1.0);
			aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, position);
			aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 60.0);
			buildPlanAddPositionInfluence(planID, position, 60.0, 100.0, cBPIFalloffLinear, true);
			buildPlanAddUnitInfluence(planID, cUnitTypedeGranary, 15.0, 100.0, cBPIFalloffNone, true);

			// Make ring around edge of map unsuitable to place fields.
			buildPlanAddPositionInfluence(planID, kbGetMapCenter(), edgeOfMapDistance, -1000.0, cBPIFalloffNone);
			buildPlanAddPositionInfluence(planID, kbGetMapCenter(), (edgeOfMapDistance - 10.0), 1000.0, cBPIFalloffNone);

			break;
		}
		default:
		{
			aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, position);
			aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 60.0);	// Maybe 60.0 will allow wonder placement some more breathing room.
			aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, position);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 60.0);
			aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 200.0);
			aiPlanSetVariableInt(planID, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);

			if (puid == cUnitTypeBarracks || puid == cUnitTypeStable || puid == cUnitTypeArtilleryDepot ||
				puid == cUnitTypedeLombard || puid == cUnitTypedeHospital || puid == cUnitTypedeCommandery ||
				puid == cUnitTypeCorral || puid == cUnitTypeypWarAcademy || puid == cUnitTypeypBarracksJapanese ||
				puid == cUnitTypeypStableJapanese || puid == cUnitTypeYPBarracksIndian || puid == cUnitTypeypCaravanserai ||
				puid == cUnitTypedeWarCamp)
			{	// 13 meter inhibition around military buildings of the same type, taking into account obstruction radii and then extra space.
				// Buffer space works for other buildings, just not buildings of the same kind.
				buildPlanAddUnitInfluence(planID, puid, 13.0, -300.0, cBPIFalloffNone, true);
			}

			break;
		}
	}
}

//==============================================================================
// selectTowerBuildPlanPosition
//==============================================================================
void selectTowerBuildPlanPosition(int buildPlan = -1)
{
	int attempt = 0;
	int numAttempts = 3 * kbGetBuildLimit(cMyID, gTowerUnit) / 2;
	vector testVec = cInvalidVector;
	static vector baseVec = cInvalidVector;
	static vector startingVec = cInvalidVector;
	int numTestVecs = 5 * kbGetBuildLimit(cMyID, gTowerUnit) / 4;
	float towerAngle = (2.0 * PI) / numTestVecs;
	float spacingDistance = 24 * sin((PI - towerAngle) / 2.0) / sin(towerAngle); // Mid- and corner-spots on a square with 'radius' spacingDistance, i.e. each side is 2 * spacingDistance.
	float exclusionRadius = spacingDistance / 2.0;

	static int towerSearch = -1;
	bool success = false;
	
	if ( (startingVec == cInvalidVector) || (baseVec != kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) ) // Base changed
	{
		baseVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)); // Start with base location
		startingVec = baseVec; 
		startingVec = xsVectorSetX(startingVec, xsVectorGetX(startingVec) + spacingDistance);
		startingVec = rotateByReferencePoint(baseVec, startingVec - baseVec, aiRandInt(360) / (180.0 / PI));
	}
	
	for (attempt = 0; < numAttempts)
	{
		testVec = rotateByReferencePoint(baseVec, startingVec - baseVec, towerAngle*aiRandInt(numTestVecs));
		debugBuildings("Testing tower location "+testVec);
		if (towerSearch < 0)
		{  // init
			towerSearch = kbUnitQueryCreate("Tower placement search");
			kbUnitQuerySetPlayerRelation(towerSearch, cPlayerRelationAny);
			kbUnitQuerySetUnitType(towerSearch, gTowerUnit);
			kbUnitQuerySetState(towerSearch, cUnitStateABQ);
		}
		kbUnitQuerySetPosition(towerSearch, testVec);
		kbUnitQuerySetMaximumDistance(towerSearch, exclusionRadius);
		kbUnitQueryResetResults(towerSearch);
		if (kbUnitQueryExecute(towerSearch) < 1)
		{  // Site is clear, use it
			if (kbAreaGroupGetIDByPosition(testVec) == kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))))
			{  // Make sure it's in the same areagroup.
				success = true;
				break;
			}
		}
	}

	// We have found a location (success == true) or we need to just do a brute force placement around the TC.
	if (success == false)
		testVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
		
		
	// Instead of base ID or areas, use a center position and falloff.
	aiPlanSetVariableVector(buildPlan, cBuildPlanCenterPosition, 0, testVec);
	if (success == true)
		aiPlanSetVariableFloat(buildPlan, cBuildPlanCenterPositionDistance, 0, exclusionRadius);
	else
		aiPlanSetVariableFloat(buildPlan, cBuildPlanCenterPositionDistance, 0, 50.0);

	// Add position influence for nearby towers
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluenceUnitTypeID, 0, gTowerUnit);   // Russian's won't notice ally towers and vice versa...oh well.
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluenceUnitDistance, 0, spacingDistance);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluenceUnitValue, 0, -20.0);        // -20 points per tower
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);  // Linear slope falloff

	// Weight it to stay very close to center point.
	aiPlanSetVariableVector(buildPlan, cBuildPlanInfluencePosition, 0, testVec);    // Position influence for landing position
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluencePositionDistance, 0, exclusionRadius);     // 100m range.
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluencePositionValue, 0, 10.0);        // 10 points for center
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);  // Linear slope falloff

	debugBuildings("Building plan (" + buildPlan + ") for tower at location " + testVec);    
}

void setTowerPosition(int buildPlan = -1, int buildingType = -1)
{
	int attempt = 0;
	int numAttempts = 3 * kbGetBuildLimit(cMyID, buildingType) / 2;
	vector testVec = cInvalidVector;
	static vector baseVec = cInvalidVector;
	static vector startingVec = cInvalidVector;
	int numTestVecs = 5 * kbGetBuildLimit(cMyID, buildingType) / 4;
	float towerAngle = (2.0 * PI) / numTestVecs;
	float spacingDistance = 25.0 + 7.0 * kbGetAge();
	float exclusionRadius = 25.0;

	static int towerSearch = -1;
	bool success = false;
	
	if ( (startingVec == cInvalidVector) || (baseVec != gHomeBase) )// Base changed
	{
		baseVec = gHomeBase; // Start with base location
		startingVec = baseVec; 
		startingVec = xsVectorSetX(startingVec, xsVectorGetX(startingVec) + spacingDistance);
		startingVec = rotateByReferencePoint(baseVec, startingVec - baseVec, aiRandInt(360) / (180.0 / PI));
	}
	
	for (attempt = 0; < numAttempts)
	{
		testVec = rotateByReferencePoint(baseVec, startingVec - baseVec, towerAngle * aiRandInt(numTestVecs));
		debugBuildings("Testing tower location "+testVec);
		if (towerSearch < 0)
		{	// init
			towerSearch = kbUnitQueryCreate("Tower placement search");
			kbUnitQuerySetPlayerRelation(towerSearch, cPlayerRelationAny);
			kbUnitQuerySetUnitType(towerSearch, buildingType);
			kbUnitQuerySetState(towerSearch, cUnitStateABQ);
		}
		kbUnitQuerySetPosition(towerSearch, testVec);
		kbUnitQuerySetMaximumDistance(towerSearch, exclusionRadius);
		kbUnitQueryResetResults(towerSearch);
		if (kbUnitQueryExecute(towerSearch) < 1)
		{	// Site is clear, use it
			if (kbAreaGroupGetIDByPosition(testVec) == kbAreaGroupGetIDByPosition(gHomeBase))
			{	// Make sure it's in the same areagroup.
				success = true;
				break;
			}
		}
	}

	// We have found a location (success == true) or we need to just do a brute force placement around the TC.
	if (success == false)
		testVec = gHomeBase;
		
		
	// Instead of base ID or areas, use a center position and falloff.
	aiPlanSetVariableVector(buildPlan, cBuildPlanCenterPosition, 0, testVec);
	if (success == true)
		aiPlanSetVariableFloat(buildPlan, cBuildPlanCenterPositionDistance, 0, exclusionRadius);
	else
		aiPlanSetVariableFloat(buildPlan, cBuildPlanCenterPositionDistance, 0, 50.0);

	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluenceUnitTypeID, 2, true);
	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluenceUnitDistance, 2, true);
	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluenceUnitValue, 2, true);
	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluenceUnitFalloff, 2, true);
	// Add negative position influence for nearby buildings of the same type.
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluenceUnitTypeID, 0, buildingType);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluenceUnitDistance, 0, exclusionRadius);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluenceUnitValue, 0, -30.0);
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear);
	// Add positive position influence for mines, to defend our settlers.
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluenceUnitTypeID, 1, cUnitTypeMine);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluenceUnitDistance, 1, 10.0);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluenceUnitValue, 1, 10.0);
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluenceUnitFalloff, 1, cBPIFalloffNone);

	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluencePosition, 2, true);
	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluencePositionDistance, 2, true);
	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluencePositionValue, 2, true);
	aiPlanSetNumberVariableValues(buildPlan, cBuildPlanInfluencePositionFalloff, 2, true);
	// Weight it to stay very close to center point.
	aiPlanSetVariableVector(buildPlan, cBuildPlanInfluencePosition, 0, testVec);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluencePositionDistance, 0, exclusionRadius);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluencePositionValue, 0, 20.0);
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);
	// Closer to the front of our base.
	aiPlanSetVariableVector(buildPlan, cBuildPlanInfluencePosition, 1, gHomeBase + gDirection_UP * 20.0);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluencePositionDistance, 1, 50.0);
	aiPlanSetVariableFloat(buildPlan, cBuildPlanInfluencePositionValue, 1, 20.0);
	aiPlanSetVariableInt(buildPlan, cBuildPlanInfluencePositionFalloff, 1, cBPIFalloffLinear);

	debugBuildings("Building plan (" + buildPlan + ") for tower at location " + testVec);
}

int getFutureHouseCountByLocation(vector location = cInvalidVector, float radius = 20.0)
{
	int retVal = 0;
	int planID = -1;
	vector position = cInvalidVector;
	for (i = 0; < arrayGetSize(gHouseBuildPlans))
	{
		planID = arrayGetInt(gHouseBuildPlans, i);
		position = aiPlanGetVariableVector(planID, cBuildPlanCenterPosition, 0);
		if (position == cInvalidVector)
			continue;
		// Planning to build a house in this area.
		if (getDistance(location, position) < radius)
			retVal++;
	}

	return(retVal);
}

//==============================================================================
// Shrine Functions
//==============================================================================
bool shouldBuildShrine(vector position = cInvalidVector, float radius = 80.0)
{
	int huntableQuery = createSimpleUnitQuery(cUnitTypeHuntable, 0, cUnitStateAlive, position, radius);
	kbUnitQuerySetAscendingSort(huntableQuery);
	int numResults = kbUnitQueryExecute(huntableQuery);
	int huntableID = -1;
	vector location = cInvalidVector;
	int huntableAreaGroup = -1;

	for (i = 0; < numResults)
	{
		huntableID = kbUnitQueryGetResult(huntableQuery, i);
		location = kbUnitGetPosition(huntableID);
		huntableAreaGroup = kbAreaGroupGetIDByPosition(location);

		if (huntableAreaGroup != kbAreaGroupGetIDByPosition(position))
			continue;
		if (resourceCloserToAlly(huntableID))
			continue;
		if (getUnitCountByLocation(cUnitTypeHuntable, 0, cUnitStateAlive, location, 20.0) >
			( 2 + 4 * (getUnitCountByLocation(cUnitTypeAbstractShrine, cPlayerRelationAny, cUnitStateAlive, location, 20.0) + getFutureHouseCountByLocation(location)) ) &&
			getUnitCountByLocation(cUnitTypedeGranary, cPlayerRelationAny, cUnitStateABQ, location, 30.0) < 1 &&
			(getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemy, cUnitStateAlive, location, 45.0) <= 2 ||
			getDistance(location, gHomeBase) < 45.0))
		{
			gShrineBuildPlanPosition = location;
			return(true);
		}
	}

	gShrineBuildPlanPosition = cInvalidVector;
	return(false);
}

void selectShrineBuildPlanPosition(int planID = -1)
{
	if (gShrineBuildPlanPosition != cInvalidVector)
	{
		aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, gShrineBuildPlanPosition);
		aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 30.0);
		// The first position influence variable for this plan, so the bool parameter needs to be true.
		buildPlanAddPositionInfluence(planID, gShrineBuildPlanPosition, 30.0, 50.0, cBPIFalloffLinear, true);
		// The first position unit variable for this plan, so the bool parameter needs to be true.
		buildPlanAddUnitInfluence(planID, cUnitTypeHuntable, 20.0, 5.0, cBPIFalloffLinear, true);
		buildPlanAddUnitInfluence(planID, cUnitTypeypShrineJapanese, 5.0, -300.0, cBPIFalloffNone);
		buildPlanAddUnitInfluence(planID, cUnitTypedeGranary, 20.0, -300.0, cBPIFalloffNone);
	}
	else
	{
		aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, gHomeBase);
		aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 80.0);
		// The first position influence variable for this plan, so the bool parameter needs to be true.
		buildPlanAddPositionInfluence(planID, gShrineBuildPlanPosition, 50.0, 50.0, cBPIFalloffLinear, true);
		// The first unit influence variable for this plan, so the bool parameter needs to be true.
		buildPlanAddUnitInfluence(planID, cUnitTypeypShrineJapanese, 5.0, -300.0, cBPIFalloffNone, true);
		aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cBuildPlanInfluenceBuilderPositionFalloff, 0, cBPIFalloffLinear);
	}
}


rule forwardShrineManager
inactive
minInterval 3
{
	static int monkQuery = -1;
	static int huntQuery = -1;
	static int shrineQuery = -1;
	static int tcQuery = -1;
	static int shrinePlanID = -1;
	int planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypShrineJapanese);
	
	if (gLandExplorePlan < 0 || kbCanAffordUnit(cUnitTypeypShrineJapanese, cEconomyEscrowID) == false || planID >= 0)
	{
		if (gExplorerControlPlan >= 0)
		{
			if (aiPlanGetState(shrinePlanID) >= 0)
				aiPlanDestroy(shrinePlanID);
			xsDisableSelf();
		}
		return;
	}
	
	if (monkQuery < 0)
	{
		monkQuery = kbUnitQueryCreate("Monk query for shrine placement");
		kbUnitQuerySetPlayerID(monkQuery, cMyID);
		kbUnitQuerySetUnitType(monkQuery, cUnitTypeAbstractJapaneseMonk);
		kbUnitQuerySetIgnoreKnockedOutUnits(monkQuery, true);
		
		huntQuery = kbUnitQueryCreate("Huntable query for shrine placement");
		kbUnitQuerySetPlayerID(huntQuery, 0);
		kbUnitQuerySetUnitType(huntQuery, cUnitTypeHuntable);
		kbUnitQuerySetMaximumDistance(huntQuery, 30.0);
		
		shrineQuery = kbUnitQueryCreate("Shrine query for shrine placement");
		kbUnitQuerySetPlayerID(shrineQuery, -1);
		kbUnitQuerySetPlayerRelation(shrineQuery, cPlayerRelationAny);
		kbUnitQuerySetUnitType(shrineQuery, cUnitTypeypShrineJapanese);
		kbUnitQuerySetMaximumDistance(shrineQuery, 30.0);
		
		tcQuery = kbUnitQueryCreate("TC query for shrine placement");
		kbUnitQuerySetPlayerID(tcQuery, -1);
		kbUnitQuerySetPlayerRelation(tcQuery, cPlayerRelationAny);
		kbUnitQuerySetUnitType(tcQuery, cUnitTypeAgeUpBuilding);
		kbUnitQuerySetMaximumDistance(tcQuery, 50.0);  
	}
	
	kbUnitQueryResetResults(monkQuery);
	int numberMonks = kbUnitQueryExecute(monkQuery);
	int numberHunts = 0;
	int numberShrines = 0;
	vector position = cInvalidVector;
	int builderID = -1;
	
	if (numberMonks == 0)
		return;
		
	// search for huntables nearby monks
	for (i = 0; < numberMonks)
	{
		builderID = kbUnitQueryGetResult(monkQuery, i);
		if (aiPlanGetType(kbUnitGetPlanID(builderID)) != cPlanExplore)
			continue;
		kbUnitQuerySetPosition(huntQuery, kbUnitGetPosition(builderID));
		kbUnitQueryResetResults(huntQuery);
		numberHunts = kbUnitQueryExecute(huntQuery);
		if (numberHunts < 3)
			continue;
		position = kbUnitGetPosition(kbUnitQueryGetResult(huntQuery, aiRandInt(numberHunts)));
		kbUnitQuerySetPosition(shrineQuery, position);
		kbUnitQueryResetResults(shrineQuery);
		numberShrines = kbUnitQueryExecute(shrineQuery);
		if (numberHunts < (4 * (numberShrines + 1) - 1))
			continue;
		kbUnitQuerySetPosition(tcQuery, position);
		kbUnitQueryResetResults(tcQuery);
		if (kbUnitQueryExecute(tcQuery) > 0)
			continue;
		planID = aiPlanCreate("Forward Shrine Build Plan", cPlanBuild);
		if (planID < 0)
			continue;
		// What to build
		aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeypShrineJapanese);

		aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, position);
		aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 30.0);

		// 3 meter separation
		aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 3.0);

		//Priority.
		aiPlanSetDesiredPriority(planID, 90);
		aiPlanSetDesiredResourcePriority(planID, 90);
		
		//Mil vs. Econ.
		aiPlanSetMilitary(planID, false);
		aiPlanSetEconomy(planID, true);
		//Escrow.
		aiPlanSetEscrowID(planID, cEconomyEscrowID);
		//Builders.
		aiPlanAddUnitType(planID, cUnitTypeAbstractJapaneseMonk, numberMonks, numberMonks, numberMonks);
		for (j = 0; < numberMonks)
			aiPlanAddUnit(planID, kbUnitQueryGetResult(monkQuery, j));
			
		aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, position);    // Influence toward position
		aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 50.0);     // 50m range.
		aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 200.0);        // 200 points max
		aiPlanSetVariableInt(planID, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);  // Linear slope falloff
		
		aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeypShrineJapanese);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, 0, 10.0);
		aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, 0, -20.0);
		aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitFalloff, 0, cBPIFalloffLinear); 
		
		//Go.
		aiPlanSetActive(planID);         
		debugBuildings("    Building a forward shrine at "+position);
		shrinePlanID = planID;
		break;
	}
}

//==============================================================================
// Torp Functions
//==============================================================================
bool shouldBuildTorp(vector position = cInvalidVector, float radius = 80.0)
{
	int mineQuery = createSimpleUnitQuery(cUnitTypeAbstractMine, 0, cUnitStateAlive, position, radius);
	kbUnitQuerySetAscendingSort(mineQuery);
	int numResults = kbUnitQueryExecute(mineQuery);
	int mineID = -1;
	vector location = cInvalidVector;
	int mineAreaGroup = -1;
	int amount = -1;
	int numTorps = -1;

	for (i = 0; < numResults)
	{
		mineID = kbUnitQueryGetResult(mineQuery, i);
		location = kbUnitGetPosition(mineID);
		mineAreaGroup = kbAreaGroupGetIDByPosition(location);
		amount = kbUnitGetResourceAmount(mineID, cResourceGold);

		if (mineAreaGroup != kbAreaGroupGetIDByPosition(position))
			continue;
		if (resourceCloserToAlly(mineID))
			continue;
		if (amount < 500.0)
			continue;

		numTorps = getUnitCountByLocation(cUnitTypedeTorp, cPlayerRelationAny, cUnitStateABQ, location, 10.0);

		if (numTorps >= 4)
			continue;

		if (getFutureHouseCountByLocation(location, 4.0) == 0 &&
			(getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemy, cUnitStateAlive, location, 45.0) <= 2 ||
			getDistance(location, gHomeBase) < 45.0))
		{
			gTorpBuildPlanPosition = location;
			return(true);
		}
	}

	gTorpBuildPlanPosition = cInvalidVector;
	return(false);
}

void selectTorpBuildPlanPosition(int planID = -1)
{
	if (gTorpBuildPlanPosition != cInvalidVector)
	{
		aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, gTorpBuildPlanPosition);
		aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 7.99);
		aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionStep, 0, 0.25);
		// The first position influence variable for this plan, so the bool parameter needs to be true.
		buildPlanAddPositionInfluence(planID, gTorpBuildPlanPosition, 100.0, 200.0, cBPIFalloffLinear, true);
	}
	else
	{
		aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, gHomeBase);
		aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 80.0);
		// The first position influence variable for this plan, so the bool parameter needs to be true.
		buildPlanAddPositionInfluence(planID, gShrineBuildPlanPosition, 80.0, 50.0, cBPIFalloffLinear, true);
		// The first unit influence variable for this plan, so the bool parameter needs to be true.
		buildPlanAddUnitInfluence(planID, cUnitTypeHuntable, 10.0, 5.0, cBPIFalloffNone, true);
		buildPlanAddUnitInfluence(planID, cUnitTypeTree, 10.0, 5.0, cBPIFalloffNone);
	}
}


//==============================================================================
// selectMountainMonasteryBuildPlanPosition
//==============================================================================
void selectMountainMonasteryBuildPlanPosition(int planID = -1)
{
	static int mineQuery = -1;
	int baseID = kbBaseGetMainID(cMyID);

	if (mineQuery < 0)
	{
		mineQuery = kbUnitQueryCreate("Mountain Monastery Mine Query");
		kbUnitQuerySetPlayerID(mineQuery, 0);
		kbUnitQuerySetUnitType(mineQuery, cUnitTypeAbstractMine);
		kbUnitQuerySetMaximumDistance(mineQuery, 100.0);
		kbUnitQuerySetAscendingSort(mineQuery, true);
	}
	kbUnitQuerySetPosition(mineQuery, gHomeBase);
	kbUnitQueryResetResults(mineQuery);
	int mineCount = kbUnitQueryExecute(mineQuery);
	int mineID = -1;
	vector location = cInvalidVector;
	bool goodPlaceFound = false;

	for (i = 0; < mineCount)
	{
		mineID = kbUnitQueryGetResult(mineQuery, i);
		location = kbUnitGetPosition(mineID);
		// Where should I build?
		if (getUnitCountByLocation(cUnitTypedeMountainMonastery, cPlayerRelationAny, cUnitStateABQ, location, 5.0) > 0)
			continue;
		goodPlaceFound = true;
		break;
	}

	if (goodPlaceFound == true)
	{
		aiPlanSetVariableInt(planID, cBuildPlanSocketID, 0, mineID);
	}
	else
	{	// Place them like towers since they can heal units.
		setTowerPosition(planID, cUnitTypedeMountainMonastery);
	}
}

//==============================================================================
// Granary Functions
//==============================================================================
bool shouldBuildGranaryHuntables(vector position = cInvalidVector, float radius = 100.0)
{
	int huntableQuery = createSimpleUnitQuery(cUnitTypeHuntable, 0, cUnitStateAlive, position, radius);
	kbUnitQuerySetAscendingSort(huntableQuery);
	int numResults = kbUnitQueryExecute(huntableQuery);
	int huntableID = -1;
	int nearbyHuntRequirement = kbGetAge() == cAge1 ? 0 : 4;
	vector location = cInvalidVector;
	int huntableAreaGroup = -1;

	for (i = 0; < numResults)
	{
		huntableID = kbUnitQueryGetResult(huntableQuery, i);
		location = kbUnitGetPosition(huntableID);
		huntableAreaGroup = kbAreaGroupGetIDByPosition(location);

		if (huntableAreaGroup != kbAreaGroupGetIDByPosition(position))
			continue;
		if (resourceCloserToAlly(huntableID))
			continue;
		if (getUnitCountByLocation(cUnitTypeHuntable, 0, cUnitStateAlive, location, 20.0) > nearbyHuntRequirement &&
			getUnitCountByLocation(cUnitTypeAbstractShrine, cPlayerRelationAny, cUnitStateABQ, location, 25.0) < 1 &&
			getUnitCountByLocation(cUnitTypedeGranary, cPlayerRelationAny, cUnitStateABQ, location, 25.0) < 1 &&
			(getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemy, cUnitStateAlive, location, 45.0) <= 2 ||
			getDistance(location, gHomeBase) < 45.0))
		{
			gGranaryBuildPlanPosition = location;
			return(true);
		}
	}

	gGranaryBuildPlanPosition = cInvalidVector;
	return(false);
}

bool shouldBuildGranaryFields(vector position = cInvalidVector, float radius = 100.0)
{
	int fieldQuery = createSimpleUnitQuery(cUnitTypedeField, cMyID, cUnitStateABQ, position, radius);
	kbUnitQuerySetAscendingSort(fieldQuery);
	int numResults = kbUnitQueryExecute(fieldQuery);
	int fieldID = -1;
	vector location = cInvalidVector;
	int fieldAreaGroup = -1;

	for (i = 0; < numResults)
	{
		fieldID = kbUnitQueryGetResult(fieldQuery, i);
		location = kbUnitGetPosition(fieldID);
		fieldAreaGroup = kbAreaGroupGetIDByPosition(location);

		if (fieldAreaGroup != kbAreaGroupGetIDByPosition(position))
			continue;
		if (getUnitCountByLocation(cUnitTypedeGranary, cMyID, cUnitStateABQ, location, 25.0) < 1 &&
			(getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemy, cUnitStateAlive, location, 45.0) <= 2 ||
			getDistance(location, gHomeBase) < 45.0))
		{
			gGranaryBuildPlanPosition = location;
			return(true);
		}
	}

	gGranaryBuildPlanPosition = cInvalidVector;
	return(false);
}

void selectGranaryBuildPlanPosition(int planID = -1)
{
	if (gGranaryBuildPlanPosition == cInvalidVector)
	{
		aiPlanDestroy(planID);
		return;
	}

	aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, gGranaryBuildPlanPosition);
	aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 30.0);
	// The first position influence variable for this plan, so the bool parameter needs to be true.
	buildPlanAddPositionInfluence(planID, gGranaryBuildPlanPosition, 30.0, 50.0, cBPIFalloffLinear, true);
	// The first unit influence variable for this plan, so the bool parameter needs to be true.
	buildPlanAddUnitInfluence(planID, cUnitTypeHuntable, 20.0, 5.0, cBPIFalloffLinear, true);
	buildPlanAddUnitInfluence(planID, cUnitTypedeField, 20.0, 10.0, cBPIFalloffLinear);
	buildPlanAddUnitInfluence(planID, cUnitTypedeGranary, 25.0, -300.0, cBPIFalloffNone);
}

rule granaryBuildPlanMonitor
inactive
minInterval 60
{
	int planID = -1;
	if (shouldBuildGranaryHuntables(gHomeBase, (60.0 + kbGetAge() * 5.0)))
	{
		planID = createBuildPlan(cUnitTypedeGranary, 1, 99, gHomeBase);
		aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 15.0);
	}
	else if (shouldBuildGranaryFields(gHomeBase, -1.0))
	{
		planID = createBuildPlan(cUnitTypedeGranary, 1, 99, gHomeBase);
		aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 1.0);
	}
}

//==============================================================================
// selectUniversityBuildPlanPosition
//==============================================================================
void selectUniversityBuildPlanPosition(int planID = -1, vector position = cInvalidVector)
{
	aiPlanSetVariableVector(planID, cBuildPlanCenterPosition, 0, position);
	aiPlanSetVariableFloat(planID, cBuildPlanCenterPositionDistance, 0, 60.0);
	// The first position influence variable for this plan, so the bool parameter needs to be true.
	buildPlanAddPositionInfluence(planID, position, 60.0, 50.0, cBPIFalloffLinear, true);
	// The first unit influence variable for this plan, so the bool parameter needs to be true.
	buildPlanAddUnitInfluence(planID, cUnitTypeTownCenter, 30.0, 100.0, cBPIFalloffNone, true);
	buildPlanAddUnitInfluence(planID, cUnitTypedePalace, 30.0, 100.0, cBPIFalloffNone);
	buildPlanAddUnitInfluence(planID, cUnitTypeTradingPost, 30.0, 100.0, cBPIFalloffNone);
}

// ================================================================================
//	findWagonToBuild
// ================================================================================
int findWagonToBuild(int puid = -1)
{
	debugBuildings("RUNNING findWagonToBuild");
	debugBuildings("Looking for a Wagon to build: " + kbGetProtoUnitName(puid));

	
	if (kbProtoUnitAvailable(puid) == false) // Safeguard against assigning Wagons to build plans for buildings in the next age because that will glitch out.
	{	
		debugBuildings(kbGetProtoUnitName(puid) + " isn't available in our age yet, don't assign a Wagon to it or it will bug out");
		return (-1);
	}

	static int wagonQueryID = -1;
	int numberFound = 0;

	// If we don't have the query yet, create one.
	if (wagonQueryID < 0)
		wagonQueryID = kbUnitQueryCreate("findWagonToBuild Unit Query");

	// Define a query to get all matching units.
	if (wagonQueryID != -1)
	{
		kbUnitQueryResetResults(wagonQueryID);
		kbUnitQuerySetPlayerID(wagonQueryID, cMyID);
		kbUnitQuerySetUnitType(wagonQueryID, cUnitTypeAbstractWagon);
		kbUnitQuerySetState(wagonQueryID, cUnitStateAlive);
	}
	else
		return (-1);

	numberFound = kbUnitQueryExecute(wagonQueryID);
	debugBuildings("We've found " + numberFound + " Wagons alive");
	
	for (i = 0; < numberFound)
	{
		int wagonID = kbUnitQueryGetResult(wagonQueryID, i);
		if (kbUnitGetPlanID(wagonID) >= 0)
		{
			continue; // Wagon already has a plan so don't mess with it.
		}
		int wagonUnitType = kbUnitGetProtoUnitID(wagonID);
		if ((wagonUnitType == cUnitTypedeHomesteadWagon) && (puid == gHouseUnit))
		{
			continue; // We don't want this wagon to be wasted on houses.
		}
		if (kbProtoUnitCanTrain(wagonUnitType, puid) == true)
		{
			debugBuildings("findWagonToBuild has found " + kbGetProtoUnitName(wagonUnitType) + " with ID: " + wagonID + " to build: " + kbGetProtoUnitName(puid));
			return(wagonUnitType);
		}
	}
	
	debugBuildings("We couldn't find a Wagon to build: " + kbGetProtoUnitName(puid));
	return (-1);
}

rule wagonMonitor
active
minInterval 20
{
	if (cvOkToBuild == false)
		return;
	
	int age = kbGetAge();
	int planID = -1;
	int numPlans = aiPlanGetActiveCount();
	int i = 0;
	int j = 0;
	int wagonType = -1;
	int wagonQueryID = createSimpleUnitQuery(cUnitTypeAbstractWagon, cMyID, cUnitStateAlive);
	int numberFound = kbUnitQueryExecute(wagonQueryID);
	int wagon = -1;
	int buildingType = -1;
	int buildLimit = -1;
	int buildingCount = -1;
	static int kingdomBuilderSpecialBuilding = -1;
	if (civIsAfrican() && kingdomBuilderSpecialBuilding < 0)
	{
		if (cMyCiv == cCivDEEthiopians)
			kingdomBuilderSpecialBuilding = cUnitTypedeMountainMonastery;
		else
			kingdomBuilderSpecialBuilding = cUnitTypedeUniversity;
	}


	if (numberFound == 0)
		return;
	
	for (i = 0; < numPlans)
	{
		planID = aiPlanGetIDByActiveIndex(i);
		if (aiPlanGetType(planID) != cPlanBuild)
			continue;
		if (aiPlanGetState(planID) == cPlanStateBuild)
			continue;
		// Wagons cannot build upon a foundation lain by an architect and vice versa.
		if (aiPlanGetUserVariableInt(planID, cBuildPlanBuilderTypeID, 0) == cUnitTypedeArchitect)
			continue;

		buildingType = aiPlanGetVariableInt(planID, cBuildPlanBuildingTypeID, 0);
		wagonType = findWagonToBuild(buildingType);
		if (wagonType >= 0)
		{
			for (j = 0; < numberFound)
			{
				wagon = kbUnitQueryGetResult(wagonQueryID, j);
				if (kbUnitGetPlanID(wagon) >= 0)
				{
					continue;
				}
				if (kbUnitIsType(wagon, wagonType) == false)
				{
					continue;
				}
				// Remove Villagers from the plan if there are some.
				if (aiPlanGetNumberUnits(planID, cUnitTypeLogicalTypeSettlerBuildLimit) > 0)
				{
					// All villagers must go away immediately to avoid being idle alongside the wagon.
					aiPlanAddUnitType(planID, cUnitTypeLogicalTypeSettlerBuildLimit, 0, 0, 0, true, true);
				}
				if (aiPlanGetNumberUnits(planID, cUnitTypeSettlerWagon) > 0)
				{
					// All villagers must go away immediately to avoid being idle alongside the wagon.
					aiPlanAddUnitType(planID, cUnitTypeSettlerWagon, 0, 0, 0, true, true);
				}

				aiPlanAddUnitType(planID, wagonType, 1, 1, 1);
				aiPlanAddUnit(planID, wagon);
				debugBuildings("Added an idle " + kbGetProtoUnitName(kbUnitGetProtoUnitID(wagon)) + " with ID: " 
				+ wagon + " to the existing Build Plan ID: " + planID);
				break;
			}
		}
	}
	
	for (i = 0; < numberFound)
	{
		wagon = kbUnitQueryGetResult(wagonQueryID, i);
		if (kbUnitGetPlanID(wagon) >= 0)
			continue;
		wagonType = kbUnitGetProtoUnitID(wagon);
		
		debugBuildings("Idle Wagon's name is: " + kbGetProtoUnitName(wagonType) + " with ID: " + wagon);

		if ((aiGetGameMode() == cGameModeEmpireWars) && (wagonType == cUnitTypedeImperialWagon))
		{
			if (cMyCiv == cCivXPAztec)  
			{
				if ((age >= cAge3) && 
					((kbUnitCount(cMyID, cUnitTypeNoblesHut, cUnitStateAlive) + 
					aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeNoblesHut, true))
					< kbGetBuildLimit(cMyID, cUnitTypeNoblesHut)))
				{
					buildingType = cUnitTypeNoblesHut;
				}
				else if ((kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateAlive) + 
						  aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeWarHut, true))
						  < kbGetBuildLimit(cMyID, cUnitTypeWarHut))
				{
					buildingType = cUnitTypeWarHut;
				}
			}
			else if ((civIsAfrican() == true) &&
					  ((kbUnitCount(cMyID, cUnitTypedePalace, cUnitStateAlive) + 
					  aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedePalace, true))
					  < kbGetBuildLimit(cMyID, cUnitTypedePalace)))
			{
				buildingType = cUnitTypedePalace;
			}	
			else if ((cMyCiv != cCivXPSioux) &&
					 ((kbUnitCount(cMyID, gTowerUnit, cUnitStateABQ) + 
					  aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gTowerUnit, true))
					  < kbGetBuildLimit(cMyID, gTowerUnit)))
			{
				buildingType = gTowerUnit;
			}
			else if ((cMyCiv == cCivXPSioux) &&
					 ((kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) + 
					  aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeWarHut, true))
					  < kbGetBuildLimit(cMyID, cUnitTypeWarHut)))
			{
				buildingType = cUnitTypeWarHut;
			}

			if (buildingType == -1) // All of the buildings above are probably at their build limit so do something else.
			{
				int arraySize = xsArrayGetSize(gMilitaryBuildings);
				int lowestCount = 1000;
				int buildingPUID = -1;

				for (j = 0; < arraySize)
				{
					buildingPUID = xsArrayGetInt(gMilitaryBuildings, j);
					buildingCount = kbUnitCount(cMyID, buildingPUID, cUnitStateABQ) +
									aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, buildingPUID, true);
					if (buildingCount < lowestCount)
					{
						buildLimit = kbGetBuildLimit(cMyID, buildingPUID);
						if ((buildingCount < buildLimit) || (buildLimit == -1))
						{
							lowestCount = buildingCount;
							buildingType = buildingPUID;
						}
					}
				}
			}
			
			if (buildingType != -1)
			{
				// Make the actual Build Plan and go to next iteration.
				planID = createBuildPlan(buildingType, 1, 75, gHomeBase, 1, wagonType);
				// aiPlanAddUnitType(planID, wagonType, 1, 1, 1);
				aiPlanAddUnit(planID, wagon);
				debugBuildings("FAILSAFE: Added an idle " + kbGetProtoUnitName(cUnitTypedeImperialWagon) + " with ID: " + wagon + " to a new Build Plan ID: " + planID);
				continue;
			}
		}

		switch (wagonType)
		{
			// Vanilla.
			case cUnitTypeBankWagon:
			{
				if (cMyCiv == cCivDutch)
				{
					buildingType = cUnitTypeBank;
				}
				else
				{
					buildingType = cUnitTypeypBankAsian;
				}
				break;
			}
			case cUnitTypeCoveredWagon:
			{
				buildingType = cUnitTypeTownCenter;
				break;
			}
			case cUnitTypeOutpostWagon:
			{
				if (civIsAfrican() == true)
				{
					buildingType = cUnitTypedeTower;
				}
				else
				{
					buildingType = cUnitTypeOutpost;
				}
				break;
			}
			case cUnitTypeFortWagon:
			{
				buildingType = cUnitTypeFortFrontier;
				break;
			}
			case cUnitTypeFactoryWagon:
			{
				buildingType = cUnitTypeFactory;
				break;
			}

			// The War Chiefs.
			case cUnitTypeWarHutTravois:
			{
				buildingType = cUnitTypeWarHut;
				break;
			}
			case cUnitTypeFarmTravois:
			{
				buildingType = cUnitTypeFarm;
				break;
			}
			case cUnitTypeNoblesHutTravois:
			{
				buildingType = cUnitTypeNoblesHut;
				break;
			}
			// xpBuilder is handled by xpBuilderMonitor.

			// The Asian Dynasties.
			case cUnitTypeTradingPostTravois:
			{
				buildingType = cUnitTypeTradingPost;
				break;
			}
			case cUnitTypeYPVillageWagon:
			{
				buildingType = cUnitTypeypVillage;
				break;
			}
			case cUnitTypeYPRicePaddyWagon:
			{
				buildingType = cUnitTypeypRicePaddy;
				break;
			}
			case cUnitTypeypArsenalWagon:
			{
				if ((cMyCiv == cCivJapanese) || (cMyCiv == cCivSPCJapanese) || (cMyCiv == cCivSPCJapaneseEnemy))
				{
					buildingType = cUnitTypeypArsenalAsian;
				}
				else
				{
					buildingType = cUnitTypeArsenal;
				}
				break;
			}
			case cUnitTypeYPCastleWagon:
			{
				buildingType = cUnitTypeypCastle;
				break;
			}
			case cUnitTypeYPDojoWagon:
			{
				buildingType = cUnitTypeypDojo;
				break;
			}
			case cUnitTypeypShrineWagon:
			{
				shouldBuildShrine(gHomeBase, 60.0);
				buildingType = cUnitTypeypShrineJapanese;
				break;
			}
			case cUnitTypeYPBerryWagon1:
			{
				buildingType = cUnitTypeypBerryBuilding;
				break;
			}
			case cUnitTypeYPDockWagon:
			{
				buildingType = gDockUnit;
				break;
			}
			case cUnitTypeYPGroveWagon:
			{
				buildingType = cUnitTypeypGroveBuilding;
				break;
			}
			case cUnitTypeypMarketWagon:
			{
				buildingType = cUnitTypeypTradeMarketAsian;
				break;
			}
			case cUnitTypeypTradingPostWagon:
			{
				if (cMyCiv == cCivDEAmericans)
				{
					if (kbTechGetStatus(cTechDEHCArkansasPost) == cTechStatusActive)
					{
						if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateABQ) +
								aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeMarket) <
							1)
						{
							buildingType = cUnitTypeMarket;
						}
						else if (
							kbUnitCount(cMyID, cUnitTypeChurch, cUnitStateABQ) +
								aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeChurch) <
							1)
						{
							buildingType = cUnitTypeChurch;
						}
						else if (
							kbUnitCount(cMyID, cUnitTypeSaloon, cUnitStateABQ) +
								aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSaloon) <
							1)
						{
							buildingType = cUnitTypeSaloon;
						}
					}
				}
				buildingType = cUnitTypeTradingPost;
				break;
			}
			case cUnitTypeypChurchWagon:
			{
				if (civIsAsian())
				{
					buildingType = cUnitTypeypChurch;
				}
				else if (cMyCiv == cCivDEMexicans)
				{
					buildingType = cUnitTypedeCathedral;
				}
				else if (cMyCiv == cCivDEItalians)
				{
					buildingType = cUnitTypedeBasilica;
				}
				else
				{
					buildingType = cUnitTypeChurch;
				}
				break;
			}
			case cUnitTypeYPMonasteryWagon:
			{
				buildingType = cUnitTypeypMonastery;
				break;
			}
			case cUnitTypeYPMilitaryRickshaw:
			{
				if (kbUnitCount(cMyID, cUnitTypeypBarracksJapanese, cUnitStateABQ) <
					kbUnitCount(cMyID, cUnitTypeypStableJapanese, cUnitStateABQ))
				{
					buildingType = cUnitTypeypBarracksJapanese;
				}
				else
				{
					buildingType = cUnitTypeypStableJapanese;
				}
				break;
			}
			case cUnitTypeypBankWagon:
			{
				buildingType = cUnitTypeypBankAsian;
				break;
			}
			// xpBuilderStart is handled by xpBuilderMonitor.
			case cUnitTypeYPSacredFieldWagon:
			{
				buildingType = cUnitTypeypSacredField;
				break;
			}
			case cUnitTypeypBlockhouseWagon:
			{
				buildingType = cUnitTypeBlockhouse;
				break;
			}

			// Definitive Edition.
			case cUnitTypedeIncaStrongholdTravois:
			{
				buildingType = cUnitTypedeIncaStronghold;
				break;
			}
			case cUnitTypedeBuilderInca:
			{
				if ((age >= cAge3) &&
					(kbUnitCount(cMyID, cUnitTypedeKallanka, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeKallanka) <
					kbGetBuildLimit(cMyID, cUnitTypedeKallanka)))
				{
					buildingType = cUnitTypedeKallanka;
				}
				else if (
					kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeWarHut) <
					kbGetBuildLimit(cMyID, cUnitTypeWarHut))
				{
					buildingType = cUnitTypeWarHut;
				}
				else // Farms have no build limit.
				{
					buildingType = cUnitTypeFarm;
				}
				break;
			}
			case cUnitTypedeEmbassyTravois:
			{
				buildingType = cUnitTypeNativeEmbassy;
				break;
			}
			case cUnitTypedeMilitaryWagon:
			{
				if (civIsEuropean() == true)
				{
					int barracks = cUnitTypeBarracks;
					int stable = cUnitTypeStable;
					if (cMyCiv == cCivRussians)
					{
						barracks = cUnitTypeBlockhouse;
					}
					else if (cMyCiv == cCivDEMaltese)
					{
						barracks = cUnitTypedeHospital;
						stable = cUnitTypedeCommandery;
					}
					int barracksCount = kbUnitCount(cMyID, barracks, cUnitStateABQ);
					int stableCount = kbUnitCount(cMyID, stable, cUnitStateABQ);
					int artilleryDepotCount = kbUnitCount(cMyID, cUnitTypeArtilleryDepot, cUnitStateABQ);
					if ((barracksCount < stableCount) || (barracksCount < artilleryDepotCount) || (barracksCount == 0))
					{
						buildingType = barracks;
					}
					else if ((stableCount < artilleryDepotCount) || (stableCount == 0))
					{
						buildingType = stable;
					}
					else
					{
						buildingType = cUnitTypeArtilleryDepot;
					}
					break;
				}
				// The logic below only happens once during EW when you get this wagon after reaching the Commerce age.
				else if (civIsNative() == true)
				{
					buildingType = cUnitTypeWarHut;
					break;
				}
				else if (civIsAfrican() == true)
				{
					buildingType = cUnitTypedePalace;
					break;
				}
				else // Asian.
				{
					buildingType = cUnitTypeypCastle;
					break;
				}
			}
			// TODO (James) deHomesteadWagon has no defaults and will only be taken by farm/plantation plans.
			case cUnitTypedeProspectorWagon:
			{
				buildingType = cUnitTypedeMineCopperBuildable;
				break;
			}
			case cUnitTypedeTorpWagon:
			{
				shouldBuildTorp(gHomeBase, 60.0);
				if (cMyCiv == cCivDESwedish)
				{
					buildingType = cUnitTypedeTorp;
				}
				else
				{
					buildingType = cUnitTypedeTorpGeneric;
				}
				break;
			}
			// deREVStarTrekWagon we never get these since we don't know how to handle them (also they don't build anything).
			case cUnitTypedeREVProspectorWagon:
			{
				buildingType = cUnitTypedeREVMineDiamondBuildable;
				break;
			}
			case cUnitTypedeFurTradeTravois:
			{
				buildingType = cUnitTypedeFurTrade;
				break;
			}
			case cUnitTypeDEMillWagon:
			{
				buildingType = cUnitTypeMill;
				break;
			}
			case cUnitTypedeLivestockPenWagonJapanese:
			{
				buildingType = cUnitTypeYPLivestockPenAsian;
				break;
			}
			case cUnitTypedeTradingPostWagon:
			{
				if (cMyCiv == cCivDEAmericans)
				{
					if (kbTechGetStatus(cTechDEHCArkansasPost) == cTechStatusActive)
					{
						if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateABQ) +
								aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeMarket) <
							1)
						{
							buildingType = cUnitTypeMarket;
						}
						else if (
							kbUnitCount(cMyID, cUnitTypeChurch, cUnitStateABQ) +
								aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeChurch) <
							1)
						{
							buildingType = cUnitTypeChurch;
						}
						else
						{
							buildingType = cUnitTypeSaloon;
						}
					}
				}
				if (buildingType == -1)
				{
					buildingType = cUnitTypeTradingPost;
				}
				break;
			}
			case cUnitTypedeStateCapitolWagon:
			{
				buildingType = cUnitTypedeStateCapitol;
				break;
			}
			case cUnitTypedeProspectorWagonCoal:
			{
				buildingType = cUnitTypedeMineCoalBuildable;
				break;
			}
			case cUnitTypedeProspectorWagonGold:
			{
				buildingType = cUnitTypedeMineGoldBuildable;
				break;
			}
			case cUnitTypedeProspectorWagonSilver:
			{
				buildingType = cUnitTypedeMineSilverBuildable;
				break;
			}
			case cUnitTypedePlantationWagon:
			{
				buildingType = cUnitTypePlantation;
				break;
			}
			case cUnitTypedeCampWagon:
			{
				if (kbGetAge() == cAge2)
					buildingType = cUnitTypedeWarCamp;
				else
					buildingType = gTowerUnit;
				break;
			}
			case cUnitTypedeLivestockMarketWagon:
			{
				buildingType = cUnitTypedeLivestockMarket;
				break;
			}
			// deImperialWagon is the Empire Wars wagon and is handled at the top of this Rule.
			case cUnitTypedeBuilderAfrican:
			{
				if (kbUnitCount(cMyID, cUnitTypedeLivestockMarket, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeLivestockMarket) <
					1)
				{
					buildingType = cUnitTypedeLivestockMarket;
				}
				else
				{
					buildingType = cUnitTypedeHouseAfrican;
				}
				break;
			}
			case cUnitTypedeNatSaltCamel:
			{
				buildingType = cUnitTypedeMineSaltBuildable;
				break;
			}
			case cUnitTypedeRedSeaWagon:
			{
				buildingType = gTowerUnit;
				break;
			}
			case cUnitTypedeArtilleryFoundryWagon:
			{
				buildingType = cUnitTypeArtilleryDepot;
				break;
			}
			case cUnitTypedeBuilderHausa:
			{
				if (
					kbUnitCount(cMyID, cUnitTypedeWarCamp, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeWarCamp) <
					4)
				{
					buildingType = cUnitTypedeWarCamp;
				}
				else if (
					(kbTechGetStatus(cTechDEAllegianceHausaArewa) == cTechStatusActive) &&
					(kbUnitCount(cMyID, cUnitTypedeTower, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeTower) <
					kbGetBuildLimit(cMyID, cUnitTypedeTower)))
				{
					buildingType = cUnitTypedeTower;
				}
				else if (kbUnitCount(cMyID, cUnitTypedeLivestockMarket, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeLivestockMarket) <
					2)
				{
					buildingType = cUnitTypedeLivestockMarket;
				}
				else
				{
					buildingType = cUnitTypedeHouseAfrican;
				}
				break;
			}
			case cUnitTypedeBuilderKingdom:
			{
				if (kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTownCenter) <
					kbGetBuildLimit(cMyID, cUnitTypeTownCenter))
				{
					buildingType = cUnitTypeTownCenter;
				}
				else if (
					kbUnitCount(cMyID, kingdomBuilderSpecialBuilding, cUnitStateABQ) +
						aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, kingdomBuilderSpecialBuilding) <
					kbGetBuildLimit(cMyID, kingdomBuilderSpecialBuilding))
				{
					buildingType = kingdomBuilderSpecialBuilding;
				}
				else
				{
					buildingType = cUnitTypedePalace;
				}
				break;
			}
			case cUnitTypedeTowerBuilder:
			{
				buildingType = cUnitTypedeTower;
				break;
			}
			case cUnitTypedeMountainMonasteryBuilder:
			{
				buildingType = cUnitTypedeMountainMonastery;
				break;
			}
			case cUnitTypedePalaceBuilder:
			{
				buildingType = cUnitTypedePalace;
				break;
			}
			case cUnitTypedeIndianMarketRickshaw: // We never age up with the Indian alliance but just put it here anyway.
			{
				buildingType = cUnitTypeypTradeMarketAsian;
				break;
			}
			case cUnitTypedeUniversityBuilder:
			{
				buildingType = cUnitTypedeUniversity;
				break;
			}
			case cUnitTypedeUSOutpostWagon:
			{
				buildingType = cUnitTypeOutpost;
				break;
			}
			case cUnitTypedeUniqueTowerBuilder:
			{
				buildingType = cUnitTypedeUniqueTower;
				break;
			}
			case cUnitTypedeKallankaTravois:
			{
				buildingType = cUnitTypedeKallanka;
				break;
			}
			case cUnitTypedeHaciendaWagon:
			{
				buildingType = cUnitTypedeHacienda;
				break;
			}
			case cUnitTypedeDockWagon:
			{
				buildingType = gDockUnit;
				break;
			}
			case cUnitTypedeFrontierWagon:
			{
				buildingType = gTowerUnit;
				break;
			}
			case cUnitTypedeLombardWagon:
			{
				buildingType = cUnitTypedeLombard;
				break;
			}
			case cUnitTypedeCommanderyWagon:
			{
				buildingType = cUnitTypedeCommandery;
				break;
			}
			case cUnitTypedeMalteseGunWagon:
			{
				buildingType = cUnitTypedeMalteseGun;
				break;
			}
			case cUnitTypedeHanoverFactoryWagon:
			{
				buildingType = cUnitTypedeHanoverFactory;
				break;
			}
			case cUnitTypedeTavernWagon:
			{
				if ((cMyCiv == cCivDEAmericans) || (cMyCiv == cCivDEMexicans))
				{
					buildingType = cUnitTypeSaloon;
				}
				else
				{
					buildingType = cUnitTypedeTavern;
				}
				break;
			}
		}
		
		if (buildingType < 0) // Didn't find a building so go to the next iteration.
		{
			continue;
		}

		/* // If there is an existing plan, add the wagon to it and remove villagers so we don't
		// potentially waste resources.
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, buildingType, true);
		if (planID >= 0 && aiPlanGetState(planID) != cPlanStateBuild)
		{
			// All villagers must go away immediately to avoid being idle alongside the wagon.
			aiPlanAddUnitType(planID, cUnitTypeLogicalTypeSettlerBuildLimit, 0, 0, 0, true, true);
			aiPlanAddUnitType(planID, cUnitTypeSettlerWagon, 0, 0, 0, true, true);
			aiPlanAddUnitType(planID, wagonType, 1, 1, 1);
			aiPlanAddUnit(planID, wagon);
			continue;
		} */

		// Are we on build limit?
		buildLimit = kbGetBuildLimit(cMyID, buildingType);
		if (buildLimit >= 1)
		{
			buildingCount = kbUnitCount(cMyID, buildingType, cUnitStateAlive) +
				aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, buildingType, true);
			if (buildingCount >= buildLimit)
			{
				continue; // We can't make this building anymore so go to the next iteration.
			}
		}
		planID = createBuildPlan(buildingType, 1, 99, gHomeBase, 1, wagonType);
		aiPlanAddUnit(planID, wagon);
	}
}

//==============================================================================
/*	Startup Buildings
	These are buildings we want to get up and running right at the start.
*/
//==============================================================================
void startupBuildings()
{
	int planID = -1;
	int buildingID = -1;

	if (cMyCiv == cCivOttomans)
	{
		planID = createBuildPlan(cUnitTypeChurch, 1, 99, gHomeBase + gDirection_DOWN * 15);
	}

	if (cMyCiv == cCivDEItalians)
	{
		createArchitectBuildPlan(cUnitTypeMarket, 92, gHomeBase);
		createArchitectBuildPlan(cUnitTypedeLombard, 91, gHomeBase);
	}

	if (cMyCiv == cCivXPIroquois)
	{
		if (gLowDifficulty)
			buildingID = gHouseUnit;
		else
			buildingID = cUnitTypeFarm;
		createBuildPlan(buildingID, 1, 99, gHomeBase + gDirection_DOWN * 15, 1, cUnitTypexpBuilderStart);
	}

	if (cMyCiv == cCivXPAztec)
		createBuildPlan(cUnitTypeCommunityPlaza, 1, 92, gHomeBase + gDirection_DOWN * 15);

	if (cMyCiv == cCivJapanese)
	{
		if (gLowDifficulty == false)
			aiPlanSetDesiredResourcePriority(createBuildPlan(cUnitTypeypConsulate, 1, 99, gHomeBase, 2), 99);
		createBuildPlan(cUnitTypeypBerryBuilding, 1, 99, gHomeBase + gDirection_DOWN * 15, 1, cUnitTypeYPBerryWagon1);
		if (kbUnitCount(cMyID, cUnitTypeYPBerryWagon1, cUnitStateAlive) > 1)
			createBuildPlan(cUnitTypeypBerryBuilding, 1, 99, gHomeBase + gDirection_DOWN * 15, 1, cUnitTypeYPBerryWagon1);
	}

	if (civIsAfrican() == true)
	{
		planID = createBuildPlan(cUnitTypedeLivestockMarket, 1, 99, gHomeBase + gDirection_DOWN * 15, 1, cUnitTypedeLivestockMarketWagon);
		if (shouldBuildGranaryHuntables(gHomeBase, 45.0))
		{
			planID = createBuildPlan(cUnitTypedeGranary, 1, 99, gHomeBase);
		}
	}

	// Lakota don't have houses, and the Africans only want to consider
	// a build plan after the livestock market values appreciate, so we
	// will launch the houseMonitor rule from there.
	if (cMyCiv != cCivXPSioux)
	{
		gHouseBuildPlans = arrayCreateInt(1, "House Build Plans");
		if (civIsAfrican() == false)
		{
			// Update suitable build plan positions.
			if (cMyCiv == cCivDESwedish)
				shouldBuildTorp(gHomeBase, 45.0);
			else if (cMyCiv == cCivJapanese)
				shouldBuildShrine(gHomeBase, 45.0);

			planID = createBuildPlan(gHouseUnit, 1, 99, gHomeBase);
			aiPlanSetDesiredResourcePriority(planID, 99);
			arrayPushInt(gHouseBuildPlans, planID);
			xsEnableRule("houseMonitor");
		}
	}
}


//==============================================================================
/*	Building Monitor
	Make sure we have the right number of buildings, or at least a build plan,
	for each required building type.
*/
//==============================================================================
rule buildingMonitor
inactive
group tcComplete
minInterval 5
{
	int planID = -1;
	int numBuildings = -1;
	int numWanted = -1;
	int buildLimit = -1;
	int numActivePlans = -1;
	bool treatyFactor = true;
	// Bool variable to be used to let us know when it is okay to build military buildings.
	// Don't construct military until there are only ten minutes remaining in the treaty.
	if (aiTreatyActive() == true && aiTreatyGetEnd() > (xsGetTime() + 10 * 60 * 1000))
		treatyFactor = false;

	vector location = cInvalidVector;
	vector baseMilitaryBuildingLocation = gHomeBase + (gDirection_UP * (5.0 + kbGetAge() * 5.0));
	if (gMyStrategy == cStrategyTreaty)
		baseMilitaryBuildingLocation = gHomeBase + gDirection_UP * 45;

	if (gDefenseReflexBaseID >= 0 && gDefenseReflexBaseID == gMainBase)
		return;

	// A Town Center if we don't have one.
	planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTownCenter);
	if (planID < 0 && kbUnitCount(cMyID, cUnitTypeAgeUpBuilding, cUnitStateAlive) < 1)
	{
		planID = createBuildPlan(cUnitTypeTownCenter, 1, 99, gHomeBase);
		aiPlanSetDesiredResourcePriority(planID, 99);
		debugBuildings("Starting a new Town Center build plan.");
	}

	// That's it for Age 1.
	if (kbGetAge() < cAge2 && agingUp() == false)
		return;

	// ****************************************************************************************************

	if (gNavyMap == true && kbUnitCount(cMyID, gDockUnit, cUnitStateABQ) < getMin(1 + kbGetAge(), 3) &&
		aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gDockUnit) < 0)
	{
		createBuildPlan(gDockUnit, 1, 70, gHomeBase);
		debugBuildings("Starting a Dock build plan.");
	}

	// Market.
	planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gMarketUnit);
	if (planID < 0 && kbUnitCount(cMyID, gMarketUnit, cUnitStateAlive) < 1)
	{
		planID = createBuildPlan(gMarketUnit, 1, 96, gHomeBase); // Just higher than house
		aiPlanSetDesiredResourcePriority(planID, 60);
		debugBuildings("Starting a new Market build plan.");
	}

	// Trading Posts (Trade Route).
	// Easy and Standard Difficulties wait until Age 4 before building TPs.
	if (cDifficultyCurrent >= cDifficultyModerate || kbGetAge() >= cAge4)
	{	// If we are in Age 2 with a non-treaty strategy, only consider building a TP
		// if we have >= 500 wood.
		if (gMyStrategy == cStrategyTreaty ||
			kbGetAge() >= cAge3 ||
			kbResourceGet(cResourceWood) >= 500)
		{
			float radius = -1.0;
			if (aiTreatyActive() == true)
				radius = 85.0;

			int socketID = -1;
			int socketQuery = createSimpleUnitQuery(cUnitTypeSocketTradeRoute, 0, cUnitStateAlive, gHomeBase, radius);
			kbUnitQuerySetAscendingSort(socketQuery, true);
			int numberFound = kbUnitQueryExecute(socketQuery);
			numBuildings = 0;

			for (i = 0; < numberFound)
			{
				socketID = kbUnitQueryGetResult(socketQuery, i);

				if (kbUnitGetProtoUnitID(socketID) == cUnitTypedeSPCSocketCityState)
					continue;

				// Ignore this location if there are threatening enemy buildings nearby.
				if (getUnitByLocation(cUnitTypeAbstractCallMinutemen, cPlayerRelationEnemy, cUnitStateABQ, kbUnitGetPosition(socketID), 50.0) >= 0)
					continue;

				// Already claimed.
				if (getUnitByLocation(cUnitTypeTradingPost, cPlayerRelationAny, cUnitStateABQ, kbUnitGetPosition(socketID), 10.0) >= 0)
				{
					if (getUnitByLocation(cUnitTypeTradingPost, cMyID, cUnitStateABQ, kbUnitGetPosition(socketID), 10.0) >= 0)
						numBuildings++;
					continue;
				}

				break;
			}

			numWanted = numberFound / (getAllyCount() + 1);
			if (numWanted == 0)
				numWanted++;
			if (numBuildings < numWanted)
			{
				planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTradingPost);
				if (planID < 0 && socketID >= 0)
				{
					if (aiGetFallenExplorerID() < 0)
						buildTradingPost(socketID, 60, cUnitTypeHero, 1);
					else if (kbGetAge() >= cAge3)
						buildTradingPost(socketID, 60, gEconUnit, 2);
				}
				debugBuildings("Starting a new Trading Post (Trade Route) build plan.");
			}
		}
	}

	// Banks for Dutch.
	if (cMyCiv == cCivDutch)
	{
		buildLimit = kbGetBuildLimit(cMyID, cUnitTypeBank);
		// Needs to be flagged as cUnitStateAlive to not be counted in the plans part.
		numBuildings = kbUnitCount(cMyID, cUnitTypeBank, cUnitStateAlive);
		numActivePlans = aiPlanGetNumberByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeBank, true);
		if ((numBuildings + numActivePlans) < buildLimit && numActivePlans < 2 && getAgingUpAge() >= cAge2)
		{
			planID = createBuildPlan(cUnitTypeBank, 1, 93, gHomeBase + gDirection_UP * 15); 
			aiPlanSetDesiredResourcePriority(planID, 55);
			debugBuildings("Starting a new Bank build plan.");
		}
		if (numBuildings < 1)
		{	// Grab the first active bank build plan and give it a higher priority so we at least get one up.
			planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeBank);
			aiPlanSetDesiredResourcePriority(planID, 65);
		}
	}

	if (gBarracksUnit != -1) // Should never be false.
	{
		numWanted = kbGetAge();
		if (numWanted < 2 &&
			(cMyCiv == cCivXPAztec || cMyCiv == cCivDEInca ||
			 cMyCiv == cCivChinese || civIsAfrican()))
		{
			numWanted = 2;
		}

		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gBarracksUnit);
		if (planID < 0 && kbUnitCount(cMyID, gBarracksUnit, cUnitStateAlive) < numWanted && treatyFactor)
		{
			planID = createBuildPlan(gBarracksUnit, 1, 70, baseMilitaryBuildingLocation);
			numBuildings = kbUnitCount(cMyID, gBarracksUnit, cUnitStateABQ);
			if (numBuildings < 1)
			{
				aiPlanSetDesiredPriority(planID, 99);
				aiPlanSetDesiredResourcePriority(planID, 99);
				debugBuildings("Starting a new Barracks Type build plan.");
			}
		}
	}

	// Stable
	if (gStableUnit != -1)
	{
		numWanted = kbGetAge();
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gStableUnit);
		if (planID < 0 && kbUnitCount(cMyID, gStableUnit, cUnitStateAlive) < numWanted && treatyFactor)
		{
			planID = createBuildPlan(gStableUnit, 1, 70, baseMilitaryBuildingLocation);
			debugBuildings("Starting a new Stable Type build plan.");
		}
	}

	// Artillery Foundry.
	// Ottomans and Maltese can build in Age 2, otherwise do not plan for it early.
	if (gArtilleryDepotUnit != -1)
	{
		if (cMyCiv == cCivOttomans || cMyCiv == cCivDEMaltese || kbGetAge() >= cAge3)
		{
			planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gArtilleryDepotUnit);
			if (planID < 0 && kbUnitCount(cMyID, gArtilleryDepotUnit, cUnitStateAlive) < getMin(2, kbGetAge()) && treatyFactor)
			{
				createBuildPlan(gArtilleryDepotUnit, 1, 70, baseMilitaryBuildingLocation);
				debugBuildings("Starting a new Artillery Depot Type build plan.");
			}
		}
	}

	// Maintain Bascillas and Lombards.
	if (cMyCiv == cCivDEItalians)
	{
		numWanted = kbGetBuildLimit(cMyID, cUnitTypedeBasilica);
		numBuildings = kbUnitCount(cMyID, cUnitTypedeBasilica, cUnitStateABQ);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeBasilica, false);
		if (planID < 0)
			planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeBasilica);
		// Only build with architects (wagons handled elsewhere).
		if (planID < 0 && numBuildings < numWanted && kbUnitCount(cMyID, cUnitTypedeArchitect, cUnitStateABQ) > 0)
		{
			createArchitectBuildPlan(cUnitTypedeBasilica, 95, gHomeBase);
			debugBuildings("Starting a new Basilica build plan.");
		}

		numWanted = getMin(4, kbGetAge());
		numBuildings = kbUnitCount(cMyID, cUnitTypedeLombard, cUnitStateABQ);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeLombard, false);
		if (planID < 0)
			planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeLombard);
		if (planID < 0 && numBuildings < numWanted)
		{
			// Look for an architect to build it, but it is not necessary.
			if (kbUnitCount(cMyID, cUnitTypedeArchitect, cUnitStateAlive) > 0)
				createArchitectBuildPlan(cUnitTypedeLombard, 85, gHomeBase);
			// If a villager needs to build it, default priority is fine.
			else
				createBuildPlan(cUnitTypedeLombard, 1, 50, gHomeBase);

			debugBuildings("Starting a new Lombard build plan.");
		}
	}

	// Community Plaza for Natives.
	if (civIsNative() == true)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeCommunityPlaza);
		location = gHomeBase + gDirection_DOWN * 10.0;
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypeCommunityPlaza, cUnitStateAlive) < 1)
		{
			if (gMyStrategy == cStrategyTreaty || (kbUnitCount(cMyID, cUnitTypexpMedicineManAztec, cUnitStateAlive) + kbUnitCount(cMyID, cUnitTypedePriestess, cUnitStateAlive) > 0))
			{	// We've reached Age 2, and we are in a treaty game or have acquired a Warrior Priest or Priestess.
				planID = createBuildPlan(cUnitTypeCommunityPlaza, 1, 92, location);
				aiPlanSetDesiredResourcePriority(planID, 60);
				debugBuildings("Starting a new Community Plaza build plan.");
			}
			else if (kbGetAge() >= cAge3)
			{	// We've reached Age 3, so let us wait no longer.
				planID = createBuildPlan(cUnitTypeCommunityPlaza, 1, 92, location);
				aiPlanSetDesiredResourcePriority(planID, 60);
				debugBuildings("Starting a new Community Plaza build plan.");
			}
		}
	}

	// Church.
	if (civIsEuropean() == true && cMyCiv != cCivDEMexicans && cMyCiv != cCivDEItalians)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeChurch);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypeChurch, cUnitStateAlive) < 1)
		{
			if (gMyStrategy == cStrategyTreaty)
			{
				planID = createBuildPlan(cUnitTypeChurch, 1, 60, gHomeBase);
				aiPlanSetDesiredResourcePriority(planID, 40);
				debugBuildings("Starting a new Church build plan.");
			}
			else if (kbGetAge() >= cAge3)
			{
				planID = createBuildPlan(cUnitTypeChurch, 1, 60, gHomeBase);
				aiPlanSetDesiredResourcePriority(planID, 40);
				debugBuildings("Starting a new Church build plan.");
			}
		}
	}

	// Cathedral.
	if (cMyCiv == cCivDEMexicans)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeCathedral);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypedeCathedral, cUnitStateAlive) < 1)
		{
			planID = createBuildPlan(cUnitTypedeCathedral, 1, 60, gHomeBase);
			aiPlanSetDesiredResourcePriority(planID, 40);
			debugBuildings("Starting a new Cathedral build plan.");
		}
	}

	// Native Embassy.
	if (xsArrayGetSize(kbVPSiteQuery(cVPNative, cMyID, cVPStateCompleted)) > 0)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeNativeEmbassy);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypeNativeEmbassy, cUnitStateAlive) < 1 && treatyFactor)
		{
			planID = createBuildPlan(cUnitTypeNativeEmbassy, 1, 60, baseMilitaryBuildingLocation);
			aiPlanSetDesiredResourcePriority(planID, 40);
			debugBuildings("Starting a new Native Embassy build plan.");
		}
	}

	// Build State Capitol for Americans if Virginia General Assembly card was sent or we are in Age 3.
	if (cMyCiv == cCivDEAmericans && (kbTechGetStatus(cTechDEHCFedGeneralAssembly) == cTechStatusActive || kbGetAge() >= cAge3))
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeStateCapitol);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypedeStateCapitol, cUnitStateAlive) < 1)
		{
			planID = createBuildPlan(cUnitTypedeStateCapitol, 1, 60, gHomeBase);
			debugBuildings("Starting a new State Capitol build plan.");
		}
	}

	// That's it for Age 2.
	if (kbGetAge() < cAge3)
		return;

	// ****************************************************************************************************

	// Trading Posts (Natives).
	if (cDifficultyCurrent >= cDifficultyModerate || kbGetAge() >= cAge4)
	{	// Sandbox and Easy Difficulties wait until Age 4 before building TPs.
		float radius2 = -1.0;
		if (aiTreatyActive() == true)
			radius2 = 85.0;

		int socketID2 = -1;
		int socketQuery2 = createSimpleUnitQuery(cUnitTypeNativeSocket, 0, cUnitStateAlive, gHomeBase, radius2);
		kbUnitQuerySetAscendingSort(socketQuery2, true);
		int numberFound2 = kbUnitQueryExecute(socketQuery2);
		numBuildings = 0;

		for (i = 0; < numberFound2)
		{
			socketID2 = kbUnitQueryGetResult(socketQuery2, i);

			if (kbUnitGetProtoUnitID(socketID2) == cUnitTypedeSPCSocketCityState)
				continue;

			// Ignore this location if there are threatening enemy buildings nearby.
			if (getUnitByLocation(cUnitTypeAbstractCallMinutemen, cPlayerRelationEnemy, cUnitStateABQ, kbUnitGetPosition(socketID2), 50.0) >= 0)
				continue;

			// Already claimed.
			if (getUnitByLocation(cUnitTypeTradingPost, cPlayerRelationAny, cUnitStateABQ, kbUnitGetPosition(socketID2), 10.0) >= 0)
			{
				if (getUnitByLocation(cUnitTypeTradingPost, cMyID, cUnitStateABQ, kbUnitGetPosition(socketID2), 10.0) >= 0)
					numBuildings++;
				continue;
			}

			break;
		}

		numWanted = numberFound2 / (getAllyCount() + 1);
		if (numWanted == 0)
			numWanted++;
		if (numBuildings < numWanted)
		{
			planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTradingPost);
			if (planID < 0 && socketID2 >= 0)
			{
				if (aiGetFallenExplorerID() < 0)
					buildTradingPost(socketID2, 50, cUnitTypeHero, 1);
				else
					buildTradingPost(socketID2, 50, gEconUnit, 2);
			}
			debugBuildings("Starting a new Trading Post (Native Socket) build plan.");
		}
	}

	// Arsenal.
	if (civIsEuropean() == true)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeArsenal);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypeArsenal, cUnitStateAlive) < 1)
		{
			createBuildPlan(cUnitTypeArsenal, 1, 60, gHomeBase);
			debugBuildings("Starting a new Arsenal build plan.");
		}
	}

	// At least one Nobles Hut.
	if (cMyCiv == cCivXPAztec)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeNoblesHut);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypeNoblesHut, cUnitStateAlive) < 1 && treatyFactor)
		{
			planID = createBuildPlan(cUnitTypeNoblesHut, 1, 70, gHomeBase);
			aiPlanSetDesiredResourcePriority(planID, 70);
			debugBuildings("Starting a new Nobles Hut build plan.");
		}
	}

	// A few Teepees.
	if (cMyCiv == cCivXPSioux)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypeTeepee, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypeTeepee) / 2;
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTeepee);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypeTeepee, 1, 70, gHomeBase);
			debugBuildings("Starting a new Teepee build plan.");
		}
	}

	// At least one Kallanka.
	if (cMyCiv == cCivDEInca)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeKallanka);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypedeKallanka, cUnitStateAlive) < 1 && treatyFactor)
		{
			planID = createBuildPlan(cUnitTypedeKallanka, 1, 70, gHomeBase);
			aiPlanSetDesiredResourcePriority(planID, 70);
			debugBuildings("Starting a new Kallanka build plan.");
		}
	}

	// Palaces.
	if (civIsAfrican() == true)
	{
		numWanted = 1 + kbGetAge();
		buildLimit = kbGetBuildLimit(cMyID, cUnitTypedePalace);
		if (kbGetAge() == cvMaxAge || numWanted > buildLimit)
			numWanted = buildLimit;
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedePalace);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypedePalace, cUnitStateABQ) < numWanted)
		{
			planID = createBuildPlan(cUnitTypedePalace, 1, 70, gHomeBase);
			aiPlanSetDesiredResourcePriority(planID, 55);
			debugBuildings("Starting a new Palace build plan.");
		}
	}

	// Consulate.
	if (civIsAsian() == true)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypConsulate);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypeypConsulate, cUnitStateAlive) < 1)
		{
			planID = createBuildPlan(cUnitTypeypConsulate, 1, 60, gHomeBase);
			debugBuildings("Starting a new Consulate build plan.");
		}
	}

	int buildingToMake = cUnitTypedeTavern;
	// Saloons, Taverns, and Monasteries.
	if (cMyCiv == cCivDEAmericans || cMyCiv == cCivDEMexicans)
		buildingToMake = cUnitTypeSaloon;
	else if (civIsAsian() == true)
		buildingToMake = cUnitTypeypMonastery;

	numBuildings = kbUnitCount(cMyID, buildingToMake, cUnitStateAlive);
	planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, buildingToMake);
	if (planID < 0 && kbGetBuildLimit(cMyID, buildingToMake) > numBuildings)
	{
		createBuildPlan(buildingToMake, 1, 50, baseMilitaryBuildingLocation);
		debugBuildings("Starting a new " + kbGetUnitTypeName(buildingToMake) + " build plan.");
	}

	// Max Out Town Centers if beneficial to do so.
	planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTownCenter);
	numBuildings = kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateAlive);
	if (planID < 0 &&
		kbGetBuildLimit(cMyID, cUnitTypeTownCenter) > numBuildings &&
		(kbGetBuildLimit(cMyID, gEconUnit) - kbUnitCount(cMyID, gEconUnit, cUnitStateABQ)) > (12 + 6 * (numBuildings - 1)))
	{
		planID = createBuildPlan(cUnitTypeTownCenter, 1, 99, gHomeBase);
		debugBuildings("Starting a new Town Center build plan.");
	}

	// That's it for Age 3.
	if (kbGetAge() < cAge4)
		return;

	// ****************************************************************************************************

	// Malta should maintain 3 Fixed Guns.
	if (cMyCiv == cCivDEMaltese)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypedeMalteseGun, cUnitStateABQ);
		numWanted = 3;
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeMalteseGun);
		if (planID < 0 && numBuildings < numWanted && treatyFactor && aiGetFallenExplorerID() < 0)
		{
			planID = createBuildPlan(cUnitTypedeMalteseGun, 1, 70, gHomeBase, 1, cUnitTypeHero);
			aiPlanSetDesiredResourcePriority(planID, 55);
			debugBuildings("Starting a new Fixed Gun build plan.");
		}
	}

	// Europeans max out on Outposts/Blockhouses.
	if (civIsEuropean() == true && cMyCiv != cCivRussians)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypeOutpost, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypeOutpost);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeOutpost);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypeOutpost, 1, 70, gHomeBase);
			debugBuildings("Starting a new Outpost build plan.");
		}
	}
	else if (cMyCiv == cCivRussians)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypeBlockhouse, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypeBlockhouse);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeBlockhouse);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypeBlockhouse, 1, 70, gHomeBase);
			debugBuildings("Starting a new Blockhouse build plan.");
		}
	}
	// Natives max out on War Huts.
	else if (civIsNative() == true)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypeWarHut);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeWarHut);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypeWarHut, 1, 70, gHomeBase);
			debugBuildings("Starting a new War Hut build plan.");
		}
	}
	else if (civIsAsian() == true)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypeypCastle, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypeypCastle);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeypCastle);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypeypCastle, 1, 70, gHomeBase);
			debugBuildings("Starting a new Castle build plan.");
		}
	}
	else if (civIsAfrican() == true)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypedeTower, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypedeTower);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeTower);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypedeTower, 1, 70, gHomeBase);
			debugBuildings("Starting a new Tower build plan.");
		}
	}

	// Aztecs max out on Nobles Huts.
	if (cMyCiv == cCivXPAztec)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypeNoblesHut, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypeNoblesHut);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeNoblesHut);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypeNoblesHut, 1, 70, gHomeBase);
			debugBuildings("Starting a new Nobles Hut build plan.");
		}
	}
	// Sioux max out on Teepees.
	else if (cMyCiv == cCivXPSioux)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypeTeepee, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypeTeepee);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeTeepee);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypeTeepee, 1, 70, gHomeBase);
			debugBuildings("Starting a new Teepee build plan.");
		}
	}
	// Incas max out on Kallankas.
	else if (cMyCiv == cCivDEInca)
	{
		numBuildings = kbUnitCount(cMyID, cUnitTypedeKallanka, cUnitStateABQ);
		numWanted = kbGetBuildLimit(cMyID, cUnitTypedeKallanka);
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeKallanka);
		if (planID < 0 && numBuildings < numWanted && treatyFactor)
		{
			createBuildPlan(cUnitTypedeKallanka, 1, 70, gHomeBase);
			debugBuildings("Starting a new Kallanka build plan.");
		}
	}

	// That's it for Age 4.
	if (kbGetAge() < cAge5)
		return;

	// ****************************************************************************************************

	// Capitol.
	if (civIsEuropean() == true && cMyCiv != cCivDEAmericans)
	{
		planID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeCapitol);
		if (planID < 0 && kbUnitCount(cMyID, cUnitTypeCapitol, cUnitStateAlive) < 1)
		{
			createBuildPlan(cUnitTypeCapitol, 1, 60, gHomeBase);
			debugBuildings("Starting a new Capitol build plan.");
		}
	}
}

//==============================================================================
// rule repairManager
//==============================================================================
rule repairManager
inactive
group tcComplete
minInterval 20
{
	if (aiGetWorldDifficulty() < cDifficultyModerate)
	{
		xsDisableSelf();
		return;
	}

	if (aiPlanGetIDByIndex(cPlanRepair, -1, true, 0) < 0)
		createRepairPlan(50);
}

//==============================================================================
// towerManager
//==============================================================================
rule towerManager
inactive
minInterval 30
{
	if (civIsEuropean() == true)
	{
		if (cMyCiv == cCivRussians)
		{
			researchSimpleTech(cTechFrontierBlockhouse, cUnitTypeBlockhouse, -1, 50);
			researchSimpleTech(cTechFortifiedBlockhouse, cUnitTypeBlockhouse, -1, 50);
		}
		else
		{
			researchSimpleTech(cTechFrontierOutpost, cUnitTypeOutpost, -1, 45);
			researchSimpleTech(cTechFortifiedOutpost, cUnitTypeOutpost, -1, 45);
		}

		if (cMyCiv == cCivDEMaltese)
		{
			researchSimpleTech(cTechDEHeavyFixedGun, cUnitTypedeMalteseGun, -1, 50);
			researchSimpleTech(cTechDEImperialFixedGun, cUnitTypedeMalteseGun, -1, 50);
		}
	}
	else if (civIsNative() == true)
	{
		researchSimpleTech(cTechStrongWarHut, cUnitTypeWarHut, -1, 45);
		researchSimpleTech(cTechMightyWarHut, cUnitTypeWarHut, -1, 45);

		if (cMyCiv == cCivXPAztec)
		{
			researchSimpleTech(cTechStrongNoblesHut, cUnitTypeNoblesHut, -1, 45);
			researchSimpleTech(cTechMightyNoblesHut, cUnitTypeNoblesHut, -1, 45);
		}
	}
	else if (civIsAsian() == true)
	{
		researchSimpleTech(cTechypFrontierCastle, cUnitTypeypCastle, -1, 45);
		researchSimpleTech(cTechypFortifiedCastle, cUnitTypeypCastle, -1, 45);
	}
	else
	{
		researchSimpleTech(cTechDESentryTower, cUnitTypedeTower, -1, 45);
		researchSimpleTech(cTechDEGuardTower, cUnitTypedeTower, -1, 45);
	}
}

//==============================================================================
/* xpBuilder monitor

	Use an idle xpBuilder to build as needed.

*/
//==============================================================================
rule xpBuilderMonitor
inactive
group tcComplete
minInterval 20
{
	if (cMyCiv != cCivXPIroquois)
	{
		xsDisableSelf();
		return;
	}

	static int activePlan = -1;

	if (activePlan != -1)   // We already have something active?
	{
		if ((aiPlanGetState(activePlan) < 0) || (aiPlanGetState(activePlan) == cPlanStateNone))
		{
			aiPlanDestroy(activePlan);
			activePlan = -1;  // Plan is bad, but didn't die.  It's dead now, so continue below.
		}
		else
		{
			return;  // Something is active, let it run.
		}
	}

	// If we get this far, there is no active plan.  See if we have a xpBuilder to use.
	int xpBuilderID = -1;
	int buildingToMake = -1;
	int buildertype = -1;
	if (kbUnitCount(cMyID, cUnitTypexpBuilderStart, cUnitStateAlive) > 0)
	{
		xpBuilderID = getUnit(cUnitTypexpBuilderStart);
		buildingToMake = gHouseUnit;  // If all else fails, make a house since we can't make warhuts.
		buildertype = cUnitTypexpBuilderStart;
	}
	else
	{
		xpBuilderID = getUnit(cUnitTypexpBuilder);
		buildingToMake = cUnitTypeWarHut;  // If all else fails, make a war hut.
		buildertype = cUnitTypexpBuilder;
	}
	if (xpBuilderID < 0)
		return;

	// We have a xpBuilder, and no plan to use it.  Find something to do with it.  
	// Simple logic.  Farm if less than 3.  War hut if less than 2.  Corral if < 2.  House if below pop limit.
	// One override....avoid farms in age 1, they're too slow.
	if (kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) < 2 && (kbGetAge() > cAge1) && (buildertype == cUnitTypexpBuilder))
		buildingToMake = cUnitTypeWarHut;
	else if (kbUnitCount(cMyID, cUnitTypeCorral, cUnitStateABQ) < 2 && (kbGetAge() > cAge1))
		buildingToMake = cUnitTypeCorral;
	else if (kbGetBuildLimit(cMyID, gHouseUnit) <= kbUnitCount(cMyID, gHouseUnit, cUnitStateAlive))
		buildingToMake = gHouseUnit;
	
	activePlan = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, buildingToMake);
	if (buildingToMake >= 0 && activePlan < 0)
	{
		activePlan = aiPlanCreate("Use an xpBuilder", cPlanBuild);
		// What to build
		aiPlanSetVariableInt(activePlan, cBuildPlanBuildingTypeID, 0, buildingToMake);

		// 3 meter separation
		aiPlanSetVariableFloat(activePlan, cBuildPlanBuildingBufferSpace, 0, 3.0);
		if (buildingToMake == gFarmUnit)
			aiPlanSetVariableFloat(activePlan, cBuildPlanBuildingBufferSpace, 0, 8.0);

		//Priority.
		aiPlanSetDesiredPriority(activePlan, 95);
		//Mil vs. Econ.
		if ((buildingToMake == cUnitTypeWarHut) || (buildingToMake == cUnitTypeCorral))
		{
			aiPlanSetMilitary(activePlan, true);
			aiPlanSetEconomy(activePlan, false);
		}
		else
		{
			aiPlanSetMilitary(activePlan, false);
			aiPlanSetEconomy(activePlan, true);
		}
		aiPlanSetEscrowID(activePlan, cEconomyEscrowID);

		aiPlanAddUnitType(activePlan, buildertype, 1, 1, 1);

		aiPlanSetBaseID(activePlan, kbBaseGetMainID(cMyID));

		//Go.
		aiPlanSetActive(activePlan);
	}
	else
	{
		aiPlanAddUnitType(activePlan, buildertype, 1, 1, 1);
	}
}

rule strongholdConstructionMonitor
inactive
minInterval 75
{
	if (cMyCiv != cCivDEInca)
	{
		xsDisableSelf();
		return;
	}
	
	if ((cvOkToBuildForts == false) && (cvOkToFortify == false)) // was OR
		return;

	if ((kbUnitCount(cMyID, cUnitTypedeIncaStrongholdTravois, cUnitStateAlive) <= 0) && (aiGetFallenExplorerID() >= 0))
		return; // No builder

	static int strongholdBuildPlanID = -1;
	
	strongholdBuildPlanID = aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypedeIncaStronghold);

	if (kbGetBuildLimit(cMyID, cUnitTypedeIncaStronghold) <= kbUnitCount(cMyID, cUnitTypedeIncaStronghold, cUnitStateAlive))
	{
		if (strongholdBuildPlanID >= 0)
		{
			aiPlanDestroy(strongholdBuildPlanID);
			strongholdBuildPlanID = -1;
		}
		return; // Don't build if we're at limit.
	}

	if (strongholdBuildPlanID < 0)
	{
		debugBuildings("Creating a stronghold build plan.");
		strongholdBuildPlanID=aiPlanCreate("Stronghold build plan ", cPlanBuild);
		aiPlanSetVariableInt(strongholdBuildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypedeIncaStronghold);
		// Priority.
		aiPlanSetDesiredPriority(strongholdBuildPlanID, 91); // higher than explorerControlPlan
		// Mil vs. Econ.
		aiPlanSetMilitary(strongholdBuildPlanID, true);
		aiPlanSetEconomy(strongholdBuildPlanID, false);
		// Escrow.
		aiPlanSetEscrowID(strongholdBuildPlanID, cMilitaryEscrowID);
		// Builders.
		if (kbUnitCount(cMyID, cUnitTypedeIncaStrongholdTravois, cUnitStateAlive) > 0)
			aiPlanAddUnitType(strongholdBuildPlanID, cUnitTypedeIncaStrongholdTravois, 1, 1, 1);
		else if (aiGetFallenExplorerID() == -1)
			aiPlanAddUnitType(strongholdBuildPlanID, cUnitTypedeIncaWarChief, 1, 1, 1);
		else
		{
			aiPlanDestroy(strongholdBuildPlanID);
			strongholdBuildPlanID = -1;
			return;
		}
		vector mainBaseVec = cInvalidVector;
		mainBaseVec = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
		if (mainBaseVec == cInvalidVector)
		{
			aiPlanDestroy(strongholdBuildPlanID);
			strongholdBuildPlanID = -1;
			return;
		}
		aiPlanSetBaseID(strongholdBuildPlanID, kbBaseGetMainID(cMyID));
		aiPlanSetVariableFloat(strongholdBuildPlanID, cBuildPlanBuildingBufferSpace, 0, 4.5);
		aiPlanSetVariableVector(strongholdBuildPlanID, cBuildPlanCenterPosition, 0, mainBaseVec);
		aiPlanSetVariableFloat(strongholdBuildPlanID, cBuildPlanCenterPositionDistance, 0, 40.0);
		aiPlanSetVariableVector(strongholdBuildPlanID, cBuildPlanInfluencePosition, 0, mainBaseVec);    // Influence toward position
		aiPlanSetVariableFloat(strongholdBuildPlanID, cBuildPlanInfluencePositionDistance, 0, 100.0);     // 100m range.
		aiPlanSetVariableFloat(strongholdBuildPlanID, cBuildPlanInfluencePositionValue, 0, 200.0);        // 200 points max
		aiPlanSetVariableInt(strongholdBuildPlanID, cBuildPlanInfluencePositionFalloff, 0, cBPIFalloffLinear);  // Linear slope falloff
		//Go.
		aiPlanSetActive(strongholdBuildPlanID);
	}
}


//==============================================================================
// buildHistoricalMapSocket
//==============================================================================
bool buildHistoricalMapSocket(int socketID = -1, int socketBuildingPUID = -1, int protoUnitCommandID = -1, int resourcePri = 50)
{
	// One plan at a time.
	if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanProtoUnitCommandID, protoUnitCommandID) >= 0)
	{
		return(false);
	}

	// Already built, skipping.
	if (getUnitByLocation(socketBuildingPUID, cPlayerRelationAny, cUnitStateABQ, kbUnitGetPosition(socketID), 10.0) >= 0)
	{
		return(false);
	}

	debugBuildings("Creating "+kbGetUnitTypeName(socketBuildingPUID)+" build plan on socket "+kbGetUnitTypeName(kbUnitGetProtoUnitID(socketID))+".");
	createProtoUnitCommandResearchPlan(protoUnitCommandID, socketID, cEconomyEscrowID, 50, resourcePri);

	return(true);
}

//==============================================================================
// turkishWarDistrictMonitor
//
// Build TPs on district sockets whenever possible.
//==============================================================================
rule turkishWarDistrictMonitor
active
minInterval 30
{
	if (cRandomMapName != "eugreatturkishwar")
	{
		xsDisableSelf();
		return;
	}

	static int socketPUIDs = -1;

	if (socketPUIDs < 0)
	{
		socketPUIDs = xsArrayCreateInt(4, -1, "Turkish War Sockets");
		xsArraySetInt(socketPUIDs, 0, cUnitTypedeSPCSocketMilitaryDistrict);
		xsArraySetInt(socketPUIDs, 1, cUnitTypedeSPCSocketMarketDistrict);
		xsArraySetInt(socketPUIDs, 2, cUnitTypedeSPCSocketArtilleryDistrict);
		xsArraySetInt(socketPUIDs, 3, cUnitTypedeSPCSocketReligiousDistrict);
	}

	// If we are at trading post limit, return.
	if (kbUnitCount(cMyID, cUnitTypeTradingPost, cUnitStateABQ) >= kbGetBuildLimit(cMyID, cUnitTypeTradingPost))
	{
		return;
	}

	for (i = 0; i < 4; i++)
	{
		int socketID = getUnit(xsArrayGetInt(socketPUIDs, i), cMyID, cUnitStateAny);

		if (socketID < 0)
		{
			continue;
		}

		if (buildHistoricalMapSocket(socketID, cUnitTypeTradingPost, cProtoUnitCommanddeSocketBuildDistrict, 55) == true)
		{
			break;
		}
	}
}

//==============================================================================
// cityStateMonitor
//
// Build TPs and towers in city states whenever possible.
//==============================================================================
rule cityStateMonitor
active
minInterval 30
{
	if (cRandomMapName != "euitalianwars")
	{
		xsDisableSelf();
		return;
	}

	int cityStateQuery = createSimpleUnitQuery(cUnitTypedeSPCSocketCityState, cMyID, cUnitStateAny);
	int numCityStates = kbUnitQueryExecute(cityStateQuery);

	// Build city state TPs.
	for (i = 0; i < numCityStates; i++)
	{
		int cityStateSocketID = kbUnitQueryGetResult(cityStateQuery, i);
		if (buildHistoricalMapSocket(cityStateSocketID, cUnitTypeTradingPost, cProtoUnitCommanddeSocketBuild, 55) == true)
		{
			return;
		}
	}

	// Build city state towers.
	if (numCityStates > 0)
	{
		int cityTowerQuery = createSimpleUnitQuery(cUnitTypedeSPCSocketCityTower, cMyID, cUnitStateAny);
		int numCityTowers = kbUnitQueryExecute(cityTowerQuery);

		for (i = 0; i < numCityTowers; i++)
		{
			int cityTowerSocketID = kbUnitQueryGetResult(cityTowerQuery, i);
			if (buildHistoricalMapSocket(cityTowerSocketID, cUnitTypedeSPCCityTower, cProtoUnitCommanddeSocketBuildCityTower, 50) == true)
			{
				return;
			}
		}
	}
}