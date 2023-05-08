//==============================================================================
/* aiTechs.xs

	This file contains stuff for managing techs including age upgrades.

*/
//==============================================================================

//==============================================================================
// ageUpgradeMonitor
//==============================================================================
rule ageUpgradeMonitor
inactive
group tcComplete
minInterval 10
{
	int politician = -1;
	int desResPriority = -1;

	if (kbGetAge() >= cAge5)
	{
		xsDisableSelf();
		return;
	}
	
	// Quit if we already have a plan in the works
	if (gAgeUpResearchPlan >= 0)
	{
		if (aiPlanGetState(gAgeUpResearchPlan) >= 0)
		{
			if (civIsAsian() == false)
			{
				politician = arrayGetInt(gAgeUpList, kbGetAge());
				//echoMessage("Aging up with: " + kbGetTechName(politician));
				if (politician >= 0)
					aiPlanSetVariableInt(gAgeUpResearchPlan, cResearchPlanTechID, 0, politician);
			}
			else
			{
				politician = arrayGetInt(gAgeUpList, kbGetAge());
				if (politician >= 0)
					aiPlanSetVariableInt(gAgeUpResearchPlan, cBuildPlanBuildingTypeID, 0, politician);
			}
			aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 51);
			if (aiGetWorldDifficulty() >= cDifficultyHard)
			{
				switch (kbGetAge())
				{
					case cAge1:
					{
						// Above houses, unless nearly housed. 
						aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 70);
						if (xsGetTime() >= 3.75*60*1000)
						{
							// Above settler priority.
							aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 76);
						}
						break;
					}
					case cAge2:
					{
						if (gMyStrategy == cStrategyTreaty)
							aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 70); // Above houses, unless nearly housed. Below first military buildings.

						if (xsGetTime() >= 12*60*1000)
						{
							desResPriority = aiPlanGetDesiredResourcePriority(gAgeUpResearchPlan);
							aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, desResPriority + 10);
						}
						break;
					}
					case cAge3:
					{
						if (gMyStrategy == cStrategyTreaty)
							aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 70); // We want generally faster age-ups.
						if (xsGetTime() >= 22*60*1000)
						{
							desResPriority = aiPlanGetDesiredResourcePriority(gAgeUpResearchPlan);
							aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, desResPriority + 10);
						}
						break;
					}
					case cAge4:
					{
						if (gMyStrategy == cStrategyTreaty)
							aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 70); // We want generally faster age-ups.
						if (xsGetTime() >= 32*60*1000)
						{
							desResPriority = aiPlanGetDesiredResourcePriority(gAgeUpResearchPlan);
							aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, desResPriority + 10);
						}
						break;
					}
				}
			}
			aiPlanSetEventHandler(gAgeUpResearchPlan, cPlanEventStateChange, "ageUpEventHandler");
			return;
		}
		else 
		{	// Plan variable is set, but plan is dead.
			aiPlanDestroy(gAgeUpResearchPlan);
			gAgeUpResearchPlan = -1;
			// OK to continue, as we don't have an active plan
		}
	}

	if (civIsAsian() == false)
	{
		politician = arrayGetInt(gAgeUpList, kbGetAge());
		if ((kbTechGetStatus(politician) == cTechStatusObtainable) && (gAgeUpResearchPlan < 0))
		{
			// We search for buildings with AgeUpBuilding abstract type which includes the command post in historical maps.
			gAgeUpResearchPlan = createResearchPlan(politician, cUnitTypeAgeUpBuilding, 99);
			aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 51);
			aiPlanSetEventHandler(gAgeUpResearchPlan, cPlanEventStateChange, "ageUpEventHandler");
			return;
		}
	}
	else
	{
		politician = arrayGetInt(gAgeUpList, kbGetAge());	// Get the specified wonder
		vector wonderLocation = gHomeBase + gDirection_DOWN * 20;
		if ((politician == cUnitTypeypWIAgraFort2) || 
			(politician == cUnitTypeypWIAgraFort3) || 
			(politician == cUnitTypeypWIAgraFort4) || 
			(politician == cUnitTypeypWIAgraFort5))
		{
			if (gMyStrategy == cStrategyTreaty)
				wonderLocation = gHomeBase + gDirection_UP * 30;
			else
				wonderLocation = gHomeBase + gDirection_UP * 15;
		}
		else if ((politician == cUnitTypeypWIKarniMata2) || 
			(politician == cUnitTypeypWIKarniMata3) || 
			(politician == cUnitTypeypWIKarniMata4) || 
			(politician == cUnitTypeypWIKarniMata5))
		{
			wonderLocation = gHomeBase + gDirection_DOWN * 40;
		}
		if (gAgeUpResearchPlan < 0)
		{
			gAgeUpResearchPlan = createBuildPlan(politician, 1, 100, wonderLocation, 4);
			aiPlanSetDesiredResourcePriority(gAgeUpResearchPlan, 51);
			aiPlanSetEventHandler(gAgeUpResearchPlan, cPlanEventStateChange, "ageUpEventHandler");
			return;
		}
	}
}

//==============================================================================
//
// Economic Upgrade Monitors
//
//==============================================================================
rule marketUpgradeMonitor
inactive
minInterval 45
{
	int techID = -1;
	int ageReq = -1;
	int planID = -1;
	int planPriority = 50;

	// Americans can get Market Techs for free via cTechDEHCHamiltonianEconomics, which MUST be in the
	// deck for Americans to research Market Techs, so be careful if you change that.
	if (cMyCiv == cCivDEAmericans && kbTechGetStatus(cTechDEHCHamiltonianEconomics) != cTechStatusActive)
		return;

	// Do not start researching market upgrades prematurely once we have reach Age 2.
	// If we do not have a barracks unit then we need to get that ASAP if this is a
	// standard or <=20 min Treaty game. However, if we are Age 1 or aging up to Age 2,
	// (and greater than Age 2) Then this check is bypassed. It is fine to research the
	// basic techs then.
	if (cMyCiv != cCivDEAmericans && gMyStrategy != cStrategyTreaty &&
		kbGetAge() == cAge2 && kbUnitCount(cMyID, gBarracksUnit, cUnitStateABQ) == 0)
		return;

	for (i = 0; < arrayGetSize(gMarketTechs))
	{
		techID = arrayGetInt(gMarketTechs, i);
		ageReq = arrayGetInt(gMarketTechsAgeReq, i);
		if (arrayGetInt(gMarketTechsPrio, i) >= 0)
			planPriority = arrayGetInt(gMarketTechsPrio, i);

		if (kbTechGetStatus(techID) == cTechStatusObtainable &&
			aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID) < 0)
		{
			if (getAgingUpAge() >= ageReq)
			{
				planID = createResearchPlan(techID, gMarketUnit, planPriority);
				aiPlanSetDesiredResourcePriority(planID, planPriority);
			}
		}
	}

	for (i = 0; < arrayGetSize(gMarketTechs))
	{
		techID = arrayGetInt(gMarketTechs, i);
		if (kbTechGetStatus(techID) != cTechStatusActive)
			return;
	}

	xsDisableSelf();
}

rule granaryUpgradeMonitor
inactive
minInterval 45
{
	int techID = -1;
	int ageReq = -1;
	int planID = -1;
	int planPriority = 60;

	for (i = 0; < arrayGetSize(gGranaryTechs))
	{
		techID = arrayGetInt(gGranaryTechs, i);
		ageReq = arrayGetInt(gGranaryTechsAgeReq, i);
		if (kbTechGetStatus(techID) == cTechStatusObtainable &&
			aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID) < 0)
		{
			if (getAgingUpAge() >= ageReq) // E.G. we are not aging up.
			{
				if (techID == cTechDEAfricanVillagerHunting1 || techID == cTechDEAfricanVillagerHunting2)
				{
					planID = createResearchPlan(techID, cUnitTypedeGranary, planPriority);
					aiPlanSetDesiredResourcePriority(planID, planPriority);
				}
				else if (kbUnitCount(cMyID, cUnitTypedeField, cUnitStateAlive) > 0)
				{
					planID = createResearchPlan(techID, cUnitTypedeGranary, planPriority);
					aiPlanSetDesiredResourcePriority(planID, planPriority);
				}
			}
		}
	}

	for (i = 0; < arrayGetSize(gGranaryTechs))
	{
		techID = arrayGetInt(gGranaryTechs, i);
		if (kbTechGetStatus(techID) != cTechStatusActive)
			return;
	}

	xsDisableSelf();
}

rule millTypeUpgradeMonitor
inactive
minInterval 45
{
	int techID = -1;
	int ageReq = -1;
	int planID = -1;
	int planPriority = 60;

	// Mexicans can get Hacienda Techs for free via cTechDEHCFedMXElBajio, which MUST be in the
	// deck for Mexicans to research Hacienda Techs, so be careful if you change that.
	if (cMyCiv == cCivDEMexicans && kbTechGetStatus(cTechDEHCFedMXElBajio) != cTechStatusActive)
		return;

	for (i = 0; < arrayGetSize(gMillTechs))
	{
		techID = arrayGetInt(gMillTechs, i);
		ageReq = arrayGetInt(gMillTechsAgeReq, i);
		if (kbTechGetStatus(techID) == cTechStatusObtainable &&
			aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID) < 0)
		{
			if (kbGetAge() >= ageReq)
			{
				planID = createResearchPlan(techID, gFarmUnit, planPriority);
				aiPlanSetDesiredResourcePriority(planID, planPriority);
			}
		}
	}

	for (i = 0; < arrayGetSize(gMillTechs))
	{
		techID = arrayGetInt(gMillTechs, i);
		if (kbTechGetStatus(techID) != cTechStatusActive)
			return;
	}

	xsDisableSelf();
}

rule plantationTypeUpgradeMonitor
inactive
minInterval 45
{
	int techID = -1;
	int ageReq = -1;
	int planID = -1;
	int planPriority = 60;

	for (i = 0; < arrayGetSize(gPlantationTechs))
	{
		techID = arrayGetInt(gPlantationTechs, i);
		ageReq = arrayGetInt(gPlantationTechsAgeReq, i);
		if (kbTechGetStatus(techID) == cTechStatusObtainable &&
			aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID) < 0)
		{
			if (kbGetAge() >= ageReq)
			{
				planID = createResearchPlan(techID, gPlantationUnit, planPriority);
				aiPlanSetDesiredResourcePriority(planID, planPriority);
			}
		}
	}

	for (i = 0; < arrayGetSize(gPlantationTechs))
	{
		techID = arrayGetInt(gPlantationTechs, i);
		if (kbTechGetStatus(techID) != cTechStatusActive)
			return;
	}

	xsDisableSelf();
}

rule mosqueUpgradeMonitor
inactive
minInterval 30
{
	int techID = -1;
	int ageReq = -1;
	int planID = -1;
	int planPriority = 55;

	for (i = 0; < arrayGetSize(gMosqueTechs))
	{
		techID = arrayGetInt(gMosqueTechs, i);
		ageReq = arrayGetInt(gMosqueTechsAgeReq, i);
		if (kbTechGetStatus(techID) == cTechStatusObtainable &&
			aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID) < 0)
		{
			if (kbGetAge() >= ageReq)
			{
				planID = createResearchPlan(techID, cUnitTypeChurch, planPriority);
				aiPlanSetDesiredResourcePriority(planID, planPriority);
			}
		}
	}

	for (i = 0; < arrayGetSize(gMosqueTechs))
	{
		techID = arrayGetInt(gMosqueTechs, i);
		if (kbTechGetStatus(techID) != cTechStatusActive)
			return;
	}

	xsDisableSelf();
}

rule allegianceUpgradeMonitor
inactive
minInterval 30
{
	int techID = -1;
	int ageReq = -1;
	int planID = -1;
	int planPriority = 50;
	static int buildingTypeID = -1;
	if (buildingTypeID < 0)
	{
		if (cMyCiv == cCivDEEthiopians)
			buildingTypeID = cUnitTypedeMountainMonastery;
		else if (cMyCiv == cCivDEHausa)
			buildingTypeID = cUnitTypedeUniversity;
	}

	for (i = 0; < arrayGetSize(gAllegianceTechs))
	{
		techID = arrayGetInt(gAllegianceTechs, i);
		ageReq = arrayGetInt(gAllegianceTechsAgeReq, i);
		if (arrayGetInt(gAllegianceTechsPrio, i) > 0) // We want a specifically set priority determined in aiInit.xs.
			planPriority = arrayGetInt(gAllegianceTechsPrio, i);
		if (kbTechGetStatus(techID) == cTechStatusObtainable &&
			aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID) < 0)
		{
			if (kbGetAge() >= ageReq)
			{
				planID = createResearchPlan(techID, buildingTypeID, planPriority);
				aiPlanSetDesiredResourcePriority(planID, planPriority);
			}
		}
	}

	if (kbGetAge() < cvMaxAge)
		return;

	for (i = 0; < arrayGetSize(gAllegianceTechs))
	{
		techID = arrayGetInt(gAllegianceTechs, i);
		// Not all techs will be active since we can only choose up to 5 Alliances.
		// So while one is obtainable, keep checking for upgrades.
		if (kbTechGetStatus(techID) == cTechStatusObtainable)
			return;
	}

	xsDisableSelf();
}

/* void SufiShariaEventHandler(int planID = -1)
{
	if (aiPlanGetState(planID) == -1)
	{
		if (kbTechGetStatus(cTechYPNatSufiSharia) == cTechStatusActive)
		{
			int settlerIncrease = gEconUnit == cUnitTypeCoureur ? 8 : 10;
			for (i = cAge1; <= cAge5)
			{
				xsArraySetInt(gTargetSettlerCounts, i, xsArrayGetInt(gTargetSettlerCounts, i) + settlerIncrease);
				xsArraySetInt(gTargetSettlerCountsBTDefault, i, xsArrayGetInt(gTargetSettlerCountsBTDefault, i) + settlerIncrease);
			}
			updateSettlersAndPopManager();
		}
	}
} */


// We have enough monitors to handle 3 different native tribes on a map.
// These rules repeatedly call the lambda to research the associated upgrades.
//==============================================================================
rule nativeTribeUpgradeMonitor1
inactive
minInterval 60
{
	debugTechs(
		"RUNNING Rule: 'nativeTribeUpgradeMonitor1' which is connected to gNativeTribeCiv1: " + kbGetCivName(gNativeTribeCiv1));
	int tradingPostID = checkAliveSuitableTradingPost(gNativeTribeCiv1);
	if (tradingPostID == -1)
	{
		return;
	}
	if (gNativeTribeResearchTechs1(tradingPostID) == true)
	{
		debugTechs("DISABLING Rule: 'nativeTribeUpgradeMonitor1'");
		xsDisableSelf();
	}
}

rule nativeTribeUpgradeMonitor2
inactive
minInterval 60
{
	debugTechs(
		"RUNNING Rule: 'nativeTribeUpgradeMonitor2' which is connected to gNativeTribeCiv2: " + kbGetCivName(gNativeTribeCiv2));
	int tradingPostID = checkAliveSuitableTradingPost(gNativeTribeCiv2);
	if (tradingPostID == -1)
	{
		return;
	}
	if (gNativeTribeResearchTechs2(tradingPostID) == true)
	{
		debugTechs("DISABLING Rule: 'nativeTribeUpgradeMonitor2'");
		xsDisableSelf();
	}
}

rule nativeTribeUpgradeMonitor3
inactive
minInterval 60
{
	debugTechs(
		"RUNNING Rule: 'nativeTribeUpgradeMonitor3' which is connected to gNativeTribeCiv3: " + kbGetCivName(gNativeTribeCiv3));
	int tradingPostID = checkAliveSuitableTradingPost(gNativeTribeCiv3);
	if (tradingPostID == -1)
	{
		return;
	}
	if (gNativeTribeResearchTechs3(tradingPostID) == true)
	{
		debugTechs("DISABLING Rule: 'nativeTribeUpgradeMonitor3'");
		xsDisableSelf();
	}
}

//==============================================================================
// setupNativeUpgrades
// Scan the map for minor native sockets and assign/activate the appropriate upgrade lambdas for them.
//==============================================================================
void setupNativeUpgrades()
{
	debugTechs("RUNNING func: 'setupNativeUpgrades'");
	bool(int) tempLambdaStorage = nativeResearchTechsEmpty; // We need to store the lambda somewhere don't we!
	int nativeSocketType = -1;                              // Here we save the ID of the socket we found in the query.
	int amountOfUniqueNatives = 0; // We use this as a counter to determine what function pointer to assign the lambda to.
	int nativeCivFound = -1; // Every iteration we find a native socket and we assign the civ constant it belongs to to this
								// variable. If it's not a duplicate we copy this to one of the gNativeTribeCiv variables.
	xsSetContextPlayer(0);
	int queryID = createSimpleGaiaUnitQuery(cUnitTypeNativeSocket);
	int numberResults = kbUnitQueryExecute(queryID);
	xsSetContextPlayer(cMyID);
	debugTechs("We found this many native sockets on the map: " + numberResults);
	xsSetContextPlayer(0);

	for (i = 0; < numberResults)
	{
		nativeSocketType = kbUnitGetProtoUnitID(kbUnitQueryGetResult(queryID, i)); // Get the proto constant of the socket.
		switch (nativeSocketType)
		{
		// Vanilla minor natives.
		case cUnitTypeSocketCaribs:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeCaribsUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatKasiriBeer,
					[]() -> bool {
					return (
						kbUnitCount(cMyID, cUnitTypeAbstractArcher, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractHandInfantry, cUnitStateABQ) >=
						12);
					},
					-1,
					tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatGarifunaDrums,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractArcher, cUnitStateABQ) >= 12); },
									-1,
									tradingPostID);

				// This upgrade is locked behind all the line upgrades for the Carib Blowgun Warriors.
				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatCeremonialFeast,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeNatBlowgunWarrior, cUnitStateABQ) >= 12); },
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeCaribsUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivCaribs;
			break;
		}
		case cUnitTypeSocketCherokee:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeCherokeeUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTech(cTechNatBasketweaving, -1, tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeCherokeeUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivCherokee;
			break;
		}
		case cUnitTypeSocketComanche:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeComancheUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTech(cTechNatTradeLanguage, -1, tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatHorseBreeding,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) >= 12); },
									-1,
									tradingPostID);

				canDisableSelf &= 
								(researchSimpleTechByCondition(
									cTechNatMustangs,
									[]() -> bool {
									return (kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) >= 12);
									},
									-1,
									tradingPostID));

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeComancheUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivComanche;
			break;
		}
		case cUnitTypeSocketCree:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeCreeUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatTanning,
					[]() -> bool {
					return (
						kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractLightInfantry, cUnitStateABQ) >=
						12);
					},
					-1,
					tradingPostID);

				canDisableSelf &=  researchSimpleTech(cTechNatTextileCraftsmanship, -1, tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeCreeUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivCree;
			break;
		}
		case cUnitTypeSocketMaya:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeMayaUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTech(cTechNatCalendar, -1, tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatCottonArmor,
									[]() -> bool {
										return (kbUnitCount(cMyID, cUnitTypeAbstractHandInfantry, cUnitStateABQ) >= 12);
									},
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeMayaUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivMaya;
			break;
		}
		case cUnitTypeSocketNootka:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeNootkaUpgradeMonitor'");

				bool canDisableSelf = (researchSimpleTechByCondition(
										cTechNatBarkClothing,
										[]() -> bool {
											return (kbGetAge() >= cAge3);
										},
										-1,
										tradingPostID));

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeNootkaUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivNootka;
			break;
		}
		case cUnitTypeSocketSeminole:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeSeminoleUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatBowyery,
					[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractArcher, cUnitStateABQ) >= 12); },
					-1,
					tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeSeminoleUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivSeminoles;
			break;
		}
		case cUnitTypeSocketTupi:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeTupiUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTech(cTechNatForestBurning, -1, tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatPoisonArrowFrogs,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractArcher, cUnitStateABQ) >= 12); },
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeTupiUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivTupi;
			break;
		}
		// The War Chiefs minor natives.
		case cUnitTypeSocketApache:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeApacheUpgradeMonitor'");

				bool canDisableSelf = (researchSimpleTechByCondition(
										cTechNatXPApacheCactus,
										[]() -> bool {
											return (kbGetAge() >= cAge3);
										},
										-1,
										tradingPostID));

				canDisableSelf &= researchSimpleTechByCondition(cTechNatXPApacheEndurance,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateABQ) >= 20); },
									-1, tradingPostID);

				if (canDisableSelf == true)
				{
					debugTechs("DISABLING Lambda: 'minorNativeApacheUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivApache;
			break;
		}
		case cUnitTypeSocketHuron:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeHuronUpgradeMonitor'");

				// Get after 30 minutes have passed.
				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatXPHuronTradeMonopoly, []() -> bool { return (xsGetTime() >= 30 * 60 * 1000); }, -1, tradingPostID);

				canDisableSelf &= 
								((researchSimpleTechByCondition(
									cTechNatXPHuronFishWedding,
									[]() -> bool {
										return (kbUnitCount(cMyID, cUnitTypeAbstractFishingBoat, cUnitStateABQ) >= 5);
									},
									-1,
									tradingPostID)) ||
								(gGoodFishingMap == false));

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeHuronUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivHuron;
			break;
		}
		case cUnitTypeSocketCheyenne:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeCheyenneUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatXPCheyenneHorseTrading,
					[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) >= 15); },
					-1,
					tradingPostID);

				canDisableSelf =
					canDisableSelf &&
					((researchSimpleTechByCondition(
						cTechNatXPCheyenneHuntingGrounds, []() -> bool { return (gTimeToFarm == false); }, -1, tradingPostID)) ||
					(gTimeToFarm == true)); // Only get this when we're not yet farming.

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeCheyenneUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivCheyenne;
			break;
		}
		case cUnitTypeSocketKlamath:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeKlamathUpgradeMonitor'");

				// Get after 30 minutes have passed.
				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatXPKlamathHuckleberryFeast, []() -> bool { return (xsGetTime() >= 30 * 60 * 100); }, -1, tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatXPKlamathWorkEthos,
									researchSimpleTechShouldCreate,
									-1,
									tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatXPKlamathStrategy,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeNatKlamathRifleman, cUnitStateABQ) >= 8); },
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeKlamathUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivKlamath;
			break;
		}
		case cUnitTypeSocketMapuche:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeMapucheUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatXPMapucheTactics,
					[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractHandInfantry, cUnitStateABQ) >= 12); },
					-1,
					tradingPostID);

				// Get after 30 minutes have passed.
				canDisableSelf &=  researchSimpleTechByCondition(
													cTechNatXPMapucheTreatyOfQuillin,
													[]() -> bool { return (xsGetTime() >= 30 * 60 * 100); },
													-1,
													tradingPostID);

				// Only get it relatively late in the game, aka when we have 60% of our maxPop.
				canDisableSelf &=  researchSimpleTechByCondition(
													cTechNatXPMapucheAdMapu,
													[]() -> bool { return (kbGetPop() >= gMaxPop * 0.6); },
													-1,
													tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeMapucheUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivMapuche;
			break;
		}
		case cUnitTypeSocketNavajo:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeNavajoUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatXPNavajoWeaving,
					[]() -> bool {
					return (
						kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractLightInfantry, cUnitStateABQ) >=
						12);
					},
					-1,
					tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatXPNavajoCraftsmanship,
									researchSimpleTechShouldCreate,
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeNavajoUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivNavajo;
			break;
		}
		case cUnitTypeSocketZapotec:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeZapotecUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechNatXPZapotecCultOfTheDead,
					[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractHandInfantry, cUnitStateABQ) >= 12); },
					-1,
					tradingPostID);

				// Get after 30 minutes have passed.
				canDisableSelf &=  researchSimpleTechByCondition(
													cTechNatXPZapotecCloudPeople,
													[]() -> bool { return (xsGetTime() >= 30 * 60 * 100); },
													-1,
													tradingPostID);

				// Only get this when we're either farming or on Plantations.
				canDisableSelf &=  researchSimpleTechByCondition(
													cTechNatXPZapotecFoodOfTheGods,
													[]() -> bool { return ((gTimeToFarm || gTimeForPlantations)); },
													-1,
													tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeZapotecUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivZapotec;
			break;
		}
		// The Asian Dynasties minor natives.
		case cUnitTypeypSocketBhakti:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeBhaktiUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechYPNatBhaktiYoga,
					[]() -> bool {
					return (
						kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractLightInfantry, cUnitStateABQ) >=
						12);
					},
					-1,
					tradingPostID);

				canDisableSelf &=  researchSimpleTechByCondition(
													cTechYPNatBhaktiReinforcedGuantlets,
													[]() -> bool {
														return (
															kbUnitCount(cMyID, cUnitTypeypNatTigerClaw, cUnitStateABQ) +
																kbUnitCount(cMyID, cUnitTypeypNatMercTigerClaw, cUnitStateABQ) >=
															12);
													},
													-1,
													tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeBhaktiUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivBhakti;
			break;
		}
		case cUnitTypeypSocketJesuit:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeJesuitUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechYPNatJesuitSmokelessPowder,
					[]() -> bool {
					return (
						kbUnitCount(cMyID, cUnitTypeAbstractGunpowderTrooper, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractGunpowderCavalry, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeAbstractArtillery, cUnitStateABQ) >=
						15);
					},
					-1,
					tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechYPNatJesuitFlyingButtress,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeBuilding, cUnitStateABQ) >= 15); },
									-1,
									tradingPostID);

				canDisableSelf &=  researchSimpleTech(cTechYPNatJesuitSchools, -1, tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeJesuitUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivJesuit;
			break;
		}
		case cUnitTypeypSocketShaolin:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeShaolinUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechYPNatShaolinClenchedFist,
					[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractRangedInfantry, cUnitStateABQ) >= 20); },
					-1,
					tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechYPNatShaolinWoodClearing,
									researchSimpleTechShouldCreate,
									-1,
									tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechYPNatShaolinDimMak,
									[]() -> bool {
										return (
											kbUnitCount(cMyID, cUnitTypeypNatRattanShield, cUnitStateABQ) +
												kbUnitCount(cMyID, cUnitTypeypNatMercRattanShield, cUnitStateABQ) >=
											12);
									},
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeShaolinUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivShaolin;
			break;
		}
		case cUnitTypeypSocketSufi: // TODO (James): Probably will rework trade route upgrades anyway, but Sufi seems to deal with settlers.
		{
			/* tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeSufiUpgradeMonitor'");

				// Get after 30 minutes have passed.
				bool canDisableSelf = researchSimpleTechByCondition(
					cTechYPNatSufiPilgramage, []() -> bool { return (xsGetTime() >= 30 * 60 * 100); }, -1, tradingPostID);

				int techStatus = kbTechGetStatus(cTechYPNatSufiSharia);

				if ((techStatus == cTechStatusActive) || (cDifficultyCurrent < cDifficultyHard))
				{
					// canDisableSelf &=  true;
					debugTechs("DISABLING Lambda: 'minorNativeSufiUpgradeMonitor' because we have all the upgrades");
				}
				else if (techStatus == cTechStatusUnobtainable)
				{
					canDisableSelf = false;
				}
				else // Obtainable
				{
					if (kbGetAge() >= cAge3 && (cvMaxCivPop == -1) &&
						((gRevolutionType & cRevolutionMilitary) ==
							0)) // We only get this upgrade on difficulties where we max out our Villagers.
								// And don't get it when we have a cvMaxCivPop set since that can mess with what the designer intended.
								// And don't get it when we're a military revolt, don't disable the rule though we may re-enable
								// Settlers.
					{
						int settlerShortfall = getSettlerShortfall();
						int planID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechYPNatSufiSharia);
						if (planID < 0)
						{
							if (settlerShortfall < 10) // We're approaching our maximum Villagers so we can get this upgrade.
							{
								planID = createSimpleResearchPlanSpecificBuilding(cTechYPNatSufiSharia, tradingPostID);
								aiPlanSetEventHandler(planID, cPlanEventStateChange, "SufiShariaEventHandler");
							}
						}
						else if (settlerShortfall > 10) // We've lost Villagers again, first rebuild them then try this upgrade again.
						{
							aiPlanDestroy(planID);
						}
					}
					canDisableSelf = false;
				}

				return (canDisableSelf);
			};
			nativeCivFound = cCivSufi; */
			break;
		}
		case cUnitTypeypSocketUdasi:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeUdasiUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechYPNatUdasiArmyOfThePure,
					[]() -> bool {
					return (
						kbUnitCount(cMyID, cUnitTypeypNatChakram, cUnitStateABQ) +
							kbUnitCount(cMyID, cUnitTypeypNatMercChakram, cUnitStateABQ) >=
						10);
					},
					-1,
					tradingPostID);

				// Only get this when we're either farming or on Plantations.
				canDisableSelf &=  researchSimpleTechByCondition(
													cTechYPNatUdasiNewYear,
													[]() -> bool { return ((gTimeToFarm || gTimeForPlantations)); },
													-1,
													tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeUdasiUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivUdasi;
			break;
		}
		case cUnitTypeypSocketZen:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeZenUpgradeMonitor'");

				bool canDisableSelf = researchSimpleTechByCondition(
					cTechYPNatZenMasterLessons,
					[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractHandInfantry, cUnitStateABQ) >= 12); },
					-1,
					tradingPostID);

				// Have at least some units before we want to reduce their upgrade costs.
				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechYPNatZenMeritocracy,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeUnit, cUnitStateABQ) >= 20); },
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeZenUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivZen;
			break;
		}
		// The African Royals minor natives.
		case cUnitTypedeSocketAkan:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeAkanUpgradeMonitor'");

				bool canDisableSelf =
					(researchSimpleTechByCondition(
						cTechDENatAkanHeroSpawn, []() -> bool { return (kbGetAge() >= cAge3); }, -1, tradingPostID)) ||
					(cvMaxAge < cAge3);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechDENatAkanDrums,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateABQ) >= 20); },
									-1,
									tradingPostID);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechDENatAkanGoldEconomy,
									researchSimpleTechShouldCreate,
									-1,
									tradingPostID);

				// Only get this when we're either farming or on Plantations.
				canDisableSelf &=  researchSimpleTechByCondition(
													cTechDENatAkanCocoaBeans,
													[]() -> bool { return ((gTimeToFarm || gTimeForPlantations)); },
													-1,
													tradingPostID);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeAkanUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivAkan;
			break;
		}
		case cUnitTypedeSocketBerbers:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeBerbersUpgradeMonitor'");

				bool canDisableSelf =
					(researchSimpleTechByCondition(
						cTechDENatBerberDynasties, []() -> bool { return (kbGetAge() >= cAge3); }, -1, tradingPostID)) ||
					(cvMaxAge < cAge3);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechDENatBerberDesertKings,
									[]() -> bool { return (kbGetAge() >= cAge3); },
									-1,
									tradingPostID);

				canDisableSelf =
					canDisableSelf &&
					((researchSimpleTechByCondition(
						cTechDENatBerberSaltCaravans, []() -> bool { return (kbGetAge() >= cAge3); }, -1, tradingPostID)) ||
					(cvMaxAge < cAge3));

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeBerbersUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivBerbers;
			break;
		}
		case cUnitTypedeSocketSomali:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeSomaliUpgradeMonitor'");

				// Expect we start farming/plantations somewhere in age 3.
				bool canDisableSelf =
					(researchSimpleTechByCondition(
						cTechDENatSudaneseHakura, []() -> bool { return (kbGetAge() >= cAge3); }, -1, tradingPostID) ||
					(cvMaxAge < cAge3));

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechDENatSomaliCoinage,
									researchSimpleTechShouldCreate,
									-1,
									tradingPostID);

				canDisableSelf &= 
								(researchSimpleTechByCondition(
									cTechDENatSomaliOryxShields,
									[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateABQ) >= 15); },
									-1,
									tradingPostID));

				canDisableSelf &= 
								(researchSimpleTechByCondition(
									cTechDENatSomaliJileDaggers,
									[]() -> bool {
										return (
											kbUnitCount(cMyID, cUnitTypeAbstractFootArcher, cUnitStateABQ) +
												kbUnitCount(cMyID, cUnitTypeAbstractRifleman, cUnitStateABQ) +
												kbUnitCount(cMyID, cUnitTypeAbstractMeleeSkirmisher, cUnitStateABQ) +
												kbUnitCount(cMyID, cUnitTypeAbstractUrumi, cUnitStateABQ) >=
											20);
									},
									-1,
									tradingPostID));

				// We as the AI can't really use the information we gain via the Lightouse effect so get it for our human friends.
				canDisableSelf &= 
								(researchSimpleTechByCondition(
									cTechDENatSomaliLighthouses,
									[]() -> bool { return ((kbGetAge() >= cAge4) && (getHumanAllyCount() >= 1)); },
									-1,
									tradingPostID) ||
								(getHumanAllyCount() == 0) || (cvMaxAge < cAge4));

				if ((canDisableSelf == true))
				{
				debugTechs("DISABLING Lambda: 'minorNativeSomaliUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivSomali;
			break;
		}
		case cUnitTypedeSocketSudanese:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeSudaneseUpgradeMonitor'");

				// Expect we start farming/plantations somewhere in age 3 so get the price reduction then.
				bool canDisableSelf = researchSimpleTechByCondition(
										cTechDENatSudaneseHakura,
										[]() -> bool { return (kbGetAge() >= cAge3); },
										-1,
										tradingPostID) ||
									(cvMaxAge < cAge3);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechDENatSudaneseQuiltedArmor,
									[]() -> bool {
										return (
											kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) +
												kbUnitCount(cMyID, cUnitTypeAbstractLightInfantry, cUnitStateABQ) >=
											10);
									},
									-1,
									tradingPostID);

				canDisableSelf =
					canDisableSelf &&
					((researchSimpleTechByCondition(
						cTechDENatSudaneseRedSeaTrade, []() -> bool { return (kbGetAge() >= cAge3); }, -1, tradingPostID)) ||
					(cvMaxAge < cAge3));

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeSudaneseUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivSudanese;
			break;
		}
		case cUnitTypedeSocketYoruba:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeYorubaUpgradeMonitor'");

				bool canDisableSelf =
					(researchSimpleTechByCondition(
						cTechDENatYorubaHerbalism, []() -> bool { return (kbGetAge() >= cAge3); }, -1, tradingPostID)) ||
					(cvMaxAge < cAge3);

				if (canDisableSelf == true)
				{
				debugTechs("DISABLING Lambda: 'minorNativeYorubaUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivYoruba;
			break;
		}
		// Definitive Edition (no DLC) minor natives.
		case cUnitTypeSocketInca: // Rebranded as Quechuas.
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				debugTechs("RUNNING Lambda: 'minorNativeQuechuasUpgradeMonitor'");

				bool canDisableSelf =
					(researchSimpleTechByCondition(
						cTechNatChasquisMessengers, []() -> bool { return (kbGetAge() >= cAge3); }, -1, tradingPostID)) ||
					(cvMaxAge < cAge3);

				canDisableSelf &= 
								researchSimpleTechByCondition(
									cTechNatMetalworking,
									researchSimpleTechShouldCreate,
									-1,
									tradingPostID);

				if (canDisableSelf == true)
				{
					debugTechs("DISABLING Lambda: 'minorNativeQuechuasUpgradeMonitor' because we have all the upgrades");
				}
				return (canDisableSelf);
			};
			nativeCivFound = cCivIncas;
			break;
		}
		// Brooklyn minor natives.
		case cUnitTypedeSocketWittelsbach:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = researchSimpleTechByCondition(
					cTechDENatWittelsbachHuntingGear,
					[]() -> bool { 
						return (kbUnitCount(cMyID, cUnitTypeAbstractSkirmisher, cUnitStateABQ) +
								kbUnitCount(cMyID, cUnitTypedeNatMountainTrooper, cUnitStateABQ) >= 10);
					},
					-1,
					tradingPostID
				);

				return (canDisableSelf);
			};

			nativeCivFound = cCivWittelsbach;
			break;
		}
		case cUnitTypedeSocketHabsburg:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = researchSimpleTech(cTechDENatHabsburgViennaCongress, -1, tradingPostID);

				return (canDisableSelf);
			};

			nativeCivFound = cCivHabsburg;
			break;
		}
		case cUnitTypedeSocketBourbon:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = researchSimpleTechByCondition(
					cTechDENatBourbonRoyalTax,
					[]() -> bool {
						return (kbUnitCount(cMyID, cUnitTypeBuilding, cUnitStateABQ) >= 20);
					},
					-1,
					tradingPostID
				);

				return (canDisableSelf);
			};

			nativeCivFound = cCivHabsburg;
			break;
		}
		case cUnitTypedeSocketJagiellon:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = researchSimpleTechByCondition(
					cTechDENatJagiellonPancerni,
					[]() -> bool {
						return (kbUnitCount(cMyID, cUnitTypeAbstractHandCavalry, cUnitStateABQ) >= 15);
					},
					-1,
					tradingPostID
				);

				canDisableSelf &= researchSimpleTechByCondition(
					cTechDENatJagiellonSarmatism,
					[]() -> bool {
						return (kbUnitCount(cMyID, cUnitTypeAbstractArcher, cUnitStateABQ) +
						kbUnitCount(cMyID, cUnitTypeShip, cUnitStateABQ) >= 15);
					},
					-1,
					tradingPostID
				);

				return (canDisableSelf);
			};

			nativeCivFound = cCivJagiellon;
			break;
		}
		case cUnitTypedeSocketVasa:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = cvMaxAge < cAge3;

				canDisableSelf |= researchSimpleTechByCondition(
					cTechDENatVasaGoldenLiberty,
					[]() -> bool { 
						return (kbGetAge() >= cAge3);
					},
					-1,
					tradingPostID
				);

				canDisableSelf &= researchSimpleTechByCondition(
					cTechDENatVasaTarKilns,
					[]() -> bool {
						return (kbUnitCount(cMyID, cUnitTypeUnit, cUnitStateABQ) >= 15);
					},
					-1,
					tradingPostID
				);

				return (canDisableSelf);
			};

			nativeCivFound = cCivVasa;
			break;
		}
		case cUnitTypedeSocketHanover:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = researchSimpleTech(cTechDENatHanoverRoyalScotsGrey, -1, tradingPostID);

				return (canDisableSelf);
			};

			nativeCivFound = cCivHanover;
			break;
		}
		case cUnitTypedeSocketOldenburg:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = researchSimpleTechByCondition(
					cTechDENatOldenBurgKalthoffRepeaters,
					[]() -> bool {
						return (kbUnitCount(cMyID, cUnitTypeAbstractSkirmisher, cUnitStateABQ) >= 15);
					},
					-1,
					tradingPostID
				);

				return (canDisableSelf);
			};

			nativeCivFound = cCivOldenburg;
			break;
		}
		case cUnitTypedeSocketWettin: // Get nothing.
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = true;

				return (canDisableSelf);
			};

			nativeCivFound = cCivWettin;
			break;
		}
		case cUnitTypedeSPCSocketCityState:
		{
			tempLambdaStorage = [](int tradingPostID = -1) -> bool {
				bool canDisableSelf = cvMaxAge < cAge3;

				canDisableSelf |= researchSimpleTechByCondition(
					cTechDESPCFortifiedCityState,
					[]() -> bool {
						return (kbGetAge() >= cAge3 && kbUnitCount(cMyID, cUnitTypedeSPCCityTower, cUnitStateAlive) >= 3);
					},
					-1,
					tradingPostID
				);

				canDisableSelf &= researchSimpleTechByCondition(
					cTechDESPCArtilleryInnovations,
					[]() -> bool {
						return (kbGetAge() >= cAge3);
					},
					-1,
					tradingPostID
				);

				return (canDisableSelf);
			};

			nativeCivFound = cCivSPCCityState;
			break;
		}
		}

		// We have found a native now let's see if we have already processed the ID before and it's a duplicate or if it's new and
		// assign it to an upgrade rule.
		if (amountOfUniqueNatives == 0)
		{
			xsSetContextPlayer(cMyID);
			gNativeTribeCiv1 = nativeCivFound;
			gNativeTribeResearchTechs1 = tempLambdaStorage;
			xsEnableRule("nativeTribeUpgradeMonitor1");
			amountOfUniqueNatives++;
			debugTechs("gNativeTribeCiv1 is: " + kbGetCivName(gNativeTribeCiv1));
			xsSetContextPlayer(0);
		}
		else if ((amountOfUniqueNatives == 1) && (gNativeTribeCiv1 != nativeCivFound))
		{
			xsSetContextPlayer(cMyID);
			gNativeTribeCiv2 = nativeCivFound;
			gNativeTribeResearchTechs2 = tempLambdaStorage;
			xsEnableRule("nativeTribeUpgradeMonitor2");
			amountOfUniqueNatives++;
			debugTechs("gNativeTribeCiv2 is: " + kbGetCivName(gNativeTribeCiv2));
			xsSetContextPlayer(0);
		}
		else if ((amountOfUniqueNatives == 2) && (gNativeTribeCiv1 != nativeCivFound) && (gNativeTribeCiv2 != nativeCivFound))
		{
			xsSetContextPlayer(cMyID);
			gNativeTribeCiv3 = nativeCivFound;
			gNativeTribeResearchTechs3 = tempLambdaStorage;
			xsEnableRule("nativeTribeUpgradeMonitor3");
			amountOfUniqueNatives++;
			debugTechs("gNativeTribeCiv3 is: " + kbGetCivName(gNativeTribeCiv3));
			return; // We have hit the maximum of natives possible that we can handle, we can safely quit now.
		}
	}
	xsSetContextPlayer(cMyID);
}

//==============================================================================
// tradeRouteUpgradeMonitor
//==============================================================================
rule tradeRouteUpgradeMonitor
inactive
minInterval 90
{
	debugTechs("RUNNING tradeRouteUpgradeMonitor rule");
	// Start with updating our bool array by looking at what the first unit on the TR is, if it's the last tier set the bool to
	// true.
	int firstMovingUnit = -1;
	int firstMovingUnitProtoID = -1;
	for (i = 0; < gNumberTradeRoutes)
	{
		firstMovingUnit = kbTradeRouteGetUnit(i, 0);
		firstMovingUnitProtoID = kbUnitGetProtoUnitID(firstMovingUnit);
		if ((firstMovingUnitProtoID == cUnitTypedeTradingFluyt) || (firstMovingUnitProtoID == cUnitTypeTrainEngine) ||
			(firstMovingUnitProtoID == cUnitTypedeCaravanGuide))
			xsArraySetBool(gTradeRouteIndexMaxUpgraded, i, true);
	}

	// If all the values in the bool array are set to true it means we can disable this rule since we have all the upgrades
	// across all TRs on the map.
	bool canDisableSelf = true;
	for (i = 0; < gNumberTradeRoutes)
	{
		if (xsArrayGetBool(gTradeRouteIndexMaxUpgraded, i) == false)
			canDisableSelf = false;
	}
	if (canDisableSelf == true)
	{
		debugTechs(
			"Disabling rule tradeRouteUpgradeMonitor since we have all upgrades active, hopefully somebody else paid for them!");
		xsDisableSelf();
	}

	int numberTradingPostsOnRoute = 0;
	int tradingPostID = -1;
	int playerID = -1;
	int ownedTradingPostID = -1;
	int numberAllyTradingPosts = 0;
	int numberEnemyTradingPosts = 0;
	int tradeRoutePrio = 53;
	int age = kbGetAge();

	for (routeIndex = 0; < gNumberTradeRoutes)
	{
		if (xsArrayGetBool(gTradeRouteIndexMaxUpgraded, routeIndex) == true)
		{
			continue;
		}

		numberTradingPostsOnRoute = kbTradeRouteGetNumberTradingPosts(routeIndex);
		ownedTradingPostID = -1;
		numberAllyTradingPosts = 0;
		numberEnemyTradingPosts = 0;
		for (postIndex = 0; < numberTradingPostsOnRoute)
		{
			tradingPostID = kbTradeRouteGetTradingPostID(
				routeIndex, postIndex); // This syscall needs no LOS and finds all IDs of (built / foundation) TPs currently on
										// that route, so no empty sockets are found.
			playerID = kbUnitGetPlayerID(tradingPostID);
			if (playerID == cMyID)
			{
				ownedTradingPostID = tradingPostID;
				numberAllyTradingPosts++;
				continue;
			}
			if (kbIsPlayerAlly(playerID) == true)
			{
				numberAllyTradingPosts++;
				continue;
			}
			if (kbIsPlayerAlly(playerID) == false)
				numberEnemyTradingPosts++;
		}
		if (ownedTradingPostID >= 0) // If we actually found a TR on this route that is ours, do the upgrade logic.
		{
			if (kbBuildingTechGetStatus(xsArrayGetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (routeIndex * 2)), 
				ownedTradingPostID) == cTechStatusObtainable)
			{
				// We have 1 or more TPs on this route than the enemy, doesn't work for upgrade all special maps.
				if (numberAllyTradingPosts - numberEnemyTradingPosts >= 1) 
				{
					researchSimpleTech(xsArrayGetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (routeIndex * 2)),
						-1, ownedTradingPostID, tradeRoutePrio);
					return;
				}
				}
				else if ((kbBuildingTechGetStatus(xsArrayGetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (routeIndex * 2)),
						ownedTradingPostID) == cTechStatusObtainable) &&
						(kbGetAge() >= cAge4))
				{
				if (numberAllyTradingPosts - numberEnemyTradingPosts >= 2) 
				{
					researchSimpleTech(xsArrayGetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (routeIndex * 2)),
						-1, ownedTradingPostID, tradeRoutePrio);
					return;
				}
			}
		}
	}
}

//==============================================================================
// fishingBoatUpgradeMonitor
//==============================================================================
rule fishingBoatUpgradeMonitor
inactive
minInterval 60
{
	bool canDisableSelf = researchSimpleTechByCondition(cTechGillNets,
		[]() -> bool { return (kbUnitCount(cMyID, gFishingUnit, cUnitStateABQ) >= 7); },
		gDockUnit);

	canDisableSelf &= researchSimpleTechByCondition(cTechLongLines,
		[]() -> bool { return (kbUnitCount(cMyID, gFishingUnit, cUnitStateABQ) >= 9); },
		gDockUnit);
		
	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

//==============================================================================
// navyUpgradeMonitor
// We don't get the very expensive European navy upgrades since we're bad at water.
// Natives don't have any regular navy upgrades so this rule isn't activated for them.
//==============================================================================
rule navyUpgradeMonitor
inactive
minInterval 90
{
	bool canDisableSelf = false;

	if (civIsAfrican() == true)
	{
		canDisableSelf = researchSimpleTechByCondition(cTechDERiverSkirmishes,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateABQ) >= 3); },
			gDockUnit);
		
		canDisableSelf &= researchSimpleTechByCondition(cTechDERiverboatHitpoints,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateABQ) >= 3); },
			gDockUnit);
	}
	else // Europeans or Asians.
	{
		canDisableSelf = researchSimpleTechByCondition(cTechCarronade,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateABQ) >= 3); },
			gDockUnit);
		
		canDisableSelf &= researchSimpleTechByCondition(cTechPercussionLocks,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateABQ) >= 3); },
			gDockUnit);
			
		canDisableSelf &= researchSimpleTechByCondition(cTechArmorPlating,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateABQ) >= 3); },
			gDockUnit);
	}

	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

rule arsenalUpgradeMonitor
inactive
minInterval 60
{
	debugTechs("RUNNING Rule: 'arsenalUpgradeMonitor'");
	int researchBuildingPUID = -1;
	bool canDisableSelf = true;

	// New Ways cards.
	if ((cMyCiv == cCivXPIroquois) || (cMyCiv == cCivXPSioux))
	{
		researchBuildingPUID = cMyCiv == cCivXPIroquois ? cUnitTypeLonghouse : cUnitTypeTeepee;
	}
	// Dutch Consulate Arsenal.
	else if ((cMyCiv == cCivJapanese) || (cMyCiv == cCivSPCJapanese) || (cMyCiv == cCivSPCJapaneseEnemy))
	{
		researchBuildingPUID = cUnitTypeypArsenalAsian;
	}
	// This means we're either European or African (Portuguese/British Alliance).
	else
	{
		researchBuildingPUID = cUnitTypeArsenal;
	}

	// Quit if there is no alive Arsenal / Teepee / Longhouse.
	if (kbUnitCount(cMyID, researchBuildingPUID, cUnitStateAlive) < 1)
	{
		return;
	}

	// Shared upgrades.
	canDisableSelf = researchSimpleTechByCondition(
		cTechCavalryCuirass,
		[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractHeavyCavalry, cUnitStateABQ) >= 12); },
		researchBuildingPUID);

	canDisableSelf &=  researchSimpleTechByCondition(
											cTechInfantryBreastplate,
											[]() -> bool {
												return (
													kbUnitCount(cMyID, cUnitTypeAbstractHandInfantry, cUnitStateABQ) +
														kbUnitCount(cMyID, cUnitTypeAbstractFootArcher, cUnitStateABQ) >=
													12);
											},
											researchBuildingPUID);

	// The Lakota don't have this upgrade.
	// Only get 'Heated Shot' upgrade on water maps.
	if ((cMyCiv != cCivXPSioux) && (gNavyMap == true))
	{
		canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechHeatedShot,
							[]() -> bool {
								return (
									(kbUnitCount(cMyID, cUnitTypeAbstractArtillery, cUnitStateABQ) >= 2) &&
									(getUnitCountByLocation(
										cUnitTypeAbstractWarShip, cPlayerRelationEnemyNotGaia, cUnitStateAlive) >= 2));
							}, // Enemy war ships
							researchBuildingPUID);
	}

	// The Haudenosaunee and Lakota don't have these 2 upgrades.
	if ((cMyCiv != cCivXPIroquois) && (cMyCiv != cCivXPSioux))
	{
		canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechGunnersQuadrant,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractArtillery, cUnitStateABQ) >= 4); },
							researchBuildingPUID);

		canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechBayonet,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractMusketeer, cUnitStateABQ) >= 12); },
							researchBuildingPUID);
	}

	// The Japanese Arsenal doesn't have these 2 upgrades.
	if ((cMyCiv != cCivJapanese) && (cMyCiv != cCivSPCJapanese) && (cMyCiv != cCivSPCJapaneseEnemy))
	{
		canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechRifling,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractRifleman, cUnitStateABQ) >= 12); },
							researchBuildingPUID);

		canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechCaracole,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractLightCavalry, cUnitStateABQ) >= 12); },
							researchBuildingPUID);
	}

	// Other civs can only get this upgrade in the advanced Arsenal but for simplicity for the Lakota it's checked here just for
	// them.
	if (cMyCiv == cCivXPSioux)
	{
		canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechPillage,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractHandCavalry, cUnitStateABQ) >= 8); },
							researchBuildingPUID);
	}

	if (canDisableSelf == true)
	{
		debugTechs("DISABLING Rule: 'arsenalUpgradeMonitor' because we have all the upgrades");
		xsDisableSelf();
	}
}

rule advancedArsenalUpgradeMonitor
inactive
minInterval 60
{
	debugTechs("RUNNING Rule: 'advancedArsenalUpgradeMonitor'");
	int researchBuildingPUID = -1;
	bool canDisableSelf = true;

	// We are Japanese and have a Golden Pavilion.
	if ((cMyCiv == cCivJapanese) || (cMyCiv == cCivSPCJapanese) || (cMyCiv == cCivSPCJapaneseEnemy))
	{
		// Check for Golden Pavilions.
		if (kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion2, cUnitStateAlive) > 0)
		{
			researchBuildingPUID = cUnitTypeypWJGoldenPavillion2;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion3, cUnitStateAlive) > 0)
		{
			researchBuildingPUID = cUnitTypeypWJGoldenPavillion3;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion4, cUnitStateAlive) > 0)
		{
			researchBuildingPUID = cUnitTypeypWJGoldenPavillion4;
		}
		else if (kbUnitCount(cMyID, cUnitTypeypWJGoldenPavillion5, cUnitStateAlive) > 0)
		{
			researchBuildingPUID = cUnitTypeypWJGoldenPavillion5;
		}
	}
	// We are European and have sent the Advanced Arsenal card.
	else
	{
		researchBuildingPUID = cUnitTypeArsenal;
	}

	// Quit if there is no Arsenal or Golden Pavilion.
	if (kbUnitCount(cMyID, researchBuildingPUID, cUnitStateAlive) < 1)
	{
		return;
	}

	// Shared Upgrades.
	canDisableSelf = researchSimpleTechByCondition(
		cTechPaperCartridge,
		[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractGunpowderTrooper, cUnitStateABQ) >= 12); },
		researchBuildingPUID);

	canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechFlintlock,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractGunpowderTrooper, cUnitStateABQ) >= 12); },
							researchBuildingPUID);

	canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechProfessionalGunners,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractArtillery, cUnitStateABQ) >= 6); },
							researchBuildingPUID);

	canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechPillage,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractHandCavalry, cUnitStateABQ) >= 8); },
							researchBuildingPUID);

	// The Golden Pavilion doesn't have the following 2 upgrades so don't check.
	if ((cMyCiv != cCivJapanese) || (cMyCiv != cCivSPCJapanese) || (cMyCiv != cCivSPCJapaneseEnemy))
	{
		canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechTrunion,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractArtillery, cUnitStateABQ) >= 6); },
							researchBuildingPUID);

		// Only these civs have access to this upgrade from all the European civs.
		if ((cMyCiv == cCivBritish) || (cMyCiv == cCivDutch) || (cMyCiv == cCivOttomans) || (cMyCiv == cCivRussians) ||
			(cMyCiv == cCivDESwedish))
		{
			canDisableSelf &= 
							researchSimpleTechByCondition(
								cTechIncendiaryGrenades,
								[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeGrenadier, cUnitStateABQ) >= 12); },
								researchBuildingPUID);
		}
	}

	if (canDisableSelf == true)
	{
		debugTechs("DISABLING Rule: 'advancedArsenalUpgradeMonitor' because we have all the upgrades");
		xsDisableSelf();
	}
}

rule churchUpgradeMonitor
inactive
minInterval 60
{
	debugTechs("RUNNING Rule: 'churchUpgradeMonitor'");
	int researchBuildingPUID = -1;
	
	if (civIsAsian() == true)
	{
		researchBuildingPUID = cUnitTypeypChurch;
	}
	else if (cMyCiv == cCivDEMexicans)
	{
		researchBuildingPUID = cUnitTypedeCathedral;
	}
	else // We're European or Ethiopians with Jesuit alliance.
	{
		researchBuildingPUID = cUnitTypeChurch;
	}

	// Quit if there is no Church / Cathedral.
	if (kbUnitCount(cMyID, researchBuildingPUID, cUnitStateAlive) < 1)
	{
		return;
	}
	
	// Just get the 2 LOS upgrades, still low priority upgrades.
	bool canDisableSelf = researchSimpleTech(cTechChurchTownWatch, researchBuildingPUID, -1, 49);

	canDisableSelf &=  researchSimpleTech(cTechChurchGasLighting, researchBuildingPUID, -1, 49);
	
	// Get the 2 training time reduction upgrades once we already have 60% of our gMaxPop.
	canDisableSelf &=  ((researchSimpleTechByCondition(cTechChurchMassCavalry,
		[]() -> bool { return (kbGetPop() >= gMaxPop * 0.6); },
		researchBuildingPUID)) ||
		(cvMaxAge < cAge4));
		
	canDisableSelf &=  ((researchSimpleTechByCondition(cTechChurchStandingArmy,
		[]() -> bool { return (kbGetPop() >= gMaxPop * 0.6); },
		researchBuildingPUID)) ||
		(cvMaxAge < cAge4));
	
	if (cMyCiv == cCivDEMexicans)
	{
		// Only get this upgrade when we're at max Houses. We will make less Houses on lower difficulties so account for that.
		canDisableSelf &=  researchSimpleTechByCondition(cTechDEChurchSevenHouses,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeHouseMed, cUnitStateAlive) ==
			gMaxPop / 10); },
			researchBuildingPUID);
		
		// Get at 500xp.
		canDisableSelf &=  researchSimpleTechByCondition(cTechDEChurchDiaDeLosMuertos,
			[]() -> bool { return (kbTechGetHCCardValuePerResource (cTechDEChurchDiaDeLosMuertos, cResourceXP) >= 500); },
			researchBuildingPUID);
	}
	
	if (canDisableSelf == true)
	{
		debugTechs("DISABLING Rule: 'churchUpgradeMonitor' because we have all the upgrades");
		xsDisableSelf();
	}
}

rule royalDecreeMonitor
inactive
minInterval 45
{
	int decreePlanID = -1;

	// Quit if we didn't ship the required card yet
	if ((kbTechGetStatus(cTechHCRoyalDecreeBritish) != cTechStatusActive) &&
		(kbTechGetStatus(cTechHCRoyalDecreeDutch) != cTechStatusActive) &&
		(kbTechGetStatus(cTechHCRoyalDecreeFrench) != cTechStatusActive) &&
		(kbTechGetStatus(cTechHCRoyalDecreeGerman) != cTechStatusActive) &&
		(kbTechGetStatus(cTechHCRoyalDecreeOttoman) != cTechStatusActive) &&
		(kbTechGetStatus(cTechHCRoyalDecreePortuguese) != cTechStatusActive) &&
		(kbTechGetStatus(cTechHCRoyalDecreeRussian) != cTechStatusActive) &&
		(kbTechGetStatus(cTechHCRoyalDecreeSpanish) != cTechStatusActive) &&
		(kbTechGetStatus(cTechDEHCRoyalDecreeMexican) != cTechStatusActive))
		return;

	// Handle Cathedrals
	int churchUnitType = cUnitTypeChurch;
	if (cMyCiv == cCivDEMexicans)
		churchUnitType = cUnitTypedeCathedral;

	// Quit if there is no church
	if (kbUnitCount(cMyID, churchUnitType, cUnitStateAlive) < 1)
		return;

	switch (cMyCiv)
	{
		case cCivBritish:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchThinRedLine) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchBlackWatch) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchRogersRangers) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if (kbTechGetStatus(cTechChurchThinRedLine) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchThinRedLine) >= 0)
					return;
				createSimpleResearchPlan(cTechChurchThinRedLine, cUnitTypeChurch, cMilitaryEscrowID, 50);
			}
			if (kbTechGetStatus(cTechChurchBlackWatch) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchBlackWatch) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchBlackWatch, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchRogersRangers) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchRogersRangers) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchRogersRangers, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivDutch:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchCoffeeTrade) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchWaardgelders) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchStadholders) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if (kbTechGetStatus(cTechChurchCoffeeTrade) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchCoffeeTrade) >= 0)
					return;
				createSimpleResearchPlan(cTechChurchCoffeeTrade, cUnitTypeChurch, cEconomyEscrowID, 50);
			}
			if (kbTechGetStatus(cTechChurchWaardgelders) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchWaardgelders) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchWaardgelders, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchStadholders) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchStadholders) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchStadholders, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivFrench:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchCodeNapoleon) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchGardeImperial1) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchGardeImperial2) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchGardeImperial3) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if ((kbTechGetStatus(cTechChurchCodeNapoleon) == cTechStatusObtainable) && (kbGetAge() >= cAge4))
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchCodeNapoleon) >= 0)
					return;
				createSimpleResearchPlan(cTechChurchCodeNapoleon, cUnitTypeChurch, cMilitaryEscrowID, 50);
			}
			if (kbTechGetStatus(cTechChurchGardeImperial1) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchGardeImperial1) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchGardeImperial1, cUnitTypeChurch, cEconomyEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchGardeImperial2) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchGardeImperial2) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchGardeImperial2, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchGardeImperial3) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchGardeImperial3) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchGardeImperial3, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivGermans:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchTillysDiscipline) == cTechStatusActive) &&
				//(kbTechGetStatus(cTechChurchWallensteinsContracts) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchZweihander) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if (kbTechGetStatus(cTechChurchTillysDiscipline) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchTillysDiscipline) >= 0)
					return;
				createSimpleResearchPlan(cTechChurchTillysDiscipline, cUnitTypeChurch, cMilitaryEscrowID, 50);
			} /*
			if (kbTechGetStatus(cTechChurchWallensteinsContracts) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchWallensteinsContracts) >=
			0) return; decreePlanID = createSimpleResearchPlan(cTechChurchWallensteinsContracts, getUnit(cUnitTypeChurch),
			cMilitaryEscrowID, 50); aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}*/
			if (kbTechGetStatus(cTechChurchZweihander) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchZweihander) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchZweihander, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivOttomans:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchTufanciCorps) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchTopcuCorps) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if (kbTechGetStatus(cTechChurchTufanciCorps) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchTufanciCorps) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchTufanciCorps, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchTopcuCorps) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchTopcuCorps) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchTopcuCorps, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivPortuguese:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchEconmediaManor) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchBestieros) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchTowerAndSword) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if ((kbTechGetStatus(cTechChurchEconmediaManor) == cTechStatusObtainable) &&
				(kbUnitCount(cMyID, cUnitTypeMill, cUnitStateAlive) >= 4) && (gTimeToFarm == true))
			{ // Only get this when we're really focusing on mills
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchEconmediaManor) >= 0)
					return;
				createSimpleResearchPlan(cTechChurchEconmediaManor, cUnitTypeChurch, cMilitaryEscrowID, 50);
			}
			if (kbTechGetStatus(cTechChurchBestieros) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchBestieros) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchBestieros, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchTowerAndSword) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchTowerAndSword) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchTowerAndSword, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivRussians:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchWesternization) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchPetrineReforms) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchKalmucks) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchBashkirPonies) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if (kbTechGetStatus(cTechChurchWesternization) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchWesternization) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchWesternization, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchPetrineReforms) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchPetrineReforms) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchPetrineReforms, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchKalmucks) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchKalmucks) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchKalmucks, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchBashkirPonies) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchBashkirPonies) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchBashkirPonies, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivSpanish:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechChurchCorsolet) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchQuatrefage) == cTechStatusActive) &&
				(kbTechGetStatus(cTechChurchWildGeeseSpanish) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if (kbTechGetStatus(cTechChurchCorsolet) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchCorsolet) >= 0)
					return;
				createSimpleResearchPlan(cTechChurchCorsolet, cUnitTypeChurch, cMilitaryEscrowID, 50);
			}
			if (kbTechGetStatus(cTechChurchQuatrefage) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchQuatrefage) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchQuatrefage, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechChurchWildGeeseSpanish) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechChurchWildGeeseSpanish) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(cTechChurchWildGeeseSpanish, cUnitTypeChurch, cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
		case cCivDEMexicans:
		{
			// Disable rule once all upgrades are available
			if ((kbTechGetStatus(cTechDEChurchFirstGuarantee) == cTechStatusActive) &&
				(kbTechGetStatus(cTechDEChurchSecondGuarantee) == cTechStatusActive) &&
				(kbTechGetStatus(cTechDEChurchThirdGuarantee) == cTechStatusActive))
			{
				xsDisableSelf();
				return;
			}

			// Get upgrades/troops as they become available
			if (kbTechGetStatus(cTechDEChurchFirstGuarantee) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechDEChurchFirstGuarantee) >= 0)
					return;
				createSimpleResearchPlan(cTechDEChurchFirstGuarantee, getUnit(cUnitTypedeCathedral), cMilitaryEscrowID, 50);
			}
			if (kbTechGetStatus(cTechDEChurchSecondGuarantee) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechDEChurchSecondGuarantee) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(
					cTechDEChurchSecondGuarantee, getUnit(cUnitTypedeCathedral), cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			if (kbTechGetStatus(cTechDEChurchThirdGuarantee) == cTechStatusObtainable)
			{
				if (aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechDEChurchThirdGuarantee) >= 0)
					return;
				decreePlanID = createSimpleResearchPlan(
					cTechDEChurchThirdGuarantee, getUnit(cUnitTypedeCathedral), cMilitaryEscrowID, 50);
				aiPlanSetDesiredResourcePriority(decreePlanID, 40);
			}
			break;
		}
	}
}

rule warHutUpgradeMonitor
inactive
minInterval 60
{
	bool canDisableSelf = researchSimpleTechByCondition(cTechStrongWarHut, 
		[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) >= 3); },
		cUnitTypeWarHut);

	canDisableSelf &= ((researchSimpleTechByCondition(cTechMightyWarHut,
		[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) >= 4); },
		cUnitTypeWarHut)) ||
		cvMaxAge < cAge4);

	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

//==============================================================================
// bigButtonAztecMonitor
// This rule researches all the big button upgrades for the Aztecs.
// Excluding the raiding parties, those are used as minutemen in useWarParties.
// TO DO add cTechBigDockCipactli after naval rework.
//==============================================================================
rule bigButtonAztecMonitor
inactive
minInterval 60
{
	debugTechs("RUNNING Rule: 'bigButtonAztecMonitor'");
	if (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive) < 20)
	{
		debugTechs("QUITING Rule: 'bigButtonAztecMonitor' because we have fewer than 20 Settlers alive");
		return; // Avoid getting upgrades here with a weak economy.
	}

	// Cheap upgrade, just get it and hope our War Chief stays alive.
	bool canDisableSelf = researchSimpleTechByCondition(
		cTechBigFirepitFounder,
		[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeCommunityPlaza, cUnitStateABQ) >= 1); },
		cUnitTypeCommunityPlaza);

	// Get at least 8 Otontin Slingers.
	canDisableSelf &=  researchSimpleTechByCondition(
											cTechBigHouseCoatlicue,
											[]() -> bool {
												return (
													(xsGetTime() >= 16 * 60 * 1000) &&
													(kbUnitCount(cMyID, cUnitTypeHouseAztec, cUnitStateABQ) >= 1) &&
													(indexProtoUnitInUnitPicker(cUnitTypexpMacehualtin) > -1));
											},
											cUnitTypeHouseAztec);

	// Get at least 12 Puma Spearmen.
	canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechBigWarHutBarometz,
							[]() -> bool {
							return (
								(xsGetTime() >= 24 * 60 * 1000) && (kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) >= 1) &&
								(indexProtoUnitInUnitPicker(cUnitTypexpPumaMan) > -1));
							},
							cUnitTypeWarHut);

	// Get at least 10 Eagle Runner Knights.
	canDisableSelf &= 
						((researchSimpleTechByCondition(
							cTechBigFarmCinteotl,
							[]() -> bool {
								return (
									(xsGetTime() >= 20 * 60 * 1000) && (kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateABQ) >= 1) &&
									(indexProtoUnitInUnitPicker(cUnitTypexpMacehualtin) > -1));
							},
							cUnitTypeFarm)) ||
						(cvMaxAge < cAge3));

	// Get at least 10 Arrow Knights.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechBigNoblesHutWarSong,
											[]() -> bool {
												return (
													(xsGetTime() >= 20 * 60 * 1000) &&
													(kbUnitCount(cMyID, cUnitTypeNoblesHut, cUnitStateABQ) >= 1) &&
													(indexProtoUnitInUnitPicker(cUnitTypexpArrowKnight) > -1));
											},
											cUnitTypeNoblesHut)) ||
										(cvMaxAge < cAge3));

	// Get at least 7 Skull Knights.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechBigPlantationTezcatlipoca,
											[]() -> bool {
												return (
													(xsGetTime() >= 28 * 60 * 1000) &&
													(kbUnitCount(cMyID, cUnitTypePlantation, cUnitStateABQ) >= 1));
											},
											cUnitTypePlantation)) ||
										(cvMaxAge < cAge3));

	if (canDisableSelf == true)
	{
		debugTechs("DISABLING Rule: 'bigButtonAztecMonitor' because we have all the upgrades");
		xsDisableSelf();
	}
}

//==============================================================================
// bigButtonIncaMonitor
// This rule researches all the big button upgrades for the Incas.
// Excluding the raiding parties, those are used as minutemen in useWarParties.
// We don't get Queen's Festival since it's just underpowered right now.
// We don't get Inti Festival since the AI isn't particularly good at using shipments anyway.
// We don't get Viracocha Worship since we don't have a specific strategy on what to do with those 2 builders.
// We don't get Urcuchillay Worship since we don't have a resource strategy to base this upgrade on.
//==============================================================================
rule bigButtonIncaMonitor
inactive
minInterval 60
{
	debugTechs("RUNNING Rule: 'bigButtonIncaMonitor'");
	if (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive) < 20)
	{
		debugTechs("QUITING Rule: 'bigButtonIncaMonitor' because we have fewer than 20 Settlers alive");
		return; // Avoid getting upgrades here with a weak economy.
	}

	// Get at least 4 Fishing Boats & Chincha Rafts.
	bool canDisableSelf =
		((researchSimpleTechByCondition(
				cTechdeBigDockTotora,
				[]() -> bool {
				return ((xsGetTime() >= 20 * 60 * 1000) && (kbUnitCount(cMyID, cUnitTypeDock, cUnitStateABQ) >= 1));
				},
				cUnitTypeDock)) ||
			(cvMaxAge < cAge3) || (gNavyMap == false));

	// Have at least 20 Infantry before we get this upgrade.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechdeBigWarHutHualcana,
											[]() -> bool {
												return (
													(kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateABQ) +
														kbUnitCount(cMyID, cUnitTypeAbstractLightInfantry, cUnitStateABQ) >=
													20) &&
													(kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) >= 1));
											},
											cUnitTypeWarHut)) ||
										(cvMaxAge < cAge3));

	// Get at least 6 Macemen.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechdeBigFirePitRoyalFestival,
											[]() -> bool {
												return (
													(xsGetTime() >= 24 * 60 * 1000) &&
													(kbUnitCount(cMyID, cUnitTypeCommunityPlaza, cUnitStateABQ) >= 1) &&
													(indexProtoUnitInUnitPicker(cUnitTypedeMaceman) > -1));
											},
											cUnitTypeCommunityPlaza)) ||
										(cvMaxAge < cAge3));

	// We're already in Industrial and have 2+ Estates, still a low priority upgrade.
	canDisableSelf &= 
						((researchSimpleTechByCondition(
							cTechdeBigPlantationCoca,
							[]() -> bool { return (kbUnitCount(cMyID, cUnitTypePlantation, cUnitStateABQ) >= 2); },
							cUnitTypePlantation,
							-1,
							45)) ||
						(cvMaxAge < cAge4));

	// Expensive upgrade so make sure we're already progressed pretty far in the game.
	canDisableSelf &= 
						((researchSimpleTechByCondition(
							cTechdeBigStrongholdThunderbolts,
							[]() -> bool {
								return (
									(kbGetAge() >= cAge4) && (kbUnitCount(cMyID, cUnitTypedeIncaStronghold, cUnitStateABQ) >= 1) &&
									(kbGetPop() >= gMaxPop * 0.6));
							},
							cUnitTypedeIncaStronghold)) ||
						(cvMaxAge < cAge4));

	if (canDisableSelf == true)
	{
		debugTechs("DISABLING Rule: 'bigButtonIncaMonitor' because we have all the upgrades");
		xsDisableSelf();
	}
}

//==============================================================================
// bigButtonLakotaMonitor
// This rule researches all the big button upgrades for the Lakota.
// Excluding the raiding parties, those are used as minutemen in useWarParties.
// We don't get Battle Anger since it's pretty expensive and our War Chief micro/macro isn't good enough.
//==============================================================================
rule bigButtonLakotaMonitor
inactive
mininterval 60
{
	debugTechs("RUNNING Rule: 'bigButtonLakotaMonitor'");
	if (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive) < 20)
	{
		debugTechs("QUITING Rule: 'bigButtonLakotaMonitor' because we have fewer than 20 Settlers alive");
		return; // Avoid getting upgrades here with a weak economy.
	}

	// Get the upgrade if we have 12 or more cavalry units.
	bool canDisableSelf = researchSimpleTechByCondition(
		cTechBigFarmHorsemanship,
		[]() -> bool {
			return (
				(kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateABQ) >= 1) &&
				(kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) >= 12));
		},
		cUnitTypeFarm);

	// Get the upgrade if we see at least 2 enemy artillery, since we're Lakota we can assume we will train cavalry to counter
	// the artillery.
	canDisableSelf &= 
						researchSimpleTechByCondition(
							cTechBigCorralBonepipeArmor,
							[]() -> bool {
							return (
								(kbUnitCount(cMyID, cUnitTypeCorral, cUnitStateABQ) >= 1) &&
								(getUnitCountByLocation(
										cUnitTypeAbstractArtillery, cPlayerRelationEnemyNotGaia, cUnitStateAlive) >= 2));
							},
							cUnitTypeCorral);

	// Get the upgrade if we have atleast 30 Villagers, still a low priority upgrade.
	canDisableSelf &=  researchSimpleTechByCondition(
											cTechDEBigTribalMarketplaceCoopLakota,
											researchSimpleTechShouldCreate,
											cUnitTypedeFurTrade,
											-1,
											45);

	// Get the upgrade if we have atleast 3 War ships, lower priority upgrade just because it's naval.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechBigDockFlamingArrows,
											[]() -> bool {
												return (
													(kbUnitCount(cMyID, cUnitTypeDock, cUnitStateABQ) >= 1) &&
													(kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateABQ) >= 3));
											},
											cUnitTypeDock,
											-1,
											45)) ||
										(cvMaxAge < cAge3) || (gNavyMap == false));

	// Just get the upgrade when in Fortress age, still a low priority upgrade.
	canDisableSelf &= 
						((researchSimpleTech(cTechBigWarHutWarDrums, cUnitTypeWarHut, -1, 45)) || (cvMaxAge < cAge3));

	// Get the upgrade if we have at least 10 Rifle units.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechBigPlantationGunTrade,
											[]() -> bool {
												return (
													(kbUnitCount(cMyID, cUnitTypePlantation, cUnitStateABQ) >= 1) &&
													((kbUnitCount(cMyID, cUnitTypexpWarRifle, cUnitStateABQ) +
															kbUnitCount(cMyID, cUnitTypexpRifleRider, cUnitStateABQ) >=
														10)));
											},
											cUnitTypePlantation)) ||
										(cvMaxAge < cAge3));

	if (canDisableSelf == true)
	{
		debugTechs("DISABLING Rule: 'bigButtonLakotaMonitor' because we have all the upgrades");
		xsDisableSelf();
	}
}

//==============================================================================
// bigButtonHaudenosauneeMonitor
// This rule researches all the big button upgrades for the Haudenosaunee.
// Excluding the raiding parties, those are used as minutemen in useWarParties.
// We don't get Secret Society since the AI has no real strategy for healing units and it will
// 	just lose its War Chief anyway and not retreat it to use it as a healer.
// We don't get Woodland Dwellers since we don't have a resource strategy to base this upgrade on.
// We don't get New Year Festival since the AI isn't particularly good at using shipments anyway.
// We don't get Strawberry Festival since we don't have a resource strategy to base this upgrade on.
// We don't get Maple Festival since we don't have a resource strategy to base this upgrade on.
//==============================================================================
rule bigButtonHaudenosauneeMonitor
inactive
mininterval 60
{
	debugTechs("RUNNING Rule: 'bigButtonHaudenosauneeMonitor'");
	if (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive) < 20)
	{
		debugTechs("QUITING Rule: 'bigButtonHaudenosauneeMonitor' because we have fewer than 20 Settlers alive");
		return; // Avoid getting upgrades here with a weak economy.
	}

	// Get the upgrade if we have 12 or more cavalry units.
	bool canDisableSelf = researchSimpleTechByCondition(
		cTechBigCorralHorseSecrets,
		[]() -> bool {
			return (
				(kbUnitCount(cMyID, cUnitTypeCorral, cUnitStateABQ) >= 1) &&
				(kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) >= 12));
		},
		cUnitTypeCorral);

	// Get the upgrade if we have 25 or more affected units or if 20 minutes have passed and we have 10 or more affected units,
	// it's a great upgrade so we kinda need it.
	int techStatus = kbTechGetStatus(cTechBigWarHutLacrosse);
	if (techStatus == cTechStatusObtainable)
	{
		int planID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechBigWarHutLacrosse);
		bool buildingAlive = kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateAlive) >= 1;
		int unitCount = kbUnitCount(cMyID, cUnitTypexpAenna, cUnitStateAlive) +
						kbUnitCount(cMyID, cUnitTypexpTomahawk, cUnitStateAlive) +
						kbUnitCount(cMyID, cUnitTypexpMusketWarrior, cUnitStateAlive);
		if (planID >= 0)
		{
			if ((buildingAlive == false) || (unitCount < 10))
			{
				aiPlanDestroy(planID);
			}
		}
		else if ((buildingAlive == true) && ((unitCount >= 25) || ((xsGetTime() >= 20 * 60 * 1000) && (unitCount >= 10))))
		{
			createSimpleResearchPlan(cTechBigWarHutLacrosse, cUnitTypeWarHut);
		}
	}
	canDisableSelf &=  techStatus == cTechStatusActive;

	// Get the upgrade if we have atleast 30 Villagers, still a low priority upgrade.
	canDisableSelf &=  researchSimpleTechByCondition(
											cTechDEBigTribalMarketplaceCoopHaudenosaunee,
											researchSimpleTechShouldCreate,
											cUnitTypedeFurTrade,
											-1,
											45);

	// Get the upgrade if we have atleast 3 War ships, lower priority upgrade just because it's naval.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechBigDockRawhideCovers,
											[]() -> bool {
												return (
													(kbUnitCount(cMyID, cUnitTypeDock, cUnitStateABQ) >= 1) &&
													(kbUnitCount(cMyID, cUnitTypeAbstractWarShip, cUnitStateABQ) >= 3));
											},
											cUnitTypeDock,
											-1,
											45)) ||
										(cvMaxAge < cAge3) || (gNavyMap == false));

	// Get this upgrade later in the game since it's not that good.
	canDisableSelf &=  ((researchSimpleTechByCondition(
											cTechBigSiegeshopSiegeDrill,
											[]() -> bool {
												return (
													(kbUnitCount(cMyID, cUnitTypeArtilleryDepot, cUnitStateABQ) >= 1) &&
													(kbUnitCount(cMyID, cUnitTypexpRam, cUnitStateABQ) +
														kbUnitCount(cMyID, cUnitTypexpMantlet, cUnitStateABQ) +
														kbUnitCount(cMyID, cUnitTypexpLightCannon, cUnitStateABQ) >=
													8));
											},
											cUnitTypeArtilleryDepot)) ||
										(cvMaxAge < cAge4));

	if (canDisableSelf == true)
	{
		debugTechs("DISABLING Rule: 'bigButtonHaudenosauneeMonitor' because we have all the upgrades");
		xsDisableSelf();
	}
}

rule tamboUpgradeMonitor
inactive
minInterval 90
{
	bool canDisableSelf = researchSimpleTechByCondition(cTechdeMightyTambos,
		[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeTradingPost, cUnitStateABQ) >= 2); },
		cUnitTypeTradingPost);
	
	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

rule strongholdUpgradeMonitor
inactive
minInterval 75
{
	bool canDisableSelf = researchSimpleTechByCondition(cTechdePukaras,
		[]() -> bool { return (kbUnitCount(cMyID, cUnitTypedeIncaStronghold, cUnitStateAlive) +
		kbUnitCount(cMyID, cUnitTypeWarHut, cUnitStateABQ) +
		kbUnitCount(cMyID, cUnitTypeTradingPost, cUnitStateABQ) >= 3); },
		cUnitTypedeIncaStronghold);

	if (cDifficultyCurrent >= cDifficultyHard)
	{
		canDisableSelf &= researchSimpleTechByCondition(cTechdeSacsayhuaman,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypedeIncaStronghold, cUnitStateAlive) >= 3); },
			cUnitTypedeIncaStronghold);
	}

	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

//==============================================================================
// monasteryUpgradeMonitor
//==============================================================================
rule monasteryUpgradeMonitor
inactive
minInterval 60
{
	// If we don't have a Monastery alive we are done here.
	int monasteryID = getUnit(cUnitTypeypMonastery, cMyID);
	if (monasteryID < 0)
	{
		return;
	}

	bool canDisableSelf = true;

	// We don't get the 2 upgrades to increase the strength of the Monk because we have no micro for him.
	if ((cMyCiv == cCivChinese) || (cMyCiv == cCivSPCChinese))
	{
		canDisableSelf = researchSimpleTechByCondition(cTechypMonasteryDiscipleAura,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeypMonkDisciple, cUnitStateABQ) >= 8); },
			-1, monasteryID);

		canDisableSelf &= researchSimpleTechByCondition(cTechypMonasteryShaolinWarrior,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeypMonkDisciple, cUnitStateABQ) >= 8); },
			-1, monasteryID);
	}

	// We don't get the Tiger because that is just wasting resources for us.
	// We don't get the healing upgrade because we have no logic to use the Monks as healers and not lose them.
	// We don't get Crushing Force because we don't micro the Monks and will probably lose them.
	else if ((cMyCiv == cCivIndians) || (cMyCiv == cCivSPCIndians))
	{
		canDisableSelf = researchSimpleTechByCondition(cTechypMonasteryIndianSpeed,
			[]() -> bool { return (kbUnitCount(cMyID, cUnitTypeAbstractCavalry, cUnitStateABQ) >= 15); },
			-1, monasteryID);
	}

	// else // We are Japanese.
	//{
	// We don't get anything from the Japanese because all their upgrades are about improving the Monks.
	//}

	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

void chooseConsulateFlag(int consulateID = -1)
{
	int consulatePlanID = -1;
	int randomizer = aiRandInt(100); // 0-99
	int flag_button_id = -1;

	if (gConsulateFlagTechID < 0)
	{
		// Choice biased towards Russians
		if ((cMyCiv == cCivChinese) || (cMyCiv == cCivSPCChinese))
		{
			if (randomizer < 52) // 52 % probability
			{
				flag_button_id = cTechypBigConsulateRussians;
				cvOkToBuildForts = true;
			}
			else if (randomizer < 68) // 16 % probability
			{
				flag_button_id = cTechypBigConsulateBritish;
			}
			else if (randomizer < 84) // 16 % probability
			{
				flag_button_id = cTechypBigConsulateFrench;
			}
			else // 16 % probability
			{
				flag_button_id = cTechypBigConsulateGermans;
			}
		}

		// Choice biased towards Portuguese on water maps, towards others on land maps
		if ((cMyCiv == cCivIndians) || (cMyCiv == cCivSPCIndians))
		{
			if (gHaveWaterSpawnFlag == true)
			{
				if (randomizer < 52) // 52 % probability
				{
				flag_button_id = cTechypBigConsulatePortuguese;
				}
				else if (randomizer < 68) // 16 % probability
				{
				flag_button_id = cTechypBigConsulateBritish;
				}
				else if (randomizer < 84) // 16 % probability
				{
				flag_button_id = cTechypBigConsulateFrench;
				}
				else // 16 % probability
				{
				flag_button_id = cTechypBigConsulateOttomans;
				xsEnableRule("consulateLevy");
				}
			}
			else // land map
			{
				if (randomizer < 16) // 16 % probability
				{
				flag_button_id = cTechypBigConsulatePortuguese;
				}
				else if (randomizer < 44) // 28 % probability
				{
				flag_button_id = cTechypBigConsulateBritish;
				}
				else if (randomizer < 72) // 28 % probability
				{
				flag_button_id = cTechypBigConsulateFrench;
				}
				else // 28 % probability
				{
				flag_button_id = cTechypBigConsulateOttomans;
				xsEnableRule("consulateLevy");
				}
			}
		}

		// Choice biased towards Portuguese on water maps, towards Isolation on land maps
		if ((cMyCiv == cCivJapanese) || (cMyCiv == cCivSPCJapanese) || (cMyCiv == cCivSPCJapanese))
		{
			if (gHaveWaterSpawnFlag == true)
			{
				if (randomizer < 40) // 40 % probability
				{
				flag_button_id = cTechypBigConsulatePortuguese;
				}
				else if (randomizer < 60) // 20 % probability
				{
				flag_button_id = cTechypBigConsulateJapanese;
				}
				else if (randomizer < 80) // 20 % probability
				{
				flag_button_id = cTechypBigConsulateDutch;
				}
				else // 20 % probability
				{
				flag_button_id = cTechypBigConsulateSpanish;
				}
			}
			else // land map
			{
				if (randomizer < 16) // 16 % probability
				{
				flag_button_id = cTechypBigConsulatePortuguese;
				}
				else if (randomizer < 68) // 52 % probability
				{
				flag_button_id = cTechypBigConsulateJapanese;
				}
				else if (randomizer < 84) // 16 % probability
				{
				flag_button_id = cTechypBigConsulateDutch;
				}
				else // 16 % probability
				{
				flag_button_id = cTechypBigConsulateSpanish;
				}
			}
		}

		gConsulateFlagTechID = flag_button_id;
	}

	if (kbTechGetStatus(gConsulateFlagTechID) == cTechStatusObtainable)
	{
		consulatePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, gConsulateFlagTechID);
		if (consulatePlanID < 0)
		{
			debugTechs("************Consulate Flag************");
			debugTechs("Our Consulate flag is: " + kbGetTechName(gConsulateFlagTechID));
			debugTechs("Randomizer value: " + randomizer);
			consulatePlanID = createSimpleResearchPlanSpecificBuilding(gConsulateFlagTechID, consulateID, cEconomyEscrowID, 40);
			aiPlanSetEventHandler(consulatePlanID, cPlanEventStateChange, "consulateFlagHandler");
		}
	}
}

void consulateFlagHandler(int planID = -1)
{
	if (aiPlanGetState(planID) == -1)
	{
		// Done.
		if (kbTechGetStatus(gConsulateFlagTechID) == cTechStatusActive)
		{
			gConsulateFlagChosen = true;
		}
	}
}

rule consulateMonitor
inactive
minInterval 45
{
	int consulateID = getUnit(cUnitTypeypConsulate, cMyID, cUnitStateAlive);
	if (consulateID < 0)
	{
		return;
	}
	// If no option has been chosen already, choose one now
	if (gConsulateFlagChosen == false)
	{
		chooseConsulateFlag(consulateID);
		return;
	}

	// Maximize export generation in Age 4 and above
	if (kbGetAge() >= cAge4 && aiUnitGetTactic(consulateID) != cTacticTax10)
	{
		// Set export gathering rate to +60 %
		aiUnitSetTactic(consulateID, cTacticTax10);
	}

	static bool allTechsActive = false;
	bool isTechActive = false;

	if (allTechsActive == false)
	{
		switch (gConsulateFlagTechID)
		{
		case cTechypBigConsulateBritish:
		{
			// TODO: settlers.
			allTechsActive = true;
			break;
		}
		case cTechypBigConsulateDutch:
		{
			allTechsActive = researchSimpleTech(cTechypConsulateDutchSaloonWagon, -1, consulateID);

			if (researchSimpleTech(cTechypConsulateDutchArsenalWagon, -1, consulateID) == true)
			{
				xsEnableRule("arsenalUpgradeMonitor");
			}
			else
			{
				allTechsActive = false;
			}

			if (researchSimpleTech(cTechypConsulateDutchChurchWagon, -1, consulateID) == true)
			{
				xsEnableRule("churchUpgradeMonitor");
			}
			else
			{
				allTechsActive = false;
			}
			break;
		}
		case cTechypBigConsulateFrench:
		{
			// TODO: resource crates.
			allTechsActive = true;
			break;
		}
		case cTechypBigConsulateGermans:
		{
			// TODO: trickles.
			allTechsActive = true;
			break;
		}
		case cTechypBigConsulateJapanese:
		{
			// (Clan offerings)
			// ypConsulateJapaneseKoujou - spawn samurai at each castle, pretty useless most of the time.

			// Allow training units in a batch of 10.
			allTechsActive = researchSimpleTech(cTechypConsulateJapaneseMasterTraining, -1, consulateID);
			break;
		}
		case cTechypBigConsulateOttomans:
		{
			// (Great bombards)
			allTechsActive = researchSimpleTech(cTechypConsulateOttomansGunpowderSiege, -1, consulateID);
			break;
		}
		case cTechypBigConsulatePortuguese:
		{
			// (Ironclad)
			if (gHaveWaterSpawnFlag == true)
			{
				allTechsActive = researchSimpleTech(cTechypConsulatePortugueseExpeditionaryFleet, -1, consulateID);
			}
			else
			{
				allTechsActive = true;
			}
			break;
		}
		case cTechypBigConsulateOttomans:
		{
			// (Great bombards)
			allTechsActive = researchSimpleTech(cTechypConsulateOttomansGunpowderSiege, -1, consulateID);
			break;
		}
		case cTechypBigConsulateRussians:
		{
			// (blockhouse wagon)
			allTechsActive &= researchSimpleTech(cTechypConsulateRussianOutpostWagon, -1, consulateID);
			allTechsActive &= researchSimpleTech(cTechypConsulateRussianFortWagon, -1, consulateID);
			allTechsActive &= researchSimpleTech(cTechypConsulateRussianFactoryWagon, -1, consulateID);
			break;
		}
		case cTechypBigConsulateSpanish:
		{
			allTechsActive = true;
			break;
		}
		}
	}

	if (cvOkToTrainArmy == false)
		return;

	// Maintain plans
	static int consulateUPID = -1;
	static int consulateMaintainPlans = -1;

	if (consulateUPID < 0)
	{
		// Create it.
		consulateUPID = kbUnitPickCreate("Consulate army");
		if (consulateUPID < 0)
			return;

		consulateMaintainPlans = xsArrayCreateInt(4, -1, "Consulate maintain plans");
	}

	int numberResults = 0;
	int trainUnitID = -1;
	int planID = -1;
	int numberToMaintain = 0;
	int mainBaseID = kbBaseGetMainID(cMyID);

	// Default init.
	kbUnitPickResetAll(consulateUPID);
	// Desired number units types, buildings.
	kbUnitPickSetDesiredNumberUnitTypes(consulateUPID, 2, 1, true);

	setUnitPickerCommon(consulateUPID);

	kbUnitPickSetMinimumCounterModePop(consulateUPID, 15);
	kbUnitPickSetPreferenceFactor(consulateUPID, cUnitTypeAbstractConsulateSiegeFortress, 1.0);
	kbUnitPickSetPreferenceFactor(consulateUPID, cUnitTypeAbstractConsulateSiegeIndustrial, 1.0);
	kbUnitPickSetPreferenceFactor(consulateUPID, cUnitTypeAbstractConsulateUnit, 1.0);
	kbUnitPickSetPreferenceFactor(consulateUPID, cUnitTypeAbstractConsulateUnitColonial, 1.0);
	// Banner armies are calculated with a weighed average of unit types the banner army contains
	kbUnitPickRemovePreferenceFactor(consulateUPID, cUnitTypeAbstractBannerArmy);
	kbUnitPickRun(consulateUPID);

	for (i = 0; < 2)
	{
		trainUnitID = kbUnitPickGetResult(consulateUPID, i);
		planID = xsArrayGetInt(consulateMaintainPlans, i);
		if (planID >= 0)
		{
			if (trainUnitID == aiPlanGetVariableInt(planID, cTrainPlanUnitType, 0))
			{
				numberToMaintain = kbResourceGet(cResourceTrade) / kbUnitCostPerResource(trainUnitID, cResourceTrade);
				aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, numberToMaintain);
				continue;
			}
			aiPlanDestroy(planID);
		}
		if (trainUnitID < 0)
			continue;
		numberToMaintain = kbResourceGet(cResourceTrade) / kbUnitCostPerResource(trainUnitID, cResourceTrade);
		planID = createSimpleMaintainPlan(trainUnitID, numberToMaintain, false, mainBaseID, 1);
		aiPlanSetDesiredResourcePriority(planID, 45 - i); // below research plans
		xsArraySetInt(consulateMaintainPlans, i, planID);
	}
}

rule agraFortUpgradeMonitor
inactive
minInterval 90
{
	// Check for the Agra Fort, if we don't find one we've lost it and we can disable this Rule.
	int agraFortID = getUnit(gAgraFortPUID);
	if (agraFortID < 0)
	{
		xsDisableSelf();
		return;
	}

	bool canDisableSelf = researchSimpleTech(cTechypFrontierAgra, -1, agraFortID);
	
	if (cDifficultyCurrent >= cDifficultyModerate)
	{
		canDisableSelf &= researchSimpleTech(cTechypFortifiedAgra, -1, agraFortID);
	}
	
	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}

rule shrineUpgradeMonitor
inactive
minInterval 60
{
	// Disable Rule once the upgrade is active.
	if (kbTechGetStatus(cTechypShrineFortressUpgrade) == cTechStatusActive)
	{
		xsDisableSelf();
		return;
	}
	int threshold = 15;
	int toshoguShrineID = getUnit(gToshoguShrinePUID);
	// Check for the Toshogu Shrine, this building boosts our Shrines so can have a lower threshold.
	if (toshoguShrineID >= 0)
	{
		threshold = 10;
	}
	
	int shrineCount = kbUnitCount(cMyID, cUnitTypeypShrineJapanese, cUnitStateABQ);

	int planID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, cTechypShrineFortressUpgrade);
	if (planID >= 0)
	{
		if (shrineCount < threshold)
		{
			aiPlanDestroy(planID);
		}
	}
	else
	{
		if (shrineCount >= threshold)
		{
			researchSimpleTech(cTechypShrineFortressUpgrade, cUnitTypeypShrineJapanese);
		}
	}
}

rule cityTowerUpgradeMonitor
inactive
minInterval 60
{
	bool canDisableSelf = researchSimpleTechByCondition(
		cTechDESPCCannonTowers, 
		// Research once we have towers on every socket we owned.
		[]() -> bool {
			return (kbUnitCount(cMyID, cUnitTypedeSPCCityTower, cUnitStateABQ) >= kbUnitCount(cMyID, cUnitTypedeSPCSocketCityTower, cUnitStateAny));
		},
		cUnitTypedeSPCCityTower
	);

	canDisableSelf &= researchSimpleTechByCondition(
		cTechDESPCTraceItalienne,
		// Research once we have towers on every socket we owned.
		[]() -> bool {
			return (kbUnitCount(cMyID, cUnitTypedeSPCCityTower, cUnitStateABQ) >= kbUnitCount(cMyID, cUnitTypedeSPCSocketCityTower, cUnitStateAny));
		},
		cUnitTypedeSPCCityTower
	);

	if (canDisableSelf == true)
	{
		xsDisableSelf();
	}
}
