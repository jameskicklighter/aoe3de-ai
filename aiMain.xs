// Includes.
include "core/aiCore.xs";

//==============================================================================
/* main
	This function is called during the loading screen before the game has started.
	Some stuff isn't initialised yet at this point so we must account for this.
*/
//==============================================================================
void main(void)
{
	aiEcho("Main is starting.");

	if (aiGetGameType() == cGameTypeCampaign)
	{
		for (player = 1; < cNumberPlayers)
		{
			if (kbIsPlayerHuman(player) == true) 
			{
				aiChat(player, "Better AI Mod is not intended for use here. Please disable it if you want to play the Campaign."); 
				break;
			}
		}
		aiResign();
	}

	// Set our random seed, "-1" is a random init. 
	// Very important that this is done early so we can use our rand functions.
	aiRandSetSeed(-1);
	
	// Analyze the map, create area matrix. We call this here and not in analyseMap because 
	// it's very important this is done early and the arrays might need it.
	kbAreaCalculate();
	
	// Generate which age ups are available to us in this age.
	// Call this here because the arrays might need it.
	aiPopulatePoliticianList();

	aiSetDistributeGatherersByResourcePercentage(true);
	// Instead of creating a fixed amount of gather plans, create a new gather plan for each resource that
	// is closest to the resource type gatherers being asked to gather.
	aiSetDistributeGatherersByClosestResource(true);
	aiSetEscrowsDisabled(true);	// Disable escrows so we can have full control of our resources
	aiSetPlanResourcePriorityEnabled(true);	// Enable resource priority for plans
	aiSetExploreDangerThreshold(110.0);
	aiSetRandomMap(true);
	aiSetAttackResponseDistance(65.0);
	aiSetAutoGatherMilitaryUnits(true);
	aiSetEconomyPercentage(1.0);
	aiSetMilitaryPercentage(1.0);

	// These numbers belonged to the now deprecated eco system.
	kbSetTargetSelectorFactor(cTSFactorDistance, -200.0); // negative is good
	kbSetTargetSelectorFactor(cTSFactorPoint, 5.0);       // positive is good
	kbSetTargetSelectorFactor(cTSFactorTimeToDone, 0.0);  // positive is good
	kbSetTargetSelectorFactor(cTSFactorBase, 100.0);      // positive is good
	kbSetTargetSelectorFactor(cTSFactorDanger, -10.0);    // negative is good

	gArrayPlan = aiPlanCreate("Array Storage", cPlanData);
	gArrayPlanSizes = aiPlanCreate("Plan Size Storage", cPlanData);
	gArrayPlanNumElements = aiPlanCreate("Plan Num Elements Storage", cPlanData);
	gFoodResources = arrayCreateInt(1, "Food Resources");
	gDecayingAnimals = arrayCreateInt(1, "Decaying Hunts");
	gWoodResources = arrayCreateInt(1, "Wood Resources");
	gGoldResources = arrayCreateInt(1, "Gold Resources");
	gFoodNumWorkers = arrayCreateInt(1, "Number Workers on Food Resource");
	gMaxFoodWorkers = arrayCreateInt(1, "Max Workers Allowed on Food Resource");
	gDecayingNumWorkers = arrayCreateInt(1, "Number Workers on Decaying Food Resource");
	gWoodNumWorkers = arrayCreateInt(1, "Number Workers on Wood Resource");
	gGoldNumWorkers = arrayCreateInt(1, "Number Workers on Gold Resource");
	gMaxGoldWorkers = arrayCreateInt(1, "Max Workers Allowed on Gold Resource");
	gMillTypePlans = arrayCreateInt(1, "Mill Type Build Plans");
	gPlantationTypePlans = arrayCreateInt(1, "Plantation Type Build Plans");
	gQueuedBuildingPriority = arrayCreateInt(1, "Inactive Build Plans Priority");

	initMapData();		// Gather vector data about the map, my allies, and my enemies.
	initPersonality();	// Pick our strategy and gather other info.
	initHandlers();		// Set up game handlers.
	initCiv();			// Initialize civ-related data.
	initArrays();		// Create the global arrays.
	startUpChats();		// Analyse our history with the players in the game and sent them an appropriate message.

	if (gGoodFishingMap == true)
	{
		gFoodFishResources = arrayCreateInt(1, "Food Fish Resources");
		gGoldFishResources = arrayCreateInt(1, "Gold Fish Resources");
	}

	cvMaxAge = aiGetMaxAge();

	// Call the rule once as a function, to get all the pop limits set up.
	popManager();

	float startingHandicap = kbGetPlayerHandicap(cMyID);
	switch (cDifficultyCurrent)
	{
		case cDifficultySandbox: // "Easy"
		{
			kbSetPlayerHandicap(cMyID, startingHandicap * 0.55); // Minus 45 percent.
			gDelayAttacks = true; // Prevent attacks...actually stays that way, never turns true.
			cvOkToBuildForts = false;
			break;
		}
		case cDifficultyEasy: // "Standard"
		{
			kbSetPlayerHandicap(cMyID, startingHandicap * 0.7); // Minus 30 percent.
			gDelayAttacks = true;
			cvOkToBuildForts = false;
			xsEnableRule("delayAttackMonitor"); // Wait until I am attacked, then let slip the hounds of war.
			break;
		}
		case cDifficultyModerate: // "Moderate"
		{
			kbSetPlayerHandicap(cMyID, startingHandicap * 0.85); // Minus 15 percent.
			aiSetMicroFlags(cMicroLevelNormal);
			break;
		}
		case cDifficultyHard: // "Hard"
		{
			kbSetPlayerHandicap(cMyID, startingHandicap * 1.0); // Baseline.
			aiSetMicroFlags(cMicroLevelHigh);
			break;
		}
		case cDifficultyExpert: // "Hardest"
		{
			kbSetPlayerHandicap(cMyID, startingHandicap * 1.15); // +15% boost.
			aiSetMicroFlags(cMicroLevelHigh);
			break;
		}
		case cDifficultyExtreme: // "Extreme"
		{
			kbSetPlayerHandicap(cMyID, startingHandicap * 1.3); // +30% boost.
			aiSetMicroFlags(cMicroLevelHigh);
			break;
		}
	}

	xsEnableRule("checkForTownCenter");

	xsEnableRule("modIntroChat");
}
