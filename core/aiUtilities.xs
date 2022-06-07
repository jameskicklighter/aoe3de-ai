//==============================================================================
/* aiUtilities.xs

   This file contains utility functions used among all files.

*/
//==============================================================================


//==============================================================================
// Debug output functions.
//==============================================================================

void echoMessage (string message = "")
{
	return; // When I release updates.

	for (player = 0; <cNumberPlayers)
	{
		aiChat(player, message);
	}
}

void debugUtilities (string message = "")
{
	if (cDebugUtilities == true)
	{
		aiEcho(message);
	}
}

void debugBuildings (string message = "")
{
	if (cDebugBuildings == true)
	{
		aiEcho(message);
	}
}

void debugTechs (string message = "")
{
	if (cDebugTechs == true)
	{
		aiEcho(message);
	}
}

void debugExploration (string message = "")
{
	if (cDebugExploration == true)
	{
		aiEcho(message);
	}
}

void debugEconomy (string message = "")
{
	if (cDebugEconomy == true)
	{
		aiEcho(message);
	}
}

void debugMilitary (string message = "")
{
	if (cDebugMilitary == true)
	{
		aiEcho(message);
	}
}

void debugHCCards (string message = "")
{
	if (cDebugHCCards == true)
	{
		aiEcho(message);
	}
}

void debugChats (string message = "")
{
	if (cDebugChats == true)
	{
		aiEcho(message);
	}
}

void debugSetup (string message = "")
{
	if (cDebugSetup == true)
	{
		aiEcho(message);
	}
}

void debugCore (string message = "")
{
	if (cDebugCore == true)
	{
		aiEcho(message);
	}
}

//==============================================================================
// Custom Array functions.
//==============================================================================
int arrayGetSize(int arrayID = -1)
{
	if (arrayID <= -1)
		return(0);
	if (arrayID > gArrayPlanIDs)
		return(0);

	return(aiPlanGetUserVariableInt(gArrayPlanSizes, arrayID, 0));
}

void arraySetSize(int arrayID = -1, int size = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;
	if (size < 0)
		return;
	if (size > arrayGetNumElements(arrayID))
		return;

	aiPlanSetUserVariableInt(gArrayPlanSizes, arrayID, 0, size);
}

int arrayGetNumElements(int arrayID = -1)
{
	if (arrayID <= -1)
		return(1);
	if (arrayID > gArrayPlanIDs)
		return(1);

	return(aiPlanGetUserVariableInt(gArrayPlanNumElements, arrayID, 0));
}

// NOTE: This function adjusts two variables: the actual length of our data array which is
// arrayID. It also updates the variable that stores the number of elements that arrayID
// possesses. This varible is stored in a separate plan
void arraySetNumElements(int arrayID = -1, int numElements = -1, bool clearValues = false)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;
	// Num elements needs to be >= 1 even if it stores nothing.
	if (numElements < 1)
		return;

	aiPlanSetNumberUserVariableValues(gArrayPlan, arrayID, numElements, clearValues);
	aiPlanSetUserVariableInt(gArrayPlanNumElements, arrayID, 0, numElements);
}

void arrayResetSelf(int arrayID = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;

	arraySetNumElements(arrayID, 1, true);
	arraySetSize(arrayID, 0);
}

// ========================================
// Integer User Variables
int arrayCreateInt(int numElements = 1, string description = "default")
{
	gArrayPlanIDs++;
	aiPlanAddUserVariableInt(gArrayPlan, gArrayPlanIDs, description, numElements);

	// 1 value (index 0) to represent the size (the defined elements) of the array at index gArrayPlanIDs.
	aiPlanAddUserVariableInt(gArrayPlanSizes, gArrayPlanIDs, "Size of Array " + description, 1);
	// Default is size 0, being that when the User Var is created, the default value is -1, or undefined.
	aiPlanSetUserVariableInt(gArrayPlanSizes, gArrayPlanIDs, 0, 0);

	// 1 value (index 0) to represent the number of (all, even undefined) elements of the array at index gArrayPlanIDs.
	aiPlanAddUserVariableInt(gArrayPlanNumElements, gArrayPlanIDs, "Num Elements of Array " + description, 1);
	aiPlanSetUserVariableInt(gArrayPlanNumElements, gArrayPlanIDs, 0, numElements);

	return(gArrayPlanIDs);
}

int arrayGetInt(int arrayID = -1, int arrayIndex = -1)
{
	if (arrayID <= -1)
		return(-1);
	if (arrayID > gArrayPlanIDs)
		return(-1);
	if (arrayIndex <= -1)
		return(-1);
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return(-1);

	return(aiPlanGetUserVariableInt(gArrayPlan, arrayID, arrayIndex));
}

void arraySetInt(int arrayID = -1, int arrayIndex = -1, int value = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;
	if (arrayIndex <= -1)
		return;
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return;

	aiPlanSetUserVariableInt(gArrayPlan, arrayID, arrayIndex, value);
}

void arrayPushInt(int arrayID = -1, int value = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;

	int size = arrayGetSize(arrayID);
	int numElements = arrayGetNumElements(arrayID);

	if (size >= numElements)
		arraySetNumElements(arrayID, numElements * 2);

	arraySetInt(arrayID, size, value);
	size++;
	arraySetSize(arrayID, size);
}

void arrayDeleteInt(int arrayID = -1, int arrayIndex = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;
	if (arrayIndex <= -1)
		return;
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return;

	int size = arrayGetSize(arrayID);
	int numElements = arrayGetNumElements(arrayID);
	size--;
	if (numElements > 1) // Do not set the number elements to zero, or the array malfunctions.
	{
		numElements--;
		// Length of arrayID is adjusted via this function. We should NOT use
		// the custom function arraySetNumElements, as that adjusts the size
		// by getting rid of the last element (untested), not necessarily the one
		// that we want to remove.
		aiPlanRemoveUserVariableValue(gArrayPlan, arrayID, arrayIndex);
		// Thus, we should adjust the numElements manually.
		aiPlanSetUserVariableInt(gArrayPlanNumElements, arrayID, 0, numElements);
	}
	// Probably already -1, but let's make sure, so that it won't be considered.
	else
	{
		arraySetInt(arrayID, arrayIndex, -1);
	}

	// Using the function we defined for size is fine, though.
	arraySetSize(arrayID, size);
}

void arrayRemoveDonePlans(int arrayID = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;

	for (planIndex = 0; < arrayGetSize(arrayID))
	{	// If we delete values while inside the loop, the size of the array shrinks
		// and we may face errors.
		if (aiPlanGetState(arrayGetInt(arrayID, planIndex)) < 0)
			arraySetInt(arrayID, planIndex, -1);
	}
	for (planIndex = 0; < arrayGetSize(arrayID))
	{
		if (arrayGetInt(arrayID, planIndex) < 0)
			arrayDeleteInt(arrayID, planIndex);
	}
}

void arrayEnablePlans(int arrayID = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;

	int planID = -1;

	for (index = 0; < arrayGetSize(arrayID))
	{
		planID = arrayGetInt(arrayID, index);
		if (planID >= 0)
			aiPlanSetActive(planID);
	}

	arrayResetSelf(arrayID);
}

void arrayShuffleInt(int arrayID = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;

	int i = arrayGetSize(arrayID) - 1;
	int j = 0;
	int temp = 0;
	while (i >= 0)
	{
		j = aiRandInt(i + 1);
		temp = arrayGetInt(arrayID, i);
		arraySetInt(arrayID, i, arrayGetInt(arrayID, j));
		arraySetInt(arrayID, j, temp);
		i = i - 1;
	}
}
// ========================================

// ========================================
// Bool User Variables
int arrayCreateBool(int numElements = 1, string description = "default")
{
	gArrayPlanIDs++;
	aiPlanAddUserVariableBool(gArrayPlan, gArrayPlanIDs, description, numElements);

	// 1 value (index 0) to represent the size (the defined elements) of the array at index gArrayPlanIDs.
	aiPlanAddUserVariableInt(gArrayPlanSizes, gArrayPlanIDs, "Size of Array " + description, 1);
	// Default is size 0, being that when the User Var is created, the default value is -1, or undefined.
	aiPlanSetUserVariableInt(gArrayPlanSizes, gArrayPlanIDs, 0, 0);

	// 1 value (index 0) to represent the number of (all, even undefined) elements of the array at index gArrayPlanIDs.
	aiPlanAddUserVariableInt(gArrayPlanNumElements, gArrayPlanIDs, "Num Elements of Array " + description, 1);
	aiPlanSetUserVariableInt(gArrayPlanNumElements, gArrayPlanIDs, 0, numElements);

	return(gArrayPlanIDs);
}

bool arrayGetBool(int arrayID = -1, int arrayIndex = -1)
{
	if (arrayID <= -1)
		return(false);
	if (arrayID > gArrayPlanIDs)
		return(false);
	if (arrayIndex <= -1)
		return(false);
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return(false);

	return(aiPlanGetUserVariableBool(gArrayPlan, arrayID, arrayIndex));
}

void arraySetBool(int arrayID = -1, int arrayIndex = -1, bool value = false)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;
	if (arrayIndex <= -1)
		return;
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return;

	aiPlanSetUserVariableBool(gArrayPlan, arrayID, arrayIndex, value);
}

void arrayPushBool(int arrayID = -1, bool value = false)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;

	int size = arrayGetSize(arrayID);
	int numElements = arrayGetNumElements(arrayID);

	if (size >= numElements)
		arraySetNumElements(arrayID, numElements * 2);

	arraySetBool(arrayID, size, value);
	size++;
	arraySetSize(arrayID, size);
}
// ========================================

// ========================================
// Vector User Variables
int arrayCreateVector(int numElements = 1, string description = "default")
{
	gArrayPlanIDs++;
	aiPlanAddUserVariableVector(gArrayPlan, gArrayPlanIDs, description, numElements);

	// 1 value (index 0) to represent the size (the defined elements) of the array at index gArrayPlanIDs.
	aiPlanAddUserVariableInt(gArrayPlanSizes, gArrayPlanIDs, "Size of Array " + description, 1);
	// Default is size 0, being that when the User Var is created, the default value is -1, or undefined.
	aiPlanSetUserVariableInt(gArrayPlanSizes, gArrayPlanIDs, 0, 0);

	// 1 value (index 0) to represent the number of (all, even undefined) elements of the array at index gArrayPlanIDs.
	aiPlanAddUserVariableInt(gArrayPlanNumElements, gArrayPlanIDs, "Num Elements of Array " + description, 1);
	aiPlanSetUserVariableInt(gArrayPlanNumElements, gArrayPlanIDs, 0, numElements);

	return(gArrayPlanIDs);
}

vector arrayGetVector(int arrayID = -1, int arrayIndex = -1)
{
	if (arrayID <= -1)
		return(cInvalidVector);
	if (arrayID > gArrayPlanIDs)
		return(cInvalidVector);
	if (arrayIndex <= -1)
		return(cInvalidVector);
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return(cInvalidVector);

	return(aiPlanGetUserVariableVector(gArrayPlan, arrayID, arrayIndex));
}

void arraySetVector(int arrayID = -1, int arrayIndex = -1, vector value = cInvalidVector)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;
	if (arrayIndex <= -1)
		return;
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return;

	aiPlanSetUserVariableVector(gArrayPlan, arrayID, arrayIndex, value);
}

void arrayPushVector(int arrayID = -1, vector value = cInvalidVector)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;

	int size = arrayGetSize(arrayID);
	int numElements = arrayGetNumElements(arrayID);

	if (size >= numElements)
		arraySetNumElements(arrayID, numElements * 2);

	arraySetVector(arrayID, size, value);
	size++;
	arraySetSize(arrayID, size);
}

void arrayDeleteVector(int arrayID = -1, int arrayIndex = -1)
{
	if (arrayID <= -1)
		return;
	if (arrayID > gArrayPlanIDs)
		return;
	if (arrayIndex <= -1)
		return;
	if (arrayIndex >= aiPlanGetNumberUserVariableValues(gArrayPlan, arrayID))
		return;

	int size = arrayGetSize(arrayID);
	int numElements = arrayGetNumElements(arrayID);
	size--;
	if (numElements > 1) // Do not set the number elements to zero, or the array malfunctions.
	{
		numElements--;
		// Length of arrayID is adjusted via this function. We should NOT use
		// the custom function arraySetNumElements, as that adjusts the size
		// by getting rid of the last element (untested), not necessarily the one
		// that we want to remove.
		aiPlanRemoveUserVariableValue(gArrayPlan, arrayID, arrayIndex);
		// Thus, we should adjust the numElements manually.
		aiPlanSetUserVariableInt(gArrayPlanNumElements, arrayID, 0, numElements);
	}
	// Probably already -1, but let's make sure, so that it won't be considered.
	else
	{
		arraySetVector(arrayID, arrayIndex, cInvalidVector);
	}

	// Using the function we defined for size is fine, though.
	arraySetSize(arrayID, size);
}
// ========================================

//==============================================================================
// Civilization checks.
//==============================================================================

bool civIsNative(void)
{
	if (cMyCiv == cCivXPIroquois || cMyCiv == cCivXPSioux || cMyCiv == cCivXPAztec || cMyCiv == cCivDEInca)
		return(true);

	return(false);
}

bool civIsAsian(void)
{
	if (cMyCiv == cCivChinese || cMyCiv == cCivJapanese || cMyCiv == cCivIndians)
		return(true);

	return(false);
}

bool civIsAfrican(void)
{
	if ((cMyCiv == cCivDEEthiopians) || (cMyCiv == cCivDEHausa))
		return (true);

	return (false);
}

bool civIsEuropean(void) // Italians/Maltese/Americans/Mexicans included for simplicity.
{
	if (civIsNative() == false && civIsAsian() == false &&
		civIsAfrican() == false)
		return(true);

	return(false);
}

bool civIsDEciv(void)
{
	if ((cMyCiv == cCivDEInca) || (cMyCiv == cCivDESwedish) || (cMyCiv == cCivDEAmericans) ||
		(cMyCiv == cCivDEEthiopians) || (cMyCiv == cCivDEEthiopians) || (cMyCiv == cCivDEHausa) ||
		(cMyCiv == cCivDEMexicans) || (cMyCiv == cCivDEItalians) || (cMyCiv == cCivDEMaltese))
		return (true);

	return (false);
}

bool isMinorNativePresent(int minorNative = -1)
{
	return(minorNative >= 0 ? ((gNativeTribeCiv1 == minorNative) || (gNativeTribeCiv2 == minorNative) || 
		(gNativeTribeCiv3 == minorNative)) : false);
}

// ================================================================================
//	Algorithms
// ================================================================================

vector rotateByReferencePoint(vector refPoint = cInvalidVector, vector vec = cInvalidVector, float angle = 0.0)
{
	if ((refPoint == cInvalidVector) || (vec == cInvalidVector))
		return(cInvalidVector);
	
	float x = xsVectorGetX(vec);
	float z = xsVectorGetZ(vec);
	vector finalLocation = cInvalidVector;
	finalLocation = xsVectorSet(x*cos(angle) - z*sin(angle) + xsVectorGetX(refPoint), 0.0, x*sin(angle) + z*cos(angle) + xsVectorGetZ(refPoint));
	return(finalLocation);
}

bool arraySortIntComp(int a = -1, int b = -1) { return (a < b); }

void arraySortInt(int arrayID = -1, int begin = 0, int end = -1, bool(int, int) comp = arraySortIntComp)
{
   int j = 0;
   int key = 0;

   if (end < 0)
      end = xsArrayGetSize(arrayID);

   for (i = begin + 1; < end)
   {
      key = xsArrayGetInt(arrayID, i);
      j = i - 1;
      while ((j >= 0) && (comp(xsArrayGetInt(arrayID, j), key) == false))
      {
         xsArraySetInt(arrayID, j + 1, xsArrayGetInt(arrayID, j));
         j--;
      }
      xsArraySetInt(arrayID, j + 1, key);
   }
}

void randomShuffleIntArray(int array = -1, int size = 0)
{
	int i = size - 1;
	int j = 0;
	int temp = 0;
	while (i >= 0)
	{
		j = aiRandInt(i + 1);
		temp = xsArrayGetInt(array, i);
		xsArraySetInt(array, i, xsArrayGetInt(array, j));
		xsArraySetInt(array, j, temp);
		i = i - 1;
	}
}

float getMin(float a = 0, float b = 0)
{
	if(a < b)
		return(a);
	return(b);
}

float getMax(float a = 0, float b = 0)
{
	if(a > b)
		return(a);
	return(b);
}

int getFloor(float a = 0)
{
	int b = a; // Auto-cast to int, which is rounded down.
	return(b);
}

int getCeiling(float a = 0)
{
	int b = a; // Auto-cast to int, which is rounded down.
	return(b + 1);
}

int getRoundedNumber(float a = 0)
{
	if (a - getFloor(a) < 0.5)
		return(getFloor(a));
	return(getCeiling(a));
}

float getDistance(vector v1 = cInvalidVector, vector v2 = cInvalidVector)
{
	vector delta = v1 - v2;
	return (xsVectorLength(delta));
}

// ================================================================================
//	General Purpose
// ================================================================================

float getAreaGroupTileTypePercentage(int areaGroupID = -1, int tileType = cTileBlack)
{
	int i = 0;
	int areaID = -1;
	float numberTiles = 0.0;
	float numberTotalTiles = 0.0;
	for (i = 0; < kbAreaGroupGetNumberAreas(areaGroupID))
	{
		areaID = kbAreaGroupGetAreaID(areaGroupID, i);
	  if ((tileType & cTileBlack) == cTileBlack)
		  numberTiles = numberTiles + kbAreaGetNumberBlackTiles(areaID);
	  if ((tileType & cTileFog) == cTileFog)
		  numberTiles = numberTiles + kbAreaGetNumberFogTiles(areaID);
	  if ((tileType & cTileVisible) == cTileVisible)
		  numberTiles = numberTiles + kbAreaGetNumberVisibleTiles(areaID);		 
	  numberTotalTiles = numberTotalTiles + kbAreaGetNumberTiles(areaID);
	}
	return(numberTiles/numberTotalTiles);
}

int getAreaGroupNumberTiles(int areaGroupID = -1)
{
	int areaID = -1;
	int numberTotalTiles = 0;
	int numberAreas = kbAreaGroupGetNumberAreas(areaGroupID);
	for (i = 0; < numberAreas)
	{
		areaID = kbAreaGroupGetAreaID(areaGroupID, i);
		numberTotalTiles = numberTotalTiles + kbAreaGetNumberTiles(areaID);
	}
	return (numberTotalTiles);
}

vector guessEnemyLocation(int player = -1)
{
	if (player < 0)
		player = aiGetMostHatedPlayerID();
	vector position = kbGetPlayerStartingPosition(player);
	
	if (aiGetWorldDifficulty() >= cDifficultyHard && position != cInvalidVector)
	{
		// For higher difficulties, assuming the AI played on this map before, it should have a rough idea of the enemy location.
		float xError = kbGetMapXSize() * 0.1;
		float zError = kbGetMapZSize() * 0.1;
		xsVectorSetX(position, xsVectorGetX(position) + aiRandFloat(0.0 - xError, xError));
		xsVectorSetZ(position, xsVectorGetZ(position) + aiRandFloat(0.0 - zError, zError));
	}
	else
	{
		// For lower difficulties, just simply create a mirror image of our base.
		vector myBaseLocation = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)); // Main base location...need to find reflection.
		vector centerOffset = kbGetMapCenter() - myBaseLocation;
		position = kbGetMapCenter() + centerOffset;  
	}

	return(position);
}

int getMapID(void)
{
	int mapIndex = 0;
	for (mapIndex = 0; < xsArrayGetSize(gMapNames))
	{
		if (xsArrayGetString(gMapNames, mapIndex) == cRandomMapName)
		{
			return(mapIndex);
		}
	}
	return(-1);
}

float getMilitaryUnitStrength(int puid = -1)
{
	float retVal = 0.0;
	retVal = retVal + kbUnitCostPerResource(puid, cResourceFood) * 0.992
						 + kbUnitCostPerResource(puid, cResourceWood) * 1.818
						 + kbUnitCostPerResource(puid, cResourceGold) * 1.587;
	retVal = retVal * 0.01;
	return(retVal);
}

int indexProtoUnitInUnitPicker(int puid = -1)
{
	int result = -1;
	for (i = 0; < gNumArmyUnitTypes)
	{
		result = kbUnitPickGetResult(gLandUnitPicker, i);
		if (puid == result)
		{
			return (i);
		}
	}
	return (-1);
}

int getAllyCount()
{
	int retVal = 0;

	int player = 0;
	for (player = 1; < cNumberPlayers)
	{
		if (player == cMyID)
			continue;

		if (kbIsPlayerAlly(player) == true)
			retVal = retVal + 1;
	}

	return(retVal);
}

int getHumanAllyCount()
{
	int retVal = 0;

	int player = 0;
	for (player = 1; < cNumberPlayers)
	{
		if (player == cMyID)
			continue;

		if (kbIsPlayerAlly(player) == true && kbIsPlayerHuman(player))
			retVal = retVal + 1;
	}

	return (retVal);
}

int getEnemyCount()
{
	int retVal = 0;

	int player = 0;
	for (player = 1; < cNumberPlayers)
	{
		if (player == cMyID)
			continue;

		if (kbIsPlayerEnemy(player) == true)
			retVal = retVal + 1;
	}

	return(retVal);
}

int getTeamPosition(int playerID = -1)
{
	int index = -1;    // Used for traversal
	int playerToGet = -1;   // i.e. get the 2nd matching playe

	// Traverse list of players, increment when we find a teammate, return when we find my number.
	int retVal = 0;      // Zero if I don't exist...
	for (index = 1; < cNumberPlayers)
	{
		if ((kbHasPlayerLost(index) == false) && (kbGetPlayerTeam(playerID) == kbGetPlayerTeam(index)))
			retVal = retVal + 1; // That's another match

		if (index == playerID)
			return(retVal);
	}
	return(-1);
}

int getEnemyPlayerByTeamPosition(int position = -1)
{

	int matchCount = 0;
	int index = -1;    // Used for traversal
	int playerToGet = -1;   // i.e. get the 2nd matching playe

	// Traverse list of players, return when we find the matching player
	for (index = 1; < cNumberPlayers)
	{
		if ((kbHasPlayerLost(index) == false) && (kbGetPlayerTeam(cMyID) != kbGetPlayerTeam(index)))
			matchCount = matchCount + 1; // Enemy player, add to the count

		if (matchCount == position)
			return(index);
	}
	return(-1);
}

bool agingUp(void)
{
	int planState = cPlanStateResearch;
	if (civIsAsian() == true)
		planState = cPlanStateBuild;
	return(aiPlanGetState(gAgeUpResearchPlan) == planState);
}

int getAgingUpAge(void)
{
	if (agingUp() == true)
		return(kbGetAge() + 1);
	return(kbGetAge());
}

bool resourceCloserToAlly(int resourceID = -1)
{
	// After 25 minutes consider all resources fair game.
	static int time = 1500000;
	static bool timeCheck = false;
	if (xsGetTime() >= time)
		timeCheck = true;
	if (timeCheck == true)
		return(false);

	// If we have no allies, check no further.
	int size = arrayGetSize(gAllyBaseArray);
	if (size <= 0)
		return(false);

	float distanceToMe = getDistance(kbUnitGetPosition(resourceID), gHomeBase);
	if (distanceToMe <= 60.0) // Always consider gathering if it is this close to our base.
		return(false);
	float distanceToAlly = -1;

	int index = 0;
	for (player = 1; < cNumberPlayers)
	{
		if (kbIsPlayerAlly(player))
		{
			if (player == cMyID)
				continue;
			// If the player has lost, the resources might as well be ours.
			if (kbHasPlayerLost(player) == false)
			{
				distanceToAlly = getDistance(kbUnitGetPosition(resourceID), arrayGetVector(gAllyBaseArray, index));
				if ((distanceToAlly * 1.2) < distanceToMe) // So we have a little wiggle room, multiply by 1.2.
					return(true);
			}
			index++;
		}
	}

	return(false);
}


bool resourceCloserToEnemy(int resourceID = -1)
{
	float distanceToMe = getDistance(kbUnitGetPosition(resourceID), gHomeBase);
	float distanceToEnemy = getDistance(kbUnitGetPosition(resourceID), avgEnemyBaseLocation);

	if (distanceToEnemy < distanceToMe)
		return(true);

	return(false);
}

// ================================================================================
//	Query Related
// ================================================================================

// ================================================================================
//	getUnit
//
//	Will return a random unit matching the parameters
// ================================================================================
int getUnit(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive)
{
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscGetUnitQuery");
	}

	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
		if (playerRelationOrID > 1000)      // Too big for player ID number
		{
			kbUnitQuerySetPlayerID(unitQueryID, -1);  // Clear the player ID, so playerRelation takes precedence.
			kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
		}
		else
		{
			kbUnitQuerySetPlayerRelation(unitQueryID, -1);
			kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
		}
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);
	}
	else
		return(-1);

	kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
	if (numberFound > 0)
		return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound)));   // Return a random dude(tte)
	return(-1);
}

// ================================================================================
//	getSpecificUnit
// ================================================================================
int getSpecificUnit(int unitTypeID = -1, int pos = 0, int playerRelationOrID = cMyID, int state = cUnitStateAlive)
{
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscGetUnitLocationQuery");
	}

	if (pos == 0)
	{
		kbUnitQueryResetResults(unitQueryID);
		if (playerRelationOrID > 1000)	// Too big for player ID number
		{
			kbUnitQuerySetPlayerID(unitQueryID, -1);
			kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
		}
		else
		{
			kbUnitQuerySetPlayerRelation(unitQueryID, -1);
			kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
		}
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);

		kbUnitQueryExecute(unitQueryID);
	}

	return(kbUnitQueryGetResult(unitQueryID, pos));
}

// ================================================================================
//	createSimpleUnitQuery
// ================================================================================
int createSimpleUnitQuery(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive, vector position = cInvalidVector, float radius = -1.0)
{
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscSimpleUnitQuery");
	}

	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
		if (playerRelationOrID > 1000)      // Too big for player ID number
		{
			kbUnitQuerySetPlayerID(unitQueryID, -1);  // Clear the player ID, so playerRelation takes precedence.
			kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
		}
		else
		{
			kbUnitQuerySetPlayerRelation(unitQueryID, -1);
			kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
		}
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		kbUnitQuerySetPosition(unitQueryID, position);
		kbUnitQuerySetMaximumDistance(unitQueryID, radius);
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);
	}
	else
		return(-1);

	kbUnitQueryResetResults(unitQueryID);
	return (unitQueryID);
}

// ================================================================================
//	reQuery: Alter the location of an already calculated Query.
// ================================================================================
int reQuery(int queryID = -1, vector location = cInvalidVector, float dist = 200.0)
{
	if (reQueryID < 0)
	{
		reQueryID = kbUnitQueryCreate("Altered Query");
		kbUnitQuerySetState(reQueryID, cUnitStateAny);
		kbUnitQuerySetAscendingSort(reQueryID, true);
	}
	kbUnitQueryResetResults(reQueryID);
	kbUnitQuerySetPosition(reQueryID, location);
	kbUnitQuerySetMaximumDistance(reQueryID, dist);
	return (kbUnitQueryExecuteOnQuery(reQueryID, queryID));
}

//==============================================================================
// createSimpleGaiaUnitQuery
// ATTENTION: before you call this function switch your context to Gaia(0) otherwise this won't work.
// Then in your code first kbUnitQueryExecute the query BEFORE you switch back to cMyID.
//==============================================================================
int createSimpleGaiaUnitQuery(int unitTypeID = -1, int state = cUnitStateAlive,
	vector position = cInvalidVector, float radius = -1.0)
{
	static int unitQueryID = -1;

	// If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscSimpleUnitQuery");
	}

	// Define a query to get all matching units
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, 0);
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		kbUnitQuerySetPosition(unitQueryID, position);
		kbUnitQuerySetMaximumDistance(unitQueryID, radius);
	}
	else
	{
		return (-1);
	}

	kbUnitQueryResetResults(unitQueryID);
	return (unitQueryID);
}

//==============================================================================
// getGaiaUnitCount
// Unit count from Gaia's perspective, use with caution to avoid cheating.
//==============================================================================
int getGaiaUnitCount(int unitTypeID = -1)
{
	xsSetContextPlayer(0);
	int numberFound = kbUnitCount(0, unitTypeID);
	xsSetContextPlayer(cMyID);
	return (numberFound);
}

//==============================================================================
// getClosestGaiaUnitPosition
// Query closest unit's position from gaia's perspective, use with caution to avoid cheating.
//==============================================================================
vector getClosestGaiaUnitPosition(int unitTypeID = -1, vector position = cInvalidVector, float radius = -1.0)
{
	xsSetContextPlayer(0);
	static int unitQueryID = -1;

	// If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("getClosestGaiaUnitPositionQuery");
	}

	// Define a query to get all matching units.
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, 0);
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
		kbUnitQuerySetPosition(unitQueryID, position);
		kbUnitQuerySetMaximumDistance(unitQueryID, radius);
		kbUnitQuerySetAscendingSort(unitQueryID, true);
	}
	else
	{
		xsSetContextPlayer(cMyID);
		return (cInvalidVector);
	}
	
	kbUnitQueryResetResults(unitQueryID);
	
	if (kbUnitQueryExecute(unitQueryID) > 0)
	{
		vector closestFishPosition = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, 0)); // Get the location of the first(closest) unit.
		xsSetContextPlayer(cMyID);
		return (closestFishPosition);
	}
	xsSetContextPlayer(cMyID);
	return (cInvalidVector);
}

// ================================================================================
//	getUnitByTech
//
//	Will return a random unit matching the parameters
// ================================================================================
int getUnitByTech(int unitTypeID = -1, int TechID = -1)
{
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscGetUnitByTechQuery");
	}

	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);
		kbUnitQuerySetPlayerRelation(unitQueryID, -1);
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetTechID(unitQueryID, TechID);
		kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);
	}
	else
		return(-1);

	kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
	if (numberFound > 0)
		return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound)));
	return(-1);
}

// ================================================================================
//	getUnitByLocation
//
//	Will return the closest unit by location.
// ================================================================================
int getUnitByLocation(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive,
	vector location = cInvalidVector, float radius = 20.0, int pos = 0)
{
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscGetUnitLocationQuery");
	}

	if (pos == 0)
	{
		kbUnitQueryResetResults(unitQueryID);
		if (playerRelationOrID > 1000)	// Too big for player ID number
		{
			kbUnitQuerySetPlayerID(unitQueryID, -1);
			kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
		}
		else
		{
			kbUnitQuerySetPlayerRelation(unitQueryID, -1);
			kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
		}
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		kbUnitQuerySetPosition(unitQueryID, location);
		kbUnitQuerySetMaximumDistance(unitQueryID, radius);
		kbUnitQuerySetAscendingSort(unitQueryID, true);
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);

		kbUnitQueryExecute(unitQueryID);
	}

	return(kbUnitQueryGetResult(unitQueryID, pos));
}

// ================================================================================
//	getClosestUnit
//
//	Will return a random unit matching the parameters
// ================================================================================
int getClosestUnit(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive, vector location = cInvalidVector, float radius = 20.0)
{
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscGetUnitLocationQuery");
	}

	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
		if (playerRelationOrID > 1000)      // Too big for player ID number
		{
			kbUnitQuerySetPlayerID(unitQueryID, -1);
			kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
		}
		else
		{
			kbUnitQuerySetPlayerRelation(unitQueryID, -1);
			kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
		}
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		kbUnitQuerySetPosition(unitQueryID, location);
		kbUnitQuerySetMaximumDistance(unitQueryID, radius);
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);
		kbUnitQuerySetAscendingSort(unitQueryID, true);
	}
	else
		return(-1);

	kbUnitQueryResetResults(unitQueryID);
	int numberFound = kbUnitQueryExecute(unitQueryID);
	if (numberFound > 0)
		return(kbUnitQueryGetResult(unitQueryID, 0));   // Return the first unit
	return(-1);
}

// ================================================================================
//	getUnitCountByLocation
//
//	Returns the number of matching units in the point/radius specified
// ================================================================================
int getUnitCountByLocation(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive, vector location = cInvalidVector, float radius = 20.0)
{
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("miscGetUnitLocationQuery");
	}

	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
		if (playerRelationOrID > 1000)      // Too big for player ID number
		{
			kbUnitQuerySetPlayerID(unitQueryID, -1);
			kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
		}
		else
		{
			kbUnitQuerySetPlayerRelation(unitQueryID, -1);
			kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
		}
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		kbUnitQuerySetPosition(unitQueryID, location);
		kbUnitQuerySetMaximumDistance(unitQueryID, radius);
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);
	}
	else
		return(-1);

	kbUnitQueryResetResults(unitQueryID);
	return(kbUnitQueryExecute(unitQueryID));
}

// ================================================================================
//	getUnitCountByTactic
// ================================================================================
int getUnitCountByTactic(int unitTypeID = -1, int playerRelationOrID = cMyID, int state = cUnitStateAlive, int tacticID = -1)
{
	int count = 0;
	static int unitQueryID = -1;

	//If we don't have the query yet, create one.
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("tacticUnitQuery");
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);
	}

	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
		if (playerRelationOrID > 1000)      // Too big for player ID number
		{
			kbUnitQuerySetPlayerID(unitQueryID, -1);
			kbUnitQuerySetPlayerRelation(unitQueryID, playerRelationOrID);
		}
		else
		{
			kbUnitQuerySetPlayerRelation(unitQueryID, -1);
			kbUnitQuerySetPlayerID(unitQueryID, playerRelationOrID);
		}
		kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
		kbUnitQuerySetState(unitQueryID, state);
		//kbUnitQuerySetPosition(unitQueryID, location);
		//kbUnitQuerySetMaximumDistance(unitQueryID, radius);
	}
	else
		return(-1);

	kbUnitQueryResetResults(unitQueryID);
	int i = 0;
	for (i = 0; < kbUnitQueryExecute(unitQueryID))
	{
		if (aiUnitGetTactic(kbUnitQueryGetResult(unitQueryID, i)) == tacticID)
			count = count + 1;
	}

	return(count);
}

//==============================================================================
// checkAliveSuitableTradingPost
// Trading Posts can have different purposes when placed on different minor native sockets.
// If you need a specific one you can use this function to get one matching your wanted subCiv.
//==============================================================================
int checkAliveSuitableTradingPost(int subCivID = -1)
{
	int queryID = createSimpleUnitQuery(cUnitTypeTradingPost, cMyID, cUnitStateAlive);
	int numberFound = kbUnitQueryExecute(queryID);
	int tradingPostID = -1;
	for (i = 0; < numberFound)
	{
		tradingPostID = kbUnitQueryGetResult(queryID, i);
		if (kbUnitGetSubCiv(tradingPostID) == subCivID)
		{
			return (tradingPostID); // We've found a Trading Post that has the right subciv so we return this ID and quit.
		}
	}
	return (-1);
}

int baseBuildingCount(int baseID = -1, int relation = cPlayerRelationAny, int state = cUnitStateAlive)
{
	int retVal = -1;

	if (baseID >= 0)
	{
		// Check for buildings in the base, regardless of player ID (only baseOwner can have buildings there)
		int owner = kbBaseGetOwner(baseID);
		retVal = getUnitCountByLocation(cUnitTypeBuilding, relation, state, kbBaseGetLocation(owner, baseID), kbBaseGetDistance(owner, baseID));
	}

	return (retVal);
}

// ================================================================================
//	isProtoUnitAffordable
//
//	Returns whether the unit is affordable by also considering resource crates we have.
// ================================================================================
bool isProtoUnitAffordable(int puid = -1)
{
	int crateQuery = createSimpleUnitQuery(cUnitTypeAbstractResourceCrate, cMyID, cUnitStateAlive);
	int numberFound = kbUnitQueryExecute(crateQuery);
	for (resource = cResourceGold; <= cResourceFood)
	{
		float total = kbResourceGet(resource);
		for (i = 0; < numberFound)
		{
			int crateID = kbUnitQueryGetResult(crateQuery, i);
			total = total + kbUnitGetResourceAmount(crateID, resource);
		}
		if (total < kbUnitCostPerResource(puid, resource))
			return(false);
	}
	return(true);
}

// ================================================================================
//	getPlayerArmyHPs
//
//	Queries all land military units.  
//	Totals hitpoints (ideal if considerHealth false, otherwise actual.)
//	Returns total
// ================================================================================
float getPlayerArmyHPs(int playerID = -1, bool considerHealth = false)
{
	int queryID = -1;    // Will recreate each time, as changing player trashes existing query settings.

	if (playerID <= 0)
		return(-1.0);

	queryID = kbUnitQueryCreate("getStrongestEnemyArmyHPs");
	kbUnitQuerySetIgnoreKnockedOutUnits(queryID, true);
	kbUnitQuerySetPlayerID(queryID, playerID, true);
	kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeLandMilitary);
	kbUnitQuerySetState(queryID, cUnitStateAlive);
	kbUnitQueryResetResults(queryID);
	kbUnitQueryExecute(queryID);

	return(kbUnitQueryGetUnitHitpoints(queryID, considerHealth));
}

// ================================================================================
//	getCurrentMilitaryPop
// ================================================================================
int getCurrentMilitaryPop()
{
	int pop = aiGetMilitaryPop() - aiGetAvailableMilitaryPop();
	return(pop);
}

//==============================================================================
// createSimpleResearchPlan
//==============================================================================
int createSimpleResearchPlan(int techID = -1, int buildingConstantID = -1, int escrowID = cRootEscrowID,
	int pri = 50, int resourcePri = 50)
{
	int planID = aiPlanCreate("Simple Research Plan, " + kbGetTechName(techID), cPlanResearch);
	if (planID < 0)
		debugUtilities("Failed to create Simple Research Plan for " + kbGetTechName(techID));
	else
	{
		aiPlanSetVariableInt(planID, cResearchPlanTechID, 0, techID);
		aiPlanSetVariableInt(planID, cResearchPlanBuildingTypeID, 0, buildingConstantID);
		aiPlanSetDesiredPriority(planID, pri);
		aiPlanSetDesiredResourcePriority(planID, resourcePri);
		aiPlanSetActive(planID);
		debugUtilities("Created a Simple Research Plan for: " + kbGetTechName(techID) + " with plan number: " + planID);
	}

	return (planID);
}

//==============================================================================
// createProtoUnitCommandResearchPlan
//==============================================================================
int createProtoUnitCommandResearchPlan(int protoUnitCommandID = -1, int buildingID = -1, int escrowID = cRootEscrowID,
	int pri = 50, int resourcePri = 50)
{
	int planID = aiPlanCreate("Proto Unit Command Research Plan, " + kbProtoUnitCommandGetName(protoUnitCommandID), cPlanResearch);
	if (planID < 0)
	{
		debugTechs("Failed to create Proto Unit Command Research Plan for " + kbProtoUnitCommandGetName(protoUnitCommandID));
	}
	else
	{
		aiPlanSetVariableInt(planID, cResearchPlanProtoUnitCommandID, 0, protoUnitCommandID);
		aiPlanSetVariableInt(planID, cResearchPlanBuildingID, 0, buildingID);
		aiPlanSetDesiredPriority(planID, pri);
		aiPlanSetDesiredResourcePriority(planID, resourcePri);
		aiPlanSetActive(planID);
		debugTechs("Created a Proto Unit Command Research Plan for: " + kbProtoUnitCommandGetName(protoUnitCommandID) + " with plan number: " + planID);
	}

	return (planID);
}

//==============================================================================
// createSimpleResearchPlanSpecificBuilding
//==============================================================================
int createSimpleResearchPlanSpecificBuilding(int techID = -1, int buildingID = -1, int escrowID = cRootEscrowID,
	int pri = 50, int resourcePri = 50)
{
	int planID = aiPlanCreate("Simple Research Plan Specific Building, " + kbGetTechName(techID), cPlanResearch);
	if (planID < 0)
		debugUtilities("Failed to create Simple Research Plan Specific Building for " + kbGetTechName(techID));
	else
	{
		aiPlanSetVariableInt(planID, cResearchPlanTechID, 0, techID);
		aiPlanSetVariableInt(planID, cResearchPlanBuildingID, 0, buildingID);
		aiPlanSetDesiredPriority(planID, pri);
		aiPlanSetDesiredResourcePriority(planID, resourcePri);
		aiPlanSetActive(planID);
		debugUtilities("Created a Simple Research Plan Specific Building for: " + kbGetTechName(techID) + " with plan number: " + planID);
	}

	return (planID);
}

// ================================================================================
//	createResearchPlan
// ================================================================================
int createResearchPlan(int techID = -1, int buildingType = -1, int pri = 50, int buildingID = -1)
{
	int planID = aiPlanCreate("Research " + kbGetTechName(techID), cPlanResearch);
	aiPlanSetVariableInt(planID, cResearchPlanTechID, 0, techID);
	aiPlanSetVariableInt(planID, cResearchPlanBuildingTypeID, 0, buildingType);
	aiPlanSetDesiredPriority(planID, pri);
	aiPlanSetVariableInt(planID, cResearchPlanBuildingID, 0, buildingID); //important for trading posts
	aiPlanSetEscrowID(planID, cRootEscrowID);
	aiPlanSetActive(planID, true);
	debugUtilities("Created a Research Plan for: " + kbGetTechName(techID) + " with plan number: " + planID);

	return(planID);
}

//==============================================================================
// researchSimpleTech
//==============================================================================
bool researchSimpleTech(int techID = -1, int buildingPUID = -1, int buildingID = -1, int resourcePri = 50)
{
	int techStatus = kbTechGetStatus(techID);
	if (techStatus == cTechStatusActive)
	{
		return (true);
	}
	if (techStatus == cTechStatusUnobtainable)
	{
		return (false);
	} // If it's Obtainable we continue with the logic.

	int upgradePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID);
	if (upgradePlanID < 0) // We have no plan yet, check if we should create one.
	{
		if (buildingPUID >= 0)
		{
			upgradePlanID = createSimpleResearchPlan(techID, buildingPUID, cMilitaryEscrowID, 50, resourcePri);
		}
		else
		{
			upgradePlanID = createSimpleResearchPlanSpecificBuilding(techID, buildingID, cMilitaryEscrowID, 50, resourcePri);
		}
	}
	return (false);
}

bool researchSimpleTechShouldCreate() { return (true); }
//==============================================================================
// researchSimpleTechByCondition
//==============================================================================
bool researchSimpleTechByCondition(int techID = -1, bool() shouldCreate = researchSimpleTechShouldCreate,
	int buildingPUID = -1, int buildingID = -1, int resourcePri = 50)
{
	int techStatus = kbTechGetStatus(techID);
	if (techStatus == cTechStatusActive)
	{
		return (true);
	}
	if (techStatus == cTechStatusUnobtainable)
	{
		return (false);
	} // If it's Obtainable we continue with the logic.

	bool create = shouldCreate(); // We use () because we want to call the function via the
								//pointer and assign the return value to create.
	int upgradePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID);
	if (upgradePlanID >= 0) // We have a plan already.
	{
		if (create == false) // Check if we need to destroy it.
		{
			aiPlanDestroy(upgradePlanID);
		}
	}
	else if (create == true) // We have no plan yet, check if we should create one.
	{
		if (buildingPUID >= 0)
		{
			upgradePlanID = createSimpleResearchPlan(techID, buildingPUID, cMilitaryEscrowID, 50, resourcePri);
		}
		else
		{
			upgradePlanID = createSimpleResearchPlanSpecificBuilding(techID, buildingID, cMilitaryEscrowID, 50, resourcePri);
		}
	}
	return (false);
}

//==============================================================================
// researchSimpleTechByConditionEventHandler
//==============================================================================
bool researchSimpleTechByConditionEventHandler(
	int techID = -1, bool() shouldCreate = researchSimpleTechShouldCreate, string eventHandlerName = "", 
	int buildingPUID = -1, int buildingID = -1, int resourcePri = 50)
{
	int techStatus = kbTechGetStatus(techID);
	if (techStatus == cTechStatusActive)
	{
		return (true);
	}
	if (techStatus == cTechStatusUnobtainable)
	{
		return (false);
	} // If it's Obtainable we continue with the logic.

	bool create = shouldCreate();
	int upgradePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID);
	if (upgradePlanID >= 0) // We have a plan already.
	{
		if (create == false) // Check if we need to destroy it.
		{
			aiPlanDestroy(upgradePlanID);
		}
	}
	else if (create == true) // We have no plan yet, check if we should create one.
	{
		if (buildingPUID >= 0)
		{
			upgradePlanID = createSimpleResearchPlan(techID, buildingPUID, cMilitaryEscrowID, 50, resourcePri);
		}
		else
		{
			upgradePlanID = createSimpleResearchPlanSpecificBuilding(techID, buildingID, cMilitaryEscrowID, 50, resourcePri);
		}
		aiPlanSetEventHandler(upgradePlanID, cPlanEventStateChange, eventHandlerName);
	}
	return (false);
}

// ================================================================================
//	createSimpleMaintainPlan
// ================================================================================
int createSimpleMaintainPlan(int puid = -1, int number = 1, bool economy = true, int baseID = -1, int batchSize = 1)
{
	//Create a the plan name.
	string planName = "Military";
	if (economy == true)
		planName = "Economy";
	planName = planName + kbGetProtoUnitName(puid) + "Maintain";
	int planID = aiPlanCreate(planName, cPlanTrain);
	if (planID < 0)
		return(-1);

	//Economy or Military.
	if (economy == true)
		aiPlanSetEconomy(planID, true);
	else
		aiPlanSetMilitary(planID, true);
	//Unit type.
	aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
	//Number.
	aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, number);
	// Batch size
	aiPlanSetVariableInt(planID, cTrainPlanBatchSize, 0, batchSize);

	//If we have a base ID, use it.
	if (baseID >= 0)
	{
		aiPlanSetBaseID(planID, baseID);
		if (economy == false)
			aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, baseID));
	}

	//   aiPlanSetVariableBool(planID, cTrainPlanUseHomeCityShipments, 0, true);

	aiPlanSetActive(planID);

	//Done.
	return(planID);
}

//==============================================================================
// addBuildersToPlan
//==============================================================================
bool addBuildersToPlan(int planID = -1, int puid = -1, int numBuilders = 1, int builderTypeID = -1)
{
	if (numBuilders <= 0)
		return(false);

	// If we have a wagon that can build this bulding, we do NOT want to assign
	// anyone else. This is unless we are building with an architect.
	int builderType = -1;
	if (builderTypeID != cUnitTypedeArchitect)
	{
		builderType = findWagonToBuild(puid);
		if (builderType >= 0)
		{
			aiPlanAddUnitType(planID, builderType, 1, 1, 1);
			aiPlanSetUserVariableInt(planID, cBuildPlanBuilderTypeID, 0, builderType);
			return(true);
		}
	}

	// If we specified a builder other than cUnitTypeLogicalTypeSettlerBuildLimit,
	// just assign them and return true.
	builderType = builderTypeID;
	if (builderType != cUnitTypeLogicalTypeSettlerBuildLimit)
	{
		aiPlanAddUnitType(planID, builderType, 1, numBuilders, numBuilders);
		aiPlanSetUserVariableInt(planID, cBuildPlanBuilderTypeID, 0, builderType);
		return(true);
	}

	// Only the War Chief can build Strongholds.
	if (puid == cUnitTypedeIncaStronghold)
	{
		if (aiGetFallenExplorerID() < 0)
		{
			aiPlanAddUnitType(planID, cUnitTypeHero, 1, 1, 1);
			aiPlanSetUserVariableInt(planID, cBuildPlanBuilderTypeID, 0, cUnitTypeHero);
			return(true);
		}
	}

	// American and Mexican generals cannot construct TCs.
	if (puid == cUnitTypeTownCenter && cMyCiv != cCivDEAmericans && cMyCiv != cCivDEMexicans)
	{
		if (aiGetFallenExplorerID() < 0)
		{
			aiPlanAddUnitType(planID, cUnitTypeHero, 1, 2, 2);
			aiPlanSetUserVariableInt(planID, cBuildPlanBuilderTypeID, 0, cUnitTypeHero);
			return(true);
		}
	}

	// This logic is not necessary when we create a plan via createBuildPlan and pass to the builderType
	// variable cUnitTypedeArchitect. This logic applies when no builder type is specified (defaulting to
	// cUnitTypeLogicalTypeSettlerBuildLimit).
	int architectID = -1;
	if (cMyCiv == cCivDEItalians &&
		(kbUnitCostPerResource(puid, cResourceWood) + kbUnitCostPerResource(puid, cResourceGold)) >= 400.0)
	{
		int architectQuery = createSimpleUnitQuery(cUnitTypedeArchitect, cMyID, cUnitStateAlive);
		int numArchitects = kbUnitQueryExecute(architectQuery);
		for (i = 0; i < numArchitects; i++)
		{
			architectID = kbUnitQueryGetResult(architectQuery, i);
			if (kbUnitGetPlanID(architectID) >= 0)
			{
				architectID = -1;
				continue;
			}
			break;
		}
		// If we have no architects, fallback to villagers.
		builderType = cUnitTypeLogicalTypeSettlerBuildLimit;
	}

	// Check to see if we have a Settler Wagon we can use, since they
	// construct buildings more quickly.
	builderType = cUnitTypeLogicalTypeSettlerBuildLimit;
	if (kbUnitCount(cMyID, cUnitTypeSettlerWagon, cUnitStateAlive) > 0)
		builderType = cUnitTypeSettlerWagon;

	// If we found an architect to build this building, use him.
	if (architectID >= 0)
	{
		aiPlanAddUnitType(planID, cUnitTypedeArchitect, 1, 1, 1);
		aiPlanAddUnit(planID, architectID);
	}
	// Fields should have no more than one builder assigned to the plan.
	// It is possible that the AI sends villagers there to "gather" from it,
	// and since the field is not yet complete more villagers end up building it.
	else if (puid == cUnitTypedeField)
		aiPlanAddUnitType(planID, builderType, 1, 1, 1);
	// If there was a specified number of villagers when we used createBuildPlan,
	// assign them here. 
	else if (numBuilders > 1)
		aiPlanAddUnitType(planID, builderType, numBuilders, numBuilders, numBuilders);
	// Otherwise if we reached this point, only use more than one villager if there
	// is a significantly large build time.
	else
	{
		if (builderType == cUnitTypeLogicalTypeSettlerBuildLimit)
			numBuilders = round(kbProtoUnitGetBuildPoints(puid) / 30.0);
		aiPlanAddUnitType(planID, builderType, 1, numBuilders, numBuilders);
	}

	aiPlanSetUserVariableInt(planID, cBuildPlanBuilderTypeID, 0, builderType);
	return(true);
}

// ================================================================================
//	createBuildPlan
// ================================================================================
int createBuildPlan(int puid = -1, int numPlans = 1, int pri = 100, vector position = cInvalidVector,
	int numBuilders = 1, int builderType = cUnitTypeLogicalTypeSettlerBuildLimit, bool setActive = true)
{
	for (i = 0; < numPlans)
	{
		int planID = aiPlanCreate("Build Plan " + numPlans + " " + kbGetUnitTypeName(puid), cPlanBuild);
		if (planID < 0)
			return(-1);
		aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, puid);
		aiPlanSetVariableFloat(planID, cBuildPlanBuildingBufferSpace, 0, 6.0);
		aiPlanSetDesiredPriority(planID, pri);
		aiPlanAddUserVariableInt(planID, cBuildPlanBuilderTypeID, "Build Plan Builder Type", 1);
		addBuildersToPlan(planID, puid, numBuilders, builderType);
		// To my knowledge, these three aren't really relevant.
		aiPlanSetEscrowID(planID, cRootEscrowID); // <---
		aiPlanSetEconomy(planID, true); // <---
		aiPlanSetMilitary(planID, false); // <---

		debugBuildings("Making build plan for " + kbGetUnitTypeName(puid));
		selectBuildPlanPosition(planID, puid, position);
		aiPlanSetActive(planID, setActive);
	}
	
	return(planID); // Only really useful if numPlans == 1, otherwise returns last value.
}

// ================================================================================
//	createArchitectBuildPlan
// ================================================================================
int createArchitectBuildPlan(int puid = -1, int pri = 50, vector position = cInvalidVector)
{
	int planID = createBuildPlan(puid, 1, pri, position, 1, cUnitTypedeArchitect, false);
	return (planID);
}

// ================================================================================
//	buildTradingPost
// ================================================================================
int buildTradingPost(int socketID = -1, int desResPriority = 50, int builderType = cUnitTypeHero, int numBuilders = 1)
{
	if (socketID < 0)
		return(-1);

	int planID = aiPlanCreate("Trading Post Build Plan", cPlanBuild);
	aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeTradingPost);
	aiPlanSetVariableInt(planID, cBuildPlanSocketID, 0, socketID);
	aiPlanAddUnitType(planID, builderType, numBuilders, numBuilders, numBuilders);
	aiPlanSetDesiredPriority(planID, 99);
	aiPlanSetDesiredResourcePriority(planID, desResPriority);
	aiPlanSetEconomy(planID, true);
	aiPlanSetMilitary(planID, false);
	aiPlanSetEscrowID(planID, cRootEscrowID);
	aiPlanSetActive(planID);

	return(planID);
}

// ================================================================================
//	createRepairPlan
// ================================================================================
int createRepairPlan(int pri = 50)
{
	if (cvOkToBuild == false)
		return(-1);

	// Check if we're under attack.
	if (gDefenseReflexBaseID == kbBaseGetMainID(cMyID))
		return(-1);

	int buildingQueryID = createSimpleUnitQuery(cUnitTypeBuilding, cMyID, cUnitStateAlive);
	int buildingID = -1;
	int buildingToRepair = -1;
	int buildingTypeID = -1;
	int planID = -1;
	int i = 0;
	
	int numberFound = kbUnitQueryExecute(buildingQueryID);
	for (i = 0; < numberFound)
	{
		// search for important buildings
		buildingID = kbUnitQueryGetResult(buildingQueryID, i);
		buildingTypeID = kbUnitGetProtoUnitID(buildingID);
		if (buildingTypeID == cUnitTypeFortFrontier ||
			buildingTypeID == cUnitTypeFactory ||
			buildingTypeID == cUnitTypeypDojo ||
			buildingTypeID == cUnitTypeTownCenter ||
			buildingTypeID == cUnitTypedeSPCCommandPost ||
			buildingTypeID == cUnitTypeTradingPost )
		{
			if (kbUnitGetHealth(buildingID) < 0.75)
			{
				buildingToRepair = buildingID;
				break;
			}
		}
	}

	if (buildingToRepair == -1)
	{
		for (i = 0; < numberFound)
		{
			buildingID = kbUnitQueryGetResult(buildingQueryID, i);
			if (kbUnitGetHealth(buildingID) < 0.5)
			{
				buildingToRepair = buildingID;
				break;
			}
		}
	}

	if (buildingToRepair == -1)
	{
		//debugUtilities("createRepairPlan aborting: no building to repair.");
		return(-1);
	}

	debugUtilities("Creating repair plan for building ID " + buildingToRepair);
	planID = aiPlanCreate(kbGetUnitTypeName(kbUnitGetProtoUnitID(buildingToRepair))+" Repair "+buildingToRepair, cPlanRepair);

	if (planID < 0)
	{
		debugUtilities("Failed to create simple repair plan for " + buildingID);
		return(-1);
	}
	else
	{
		aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingToRepair);
		aiPlanSetVariableBool(planID, cRepairPlanPersistent, 0, false);
		aiPlanSetDesiredResourcePriority(planID, pri);
		//aiPlanSetEscrowID(planID, escrowID);
		aiPlanSetActive(planID);
	}
	return(planID);
}

// ================================================================================
//	createTransportPlan
// ================================================================================
int createTransportPlan(vector gatherPoint = cInvalidVector, vector targetPoint = cInvalidVector, int pri = 50, bool returnWhenDone = true)
{
	if (aiGetWaterMap() == false)
		return(-1);
	  
	int shipQueryID = createSimpleUnitQuery(cUnitTypeTransport, cMyID, cUnitStateAlive);
	int numberFound = kbUnitQueryExecute(shipQueryID);
	int shipID = -1;
	float shipHitpoints = 0.0;
	int unitPlanID = -1;
	int transportID = -1;
	float transportHitpoints = 0.0;
	for (i = 0; < numberFound)
	{
	  shipID = kbUnitQueryGetResult(shipQueryID, i);
	  unitPlanID = kbUnitGetPlanID(shipID);
	  if (unitPlanID >= 0 && (aiPlanGetDesiredPriority(unitPlanID) > pri || aiPlanGetType(unitPlanID) == cPlanTransport))
		  continue;
	  shipHitpoints = kbUnitGetCurrentHitpoints(shipID);
	  if (shipHitpoints > transportHitpoints)
	  {
		 transportID = shipID;
		 transportHitpoints = shipHitpoints;
	  }
	}
	
	if (transportID < 0)
		return(-1);
	
	int planID = aiPlanCreate(kbGetUnitTypeName(kbUnitGetProtoUnitID(transportID))+" Transport Plan, ", cPlanTransport);
	
	if (planID < 0)
		return(-1);
	  
	aiPlanSetVariableInt(planID, cTransportPlanTransportID, 0, transportID);
	aiPlanSetVariableInt(planID, cTransportPlanTransportTypeID, 0, kbUnitGetProtoUnitID(transportID));
	// must add the transport unit otherwise other plans might try to use this unit
	aiPlanAddUnitType(planID, kbUnitGetProtoUnitID(transportID), 1, 1, 1);
	if (aiPlanAddUnit(planID, transportID) == false)
	{
		aiPlanDestroy(planID);
		return(-1);
	}
	
	aiPlanSetVariableVector(planID, cTransportPlanGatherPoint, 0, gatherPoint);
	aiPlanSetVariableVector(planID, cTransportPlanTargetPoint, 0, targetPoint);
	aiPlanSetVariableBool(planID, cTransportPlanReturnWhenDone, 0, returnWhenDone);
	aiPlanSetVariableBool(planID, cTransportPlanPersistent, 0, false);
	aiPlanSetVariableBool(planID, cTransportPlanMaximizeXportMovement, 0, true);
	aiPlanSetVariableInt(planID, cTransportPlanPathType, 0, cTransportPathTypePoints);
	
	aiPlanSetRequiresAllNeedUnits(planID, true);
	aiPlanSetDesiredPriority(planID, pri);
	aiPlanSetActive(planID);
	
	return(planID);
}

// ================================================================================
//	createMainBase
// ================================================================================
int createMainBase(vector mainVec = cInvalidVector)
{
	debugUtilities("Creating main base at " + mainVec);
	if (mainVec == cInvalidVector)
		return(-1);

	int oldMainID = kbBaseGetMainID(cMyID);
	int i = 0;

	int count = -1;
	static int unitQueryID = -1;
	int buildingID = -1;
	string buildingName = "";
	if (unitQueryID < 0)
	{
		unitQueryID = kbUnitQueryCreate("NewMainBaseBuildingQuery");
		kbUnitQuerySetIgnoreKnockedOutUnits(unitQueryID, true);
	}

	//Define a query to get all matching units
	/* if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerRelation(unitQueryID, -1);
		kbUnitQuerySetPlayerID(unitQueryID, cMyID);

		kbUnitQuerySetUnitType(unitQueryID, cUnitTypeBuilding);
		kbUnitQuerySetState(unitQueryID, cUnitStateABQ);
		kbUnitQuerySetPosition(unitQueryID, mainVec);      // Checking new base vector
		kbUnitQuerySetMaximumDistance(unitQueryID, 50.0);
	}

	kbUnitQueryResetResults(unitQueryID);
	count = kbUnitQueryExecute(unitQueryID); */


	// while (oldMainID >= 0)
	// {
		debugUtilities("Old main base was " + oldMainID + " at " + kbBaseGetLocation(cMyID, oldMainID));
		/* kbUnitQuerySetPosition(unitQueryID, kbBaseGetLocation(cMyID, oldMainID));      // Checking old base location
		kbUnitQueryResetResults(unitQueryID);
		count = kbUnitQueryExecute(unitQueryID);
		int unitID = -1; */


		// Remove old base's resource breakdowns
		// aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, oldMainID);
		// aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, oldMainID);
		// aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHerdable, oldMainID);
		// aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, oldMainID);
		// aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, oldMainID);
		// aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, oldMainID);
		// aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, oldMainID);
		// aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, oldMainID);

		// kbBaseDestroy(cMyID, oldMainID);
		oldMainID = kbBaseGetMainID(cMyID);
	// }

	// Also destroy bases nearby that can overlap with our radius.
	// count = kbBaseGetNumber(cMyID);
	// for (i = 0; < count)
	// {
	// 	int baseID = kbBaseGetIDByIndex(cMyID, i);
	// 	if (getDistance(kbBaseGetLocation(cMyID, baseID), mainVec) < kbBaseGetDistance(cMyID, baseID))
	// 		kbBaseDestroy(cMyID, baseID);
	// }

	int newBaseID = kbBaseCreate(cMyID, "Base" + kbBaseGetNextID(), mainVec, 50.0);
	debugUtilities("New main base ID is " + newBaseID);
	if (newBaseID > -1)
	{
		//Figure out the front vector.
		vector baseFront = xsVectorNormalize(kbGetMapCenter() - mainVec);
		kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
		debugUtilities("Setting front vector to " + baseFront);
		//Military gather point.
		float milDist = 40.0;
		while (kbAreaGroupGetIDByPosition(mainVec + (baseFront*milDist)) != kbAreaGroupGetIDByPosition(mainVec))
		{
			milDist = milDist - 5.0;
			if (milDist < 6.0)
				break;
		}
		vector militaryGatherPoint = gHomeBase + gDirection_UP * 40;

		kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
		//Set the other flags.
		// kbBaseSetMilitary(cMyID, newBaseID, true);
		// kbBaseSetEconomy(cMyID, newBaseID, true);
		//Set the resource distance limit.

		// 200m x 200m map, assume I'm 25 meters in, I'm 150m from enemy base.  This sets the range at 80m.
		//(cMyID, newBaseID, (kbGetMapXSize() + kbGetMapZSize())/5);   // 40% of average of map x and z dimensions.
		float dist = getDistance(kbGetMapCenter(), kbBaseGetLocation(cMyID, newBaseID));
		// Limit our distance, don't go pass the center of the map
		if (dist < 150.0)
			kbBaseSetMaximumResourceDistance(cMyID, newBaseID, dist);
		else
			kbBaseSetMaximumResourceDistance(cMyID, newBaseID, 80.0); // Down from 150.0.

		kbBaseSetSettlement(cMyID, newBaseID, true);
		//Set the main-ness of the base.
		kbBaseSetMain(cMyID, newBaseID, true);

		// Add the TC, if any.
		int tcID = getUnit(cUnitTypeAgeUpBuilding, cMyID, cUnitStateABQ);
		if (tcID >= 0)
		{
			kbBaseAddUnit(cMyID, newBaseID, tcID);
		}
	}

	// Move the defend plan and reserve plan
	xsEnableRule("endDefenseReflexDelay"); // Delay so that new base ID will exist

	return(newBaseID);
}

//==============================================================================
// handleTributeRequest
// Checks whether we have enough resources to be able to afford a tribute.
// And if we have enough we also make the tribute here.
//==============================================================================
bool handleTributeRequest(int resourceToTribute = -1, int playerToTributeTo = -1)
{
	int amountAvailable = xsArrayGetFloat(gResourceNeeds, resourceToTribute) * -0.85; // Leave room for tribute penalty.
	if (aiResourceIsLocked(resourceToTribute) == true)
	{
		amountAvailable = 0.0;
	}
	if (amountAvailable > 100.0) // We will tribute something.
	{ 
		debugUtilities("We will tribute some: " + kbGetResourceName(resourceToTribute) + " to player: " + playerToTributeTo);
		gLastTribSentTime = xsGetTime();
		if (amountAvailable > 200.0)
		{
			aiTribute(playerToTributeTo, resourceToTribute, amountAvailable / 2);
		}
		else
		{
			aiTribute(playerToTributeTo, resourceToTribute, 100.0);
		}
		return (true);
	}
	debugUtilities("We don't have enough: "+ kbGetResourceName(resourceToTribute) + " to tribute to player: " + playerToTributeTo);
	return (false);
}

//==============================================================================
// isDefendingOrAttacking
// We only allow 1 "real" combat plan to be active at a time
// So that would be either a main attack plan or a defend plan not being one
// of the 4 persistent combat defend plans. So exclude all those in this search.
//==============================================================================
bool isDefendingOrAttacking()
{
	int numPlans = aiPlanGetActiveCount();
	int existingPlanID = -1;
	
	for (int i = 0; i < numPlans; i++)
	{
		existingPlanID = aiPlanGetIDByActiveIndex(i);
		if (aiPlanGetType(existingPlanID) != cPlanCombat)
		{
			continue;
		}
		if (aiPlanGetVariableInt(existingPlanID, cCombatPlanCombatType, 0) == cCombatPlanCombatTypeDefend)
		{
			if ((existingPlanID != gExplorerControlPlan) &&
				(existingPlanID != gLandDefendPlan0) && 
				(existingPlanID != gLandReservePlan) &&
				(existingPlanID != gBaseDefendPlan) &&
				(existingPlanID != gNavyRepairPlan) && 
				(existingPlanID != gNavyDefendPlan)/*  && 
				(existingPlanID != gHealerPlan) */)
			{
				debugUtilities("isDefendingOrAttacking: don't create another combat plan because we already have one named: "
				+ aiPlanGetName(existingPlanID));
				return (true);
			}
		}
		else // Attack plan.
		{
			if ((aiPlanGetParentID(existingPlanID) < 0) && // No parent so not a reinforcing child plan.
				(existingPlanID != gNavyAttackPlan))
			{
				debugUtilities("isDefendingOrAttacking: don't create another combat plan because we already have one named: "
				+ aiPlanGetName(existingPlanID));
				return (true);
			}
		}
	}
	
	return (false);
}

bool getHomeBaseThreatened(void)
{
	if (gHomeBase == cInvalidVector)
		return(false);

	float checkDistance = 40.0 + 10.0 * kbGetAge();
	int allyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationAlly,
					cUnitStateAlive, gHomeBase, checkDistance);
	int enemyCount = getUnitCountByLocation(cUnitTypeLogicalTypeLandMilitary, cPlayerRelationEnemyNotGaia,
					cUnitStateAlive, gHomeBase, checkDistance);

	if ((allyCount + 5.0 * kbGetAge()) < enemyCount)
		return(true);

	return(false);
}
