// ================================================================================
//	aiSetup.xs - Initialize the data we will use for the AI.
// ================================================================================


// ================================================================================
//	initMapData() - Gather vector data about the map, my allies, and my enemies.
// ================================================================================
void initMapData(void)
{
	int numAllies = getAllyCount();
	vector allyBaseLocation = cInvalidVector;
	int numEnemies = getEnemyCount();
	vector enemyBaseLocation = cInvalidVector;
	avgEnemyBaseLocation = cInvalidVector;
	vector north = cInvalidVector;

	int tcUnit = getUnit(cUnitTypeLogicalTypeTCBuildLimit);
	int explorerUnit = getUnit(cUnitTypeHero);
	if (tcUnit >= 0)
		gHomeBase = kbUnitGetPosition(tcUnit);
	else if (explorerUnit >= 0)
		gHomeBase = kbUnitGetPosition(explorerUnit);
	else
		gHomeBase = kbGetPlayerStartingPosition(cMyID);

	gAllyBaseArray = arrayCreateVector(numAllies, "Ally Base Array");
	gEnemyBaseArray = arrayCreateVector(numEnemies, "Enemy Base Array");

	for (player = 1; < cNumberPlayers) // 0 is Gaia.
	{
		if (kbIsPlayerAlly(player))
		{
			if (player == cMyID)
				continue;
			allyBaseLocation = kbGetPlayerStartingPosition(player);
			arrayPushVector(gAllyBaseArray, allyBaseLocation);
		}
		else if (kbIsPlayerEnemy(player))
		{
			enemyBaseLocation = kbGetPlayerStartingPosition(player);
			arrayPushVector(gEnemyBaseArray, enemyBaseLocation);
		}
	}

	for (i = 0; < numEnemies)
	{
		if (avgEnemyBaseLocation == cInvalidVector)
			avgEnemyBaseLocation = arrayGetVector(gEnemyBaseArray, i);
		else
			avgEnemyBaseLocation = avgEnemyBaseLocation + arrayGetVector(gEnemyBaseArray, i);
	}
	avgEnemyBaseLocation = avgEnemyBaseLocation / numEnemies;
	// Acts like a compass with North facing the average vector of the middle of the Map
	// and the average enemy location.
	north = ((kbGetMapCenter() - gHomeBase) + (avgEnemyBaseLocation - gHomeBase)) / 2.0;

	// Vectors for Directions.
	gDirection_UP = xsVectorNormalize(north);
	gDirection_DOWN = gDirection_UP * -1.0;
	gDirection_RIGHT = xsVectorSet(xsVectorGetZ(gDirection_UP), 0.0, xsVectorGetX(gDirection_UP) * -1.0);
	gDirection_LEFT = gDirection_RIGHT * -1.0;

	xsArraySetString(gMapNames, 0, "afatlas");
	xsArraySetString(gMapNames, 1, "afatlaslarge");
	xsArraySetString(gMapNames, 2, "afdarfur");
	xsArraySetString(gMapNames, 3, "afdarfurlarge");
	xsArraySetString(gMapNames, 4, "afdunes");
	xsArraySetString(gMapNames, 5, "afduneslarge");
	xsArraySetString(gMapNames, 6, "afgold coast");
	xsArraySetString(gMapNames, 7, "afgold coastlarge");
	xsArraySetString(gMapNames, 8, "afgreat rift");
	xsArraySetString(gMapNames, 9, "afgreat riftlarge");
	xsArraySetString(gMapNames, 10, "afhighlands");
	xsArraySetString(gMapNames, 11, "afhighlandslarge");
	xsArraySetString(gMapNames, 12, "afhorn");
	xsArraySetString(gMapNames, 13, "afhornlarge");
	xsArraySetString(gMapNames, 14, "afivorycoast");
	xsArraySetString(gMapNames, 15, "afivorycoastlarge");
	xsArraySetString(gMapNames, 16, "aflakechad");
	xsArraySetString(gMapNames, 17, "aflakechadlarge");
	xsArraySetString(gMapNames, 18, "afnigerdelta");
	xsArraySetString(gMapNames, 19, "afnigerdeltalarge");
	xsArraySetString(gMapNames, 20, "afniger river");
	xsArraySetString(gMapNames, 21, "afniger riverlarge");
	xsArraySetString(gMapNames, 22, "afnile valley");
	xsArraySetString(gMapNames, 23, "afnile valleylarge");
	xsArraySetString(gMapNames, 24, "afpeppercoast");
	xsArraySetString(gMapNames, 25, "afpeppercoastlarge");
	xsArraySetString(gMapNames, 26, "afsahel");
	xsArraySetString(gMapNames, 27, "afsahellarge");
	xsArraySetString(gMapNames, 28, "afsavanna");
	xsArraySetString(gMapNames, 29, "afsavannalarge");
	xsArraySetString(gMapNames, 30, "afsiwaoasis");
	xsArraySetString(gMapNames, 31, "afsiwaoasislarge");
	xsArraySetString(gMapNames, 32, "afsudd");
	xsArraySetString(gMapNames, 33, "afsuddlarge");
	xsArraySetString(gMapNames, 34, "afswahilicoast");
	xsArraySetString(gMapNames, 35, "afswahilicoastlarge");
	xsArraySetString(gMapNames, 36, "aftassili");
	xsArraySetString(gMapNames, 37, "aftassililarge");
	xsArraySetString(gMapNames, 38, "aftripolitania");
	xsArraySetString(gMapNames, 39, "aftripolitanialarge");
	xsArraySetString(gMapNames, 40, "alaska");
	xsArraySetString(gMapNames, 41, "alaskalarge");
	xsArraySetString(gMapNames, 42, "amazonia");
	xsArraySetString(gMapNames, 43, "amazonialarge");
	xsArraySetString(gMapNames, 44, "andes upper");
	xsArraySetString(gMapNames, 45, "andes upperlarge");
	xsArraySetString(gMapNames, 46, "andes");
	xsArraySetString(gMapNames, 47, "andeslarge");
	xsArraySetString(gMapNames, 48, "araucania");
	xsArraySetString(gMapNames, 49, "araucanialarge");
	xsArraySetString(gMapNames, 50, "arctic territories");
	xsArraySetString(gMapNames, 51, "arctic territorieslarge");
	xsArraySetString(gMapNames, 52, "bahia");
	xsArraySetString(gMapNames, 53, "bahialarge");
	xsArraySetString(gMapNames, 54, "baja california");
	xsArraySetString(gMapNames, 55, "baja californialarge");
	xsArraySetString(gMapNames, 56, "bayou");
	xsArraySetString(gMapNames, 57, "bayoularge");
	xsArraySetString(gMapNames, 58, "bengal");
	xsArraySetString(gMapNames, 59, "bengallarge");
	xsArraySetString(gMapNames, 60, "borneo");
	xsArraySetString(gMapNames, 61, "borneolarge");
	xsArraySetString(gMapNames, 62, "california");
	xsArraySetString(gMapNames, 63, "californialarge");
	xsArraySetString(gMapNames, 64, "caribbean");
	xsArraySetString(gMapNames, 65, "caribbeanlarge");
	xsArraySetString(gMapNames, 66, "carolina");
	xsArraySetString(gMapNames, 67, "carolinalarge");
	xsArraySetString(gMapNames, 68, "cascade range");
	xsArraySetString(gMapNames, 69, "cascade rangelarge");
	xsArraySetString(gMapNames, 70, "central plain");
	xsArraySetString(gMapNames, 71, "central plainlarge");
	xsArraySetString(gMapNames, 72, "ceylon");
	xsArraySetString(gMapNames, 73, "ceylonlarge");
	xsArraySetString(gMapNames, 74, "colorado");
	xsArraySetString(gMapNames, 75, "coloradolarge");
	xsArraySetString(gMapNames, 76, "dakota");
	xsArraySetString(gMapNames, 77, "dakotalarge");
	xsArraySetString(gMapNames, 78, "deccan");
	xsArraySetString(gMapNames, 79, "deccanLarge");
	xsArraySetString(gMapNames, 80, "fertile crescent");
	xsArraySetString(gMapNames, 81, "fertile crescentlarge");
	xsArraySetString(gMapNames, 82, "florida");
	xsArraySetString(gMapNames, 83, "floridalarge");
	xsArraySetString(gMapNames, 84, "gran chaco");
	xsArraySetString(gMapNames, 85, "gran chacolarge");
	xsArraySetString(gMapNames, 86, "great lakes");
	xsArraySetString(gMapNames, 87, "greak lakesLarge");
	xsArraySetString(gMapNames, 88, "great plains");
	xsArraySetString(gMapNames, 89, "great plainslarge");
	xsArraySetString(gMapNames, 90, "himalayas");
	xsArraySetString(gMapNames, 91, "himalayaslarge");
	xsArraySetString(gMapNames, 92, "himalayasupper");
	xsArraySetString(gMapNames, 93, "himalayasupperlarge");
	xsArraySetString(gMapNames, 94, "hispaniola");
	xsArraySetString(gMapNames, 95, "hispaniolalarge");
	xsArraySetString(gMapNames, 96, "hokkaido");
	xsArraySetString(gMapNames, 97, "hokkaidolarge");
	xsArraySetString(gMapNames, 98, "honshu");
	xsArraySetString(gMapNames, 99, "honshularge");
	xsArraySetString(gMapNames, 100, "honshuregicide");
	xsArraySetString(gMapNames, 101, "honshuregicidelarge");
	xsArraySetString(gMapNames, 102, "indochina");
	xsArraySetString(gMapNames, 103, "indochinalarge");
	xsArraySetString(gMapNames, 104, "indonesia");
	xsArraySetString(gMapNames, 105, "indonesialarge");
	xsArraySetString(gMapNames, 106, "kamchatka");
	xsArraySetString(gMapNames, 107, "kamchatkalarge");
	xsArraySetString(gMapNames, 108, "korea");
	xsArraySetString(gMapNames, 109, "korealarge");
	xsArraySetString(gMapNames, 110, "malaysia");
	xsArraySetString(gMapNames, 111, "malaysialarge");
	xsArraySetString(gMapNames, 112, "manchuria");
	xsArraySetString(gMapNames, 113, "manchurialarge");
	xsArraySetString(gMapNames, 114, "mexico");
	xsArraySetString(gMapNames, 115, "mexicolarge");
	xsArraySetString(gMapNames, 116, "minasgerais");
	xsArraySetString(gMapNames, 117, "minasgeraislarge");
	xsArraySetString(gMapNames, 118, "mongolia");
	xsArraySetString(gMapNames, 119, "mongolialarge");
	xsArraySetString(gMapNames, 120, "new england");
	xsArraySetString(gMapNames, 121, "new englandlarge");
	xsArraySetString(gMapNames, 122, "northwest territory");
	xsArraySetString(gMapNames, 123, "northwest territorylarge");
	xsArraySetString(gMapNames, 124, "orinoco");
	xsArraySetString(gMapNames, 125, "orinocolarge");
	xsArraySetString(gMapNames, 126, "ozarks");
	xsArraySetString(gMapNames, 127, "ozarkslarge");
	xsArraySetString(gMapNames, 128, "painted desert");
	xsArraySetString(gMapNames, 129, "painted desertlarge");
	xsArraySetString(gMapNames, 130, "pampas sierras");
	xsArraySetString(gMapNames, 131, "pampas sierraslarge");
	xsArraySetString(gMapNames, 132, "pampas");
	xsArraySetString(gMapNames, 133, "pampas large");
	xsArraySetString(gMapNames, 134, "parallel rivers");
	xsArraySetString(gMapNames, 135, "parallel riverslarge");
	xsArraySetString(gMapNames, 136, "patagonia");
	xsArraySetString(gMapNames, 137, "patagonialarge");
	xsArraySetString(gMapNames, 138, "plymouth");
	xsArraySetString(gMapNames, 139, "plymouthlarge");
	xsArraySetString(gMapNames, 140, "punjab");
	xsArraySetString(gMapNames, 141, "punjablarge");
	xsArraySetString(gMapNames, 142, "rockies");
	xsArraySetString(gMapNames, 143, "rockieslarge");
	xsArraySetString(gMapNames, 144, "saguenay");
	xsArraySetString(gMapNames, 145, "saguenaylarge");
	xsArraySetString(gMapNames, 146, "siberia");
	xsArraySetString(gMapNames, 147, "siberialarge");
	xsArraySetString(gMapNames, 148, "silkroad");
	xsArraySetString(gMapNames, 149, "silkroadlarge");
	xsArraySetString(gMapNames, 150, "sonora");
	xsArraySetString(gMapNames, 151, "sonoralarge");
	xsArraySetString(gMapNames, 152, "texas");
	xsArraySetString(gMapNames, 153, "texaslarge");
	xsArraySetString(gMapNames, 154, "unknown");
	xsArraySetString(gMapNames, 155, "unknownlarge");
	xsArraySetString(gMapNames, 156, "yellow riverdry");
	xsArraySetString(gMapNames, 157, "yellow riverdrylarge");
	xsArraySetString(gMapNames, 158, "yucatan");
	xsArraySetString(gMapNames, 159, "yucatanlarge");
	xsArraySetString(gMapNames, 160, "yukon");
	xsArraySetString(gMapNames, 161, "yukonlarge");
	xsArraySetString(gMapNames, 162, "aftranssahara");
	xsArraySetString(gMapNames, 163, "aftranssaharalarge");
	xsArraySetString(gMapNames, 164, "aflostsahara");
	xsArraySetString(gMapNames, 165, "aflostsaharalarge");
	xsArraySetString(gMapNames, 166, "guianas");
	xsArraySetString(gMapNames, 167, "guianaslarge");
	xsArraySetString(gMapNames, 168, "panama");
	xsArraySetString(gMapNames, 169, "panamalarge");
	xsArraySetString(gMapNames, 170, "texasfrontier");
	xsArraySetString(gMapNames, 171, "texasfrontierlarge");
	xsArraySetString(gMapNames, 172, "aflakevictoria");
	xsArraySetString(gMapNames, 173, "aflakevictorialarge");
	xsArraySetString(gMapNames, 174, "afarabia");
	xsArraySetString(gMapNames, 175, "afarabialarge");
	xsArraySetString(gMapNames, 176, "afcongobasin");
	xsArraySetString(gMapNames, 177, "afcongobasinlarge");
	xsArraySetString(gMapNames, 178, "eualps");
	xsArraySetString(gMapNames, 179, "eualpslarge");
	xsArraySetString(gMapNames, 180, "euantolia");
	xsArraySetString(gMapNames, 181, "euanatolialarge");
	xsArraySetString(gMapNames, 182, "euarchipelago");
	xsArraySetString(gMapNames, 183, "euarchipelagolarge");
	xsArraySetString(gMapNames, 184, "eubalkans");
	xsArraySetString(gMapNames, 185, "eubalkanslarge");
	xsArraySetString(gMapNames, 186, "eublackforest");
	xsArraySetString(gMapNames, 187, "eublackforestlarge");
	xsArraySetString(gMapNames, 188, "eubohemia");
	xsArraySetString(gMapNames, 189, "eubohemialarge");
	xsArraySetString(gMapNames, 190, "eucarpathians");
	xsArraySetString(gMapNames, 191, "eucarpathianslarge");
	xsArraySetString(gMapNames, 192, "eudanishstrait");
	xsArraySetString(gMapNames, 193, "eudanishstraitlarge");
	xsArraySetString(gMapNames, 194, "eudeluge");
	xsArraySetString(gMapNames, 195, "eudnieperbasin");
	xsArraySetString(gMapNames, 196, "eudnieperbasinlarge");
	xsArraySetString(gMapNames, 197, "eueightyyearswar");
	xsArraySetString(gMapNames, 198, "euengland");
	xsArraySetString(gMapNames, 199, "euenglandlarge");
	xsArraySetString(gMapNames, 200, "eufinland");
	xsArraySetString(gMapNames, 201, "eufinlandlarge");
	xsArraySetString(gMapNames, 202, "eufrance");
	xsArraySetString(gMapNames, 203, "eufrancelarge");
	xsArraySetString(gMapNames, 204, "eugreatnorthernwar");
	xsArraySetString(gMapNames, 205, "eugreatturkishwar");
	xsArraySetString(gMapNames, 206, "euhungarianplans");
	xsArraySetString(gMapNames, 207, "euhungarianplanslarge");
	xsArraySetString(gMapNames, 208, "euiberia");
	xsArraySetString(gMapNames, 209, "euiberialarge");
	xsArraySetString(gMapNames, 210, "euireland");
	xsArraySetString(gMapNames, 211, "euirelandlarge");
	xsArraySetString(gMapNames, 212, "euitalianwars");
	xsArraySetString(gMapNames, 213, "euitaly");
	xsArraySetString(gMapNames, 214, "euitalylarge");
	xsArraySetString(gMapNames, 215, "eulowcountries");
	xsArraySetString(gMapNames, 216, "eulowcountrieslarge");
	xsArraySetString(gMapNames, 217, "eunapoleonicwars");
	xsArraySetString(gMapNames, 218, "eupripetmarshes");
	xsArraySetString(gMapNames, 219, "eupripetmarsheslarge");
	xsArraySetString(gMapNames, 220, "eupyrenees");
	xsArraySetString(gMapNames, 221, "eupyreneeslarge");
	xsArraySetString(gMapNames, 222, "eurussoturkwar");
	xsArraySetString(gMapNames, 223, "eusardiniacorsica");
	xsArraySetString(gMapNames, 224, "eusardiniacorsicalarge");
	xsArraySetString(gMapNames, 225, "eusaxony");
	xsArraySetString(gMapNames, 226, "eusaxonylarge");
	xsArraySetString(gMapNames, 227, "euscandinavia");
	xsArraySetString(gMapNames, 228, "euscandinavialarge");
	xsArraySetString(gMapNames, 229, "euthirtyyearswar");
	xsArraySetString(gMapNames, 230, "euvistulabasin");
	xsArraySetString(gMapNames, 231, "euvistulabasinlarge");
	xsArraySetString(gMapNames, 232, "euwallachia");
	xsArraySetString(gMapNames, 233, "euwallachialarge");
	// List above is up to date for the Italy/Malta release.

	debugSetup("         Analyzing Map");
	debugSetup("Map name is: " + cRandomMapName);

	// Disable any LOST maps.
	if ((cRandomMapName == "afLOSTSahara") || (cRandomMapName == "afLOSTSaharaLarge"))
	{
		aiErrorMessageId(111386); // "This map cannot be played by the AI."
		cvInactiveAI = true;
	}
	
	// Initialize all the global water variables so we know what we're dealing with on this map.
	gWaterSpawnFlagID = getUnit(cUnitTypeHomeCityWaterSpawnFlag, cMyID);
	if (gWaterSpawnFlagID >= 0)
	{
		gNavyVec = kbUnitGetPosition(gWaterSpawnFlagID);
		gHaveWaterSpawnFlag = true;
		gNavyMap = true;
	}
	else
	{
		debugSetup("We have no Water Spawn Flag, leaving all navy related variables on false/invalid");
	}

	if (gNavyMap == true)
	{
		xsEnableRule("waterExplore");
		waterExplore(); // Call instantly to start scouting if we have starting ships.
	}

	// Basically if we find any fish on the map we decide it's a good fishing map.
	if (getGaiaUnitCount(cUnitTypeFish) > 0)
	{
		gGoodFishingMap = true;
	}
	debugSetup("gGoodFishingMap = " + gGoodFishingMap);

	// Check for island map and starting on different islands.
	vector tempPlayerVec = cInvalidVector;
	int tempBaseVecAreaGroupID = kbAreaGroupGetIDByPosition(gHomeBase);
	gIslandMap = kbGetIslandMap();
	for (player = 1; < cNumberPlayers)
	{
		if (player == cMyID)
		{
			continue;
		}
		tempPlayerVec = kbGetPlayerStartingPosition(player);
		if (tempPlayerVec == cInvalidVector)
		{
			continue;
		}
		if (kbAreAreaGroupsPassableByLand(tempBaseVecAreaGroupID, kbAreaGroupGetIDByPosition(tempPlayerVec)) == false)
		{
			gStartOnDifferentIslands = true;
			break;
		}
	}
	debugSetup("Island map is " + gIslandMap + ", players start on different islands is " + gStartOnDifferentIslands);

	// On these maps we want to transport, which is what aiSetWaterMap is used for.
	if (gStartOnDifferentIslands == true)
	{
		aiSetWaterMap(true);
	}

	gNumberTradeRoutes = kbGetNumberTradeRoutes();
	if (gNumberTradeRoutes > 0)
	{
		debugSetup("Amount of Trading Routes found: " + gNumberTradeRoutes);
		gTradeRouteIndexAndType = xsArrayCreateInt(gNumberTradeRoutes, -1, "Trade Route Types");
		gTradeRouteIndexMaxUpgraded = xsArrayCreateBool(gNumberTradeRoutes, false, "Trade Route Max Upgraded");
		gTradeRouteCrates = xsArrayCreateInt(
			gNumberTradeRoutes * 4, -1, "Trade Route Crates"); // We have to save 4 crates per route. Infuence is always to same
																// but must be saved for the logic to work.
		gTradeRouteUpgrades = xsArrayCreateInt(
			gNumberTradeRoutes * 2, -1, "Trade Route Upgrades"); // Always 2 upgrades per route.

		int firstMovingUnit = -1;
		int firstMovingUnitProtoID = -1;
		for (i = 0; < gNumberTradeRoutes)
		{
			xsSetContextPlayer(0);
			if (kbUnitGetPlayerID(kbTradeRouteGetTradingPostID(i, 0)) == 0)
			{
				xsSetContextPlayer(cMyID);
				xsArraySetBool(gTradeRouteIndexMaxUpgraded, i, true);
				if (kbTechGetStatus(cTechdeMapAfrican) == cTechStatusActive)
				{
					debugSetup("Route: " + i + " is an African capturable Trading Route which can't be upgraded");
					xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteCapturableAfrica);
					xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypedeCrateofFoodAfrican1);
					xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypedeCrateofWoodAfrican1);
					xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypedeCrateofCoinAfrican1);
					xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
				}
				else
				{
					debugSetup("Route: " + i + " is an Asian capturable Trading Route which can't be upgraded");
					xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteCapturableAsia);
					xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypeypTradeCrateofFood);
					xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypeypTradeCrateofWood);
					xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypeypTradeCrateofCoin);
					xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
				}
				continue;
			}
			xsSetContextPlayer(cMyID);
			firstMovingUnit = kbTradeRouteGetUnit(i, 0);
			firstMovingUnitProtoID = kbUnitGetProtoUnitID(firstMovingUnit);
			if ((firstMovingUnitProtoID == cUnitTypedeTradingShip) || (firstMovingUnitProtoID == cUnitTypedeTradingGalleon) ||
				(firstMovingUnitProtoID == cUnitTypedeTradingFluyt))
			{
				debugSetup("Route: " + i + " is a Naval Trading Route");
				xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteNaval);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (i * 2), cTechDETradeRouteUpgradeWater1);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (i * 2), cTechDETradeRouteUpgradeWater2);
				xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypedeCrateofFoodWater);
				xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypedeCrateofWoodWater);
				xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypedeCrateofCoinWater);
				xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
			}
			else if (kbTechGetStatus(cTechDEEnableTradeRouteNativeAmerican) == cTechStatusActive)
			{
				debugSetup("Route: " + i + " is a South American Trading Route");
				xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteSouthAmerica);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (i * 2), cTechdeTradeRouteUpgradeAmerica1);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (i * 2), cTechdeTradeRouteUpgradeAmerica2);
				xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypedeCrateofFoodAmerican);
				xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypedeCrateofWoodAmerican);
				xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypedeCrateofCoinAmerican);
				xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
			}
			else if (kbTechGetStatus(cTechYPEnableAsianNativeOutpost) == cTechStatusActive)
			{
				debugSetup("Route: " + i + " is an Asian Trading Route");
				xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteAsia);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (i * 2), cTechypTradeRouteUpgrade1);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (i * 2), cTechypTradeRouteUpgrade2);
				xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypeypCrateofFood1);
				xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypeypCrateofWood1);
				xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypeypCrateofCoin1);
				xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
			}
			else if (kbTechGetStatus(cTechDEEnableTradeRouteAfrican) == cTechStatusActive)
			{
				debugSetup("Route: " + i + " is an African Trading Route");
				xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteAfrica);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (i * 2), cTechDETradeRouteUpgradeAfrica1);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (i * 2), cTechDETradeRouteUpgradeAfrica2);
				xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypedeCrateofFoodAfrican);
				xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypedeCrateofWoodAfrican);
				xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypedeCrateofCoinAfrican);
				xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
			}
			else if (kbTechGetStatus(cTechDEEnableTradeRouteUpgradeAll) == cTechStatusActive)
			{
				debugSetup(
					"Route: " + i +
					" is a special North American Trading Route where upgrading one route also upgrades all the others, we can't play smart with this");
				xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteAll);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (i * 2), cTechDETradeRouteUpgradeAll1);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (i * 2), cTechDETradeRouteUpgradeAll2);
				xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypedeCrateofFood);
				xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypedeCrateofWood);
				xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypedeCrateofCoin);
				xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
			}
			else // It all defaults to North America.
			{
				debugSetup("Route: " + i + " is a North American Trading Route");
				xsArraySetInt(gTradeRouteIndexAndType, i, cTradeRouteNorthAmerica);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteFirstUpgrade + (i * 2), cTechTradeRouteUpgrade1);
				xsArraySetInt(gTradeRouteUpgrades, cTradeRouteSecondUpgrade + (i * 2), cTechTradeRouteUpgrade2);
				xsArraySetInt(gTradeRouteCrates, 0 + (i * 4), cUnitTypeTradeCrateofFood);
				xsArraySetInt(gTradeRouteCrates, 1 + (i * 4), cUnitTypeTradeCrateofWood);
				xsArraySetInt(gTradeRouteCrates, 2 + (i * 4), cUnitTypeTradeCrateofCoin);
				xsArraySetInt(gTradeRouteCrates, 3 + (i * 4), cUnitTypedeTradeCrateofInfluence);
			}
		}
	}
	else
	{
		debugSetup("We found no Trading Routes on this map");
	}
}


// ================================================================================
//	initCiv() - Set up civlization-specific data.
// ================================================================================
void initCiv(void) {
	// Listing is somewhat repetitive, but do it anyway for clarity.
	gAgeUpList = arrayCreateInt(1, "Age-Up List");
	int tempShuffleArray = -1;
	int firstIndex = -1;

	switch (cMyCiv) {
		case cCivSpanish: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseMed;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianPhilosopherPrince);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechPoliticianEngineer);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivBritish: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeManor;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianPhilosopherPrince);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechPoliticianTycoon);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivFrench: {
			gEconUnit = cUnitTypeCoureur;
			gHouseUnit = cUnitTypeHouse;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianQuartermaster);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechPoliticianTycoon);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivPortuguese: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseMed;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianQuartermaster);
			arrayPushInt(gAgeUpList, cTechPoliticianExiledPrince);
			arrayPushInt(gAgeUpList, cTechPoliticianTycoon);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivDutch: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouse;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeFluyt;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianQuartermaster);
			arrayPushInt(gAgeUpList, cTechPoliticianExiledPrince);
			arrayPushInt(gAgeUpList, cTechPoliticianTycoon);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivRussians: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseEast;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBlockhouse;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeBlockhouse;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianQuartermaster);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechPoliticianEngineer);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivGermans: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseEast;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianQuartermaster);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechPoliticianTycoon);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivOttomans: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseMed;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeGalley;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianQuartermaster);
			arrayPushInt(gAgeUpList, cTechPoliticianExiledPrince);
			arrayPushInt(gAgeUpList, cTechPoliticianTycoon);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivDESwedish: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypedeTorp;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianPhilosopherPrince);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechPoliticianEngineer);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
			break;
		}
		case cCivDEItalians: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseMed;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypedeGalleass;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianPhilosopherPrince);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechDEPoliticianPope);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
		}
		case cCivDEMaltese: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseMed;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypedeHospital;
			gStableUnit = cUnitTypedeCommandery;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypedeOrderGalley;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			arrayPushInt(gAgeUpList, cTechPoliticianQuartermaster);
			arrayPushInt(gAgeUpList, cTechPoliticianBishopFortress);
			arrayPushInt(gAgeUpList, cTechDEPoliticianPope);
			arrayPushInt(gAgeUpList, cTechPoliticianPresidente);
		}
		case cCivDEAmericans: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouse;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeMill;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeLivestockPen;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypedeSloop;
			gGalleonUnit = cUnitTypedeSteamer;
			gFrigateUnit = -1;
			gMonitorUnit = cUnitTypexpIronclad;

			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalMassachusetts);
			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalNewHampshire);
			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalVermont);
			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalTexas);
			break;
		}
		case cCivDEMexicans: {
			gEconUnit = cUnitTypeSettler;
			gHouseUnit = cUnitTypeHouseMed;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypedeHacienda;
			gPlantationUnit = cUnitTypedeHacienda;
			gLivestockPenUnit = cUnitTypedeHacienda;
			gBarracksUnit = cUnitTypeBarracks;
			gStableUnit = cUnitTypeStable;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeOutpost;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypedeSloop;
			gGalleonUnit = cUnitTypedeSteamer;
			gFrigateUnit = -1;
			gMonitorUnit = cUnitTypexpIronclad;

			gFarmFoodTactic = cTacticHaciendaFood;
			gFarmGoldTactic = cTacticHaciendaCoin;

			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalMXQueretaro);
			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalMXCoahuila);
			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalMXGuanajuato);
			arrayPushInt(gAgeUpList, cTechDEPoliticianFederalMXJalisco);
			break;
		}
		case cCivXPIroquois: {
			gEconUnit = cUnitTypeSettlerNative;
			gHouseUnit = cUnitTypeLonghouse;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeFarm;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeFarm;
			gBarracksUnit = cUnitTypeWarHut;
			gStableUnit = cUnitTypeCorral;
			gArtilleryDepotUnit = cUnitTypeArtilleryDepot;
			gTowerUnit = cUnitTypeWarHut;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypexpWarCanoe;
			gGalleonUnit = cUnitTypeCanoe;
			gFrigateUnit = -1;
			gMonitorUnit = -1;

			arrayPushInt(gAgeUpList, cTechTribalIroquoisWisewoman2);
			arrayPushInt(gAgeUpList, cTechTribalIroquoisYouth3);
			arrayPushInt(gAgeUpList, cTechTribalIroquoisChief4);
			arrayPushInt(gAgeUpList, cTechTribalIroquoisWarrior5);
			break;
		}
		case cCivXPSioux: {
			gEconUnit = cUnitTypeSettlerNative;
			gHouseUnit = -1;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeFarm;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeFarm;
			gBarracksUnit = cUnitTypeWarHut;
			gStableUnit = cUnitTypeCorral;
			gArtilleryDepotUnit = -1;
			gTowerUnit = cUnitTypeWarHut;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypexpWarCanoe;
			gGalleonUnit = cUnitTypeCanoe;
			gFrigateUnit = -1;
			gMonitorUnit = -1;

			arrayPushInt(gAgeUpList, cTechTribalSiouxChief2);
			arrayPushInt(gAgeUpList, cTechTribalSiouxShaman3);
			arrayPushInt(gAgeUpList, cTechTribalSiouxWisewoman4);
			arrayPushInt(gAgeUpList, cTechTribalSiouxYouth5);
			break;
		}
		case cCivXPAztec: {
			gEconUnit = cUnitTypeSettlerNative;
			gHouseUnit = cUnitTypeHouseAztec;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeFarm;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeFarm;
			gBarracksUnit = cUnitTypeWarHut;
			gStableUnit = -1;
			gArtilleryDepotUnit = -1;
			gTowerUnit = cUnitTypeWarHut;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypexpWarCanoe;
			gGalleonUnit = cUnitTypeCanoe;
			gFrigateUnit = cUnitTypexpTlalocCanoe;
			gMonitorUnit = -1;

			if (gMyStrategy == cStrategyTreaty) {
				arrayPushInt(gAgeUpList, cTechTribalAztecYouth2);
				arrayPushInt(gAgeUpList, cTechTribalAztecChief3);
				arrayPushInt(gAgeUpList, cTechTribalAztecShaman4);
			}
			else {
				arrayPushInt(gAgeUpList, cTechTribalAztecShaman2);
				arrayPushInt(gAgeUpList, cTechTribalAztecYouth3);
				arrayPushInt(gAgeUpList, cTechTribalAztecChief4);
			}
			arrayPushInt(gAgeUpList, cTechTribalAztecWisewoman5);
			break;
		}
		case cCivDEInca: {
			gEconUnit = cUnitTypeSettlerNative;
			gHouseUnit = cUnitTypedeHouseInca;
			gMarketUnit = cUnitTypeMarket;
			gFarmUnit = cUnitTypeFarm;
			gPlantationUnit = cUnitTypePlantation;
			gLivestockPenUnit = cUnitTypeFarm;
			gBarracksUnit = cUnitTypeWarHut;
			gStableUnit = -1;
			gArtilleryDepotUnit = -1;
			gTowerUnit = cUnitTypeWarHut;
			gDockUnit = cUnitTypeDock;
			gFishingUnit = cUnitTypeFishingBoat;
			gCaravelUnit = cUnitTypedeChinchaRaft;
			gGalleonUnit = -1;
			gFrigateUnit = -1;
			gMonitorUnit = -1;

			arrayPushInt(gAgeUpList, cTechTribalIncaShaman2);
			arrayPushInt(gAgeUpList, cTechTribalIncaChief3);
			arrayPushInt(gAgeUpList, cTechTribalIncaYouth4);
			arrayPushInt(gAgeUpList, cTechTribalIncaWarrior5);
			break;
		}
		case cCivJapanese: {
			gEconUnit = cUnitTypeypSettlerJapanese;
			gHouseUnit = cUnitTypeypShrineJapanese;
			gMarketUnit = cUnitTypeypTradeMarketAsian;
			gFarmUnit = cUnitTypeypRicePaddy;
			gPlantationUnit = cUnitTypeypRicePaddy;
			gLivestockPenUnit = cUnitTypeypShrineJapanese;
			gBarracksUnit = cUnitTypeypBarracksJapanese;
			gStableUnit = cUnitTypeypStableJapanese;
			gArtilleryDepotUnit = cUnitTypeypCastle;
			gTowerUnit = cUnitTypeypCastle;
			gDockUnit = cUnitTypeYPDockAsian;
			gFishingUnit = cUnitTypeypFishingBoatAsian;
			gCaravelUnit = cUnitTypeypFune;
			gGalleonUnit = cUnitTypeypAtakabune;
			gFrigateUnit = cUnitTypeypTekkousen;
			gMonitorUnit = cUnitTypeMonitor;

			gFarmFoodTactic = cTacticPaddyFood;
			gFarmGoldTactic = cTacticPaddyCoin;

			arrayPushInt(gAgeUpList, cUnitTypeypWJToshoguShrine2);
			arrayPushInt(gAgeUpList, cUnitTypeypWJGiantBuddha3);
			arrayPushInt(gAgeUpList, cUnitTypeypWJGoldenPavillion4);
			arrayPushInt(gAgeUpList, cUnitTypeypWJToriiGates5);
			break;
		}
		case cCivChinese: {
			gEconUnit = cUnitTypeypSettlerAsian;
			gHouseUnit = cUnitTypeypVillage;
			gMarketUnit = cUnitTypeypTradeMarketAsian;
			gFarmUnit = cUnitTypeypRicePaddy;
			gPlantationUnit = cUnitTypeypRicePaddy;
			gLivestockPenUnit = cUnitTypeypVillage;
			gBarracksUnit = cUnitTypeypWarAcademy;
			gStableUnit = -1;
			gArtilleryDepotUnit = cUnitTypeypCastle;
			gTowerUnit = cUnitTypeypCastle;
			gDockUnit = cUnitTypeYPDockAsian;
			gFishingUnit = cUnitTypeypFishingBoatAsian;
			gCaravelUnit = cUnitTypeypWarJunk;
			gGalleonUnit = -1;
			gFrigateUnit = cUnitTypeypFuchuan;
			gMonitorUnit = cUnitTypeMonitor;

			gFarmFoodTactic = cTacticPaddyFood;
			gFarmGoldTactic = cTacticPaddyCoin;

			arrayPushInt(gAgeUpList, cUnitTypeypWCSummerPalace2);
			arrayPushInt(gAgeUpList, cUnitTypeypWCTempleOfHeaven3);
			arrayPushInt(gAgeUpList, cUnitTypeypWCConfucianAcademy4);
			arrayPushInt(gAgeUpList, cUnitTypeypWCPorcelainTower5);
			break;
		}
		case cCivIndians: {
			gEconUnit = cUnitTypeypSettlerIndian;
			gHouseUnit = cUnitTypeypHouseIndian;
			gMarketUnit = cUnitTypeypTradeMarketAsian;
			gFarmUnit = cUnitTypeypRicePaddy;
			gPlantationUnit = cUnitTypeypRicePaddy;
			gLivestockPenUnit = cUnitTypeypSacredField;
			gBarracksUnit = cUnitTypeYPBarracksIndian;
			gStableUnit = cUnitTypeypCaravanserai;
			gArtilleryDepotUnit = cUnitTypeypCastle;
			gTowerUnit = cUnitTypeypCastle;
			gDockUnit = cUnitTypeYPDockAsian;
			gFishingUnit = cUnitTypeypFishingBoatAsian;
			gCaravelUnit = cUnitTypeCaravel;
			gGalleonUnit = cUnitTypeGalleon;
			gFrigateUnit = cUnitTypeFrigate;
			gMonitorUnit = cUnitTypeMonitor;

			gFarmFoodTactic = cTacticPaddyFood;
			gFarmGoldTactic = cTacticPaddyCoin;

			arrayPushInt(gAgeUpList, cUnitTypeypWIAgraFort2);
			arrayPushInt(gAgeUpList, cUnitTypeypWIKarniMata3);
			arrayPushInt(gAgeUpList, cUnitTypeypWITowerOfVictory4);
			arrayPushInt(gAgeUpList, cUnitTypeypWITajMahal5);
			break;
		}
		case cCivDEEthiopians: {
			gEconUnit = cUnitTypedeSettlerAfrican;
			gHouseUnit = cUnitTypedeHouseAfrican;
			gMarketUnit = cUnitTypedeLivestockMarket;
			gFarmUnit = cUnitTypedeField;
			gPlantationUnit = cUnitTypedeField;
			gLivestockPenUnit = cUnitTypedeLivestockMarket;
			gBarracksUnit = cUnitTypedeWarCamp;
			gStableUnit = -1;
			gArtilleryDepotUnit = -1;
			gTowerUnit = cUnitTypedeTower;
			gDockUnit = cUnitTypedePort;
			gFishingUnit = cUnitTypedeFishingBoatAfrican;
			gCaravelUnit = cUnitTypedeBattleCanoe;
			gGalleonUnit = -1;
			gFrigateUnit = cUnitTypedeMercDhow;
			gMonitorUnit = cUnitTypedeCannonBoat;

			gFarmFoodTactic = cTacticFieldFood;
			gFarmGoldTactic = cTacticFieldCoin;

			// Randomize Age Ups before Age 5, where we want Arabs.
			gAllegianceSomali = arrayCreateInt(3, "Somali Age-ups");
			arrayPushInt(gAllegianceSomali, cTechDEAllegianceSomali2);
			arrayPushInt(gAllegianceSomali, cTechDEAllegianceSomali3);
			arrayPushInt(gAllegianceSomali, cTechDEAllegianceSomali4);
			gAllegianceHabesha = arrayCreateInt(3, "Habesha Age-ups");
			arrayPushInt(gAllegianceHabesha, cTechDEAllegianceHabesha2);
			arrayPushInt(gAllegianceHabesha, cTechDEAllegianceHabesha3);
			arrayPushInt(gAllegianceHabesha, cTechDEAllegianceHabesha4);
			gAllegianceJesuit = arrayCreateInt(3, "Jesuit Age-ups");
			arrayPushInt(gAllegianceJesuit, cTechDEAllegianceJesuit2);
			arrayPushInt(gAllegianceJesuit, cTechDEAllegianceJesuit3);
			arrayPushInt(gAllegianceJesuit, cTechDEAllegianceJesuit4);
			gAllegiancePortuguese = arrayCreateInt(3, "Portuguese Age-ups");
			arrayPushInt(gAllegiancePortuguese, cTechDEAllegiancePortuguese2);
			arrayPushInt(gAllegiancePortuguese, cTechDEAllegiancePortuguese3);
			arrayPushInt(gAllegiancePortuguese, cTechDEAllegiancePortuguese4);
			gAllegianceSudanese = arrayCreateInt(3, "Sudanese Age-ups");
			arrayPushInt(gAllegianceSudanese, cTechDEAllegianceSudanese2);
			arrayPushInt(gAllegianceSudanese, cTechDEAllegianceSudanese3);
			arrayPushInt(gAllegianceSudanese, cTechDEAllegianceSudanese4);
			gAllegianceIndian = arrayCreateInt(3, "Indian Age-ups");
			arrayPushInt(gAllegianceIndian, -1);
			arrayPushInt(gAllegianceIndian, cTechDEAllegianceIndian3);
			arrayPushInt(gAllegianceIndian, cTechDEAllegianceIndian4);
			gAllegianceOromo = arrayCreateInt(3, "Oromo Age-ups");
			arrayPushInt(gAllegianceOromo, -1);
			arrayPushInt(gAllegianceOromo, -1);
			arrayPushInt(gAllegianceOromo, cTechDEAllegianceOromo4);

			tempShuffleArray = arrayCreateInt(5, "Age-up Shuffle Ethiopia");
			firstIndex = -1;

			if (gGoodFishingMap == true)
				arrayPushInt(tempShuffleArray, gAllegianceSomali);
			arrayPushInt(tempShuffleArray, gAllegianceHabesha);
			arrayPushInt(tempShuffleArray, gAllegianceJesuit);
			arrayPushInt(tempShuffleArray, gAllegiancePortuguese);
			arrayPushInt(tempShuffleArray, gAllegianceSudanese);
			// Don't shuffle here, as we should choose Somali to get free fishing boats.
			// gAllegianceSomali currently resides at index 0.
			if (gGoodFishingMap == false)
				arrayShuffleInt(tempShuffleArray);
			firstIndex = arrayGetInt(tempShuffleArray, 0);
			// Age up to 2 with...
			arrayPushInt(gAgeUpList, arrayGetInt(firstIndex, 0));

			// Update the list...
			arrayDeleteInt(tempShuffleArray, 0);
			arrayPushInt(tempShuffleArray, gAllegianceIndian);
			arrayShuffleInt(tempShuffleArray);
			firstIndex = arrayGetInt(tempShuffleArray, 0);
			// Age up to 3 with...
			arrayPushInt(gAgeUpList, arrayGetInt(firstIndex, 1));

			// Update the list...
			arrayDeleteInt(tempShuffleArray, 0);
			arrayPushInt(tempShuffleArray, gAllegianceOromo);
			arrayShuffleInt(tempShuffleArray);
			firstIndex = arrayGetInt(tempShuffleArray, 0);
			// Age up to 4 with...
			arrayPushInt(gAgeUpList, arrayGetInt(firstIndex, 2));

			// Age up to 5 with Arabs always.
			arrayPushInt(gAgeUpList, cTechDEAllegianceArab5);

			break;
		}
		case cCivDEHausa: {
			gEconUnit = cUnitTypedeSettlerAfrican;
			gHouseUnit = cUnitTypedeHouseAfrican;
			gMarketUnit = cUnitTypedeLivestockMarket;
			gFarmUnit = cUnitTypedeField;
			gPlantationUnit = cUnitTypedeField;
			gLivestockPenUnit = cUnitTypedeLivestockMarket;
			gBarracksUnit = cUnitTypedeWarCamp;
			gStableUnit = -1;
			gArtilleryDepotUnit = -1;
			gTowerUnit = cUnitTypedeTower;
			gDockUnit = cUnitTypedePort;
			gFishingUnit = cUnitTypedeFishingBoatAfrican;
			gCaravelUnit = cUnitTypedeBattleCanoe;
			gGalleonUnit = -1;
			gFrigateUnit = cUnitTypedeMercXebec;
			gMonitorUnit = cUnitTypedeCannonBoat;

			gFarmFoodTactic = cTacticFieldFood;
			gFarmGoldTactic = cTacticFieldCoin;

			// Randomize Age Ups before Age 5, where we want British.
			gAllegianceBerbers = arrayCreateInt(3, "Berber Age-ups");
			arrayPushInt(gAllegianceBerbers, cTechDEAllegianceBerber2);
			arrayPushInt(gAllegianceBerbers, cTechDEAllegianceBerber3);
			arrayPushInt(gAllegianceBerbers, cTechDEAllegianceBerber4);
			gAllegianceHausa = arrayCreateInt(3, "Hausa Age-ups");
			arrayPushInt(gAllegianceHausa, cTechDEAllegianceHausa2);
			arrayPushInt(gAllegianceHausa, cTechDEAllegianceHausa3);
			arrayPushInt(gAllegianceHausa, cTechDEAllegianceHausa4);
			gAllegianceMoraccan = arrayCreateInt(3, "Moraccan Age-ups");
			arrayPushInt(gAllegianceMoraccan, cTechDEAllegianceMoroccan2);
			arrayPushInt(gAllegianceMoraccan, cTechDEAllegianceMoroccan3);
			arrayPushInt(gAllegianceMoraccan, cTechDEAllegianceMoroccan4);
			gAllegianceSonghai = arrayCreateInt(3, "Songhai Age-ups");
			arrayPushInt(gAllegianceSonghai, cTechDEAllegianceSonghai2);
			arrayPushInt(gAllegianceSonghai, cTechDEAllegianceSonghai3);
			arrayPushInt(gAllegianceSonghai, cTechDEAllegianceSonghai4);
			gAllegianceAkan = arrayCreateInt(3, "Akan Age-ups");
			arrayPushInt(gAllegianceAkan, cTechDEAllegianceAkan2);
			arrayPushInt(gAllegianceAkan, cTechDEAllegianceAkan3);
			arrayPushInt(gAllegianceAkan, cTechDEAllegianceAkan4);
			gAllegianceFulani = arrayCreateInt(3, "Fulani Age-ups");
			arrayPushInt(gAllegianceFulani, -1);
			arrayPushInt(gAllegianceFulani, cTechDEAllegianceFulani3);
			arrayPushInt(gAllegianceFulani, cTechDEAllegianceFulani4);
			gAllegianceYoruba = arrayCreateInt(3, "Yoruba Age-ups");
			arrayPushInt(gAllegianceYoruba, -1);
			arrayPushInt(gAllegianceYoruba, -1);
			arrayPushInt(gAllegianceYoruba, cTechDEAllegianceYoruba4);

			tempShuffleArray = arrayCreateInt(5, "Age-up Shuffle Hausa");
			firstIndex = -1;

			arrayPushInt(tempShuffleArray, gAllegianceBerbers);
			arrayPushInt(tempShuffleArray, gAllegianceHausa);
			arrayPushInt(tempShuffleArray, gAllegianceMoraccan);
			arrayPushInt(tempShuffleArray, gAllegianceSonghai);
			arrayPushInt(tempShuffleArray, gAllegianceAkan);
			arrayShuffleInt(tempShuffleArray);
			firstIndex = arrayGetInt(tempShuffleArray, 0);
			// Age up to 2 with...
			arrayPushInt(gAgeUpList, arrayGetInt(firstIndex, 0));

			// Update the list...
			arrayDeleteInt(tempShuffleArray, 0);
			arrayPushInt(tempShuffleArray, gAllegianceFulani);
			arrayShuffleInt(tempShuffleArray);
			firstIndex = arrayGetInt(tempShuffleArray, 0);
			// Age up to 3 with...
			arrayPushInt(gAgeUpList, arrayGetInt(firstIndex, 1));

			// Update the list...
			arrayDeleteInt(tempShuffleArray, 0);
			arrayPushInt(tempShuffleArray, gAllegianceYoruba);
			arrayShuffleInt(tempShuffleArray);
			firstIndex = arrayGetInt(tempShuffleArray, 0);
			// Age up to 4 with...
			arrayPushInt(gAgeUpList, arrayGetInt(firstIndex, 2));

			// Age up to 5 with British always.
			arrayPushInt(gAgeUpList, cTechDEAllegianceBritish5);

			break;
		}
	}
}


// ================================================================================
//	initPersonality() - Choose a strategy.
// ================================================================================
void initPersonality(void)
{
	if (aiTreatyGetEnd() - xsGetTime() > 21 * 60 * 1000) // 30 Minute Treaty or more.
		gMyStrategy = cStrategyTreaty;
	else
		gMyStrategy = cStrategyStandard;
}


// ================================================================================
//	initHandlers() - Set up game handlers.
// ================================================================================
void initHandlers(void) {
	// Setup the building constructed handler.
	aiCommsSetEventHandler("commHandler");
	aiSetHandler("shipGrantedHandler", cXSShipResourceGranted);
	// Setup shipment arrival handler.
	aiSetHandler("transportShipmentArrive", cXSHomeCityTransportArriveHandler);
	aiSetHandler("nuggetHandler", cXSNuggetHandler);
	aiSetHandler("ageUpHandler", cXSPlayerAgeHandler);
	aiSetHandler("selfAgeUpHandler", cXSAgeHandler); // Indicates that we have aged up.

	aiSetHandler("buildingConstructedHandler", cXSBuildHandler);
	aiSetHandler("buildingPlacementFailedHandler", cXSBuildingPlacementFailedHandler);

	if (aiIsMonopolyAllowed() == true)
	{
		xsEnableRule("monopolyManager");
		
		// Handler when a player starts the monopoly victory timer.
		aiSetHandler("monopolyStartHandler", cXSMonopolyStartHandler);
	
		// And when a monopoly timer prematurely ends.
		aiSetHandler("monopolyEndHandler", cXSMonopolyEndHandler);
	}
	if (aiIsKOTHAllowed() == true)
	{
		// Handler when a player starts the KOTH victory timer.
		aiSetHandler("KOTHVictoryStartHandler", cXSKOTHVictoryStartHandler);
	
		// And when a KOTH timer prematurely ends.
		aiSetHandler("KOTHVictoryEndHandler", cXSKOTHVictoryEndHandler);
	}

	aiSetHandler("resignHandler", cXSResignHandler);
	// Game ending handler, to save game-to-game data before game ends.
	aiSetHandler("gameOverHandler", cXSGameOverHandler);
}


// ================================================================================
//	initArrays() - Initialize data that has not yet been accounted for.
// ================================================================================
void initArrays(void)
{

	gArrayEnemyPlayerIDs = xsArrayCreateInt(cNumberPlayers - 2, -1, "Enemy Player IDs");
	gStartingPosDistances = xsArrayCreateFloat(cNumberPlayers, 0.0, "Player Starting Position Distances");
	vector startLoc = kbGetPlayerStartingPosition(cMyID);

	for (i = 1; < cNumberPlayers)
		xsArraySetFloat(gStartingPosDistances, i, xsVectorLength(startLoc - kbGetPlayerStartingPosition(i)));

	gFirstAgeTime = xsArrayCreateInt(5, 60 * 60 * 1000, "Time age was reached");
	xsArraySetInt(gFirstAgeTime, cAge2, -10 * 60 * 1000); // So we always bump the priority for getting Commerce.

	gResourceNeeds = xsArrayCreateFloat(3, 0.0, "Resource Needs");
	if (cMyCiv == cCivDESwedish)
		gTorpPositionsToAvoid = xsArrayCreateVector(1, cInvalidVector, "Torp Positions To Avoid");

	switch (cMyCiv)
	{
		case cCivRussians:
		{
			gMilitaryBuildings = xsArrayCreateInt(5, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeBlockhouse);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeStable);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeArtilleryDepot);
			xsArraySetInt(gMilitaryBuildings, 3, cUnitTypedeTavern);
			xsArraySetInt(gMilitaryBuildings, 4, cUnitTypeChurch);
			break;
		}
		case cCivDEItalians:
		{
			gMilitaryBuildings = xsArrayCreateInt(5, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeBarracks);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeStable);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeArtilleryDepot);
			xsArraySetInt(gMilitaryBuildings, 3, cUnitTypedeLombard);
			xsArraySetInt(gMilitaryBuildings, 4, cUnitTypeChurch);
			break;
		}
		case cCivDEMaltese:
		{
			gMilitaryBuildings = xsArrayCreateInt(6, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypedeHospital);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypedeCommandery);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeArtilleryDepot);
			xsArraySetInt(gMilitaryBuildings, 3, cUnitTypedeTavern);
			xsArraySetInt(gMilitaryBuildings, 4, cUnitTypeChurch);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeOutpost);
			break;
		}
		case cCivXPIroquois:
		{
			gMilitaryBuildings = xsArrayCreateInt(3, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeWarHut);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeCorral);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeArtilleryDepot);
			xsArraySetInt(gMilitaryBuildings, 3, cUnitTypeNativeEmbassy);
			break;
		}
		case cCivXPSioux:
		{
			gMilitaryBuildings = xsArrayCreateInt(2, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeWarHut);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeCorral);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeNativeEmbassy);
			break;
		}
		case cCivXPAztec:
		{
			gMilitaryBuildings = xsArrayCreateInt(3, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeWarHut);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeNoblesHut);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeNativeEmbassy);
		}
		case cCivDEInca:
		{
			gMilitaryBuildings = xsArrayCreateInt(2, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeWarHut);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypedeKallanka);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeNativeEmbassy);
			break;
		}
		case cCivChinese:
		{
			gMilitaryBuildings = xsArrayCreateInt(3, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeypWarAcademy);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeypCastle);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeypMonastery);
			break;
		}
		case cCivJapanese:
		{
			gMilitaryBuildings = xsArrayCreateInt(5, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeypBarracksJapanese);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeypStableJapanese);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeypCastle);
			xsArraySetInt(gMilitaryBuildings, 3, cUnitTypeypMonastery);
			xsArraySetInt(gMilitaryBuildings, 4, cUnitTypeypChurch);
			break;
		}
		case cCivIndians:
		{
			gMilitaryBuildings = xsArrayCreateInt(4, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeYPBarracksIndian);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeypCaravanserai);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeypCastle);
			xsArraySetInt(gMilitaryBuildings, 3, cUnitTypeypMonastery);
			break;
		}
		case cCivDEEthiopians:
		case cCivDEHausa:
		{
			gMilitaryBuildings = xsArrayCreateInt(2, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypedeWarCamp);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypedeTower);
			break;
		}
		default:
		{
			gMilitaryBuildings = xsArrayCreateInt(5, -1, "Military Buildings");
			xsArraySetInt(gMilitaryBuildings, 0, cUnitTypeBarracks);
			xsArraySetInt(gMilitaryBuildings, 1, cUnitTypeStable);
			xsArraySetInt(gMilitaryBuildings, 2, cUnitTypeArtilleryDepot);
			if (cMyCiv == cCivDEAmericans || cMyCiv == cCivDEMexicans)
				xsArraySetInt(gMilitaryBuildings, 3, cUnitTypeSaloon);
			else
				xsArraySetInt(gMilitaryBuildings, 3, cUnitTypedeTavern);
			xsArraySetInt(gMilitaryBuildings, 4, cUnitTypeChurch);
			break;
		}
	}

	gArmyUnitBuildings = xsArrayCreateInt(gNumArmyUnitTypes, -1, "Army Unit Buildings");
	gArmyUnitMaintainPlans = xsArrayCreateInt(gNumArmyUnitTypes, -1, "Army Unit Maintain Plans");
	gFullGranaries = xsArrayCreateInt(20, -1, "Full Granaries");

	gMarketTechs = arrayCreateInt(1, "Market Techs");
	gMarketTechsAgeReq = arrayCreateInt(1, "Market Techs Age Requirements");
	gMarketTechsPrio = arrayCreateInt(1, "Market Techs Priority");
	gMillTechs = arrayCreateInt(1, "Mill Type Techs");
	gMillTechsAgeReq = arrayCreateInt(1, "Mill Type Techs Age Requirements");
	if (civIsAsian() == false && civIsAfrican() == false)
	{
		gPlantationTechs = arrayCreateInt(1, "Plantation Type Techs");
		gPlantationTechsAgeReq = arrayCreateInt(1, "Plantation Type Techs Age Requirements");
	}

	if (civIsEuropean() == true)
	{
		// Market.
		arrayPushInt(gMarketTechs, cTechHuntingDogs);
		arrayPushInt(gMarketTechsAgeReq, cAge1);
		arrayPushInt(gMarketTechsPrio, 60);
		arrayPushInt(gMarketTechs, cTechGangsaw);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechPlacerMines);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		if (cMyCiv == cCivDEAmericans || cMyCiv == cCivDEMexicans)
		{
			arrayPushInt(gMarketTechs, cTechDEFrontiersmen);
			arrayPushInt(gMarketTechsAgeReq, cAge3); // We don't want to research until Age 3.
			arrayPushInt(gMarketTechsPrio, 40);
		}
		else
		{
			arrayPushInt(gMarketTechs, cTechGreatCoat);
			arrayPushInt(gMarketTechsAgeReq, cAge2); // We don't want to research until Age 2.
			arrayPushInt(gMarketTechsPrio, 40);
			arrayPushInt(gMarketTechs, cTechBlunderbuss);
			arrayPushInt(gMarketTechsAgeReq, cAge3); // We don't want to research until Age 3.
			arrayPushInt(gMarketTechsPrio, 40);
		}
		arrayPushInt(gMarketTechs, cTechSteelTraps);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, 60);
		arrayPushInt(gMarketTechs, cTechLogFlume);
		// Italians want techs early for free villager.
		// Americans can research this free with Hamiltonian Economics.
		if (gMyStrategy == cStrategyTreaty || cMyCiv == cCivDEItalians || cMyCiv == cCivDEAmericans)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechAmalgamation);
		// Italians want techs early for free villager.
		// Americans can research this free with Hamiltonian Economics.
		if (gMyStrategy == cStrategyTreaty || cMyCiv == cCivDEItalians || cMyCiv == cCivDEAmericans)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechCircularSaw);
		arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		if (cMyCiv == cCivDEMexicans)
		{
			// Hacienda.
			arrayPushInt(gMillTechs, cTechSeedDrill);
			arrayPushInt(gMillTechsAgeReq, cAge2);
			arrayPushInt(gMillTechs, cTechSelectiveBreeding);
			arrayPushInt(gMillTechsAgeReq, cAge3);
			arrayPushInt(gMillTechs, cTechArtificialFertilizer);
			arrayPushInt(gMillTechsAgeReq, cAge3);
			arrayPushInt(gMillTechs, cTechBookkeeping);
			arrayPushInt(gMillTechsAgeReq, cAge3);
			arrayPushInt(gMillTechs, cTechHomesteading);
			arrayPushInt(gMillTechsAgeReq, cAge4);
			arrayPushInt(gMillTechs, cTechOreRefining);
			arrayPushInt(gMillTechsAgeReq, cAge4);
		}
		else
		{
			// Mill.
			arrayPushInt(gMillTechs, cTechSeedDrill);
			arrayPushInt(gMillTechsAgeReq, cAge2);
			arrayPushInt(gMillTechs, cTechArtificialFertilizer);
			arrayPushInt(gMillTechsAgeReq, cAge3);
			// Estate.
			arrayPushInt(gPlantationTechs, cTechBookkeeping);
			arrayPushInt(gPlantationTechsAgeReq, cAge3);
			arrayPushInt(gPlantationTechs, cTechHomesteading);
			arrayPushInt(gPlantationTechsAgeReq, cAge4);
			arrayPushInt(gPlantationTechs, cTechOreRefining);
			arrayPushInt(gPlantationTechsAgeReq, cAge4);
		}

		if (cMyCiv == cCivOttomans)
		{
			gMosqueTechs = arrayCreateInt(6, "Mosque Special Techs");
			gMosqueTechsAgeReq = arrayCreateInt(6, "Mosque Special Techs Age Requirement");
			arrayPushInt(gMosqueTechs, cTechChurchMilletSystem);
			arrayPushInt(gMosqueTechsAgeReq, cAge1);
			arrayPushInt(gMosqueTechs, cTechChurchKopruluViziers);
			arrayPushInt(gMosqueTechsAgeReq, cAge1);
			arrayPushInt(gMosqueTechs, cTechChurchAbbassidMarket);
			arrayPushInt(gMosqueTechsAgeReq, cAge2);
			arrayPushInt(gMosqueTechs, cTechChurchGalataTowerDistrict);
			arrayPushInt(gMosqueTechsAgeReq, cAge2);
			arrayPushInt(gMosqueTechs, cTechChurchTopkapi);
			arrayPushInt(gMosqueTechsAgeReq, cAge3);
			arrayPushInt(gMosqueTechs, cTechChurchTanzimat);
			arrayPushInt(gMosqueTechsAgeReq, cAge4);
		}
	}
	else if (civIsNative() == true)
	{
		// Market.
		arrayPushInt(gMarketTechs, cTechHuntingDogs);
		arrayPushInt(gMarketTechsAgeReq, cAge1);
		arrayPushInt(gMarketTechsPrio, 60);
		arrayPushInt(gMarketTechs, cTechLumberCeremony);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		if (cMyCiv != cCivXPIroquois && cMyCiv != cCivXPSioux)
		{
			arrayPushInt(gMarketTechs, cTechPlacerMines);
			arrayPushInt(gMarketTechsAgeReq, cAge2);
			arrayPushInt(gMarketTechsPrio, -1);
		}
		arrayPushInt(gMarketTechs, cTechSpiritMedicine);
		arrayPushInt(gMarketTechsAgeReq, cAge3); // We don't want to research until Age 3.
		arrayPushInt(gMarketTechsPrio, 40);
		arrayPushInt(gMarketTechs, cTechForestPeopleCeremony);
		if (gMyStrategy == cStrategyTreaty)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechForestSpiritCeremony);
		arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechImpDeforestationNative);
		arrayPushInt(gMarketTechsAgeReq, cAge5);
		arrayPushInt(gMarketTechsPrio, 60);
		// Mill.
		arrayPushInt(gMillTechs, cTechGreatFeast);
		arrayPushInt(gMillTechsAgeReq, cAge2); // We don't want to research until Age 2.
		arrayPushInt(gMillTechs, cTechHarvestCeremony);
		arrayPushInt(gMillTechsAgeReq, cAge3); // We don't want to research until Age 3.
		arrayPushInt(gMillTechs, cTechGreenCornCeremony);
		arrayPushInt(gMillTechsAgeReq, cAge3);
		arrayPushInt(gMillTechs, cTechImpLargeScaleGathering);
		arrayPushInt(gMillTechsAgeReq, cAge3);
		// Estate.
		if (cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux)
		{
			arrayPushInt(gPlantationTechs, cTechEarthCeremonyNoMine);
			arrayPushInt(gPlantationTechsAgeReq, cAge3);
			arrayPushInt(gPlantationTechs, cTechEarthGiftCeremonyNoMine);
			arrayPushInt(gPlantationTechsAgeReq, cAge3);
			arrayPushInt(gPlantationTechs, cTechImpExcessiveTributeNativeNoMine);
			arrayPushInt(gPlantationTechsAgeReq, cAge5);
		}
		else
		{
			arrayPushInt(gPlantationTechs, cTechEarthCeremony);
			arrayPushInt(gPlantationTechsAgeReq, cAge3);
			arrayPushInt(gPlantationTechs, cTechEarthGiftCeremony);
			arrayPushInt(gPlantationTechsAgeReq, cAge3);
			arrayPushInt(gPlantationTechs, cTechImpExcessiveTributeNative);
			arrayPushInt(gPlantationTechsAgeReq, cAge5);
		}
	}
	else if (civIsAsian() == true)
	{
		// Market.
		if (cMyCiv == cCivJapanese)
		{
			arrayPushInt(gMarketTechs, cTechypMarketBerryDogs);
			arrayPushInt(gMarketTechsAgeReq, cAge1);
			arrayPushInt(gMarketTechsPrio, 60);
			arrayPushInt(gMarketTechs, cTechypMarketBerryTraps);
			arrayPushInt(gMarketTechsAgeReq, cAge2);
			arrayPushInt(gMarketTechsPrio, 60);
		}
		else
		{
			arrayPushInt(gMarketTechs, cTechypMarketHuntingDogs);
			arrayPushInt(gMarketTechsAgeReq, cAge1);
			arrayPushInt(gMarketTechsPrio, 60);
			arrayPushInt(gMarketTechs, cTechypMarketSteelTraps);
			arrayPushInt(gMarketTechsAgeReq, cAge2);
			arrayPushInt(gMarketTechsPrio, 60);
		}
		arrayPushInt(gMarketTechs, cTechypMarketGangsaw);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechypMarketPlacerMines);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechypMarketWheelbarrow);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechypMarketSpiritMedicine);
		arrayPushInt(gMarketTechsAgeReq, cAge3); // We don't want to research until Age 3.
		arrayPushInt(gMarketTechsPrio, 40);
		arrayPushInt(gMarketTechs, cTechypMarketLogFlume);
		if (gMyStrategy == cStrategyTreaty)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechypMarketAmalgamation);
		if (gMyStrategy == cStrategyTreaty)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechypMarketWheelbarrow2);
		if (gMyStrategy == cStrategyTreaty)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechypMarketCircularSaw);
		arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechypImpDeforestationAsian);
		arrayPushInt(gMarketTechsAgeReq, cAge5);
		arrayPushInt(gMarketTechsPrio, 60);
		// Rice Paddy.
		// Food Techs.
		arrayPushInt(gMillTechs, cTechypCultivateWasteland);
		arrayPushInt(gMillTechsAgeReq, cAge3); // We don't want to research until Age 3.
		arrayPushInt(gMillTechs, cTechypWaterConservancy);
		arrayPushInt(gMillTechsAgeReq, cAge3);
		arrayPushInt(gMillTechs, cTechypIrrigationSystems);
		arrayPushInt(gMillTechsAgeReq, cAge4);
		arrayPushInt(gMillTechs, cTechypImpLargeScaleAgricultureAsian);
		arrayPushInt(gMillTechsAgeReq, cAge5);
		// Gold Techs.
		arrayPushInt(gMillTechs, cTechypCropMarket);
		arrayPushInt(gMillTechsAgeReq, cAge3); // We don't want to research until Age 3.
		arrayPushInt(gMillTechs, cTechypSharecropping);
		arrayPushInt(gMillTechsAgeReq, cAge3);
		arrayPushInt(gMillTechs, cTechypLandRedistribution);
		arrayPushInt(gMillTechsAgeReq, cAge4);
		arrayPushInt(gMillTechs, cTechypCooperative);
		arrayPushInt(gMillTechsAgeReq, cAge4);
		arrayPushInt(gMillTechs, cTechypImpExcessiveTributeAsian);
		arrayPushInt(gMillTechsAgeReq, cAge5);
	}
	else
	{
		// Livestock Market.
		arrayPushInt(gMarketTechs, cTechSelectiveBreeding);
		arrayPushInt(gMarketTechsAgeReq, cAge3); // We don't want to research until Age 3.
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechDEAfricanVillagerWoodcutting1);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechPlacerMines);
		arrayPushInt(gMarketTechsAgeReq, cAge2);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechDEAfricanVillagerHitpoints);
		arrayPushInt(gMarketTechsAgeReq, cAge2); // We don't want to research until Age 2.
		arrayPushInt(gMarketTechsPrio, 40);
		arrayPushInt(gMarketTechs, cTechDEAfricanVillagerDamage);
		arrayPushInt(gMarketTechsAgeReq, cAge5); // We don't want to research until Age 5.
		arrayPushInt(gMarketTechsPrio, 40);		// Oneshotting hunts near granaries leaves some units stuck trying to gather.
		arrayPushInt(gMarketTechs, cTechDEAfricanVillagerWoodcutting2);
		if (gMyStrategy == cStrategyTreaty)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechAmalgamation);
		if (gMyStrategy == cStrategyTreaty)
			arrayPushInt(gMarketTechsAgeReq, cAge2);
		else
			arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechDEAfricanVillagerWoodcutting3);
		arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechDETranshumance);
		arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechDECowLoans);
		arrayPushInt(gMarketTechsAgeReq, cAge3);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechDEAfricanVillagerMiningGoldPurification);
		arrayPushInt(gMarketTechsAgeReq, cAge4);
		arrayPushInt(gMarketTechsPrio, -1);
		arrayPushInt(gMarketTechs, cTechDEImpDeforestationAfrican);
		arrayPushInt(gMarketTechsAgeReq, cAge5);
		arrayPushInt(gMarketTechsPrio, 60);
		// Granary (which includes food and gold upgrades for fields).
		gGranaryTechs = arrayCreateInt(1, "Granary Techs");
		gGranaryTechsAgeReq = arrayCreateInt(1, "Granary Techs Age Requirements");
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerHunting1);
		arrayPushInt(gGranaryTechsAgeReq, cAge1);
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerHunting2);
		arrayPushInt(gGranaryTechsAgeReq, cAge2);
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerFarming1);
		arrayPushInt(gGranaryTechsAgeReq, cAge3);
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerFarmingGold1);
		arrayPushInt(gGranaryTechsAgeReq, cAge3);
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerFarming2);
		arrayPushInt(gGranaryTechsAgeReq, cAge3);
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerFarmingGold2);
		arrayPushInt(gGranaryTechsAgeReq, cAge3);
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerFarming3);
		arrayPushInt(gGranaryTechsAgeReq, cAge4);
		arrayPushInt(gGranaryTechs, cTechDEAfricanVillagerFarmingGold3);
		arrayPushInt(gGranaryTechsAgeReq, cAge4);
		arrayPushInt(gGranaryTechs, cTechDEImpLargeScaleGatheringAfrican);
		arrayPushInt(gGranaryTechsAgeReq, cAge5);

		// Keep in mind these are only actually researched if they become available via age-ups.
		gAllegianceTechs = arrayCreateInt(1, "Allegiance Techs");
		// For these, the "age requirement" is just whenever we want the AI to research it.
		// More prevalent would be things that give influence for units killed/etc --
		// we would want to wait a bit. Otherwise, -1 means no requirement.
		gAllegianceTechsAgeReq = arrayCreateInt(1, "Allegiance Techs Age Requirements");
		// If -1 (resource) priority, it will be set to 50 (resource) priority by default
		// in the rule in aiMain.xs.
		gAllegianceTechsPrio = arrayCreateInt(1, "Allegiance Techs Priority");

		if (cMyCiv == cCivDEEthiopians)
		{
			// Somali
			arrayPushInt(gAllegianceTechs, cTechDENatSomaliBerberaSeaport);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 99); // Very valuable and cheap.
			arrayPushInt(gAllegianceTechs, cTechDENatSomaliCoinage);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Habesha
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceHabeshaRelicEntertainment); // Valuable but expensive (2000 Influence).
			arrayPushInt(gAllegianceTechsAgeReq, cAge3);
			arrayPushInt(gAllegianceTechsPrio, 60);
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceHabeshaTimkat);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Jesuit
			arrayPushInt(gAllegianceTechs, cTechYPNatJesuitSchools);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 99); // Very valuable and cheap.
			arrayPushInt(gAllegianceTechs, cTechYPNatJesuitSmokelessPowder);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Portuguese (also enable European Arsenal improvements)
			arrayPushInt(gAllegianceTechs, cTechDEAllegiancePortugueseCrusaders);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 45);
			arrayPushInt(gAllegianceTechs, cTechDEAllegiancePortugueseOrgans); // TODO (James): Require at least 4 Mountain Monasteries.
			arrayPushInt(gAllegianceTechsAgeReq, cAge4);
			arrayPushInt(gAllegianceTechsPrio, 45);

			// Sudanese
			arrayPushInt(gAllegianceTechs, cTechDENatSudaneseRedSeaTrade);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 60);
			arrayPushInt(gAllegianceTechs, cTechDENatSudaneseQuiltedArmor);
			arrayPushInt(gAllegianceTechsAgeReq, cAge3);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Indians (also enables Asian Market improvements)
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceIndianVillagers);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 99); // Very valuable and cheap..
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceIndianCosts);
			arrayPushInt(gAllegianceTechsAgeReq, cAge4);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Oromo
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceOromoFields);
			arrayPushInt(gAllegianceTechsAgeReq, cAge5);
			arrayPushInt(gAllegianceTechsPrio, -1);
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceOromoUnits);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 60);

			// Arabs
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceArabMercenaryCost);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 99); // Very valuable.
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceArabMercenaryGold);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 98); // Very valuable.
		}
		else if (cMyCiv == cCivDEHausa)
		{
			// Berbers
			arrayPushInt(gAllegianceTechs, cTechDENatGhorfas);
			arrayPushInt(gAllegianceTechsAgeReq, cAge3);
			arrayPushInt(gAllegianceTechsPrio, 40);
			arrayPushInt(gAllegianceTechs, cTechYPNatJesuitSmokelessPowder);
			arrayPushInt(gAllegianceTechsAgeReq, cAge4);
			arrayPushInt(gAllegianceTechsPrio, 40);

			// Hausa
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceHausaKanoChronicle);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 99); // Very valuable.
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceHausaBayajiddaEpic);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Moroccans
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceMoroccanTreePlanting);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 99); // Very valuable.
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceMoroccanArmaGarrisons);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Songhai
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceSonghaiTimbuktuChronicle);
			arrayPushInt(gAllegianceTechsAgeReq, cAge4);
			arrayPushInt(gAllegianceTechsPrio, -1);
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceSonghaiMansaMusaEpic);
			arrayPushInt(gAllegianceTechsAgeReq, cAge4);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Akan
			arrayPushInt(gAllegianceTechs, cTechDENatAkanGoldEconomy);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 60);
			// Ignore cTechDENatAkanPalmOil

			// Fulani (also enables Goats at the Livestock Market)
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceFulaniMigrations); // TODO (James): See what the long range attack is.
			arrayPushInt(gAllegianceTechsAgeReq, cAge4);					   // If not automatic attack, scrap this upgrade.
			arrayPushInt(gAllegianceTechsPrio, 40);
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceFulaniGerewolFestival);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// Yoruba
			// Ignore cTechDENatYorubaTwins until condition can be added to check number of Yoruba units.
			arrayPushInt(gAllegianceTechs, cTechDENatYorubaWrestling);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);

			// British (also enable European Arsenal improvements)
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceBritishArtillery);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, 60);
			arrayPushInt(gAllegianceTechs, cTechDEAllegianceBritishArmy);
			arrayPushInt(gAllegianceTechsAgeReq, -1);
			arrayPushInt(gAllegianceTechsPrio, -1);
		}
	}

	gGarrisonableBuilding = arrayCreateInt(1, "Garrison Buildings");
}


//==============================================================================
/* startUpChats
	Analyze our history with the players in the game and send them an appropriate message.
	
	Save these user vars here:
	wasMyAllyLastGame
	lastGameDifficulty
	lastMapID
	myEnemyCount
	myAllyCount
	
	The other used user vars will be saved by gameOverHandler.
*/
//==============================================================================
void startUpChats()
{
	debugSetup("***Sending start up chats***");

	for (pid = 1; < cNumberPlayers)
	{
		// Skip ourself.
		if (pid == cMyID)
		{
			continue;
		}

		// Get player name. This also works for playing against other AI we then get the personalities' name.
		string playerName = kbGetPlayerName(pid);
		debugSetup("PlayerName: " + playerName);
		int mapID = getMapID();

		// Have we played against them before?
		int playerHistoryID = aiPersonalityGetPlayerHistoryIndex(playerName);
		if (playerHistoryID == -1)
		{
			debugSetup("Never played against: " + playerName);
			// Lets make a new player history.
			playerHistoryID = aiPersonalityCreatePlayerHistory(playerName);
			if (playerHistoryID == -1)
			{
			debugSetup("WARNING: failed to create player history for " + playerName);
			}
			else
			{
			debugSetup("Created new history for player: " + playerName);
			}
			if (kbIsPlayerAlly(pid) == true)
			{
			sendStatement(pid, cAICommPromptToAllyIntro);
			}
			else
			{
			sendStatement(pid, cAICommPromptToEnemyIntro);
			}
		}
		else // We have a player history so we can send chats based on our history with them.
		{
			// Consider chats based on player history.
			
			bool wasAllyLastTime = true;
			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "wasMyAllyLastGame") == 0.0)
			{
			wasAllyLastTime = false;
			} 
			bool isAllyThisTime = true;
			if (kbIsPlayerAlly(pid) == false)
			{
			isAllyThisTime = false;
			}
			bool difficultyIsHigher = false;
			bool difficultyIsLower = false;
			int lastDifficulty = aiPersonalityGetPlayerUserVar(playerHistoryID, "lastGameDifficulty");
			if (lastDifficulty >= 0)
			{
			if (lastDifficulty > cDifficultyCurrent)
			{
				difficultyIsLower = true;
			}
			if (lastDifficulty < cDifficultyCurrent)
			{
				difficultyIsHigher = true;
			}
			}
			bool iBeatHimLastTime = false;
			bool heBeatMeLastTime = false;
			bool iCarriedHimLastTime = false;
			bool heCarriedMeLastTime = false;

			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "heBeatMeLastTime") == 1.0)
			{
			heBeatMeLastTime = true;
			}
			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "iBeatHimLastTime") == 1.0)
			{
			iBeatHimLastTime = true;
			}
			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "iCarriedHimLastTime") == 1.0)
			{
			iCarriedHimLastTime = true;
			}
			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "heCarriedMeLastTime") == 1.0)
			{
			heCarriedMeLastTime = true;
			}
			
			if (wasAllyLastTime == false)
			{
			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "iBeatHimLastTime") == 1.0)
			{
				iBeatHimLastTime = true;
			}
			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "heBeatMeLastTime") == 1.0)
			{
				heBeatMeLastTime = true;
			}
			}

			bool iWonLastGame = false;
			if (aiPersonalityGetPlayerUserVar(playerHistoryID, "iWonLastGame") == 1.0)
			{
			iWonLastGame = true;
			}
			
			// We've loaded all the variables, now start analyzing what chat to send.
			if (isAllyThisTime == true)
			{
			if (difficultyIsHigher == true)
			{
				sendStatement(pid, cAICommPromptToAllyIntroWhenDifficultyHigher);
			}
			else if (difficultyIsLower == true)
			{
				sendStatement(pid, cAICommPromptToAllyIntroWhenDifficultyLower);
			}
			else if (iCarriedHimLastTime == true)
			{
				sendStatement(pid, cAICommPromptToAllyIntroWhenICarriedHimLastGame);
			}
			else if (heCarriedMeLastTime == true)
			{
				sendStatement(pid, cAICommPromptToAllyIntroWhenHeCarriedMeLastGame);
			}
			else if (iBeatHimLastTime == true)
			{
				sendStatement(pid, cAICommPromptToAllyIntroWhenIBeatHimLastGame);
			}
			else if (heBeatMeLastTime == true)
			{
				sendStatement(pid, cAICommPromptToAllyIntroWhenHeBeatMeLastGame);
			}
			else if ((mapID >= 0) && (mapID == aiPersonalityGetPlayerUserVar(playerHistoryID, "lastMapID")))
			{
				sendStatement(pid, cAICommPromptToAllyIntroWhenMapRepeats);
			}
			else if (wasAllyLastTime == true)
			{
				if (iWonLastGame == false)
				{
					sendStatement(pid, cAICommPromptToAllyIntroWhenWeLostLastGame);
				}
				else
				{
					sendStatement(pid, cAICommPromptToAllyIntroWhenWeWonLastGame);
				}
			}
			else // Default to a standard intro so we at least say something.
			{
				sendStatement(pid, cAICommPromptToAllyIntro);
			}
			}
			else // We are enemies.
			{ 
			if (difficultyIsHigher == true)
			{
				sendStatement(pid, cAICommPromptToEnemyIntroWhenDifficultyHigher);
			}
			else if (difficultyIsLower == true)
			{
				sendStatement(pid, cAICommPromptToEnemyIntroWhenDifficultyLower);
			}
			else if ((mapID >= 0) && (mapID == aiPersonalityGetPlayerUserVar(playerHistoryID, "lastMapID")))
			{
				sendStatement(pid, cAICommPromptToEnemyIntroWhenMapRepeats);
			}
			else if (wasAllyLastTime == false) // Was enemy last game and now again.
			{
				// Check if he changed the odds.
				int allyCount = getAllyCount();
				int enemyCount = getEnemyCount();
				int previousEnemyCount = aiPersonalityGetPlayerUserVar(playerHistoryID, "myEnemyCount");
				int previousAllyCount = aiPersonalityGetPlayerUserVar(playerHistoryID, "myAllyCount");
				
				if (previousEnemyCount == enemyCount)
				{                                 
					if (previousAllyCount > allyCount) // I have fewer allies now.
					{
						sendStatement(pid, cAICommPromptToEnemyIntroWhenTeamOddsEasier);
					}
					if (previousAllyCount < allyCount) // I have more allies now.
					{
						sendStatement(pid, cAICommPromptToEnemyIntroWhenTeamOddsHarder);
					}
				}
				else if (previousAllyCount == allyCount) // Else, check if allyCount is the same, but enemyCount is smaller.
				{
					if (previousEnemyCount > enemyCount) // I have fewer enemies now.
					{
						sendStatement(pid, cAICommPromptToEnemyIntroWhenTeamOddsHarder);
					}
					if (previousEnemyCount < enemyCount) // I have more enemies now.
					{
						sendStatement(pid, cAICommPromptToEnemyIntroWhenTeamOddsEasier);
					}
				}
				else // Default to a standard intro so we at least say something.
				{
					sendStatement(pid, cAICommPromptToEnemyIntro);
				}
			}
			else // Default to a standard intro so we at least say something.
			{
				sendStatement(pid, cAICommPromptToEnemyIntro);
			}
			}
		} // End of the chats, still in the for loop.

		// Save info about this game.
		aiPersonalitySetPlayerUserVar(playerHistoryID, "lastGameDifficulty", cDifficultyCurrent);
		int wasAlly = 0;
		if (kbIsPlayerAlly(pid) == true)
		{
			wasAlly = 1;
		}
		else
		{ // He is an enemy, remember the odds (i.e. 1v3, 2v2, etc.).
			aiPersonalitySetPlayerUserVar(playerHistoryID, "myAllyCount", getAllyCount());
			aiPersonalitySetPlayerUserVar(playerHistoryID, "myEnemyCount", getEnemyCount());
		}
		aiPersonalitySetPlayerUserVar(playerHistoryID, "wasMyAllyLastGame", wasAlly);
		aiPersonalitySetPlayerUserVar(playerHistoryID, "lastMapID", mapID);
	}
}


//=================================================================================
// gameStartup: Get ready for our game.
//=================================================================================
void gameStartup(void)
{
	int planID = -1;
	int buildingID = -1;

	createDeck();
	xsEnableRule("startingCrates");
	if (cDifficultyCurrent != cDifficultySandbox)
	{
		xsEnableRule("mostHatedEnemy");
		mostHatedEnemy();
		xsEnableRule("rescueExplorer");
	}

	xsEnableRule("exploreMonitor");

	//Create a herd plan to gather all herdables that we encounter.
	gHerdPlanID = aiPlanCreate("GatherHerdable Plan", cPlanHerd);
	aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
	aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeTownCenter);
	aiPlanSetVariableFloat(gHerdPlanID, cHerdPlanDistance, 0, 4.0);
	aiPlanSetActive(gHerdPlanID);
	xsEnableRule("herdMonitor");

	updateResourceDistribution();

	xsEnableRule("ageUpgradeMonitor");

	xsEnableRule("ransomExplorer");

	if (cMyCiv == cCivDEEthiopians)
		xsEnableRule("taskAbuns");

	startupBuildings();
	xsEnableRule("townCenterComplete"); // Rule to build other buildings after TC completion
	xsEnableRuleGroup("postStartup");
}


//=================================================================================
// checkForTownCenter: Make sure we have a Town Center before we proceed.
//=================================================================================
rule checkForTownCenter
inactive
minInterval 1
{
	static bool done = false;
	if (done == false)
	{
		done = true;
		// The following are okay to enable while we wait for a TC.
		gMainBase = createMainBase(gHomeBase);
		xsEnableRule("envoyMonitor");
		xsEnableRule("nativeScoutMonitor");
		xsEnableRule("mongolScoutMonitor");
		if (cMyCiv == cCivDEItalians)
			xsEnableRule("architectManager");
		if (cMyCiv == cCivDEInca)
			xsEnableRule("chasquiMonitor");

		if (kbUnitCount(cMyID, cUnitTypeAgeUpBuilding, cUnitStateAlive) == 0)
		{
			int planID = -1;
			int numCoveredWagons = kbUnitCount(cMyID, cUnitTypeCoveredWagon, cUnitStateAlive);
			if (numCoveredWagons > 0)
				createBuildPlan(cUnitTypeTownCenter, numCoveredWagons, 100, gHomeBase, 1, cUnitTypeCoveredWagon);
			else
			{
				planID = createBuildPlan(cUnitTypeTownCenter, 1, 100, gHomeBase);
				aiPlanSetDesiredResourcePriority(planID, 99);
				aiPlanAddUnitType(planID, cUnitTypeLogicalTypeSettlerBuildLimit, 1, 3, 5);
				if (cMyCiv != cCivDEAmericans && cMyCiv != cCivDEMexicans)
					aiPlanAddUnitType(planID, cUnitTypeHero, 1, 2, 2);
				// Big bug on Eurasian Steppe (Indians).
				if (kbResourceGet(cResourceWood) < 500)
				{
					xsDisableSelf();
					gameStartup();
				}
			}
		}
	}

	if (kbUnitCount(cMyID, cUnitTypeAgeUpBuilding, cUnitStateAlive) > 0)
	{
		xsDisableSelf();
		gameStartup();
	}
}


//==============================================================================
/* townCenterComplete

	Wait until the town center is complete, then build other stuff next to it.
	In a start with a TC, this will fire very quickly.
	In a scenario with no TC, we do the best we can.

*/
//==============================================================================
rule townCenterComplete
inactive
minInterval 2
{
	kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 80.0);

	// Town center found, start building the other buildings
	xsDisableSelf();
	xsEnableRuleGroup("tcComplete");

	if (cMyCiv != cCivOttomans)
	{
		gSettlerMaintainPlan = createSimpleMaintainPlan(gEconUnit, kbGetBuildLimit(cMyID, gEconUnit), true, kbBaseGetMainID(cMyID), 1);
		aiPlanSetDesiredResourcePriority(gSettlerMaintainPlan, 75);
	}

	xsEnableRule("ShouldIResign");

	if (cMyCiv == cCivJapanese)
	{
		xsEnableRule("shrineTacticMonitor");
		xsEnableRule("goldenPavillionTacticMonitor");
		xsEnableRule("forwardShrineManager");
	}

	//if ((gWaterMap == true) || (kbUnitCount(cMyID, cUnitTypeHomeCityWaterSpawnFlag) > 0))
	//   gWaterTransportUnitMaintainPlan = createSimpleMaintainPlan(gCaravelUnit, 1, true, kbBaseGetMainID(cMyID), 1);

	// if (aiGetGameMode() == cGameModeDeathmatch)
	// 	deathMatchSetup();   // Add a bunch of custom stuff for a DM jump-start.

	if (kbUnitCount(cMyID, cUnitTypeypDaimyoRegicide, cUnitStateAlive) > 0)
		xsEnableRule("regicideMonitor");

	int flagUnit = getUnit(cUnitTypeHomeCityWaterSpawnFlag, cMyID);
	if (flagUnit >= 0)
		gNavyVec = kbUnitGetPosition(flagUnit);

	gLastClaimTradeMissionTime = xsGetTime();
	// Don't claim native TPs until 15 minutes.
	gLastClaimNativeMissionTime = xsGetTime() + 900000;
}


//==============================================================================
// Mod Intro Chat
//==============================================================================
rule modIntroChat
inactive
minInterval 10
{
	int firstNonHumanPlayer = -1;
	for (player = 1; < cNumberPlayers)
	{
		if (kbIsPlayerHuman(player) == false) 
		{
			firstNonHumanPlayer = player;
			break;
		}
	}
	if (cMyID == firstNonHumanPlayer )
	{
		for (player = 1; < cNumberPlayers)
		{
			aiChat(player, "Better AI Mod. Version 4.3: Last updated on 6 August 2022.");
		}
	}

	xsDisableSelf();
}
