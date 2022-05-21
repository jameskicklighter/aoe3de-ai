// ================================================================================
//	aiHCCards.xs
// ================================================================================
void addCardInfoToArrays(int cardTechID = -1, bool isMilitaryUnit = false,
	bool isMilitaryUpgrade = false, bool isExtended = false, int cardIndex = -1,
	int sentCount = 0)
{
	arrayPushInt(gCardList, cardTechID);
	arrayPushBool(gCardListIsMilitaryUnit, isMilitaryUpgrade);
	arrayPushBool(gCardListIsMilitaryUpgrade, isMilitaryUpgrade);
	arrayPushBool(gCardListIsExtended, isExtended);
	arrayPushInt(gCardListIndexInDeck, cardIndex);
	arrayPushInt(gCardListSentCount, sentCount);
}

void selectCards(void)
{
	// 31 is the maximum deck size.

	// Stores the integer value of a card's tech ID.
	gCardList = arrayCreateInt(31, "Card Tech ID List");
	// Stores a boolean indicating whether a card at index 0...31 in gCardList
	// is a military unit shipment (primarily).
	gCardListIsMilitaryUnit = arrayCreateBool(31, "Card Is Military Unit");
	// Stores a boolean indicating whether a card at index 0...31 in gCardList
	// is a good defensive option to send if under attack, that isn't a military unit.
	gCardListIsMilitaryUpgrade = arrayCreateBool(31, "Card Is Military Upgrade");
	// Stores a boolean indicating whether a card at index 0...31 in gCardList
	// is in the default deck or the extended deck (extended only applicable to
	// US and Mexican civilizations).
	gCardListIsExtended = arrayCreateBool(31, "Card Is In Extended Deck");
	// Stores an integer indicating the position of the card at index 0...31 in gCardList
	// in the given deck (gDefaultDeck or the extended deck). Will be initialized after
	// deck creation for non-extended deck cards. Extended deck cards can be initialized
	// as they will have a fixed position in the extended deck that is easy to determine.
	gCardListIndexInDeck = arrayCreateInt(31, "Card Index In Deck");
	// Stores an integer indicating the number of times the card at index 0...31
	// in gCardList has been sent. Initialized to 0 via the addCardInfoToArrays function.
	gCardListSentCount = arrayCreateInt(31, "Card Sent Count");

	gSentCardList = arrayCreateInt(30, "Sent Card Tech IDs");
	gPriorityCards = arrayCreateInt(1, "Priority Cards");
	gMilitaryDefensiveCards = arrayCreateInt(1, "Military Defensive Cards"); // To be used when the main base is under threat.
	// gResourceDependentCards = arrayCreateInt(1, "Resource Dependent Cards"); // To be used next update.

	switch (cMyCiv)
	{
		// Card order is indicative of general priority, with more specific checks to be
		// implemented in shipGrantedHandler() itself (such as not sending 700f in Age 4).
		case cCivSpanish:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCXPIndustrialRevolution);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechDEHCMarvelousYear);
			addCardInfoToArrays(cTechHCXPSpanishGold);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechDEHCHouseOfTrastamara);
			addCardInfoToArrays(cTechHCShipLancers3, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCShipSettlers3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipSettlers4);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipRodeleros5, true);
			addCardInfoToArrays(cTechHCXPEconomicTheory);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechDEHCLiberationMarch, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCRoyalDecreeSpanish);
			addCardInfoToArrays(cTechDEHCPeninsularGuerrillas, false, true);
			addCardInfoToArrays(cTechHCCaballeros, false, true);
			addCardInfoToArrays(cTechHCHandCavalryCombatSpanish, false, true);
			addCardInfoToArrays(cTechHCShipFalconets2, true);
			break;
		}
		case cCivBritish:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCRobberBarons);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechHCShipMusketeers4, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCShipSettlers3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipSettlers4);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipMusketeers1, true);
			addCardInfoToArrays(cTechHCImprovedLongbows, false, true);
			addCardInfoToArrays(cTechDEHCRangers, false, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCRoyalDecreeBritish);
			addCardInfoToArrays(cTechHCMusketeerGrenadierCombatBritish, false, true);
			addCardInfoToArrays(cTechHCCavalryCombatBritish, false, true);
			addCardInfoToArrays(cTechHCMusketeerGrenadierHitpointsBritishTeam, false, true);
			addCardInfoToArrays(cTechHCMusketeerGrenadierDamageBritish, false, true);
			addCardInfoToArrays(cTechHCXPShipRocketsRepeat, true);
			break;
		}
		case cCivFrench:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCRobberBarons);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechHCShipCuirassiers3, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCShipCoureurs3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipCoureurs2);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipCrossbowmen1, true);
			addCardInfoToArrays(cTechHCXPEconomicTheory);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCXPThoroughbreds, false, true);
			addCardInfoToArrays(cTechHCCavalryCombatFrench, false, true);
			addCardInfoToArrays(cTechHCRangedInfantryDamageFrenchTeam, false, true);
			addCardInfoToArrays(cTechHCRangedInfantryHitpointsFrench, false, true);
			addCardInfoToArrays(cTechHCWildernessWarfare, false, true);
			addCardInfoToArrays(cTechHCXPGribeauvalSystem, false, true);
			addCardInfoToArrays(cTechHCShipFalconets2, true);
			break;
		}
		case cCivPortuguese:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCRobberBarons);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCShipOrganGuns1, true);
			addCardInfoToArrays(cTechHCShipCacadores3, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCXPEconomicTheory);
			addCardInfoToArrays(cTechHCColonialMilitia, false, true);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipMusketeers1, true);
			addCardInfoToArrays(cTechHCTeamWoodCrates);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCRoyalDecreePortuguese);
			addCardInfoToArrays(cTechHCRangedInfantryCombatPortuguese, false, true);
			addCardInfoToArrays(cTechHCXPGenitours, false, true);
			addCardInfoToArrays(cTechHCDragoonCombatPortuguese, false, true);
			addCardInfoToArrays(cTechHCRangedInfantryDamagePortuguese, false, true);
			addCardInfoToArrays(cTechHCRangedInfantryHitpointsPortugueseTeam, false, true);
			addCardInfoToArrays(cTechHCXPShipMusketeersRepeat, true);
			break;
		}
		case cCivDutch:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCRobberBarons);
			addCardInfoToArrays(cTechHCBetterBanks);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCRoyalDecreeDutch);
			addCardInfoToArrays(cTechHCShipSkirmishers3, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCShipSettlers3);
			addCardInfoToArrays(cTechHCXPBankWagon);
			addCardInfoToArrays(cTechHCDutchEastIndiaCompany);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipFoodCrates3);
			addCardInfoToArrays(cTechHCShipPikemen1, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCBanks1);
			addCardInfoToArrays(cTechHCBanks2);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCInfantryCombatDutch, false, true);
			addCardInfoToArrays(cTechHCCavalryCombatDutch, false, true);
			addCardInfoToArrays(cTechHCInfantryHitpointsDutchTeam, false, true);
			addCardInfoToArrays(cTechHCXPMilitaryReforms, false, true);
			addCardInfoToArrays(cTechHCShipFalconets2, true);

			break;
		}
		case cCivRussians:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCXPIndustrialRevolution);
			addCardInfoToArrays(cTechHCRoyalDecreeRussian);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechHCShipMusketeersRussian2, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCXPDistributivism);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipStrelets1, true);
			addCardInfoToArrays(cTechHCShipCossacks4, true);
			addCardInfoToArrays(cTechHCXPEconomicTheory);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCDuelingSchoolTeam, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechHCRansack, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCUniqueCombatRussian, false, true);
			addCardInfoToArrays(cTechHCCavalryCombatRussian, false, true);
			addCardInfoToArrays(cTechHCStreletsCombatRussian, false, true);
			addCardInfoToArrays(cTechHCShipFalconets2, true);

			break;
		}
		case cCivGermans:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactoryGerman);
			addCardInfoToArrays(cTechHCRobberBaronsGerman);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCUnlockFortGerman);
			addCardInfoToArrays(cTechHCShipSkirmishers3German, true);
			addCardInfoToArrays(cTechHCShipUhlans4, true);
			addCardInfoToArrays(cTechHCGuildArtisans);
			addCardInfoToArrays(cTechHCRefrigerationGerman);
			addCardInfoToArrays(cTechHCRoyalMintGerman);
			addCardInfoToArrays(cTechHCShipSettlerWagons3);
			addCardInfoToArrays(cTechHCShipWoodCrates3German);
			addCardInfoToArrays(cTechHCShipSettlerWagons4);
			addCardInfoToArrays(cTechHCShipCoinCrates3German);
			addCardInfoToArrays(cTechHCShipUhlans1, true);
			addCardInfoToArrays(cTechHCGermantownFarmers);
			addCardInfoToArrays(cTechHCXPEconomicTheory);
			addCardInfoToArrays(cTechHCImprovedBuildingsGerman, false, true);
			addCardInfoToArrays(cTechHCFencingSchoolGerman, false, true);
			addCardInfoToArrays(cTechHCRidingSchoolGerman, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenalGerman);
			addCardInfoToArrays(cTechHCRoyalDecreeGerman);
			addCardInfoToArrays(cTechHCCavalryCombatGerman, false, true);
			addCardInfoToArrays(cTechHCUhlanCombatGerman, false, true);
			addCardInfoToArrays(cTechHCRangedInfantryHitpointsGerman, false, true);
			addCardInfoToArrays(cTechHCXPShipCannonsRepeat, true);
			break;
		}
		case cCivOttomans:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCRobberBarons);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCShipSpahis3, true);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechHCShipAbusGuns1, true);
			addCardInfoToArrays(cTechHCShipJanissaries4, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCShipSettlers3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipSettlers4);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipJanissaries1, true);
			addCardInfoToArrays(cTechHCXPEconomicTheory);
			addCardInfoToArrays(cTechHCRoyalDecreeOttoman);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCJanissaryCost, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechHCEngineeringSchool, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCJanissaryCombatOttoman, false, true);
			addCardInfoToArrays(cTechHCCavalryCombatOttoman, false, true);
			addCardInfoToArrays(cTechHCShipGreatBombards1, true);
			break;
		}
		case cCivDESwedish:
		{	// Cards
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCXPIndustrialRevolution);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechDEHCKalmarCastle);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechDEHCShipCaroleans2, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechDEHCBlackberries);
			addCardInfoToArrays(cTechHCShipSettlers3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechDEHCDominions);
			addCardInfoToArrays(cTechDEHCEngelsbergIronworks);
			addCardInfoToArrays(cTechDEHCBlueberries);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipPikemen1, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechDEHCCaseShot, false, true);
			addCardInfoToArrays(cTechDEHCSveaLifeguard, false, true);
			addCardInfoToArrays(cTechDEHCPlatoonFire, false, true);
			addCardInfoToArrays(cTechDEHCSnaplocks, false, true);
			addCardInfoToArrays(cTechDEHCHeavyInfHitpointsTeam);
			addCardInfoToArrays(cTechDEHCShipCaroleansRepeat, true);
			break;
		}
		// For Americans and Mexicans, include some Federal Cards for priority reasons,
		// but they won't be added to the deck when gCardList is called because they are not
		// standard cards, but gained through age-ups.
		case cCivDEAmericans:
		{	// Cards
			addCardInfoToArrays(cTechHCRobberBarons, false, false, true); // Federal Card, granted in Age 4 automatically.
			addCardInfoToArrays(cTechHCXPIndustrialRevolution, false, false, true); // Federal Card, granted in Age 4 automatically.
			addCardInfoToArrays(cTechDEHCFedNewHampshireManufacturing, false, false, true); // Federal Card
			addCardInfoToArrays(cTechDEHCHamiltonianEconomics);
			addCardInfoToArrays(cTechDEHCFedVermontCoppers, false, false, true); // Federal Card
			addCardInfoToArrays(cTechDEHCFedAlamo, true, true, true); // Federal Card
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechDEHCShipStateMilitia2, true);
			addCardInfoToArrays(cTechDEHCFedPlymouthSettlers, false, false, true); // Federal Card
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCTextileMills);
			// Don't attempt to chop out French Immigrants shipment if we have negative handicap.
			if (cDifficultyCurrent >= cDifficultyHard)
			{
				addCardInfoToArrays(cTechDEHCImmigrantsFrench);
				gForceWoodGathering = true;
				xsEnableRule("forcedWoodCoroutine");
			}
			else
				addCardInfoToArrays(cTechDEHCImmigrantsIrish);
			addCardInfoToArrays(cTechDEHCImmigrantsDutch);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCShipStateMilitia1, true);
			addCardInfoToArrays(cTechDEHCSpringfieldArmory);
			addCardInfoToArrays(cTechDEHCUSMarines, false, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechDEHCTrainTimeUS, false, true);
			addCardInfoToArrays(cTechDEHCLongRifles, false, true);
			addCardInfoToArrays(cTechDEHCRegularCombat, false, true);
			addCardInfoToArrays(cTechDEHCContinentalRangers, false, true);
			addCardInfoToArrays(cTechDEHCBuffaloSoldiers, false, true);
			addCardInfoToArrays(cTechDEHCCoffeeMillGun, false, true);
			addCardInfoToArrays(cTechDEHCShipHorseArtilleryRepeat1, true);
			break;
		}
		case cCivDEMexicans:
		{	// Cards
			addCardInfoToArrays(cTechDEHCPorfiriato);
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechDEHCFedMXElBajio); // Federal Card
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechDEHCMexicanMint);
			addCardInfoToArrays(cTechDEHCFedMXTonalaCeramics); // Federal Card
			addCardInfoToArrays(cTechDEHCFedMXOurLadyOfLight); // Federal Card
			addCardInfoToArrays(cTechDEHCAlhondigaDeGranaditas);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCShipSettlers4);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCIturbidePalace);
			addCardInfoToArrays(cTechDEHCPresidialLancers);
			addCardInfoToArrays(cTechHCImprovedBuildings);
			addCardInfoToArrays(cTechDEHCLiberationMarch);
			addCardInfoToArrays(cTechDEHCSevenLaws);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechHCCaballeros);
			addCardInfoToArrays(cTechDEHCObservers);
			addCardInfoToArrays(cTechDEHCCavalryCombatMexican);
			addCardInfoToArrays(cTechHCShipFalconets3);
			addCardInfoToArrays(cTechDEHCShipSoldado1);
			addCardInfoToArrays(cTechDEHCShipInsurgente1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCIturbidePalace);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipSoldado1);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipInsurgente1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivXPIroquois:
		{	// Cards
			addCardInfoToArrays(cTechHCXPShipVillagers3);
			addCardInfoToArrays(cTechHCShipWoodCrates2);
			addCardInfoToArrays(cTechHCXPShipVillagers4);
			addCardInfoToArrays(cTechHCShipCoinCrates2);
			addCardInfoToArrays(cTechHCXPTownDance);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCSustainableAgriculture);
			addCardInfoToArrays(cTechHCRumDistillery);
			addCardInfoToArrays(cTechHCXPNewWaysIroquois);
			addCardInfoToArrays(cTechHCImprovedBuildings);
			addCardInfoToArrays(cTechHCXPInfantryCombatIroquois);
			addCardInfoToArrays(cTechHCXPWarHutTrainingIroquois);
			addCardInfoToArrays(cTechHCXPInfantryLOSTeam);
			addCardInfoToArrays(cTechHCXPWarChiefIroquois1);
			addCardInfoToArrays(cTechHCXPWarChiefIroquois2);
			addCardInfoToArrays(cTechHCXPSiegeDiscipline);
			addCardInfoToArrays(cTechHCEngineeringSchool);
			addCardInfoToArrays(cTechHCXPSiegeCombat);
			addCardInfoToArrays(cTechHCXPConservativeTactics);
			addCardInfoToArrays(cTechHCXPShipMixedCratesRepeat);
			addCardInfoToArrays(cTechHCXPShipLightCannon2);
			addCardInfoToArrays(cTechHCXPShipMantletsRepeat);
			addCardInfoToArrays(cTechHCXPFrenchAllies1);
			addCardInfoToArrays(cTechHCXPShipMusketWarriors3);
			addCardInfoToArrays(cTechHCXPShipTomahawk1);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPTownDance);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipLightCannon2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipMantletsRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPFrenchAllies1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipMusketWarriors3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipTomahawk1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivXPSioux:
		{	// Cards
			addCardInfoToArrays(cTechHCXPCommandSkill);
			addCardInfoToArrays(cTechHCXPAdoption);
			addCardInfoToArrays(cTechHCXPShipVillagers2);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCXPShipVillagers4);
			addCardInfoToArrays(cTechHCXPGreatHunter);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCXPTownDance);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCFoodSilos);
			addCardInfoToArrays(cTechHCXPNewWaysSioux);
			addCardInfoToArrays(cTechHCImprovedBuildings);
			addCardInfoToArrays(cTechHCRidingSchool);
			addCardInfoToArrays(cTechHCXPFriendlyTerritory);
			addCardInfoToArrays(cTechHCXPNomadicExpansion);
			addCardInfoToArrays(cTechHCXPMustangs);
			addCardInfoToArrays(cTechHCXPWindRunner);
			addCardInfoToArrays(cTechHCXPCavalryCombatSioux);
			addCardInfoToArrays(cTechHCXPSiouxTwoKettleSupport);
			addCardInfoToArrays(cTechHCXPSiouxSanteeSupport);
			addCardInfoToArrays(cTechHCXPOnikare);
			addCardInfoToArrays(cTechHCXPBuffalo2);
			addCardInfoToArrays(cTechHCXPShipAxeRidersRepeat);
			addCardInfoToArrays(cTechHCXPShipWarRifles1);
			addCardInfoToArrays(cTechHCXPShipAxeRiders3);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPTownDance);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPSiouxTwoKettleSupport);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPSiouxSanteeSupport);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipAxeRidersRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipWarRifles1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipAxeRiders3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivXPAztec:
		{	// Cards
			addCardInfoToArrays(cTechHCXPChinampa2);
			addCardInfoToArrays(cTechHCXPTempleXolotl);
			addCardInfoToArrays(cTechHCXPAztecMining);
			addCardInfoToArrays(cTechHCXPShipVillagers3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCXPShipMedicineMen2Aztec);
			addCardInfoToArrays(cTechHCXPShipVillagers4);
			addCardInfoToArrays(cTechHCXPCoinCratesAztec3);
			addCardInfoToArrays(cTechHCXPTownDance);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCImprovedBuildings);
			addCardInfoToArrays(cTechHCFencingSchool);
			addCardInfoToArrays(cTechHCXPWarHutTraining);
			addCardInfoToArrays(cTechHCXPScorchedEarth);
			addCardInfoToArrays(cTechHCXPChinampa1);
			addCardInfoToArrays(cTechHCXPTempleCenteotl);
			addCardInfoToArrays(cTechHCXPTempleXipeTotec);
			addCardInfoToArrays(cTechHCXPTempleTlaloc);
			addCardInfoToArrays(cTechHCXPKnightCombat);
			addCardInfoToArrays(cTechHCXPCoyoteCombat);
			addCardInfoToArrays(cTechHCGrainMarket);
			addCardInfoToArrays(cTechHCFoodSilos);
			addCardInfoToArrays(cTechHCXPExtensiveFortificationsAztec);
			addCardInfoToArrays(cTechHCXPShipMacehualtinsRepeat);
			addCardInfoToArrays(cTechHCXPShipMacehualtins3);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPTownDance);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPTempleCenteotl);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPTempleXipeTotec);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPTempleTlaloc);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipMacehualtinsRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipMacehualtins3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivDEInca:
		{	// Cards
			addCardInfoToArrays(cTechDEHCTerraceFarming);
			addCardInfoToArrays(cTechDEHCChichaBrewing);
			addCardInfoToArrays(cTechDEHCMachuPicchu);
			addCardInfoToArrays(cTechDEHCHuankaSupport);
			addCardInfoToArrays(cTechDEHCIncaFortifications);
			addCardInfoToArrays(cTechHCXPShipVillagers3);
			addCardInfoToArrays(cTechDEHCShipWoodCratesInfInca);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCMonumentalArchitecture);
			addCardInfoToArrays(cTechDEHCChasquisMessengers);
			addCardInfoToArrays(cTechDEHCRoadBuilding);
			addCardInfoToArrays(cTechDEHCCurare);
			addCardInfoToArrays(cTechYPHCImprovedBuildingsTeam);
			addCardInfoToArrays(cTechHCFoodSilos);
			addCardInfoToArrays(cTechDEHCMeleeInfCombatInca);
			addCardInfoToArrays(cTechDEHCIncaBridgesTeam);
			addCardInfoToArrays(cTechDEHCRangedInfDamageInca);
			addCardInfoToArrays(cTechDEHCRangedInfHitpointsInca);
			addCardInfoToArrays(cTechDEHCWarChiefInca2);
			addCardInfoToArrays(cTechDEHCWarChiefInca1);
			addCardInfoToArrays(cTechDEHCCollaSupport);
			addCardInfoToArrays(cTechDEHCCajamarcaSupport);
			addCardInfoToArrays(cTechDEHCChimuSupport);
			addCardInfoToArrays(cTechDEHCShipJungleBowmenRepeat);
			addCardInfoToArrays(cTechDEHCShipJungleBowmen1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCMonumentalArchitecture);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCCollaSupport);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCCajamarcaSupport);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCChimuSupport);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipJungleBowmenRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipJungleBowmen1);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCImprovedBuildingsTeam);
			break;
		}
		case cCivJapanese:
		{	// Cards
			addCardInfoToArrays(cTechYPHCIncreasedTribute);
			addCardInfoToArrays(cTechYPHCCheapUnitUpgradesTeam);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechypHCShipWoodCrates2);
			addCardInfoToArrays(cTechYPHCShipSettlersAsian2);
			addCardInfoToArrays(cTechypHCShipCoinCrates2);
			addCardInfoToArrays(cTechYPHCAdvancedConsulate);
			addCardInfoToArrays(cTechYPHCAdvancedRicePaddy);
			addCardInfoToArrays(cTechYPHCShipBerryWagon2);
			addCardInfoToArrays(cTechHCImprovedBuildings);
			addCardInfoToArrays(cTechYPHCBakufu);
			addCardInfoToArrays(cTechYPHCJapaneseSiege);
			addCardInfoToArrays(cTechYPHCAshigaruAntiCavalryDamage);
			addCardInfoToArrays(cTechYPHCArtilleryCostJapanese);
			addCardInfoToArrays(cTechYPHCNaginataAntiInfantryDamage);
			addCardInfoToArrays(cTechYPHCYumiRange);
			addCardInfoToArrays(cTechYPHCArtilleryHitpointsJapanese);
			addCardInfoToArrays(cTechYPHCSmoothRelations); // Probably removable.
			addCardInfoToArrays(cTechYPHCEnlistIrregulars);
			addCardInfoToArrays(cTechYPHCShipFlamingArrow3);
			addCardInfoToArrays(cTechYPHCShipNaginataRider1);
			addCardInfoToArrays(cTechYPHCShipFlamingArrow1);
			addCardInfoToArrays(cTechYPHCShipAshigaru4);
			addCardInfoToArrays(cTechYPHCShipAshigaru2);

			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCEnlistIrregulars);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipFlamingArrow3);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipNaginataRider1);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipFlamingArrow1);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipAshigaru4);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipAshigaru2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivChinese:
		{	// Cards
			addCardInfoToArrays(cTechYPHCConfusciousGift);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechYPHCSpawnRefugees1);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechYPHCAdvancedConsulate);
			addCardInfoToArrays(cTechYPHCAdvancedRicePaddy);
			addCardInfoToArrays(cTechHCImprovedBuildings);
			addCardInfoToArrays(cTechYPHCBannerSchool);
			addCardInfoToArrays(cTechYPHCAccupuncture);
			addCardInfoToArrays(cTechYPHCOldHanArmyReforms);
			addCardInfoToArrays(cTechYPHCHanAntiCavalryBonus);
			addCardInfoToArrays(cTechYPHCWesternReforms);
			addCardInfoToArrays(cTechYPHCTerritorialArmyCombat);
			addCardInfoToArrays(cTechYPHCEngineeringSchoolTeam);
			addCardInfoToArrays(cTechYPHCArtilleryCombatChinese);
			addCardInfoToArrays(cTechYPHCSmoothRelations); // Probably removable.
			addCardInfoToArrays(cTechYPHCAdvancedIrregulars);
			addCardInfoToArrays(cTechYPHCVillageShooty);
			addCardInfoToArrays(cTechYPHCShipFlyingCrow2);
			addCardInfoToArrays(cTechYPHCShipArquebusier1);
			addCardInfoToArrays(cTechYPHCShipChangdao2);
			addCardInfoToArrays(cTechYPHCShipChuKoNu2);
			addCardInfoToArrays(cTechYPHCShipChuKoNu1);

			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCAdvancedIrregulars);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipFlyingCrow2);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipArquebusier1);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipChangdao2);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipChuKoNu2);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipChuKoNu1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivIndians:
		{	// Cards
			addCardInfoToArrays(cTechYPHCRoyalMintIndians);
			addCardInfoToArrays(cTechYPHCGurkhaAid);
			addCardInfoToArrays(cTechYPHCAgrarianism);
			addCardInfoToArrays(cTechYPHCForeignLogging);
			addCardInfoToArrays(cTechYPHCShipWoodCrates2Indians);
			addCardInfoToArrays(cTechYPHCShipCoinCrates2Indians);
			addCardInfoToArrays(cTechYPHCAdvancedConsulateIndians);
			addCardInfoToArrays(cTechYPHCAdvancedRicePaddyIndians);
			addCardInfoToArrays(cTechYPHCGoraksha);
			addCardInfoToArrays(cTechYPHCImprovedBuildingsTeam);
			addCardInfoToArrays(cTechYPHCFencingSchoolIndians);
			addCardInfoToArrays(cTechYPHCRidingSchoolIndians);
			addCardInfoToArrays(cTechYPHCSustainableAgricultureIndians);
			addCardInfoToArrays(cTechYPHCInfantrySpeedHitpointsTeam);
			addCardInfoToArrays(cTechYPHCEastIndiaCompany);
			addCardInfoToArrays(cTechYPHCCamelDamageIndians);
			addCardInfoToArrays(cTechYPHCCamelFrightening);
			addCardInfoToArrays(cTechYPHCIndianMonkFrighten);
			addCardInfoToArrays(cTechYPHCSmoothRelationsIndians);
			addCardInfoToArrays(cTechYPHCEnlistIrregularsIndians);
			addCardInfoToArrays(cTechYPHCShipUrumiRegiment);
			addCardInfoToArrays(cTechYPHCShipUrumi2);
			addCardInfoToArrays(cTechYPHCShipSepoy3);
			addCardInfoToArrays(cTechYPHCShipUrumi1);
			addCardInfoToArrays(cTechYPHCShipSepoy1);

			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCEnlistIrregularsIndians);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipUrumiRegiment);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipUrumi2);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipSepoy3);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipUrumi1);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCShipSepoy1);
			arrayPushInt(gMilitaryDefensiveCards, cTechYPHCImprovedBuildingsTeam);
			break;
		}
		case cCivDEEthiopians:
		{	// Cards
			addCardInfoToArrays(cTechDEHCAdvancedLivestockMarket);
			addCardInfoToArrays(cTechDEHCRoofAfrica);
			addCardInfoToArrays(cTechDEHCIyasuReforms);
			addCardInfoToArrays(cTechDEHCShipVillagersAbunRepeat);
			addCardInfoToArrays(cTechDEHCFasilidesCastle);
			addCardInfoToArrays(cTechDEHCJesuitInfluence);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechDEHCLalibelaRockChurch);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCHeyWat);
			addCardInfoToArrays(cTechDEHCAdvancedAgriculture);
			addCardInfoToArrays(cTechDEHCBeekeepers);
			addCardInfoToArrays(cTechDEHCFazogli);
			addCardInfoToArrays(cTechDEHCFasterTrainingUnitsAfrican);
			addCardInfoToArrays(cTechDEHCJesuitSpirituality);
			addCardInfoToArrays(cTechDEHCCoffeeConsumption);
			addCardInfoToArrays(cTechDEHCZebenyas);
			addCardInfoToArrays(cTechDEHCTigrayMekonnen);
			addCardInfoToArrays(cTechDEHCCartridgeCurrency);
			addCardInfoToArrays(cTechDEHCChewaWarriors);
			addCardInfoToArrays(cTechDEHCShewaRiders);
			addCardInfoToArrays(cTechDEHCMassLeviesAfrican);
			addCardInfoToArrays(cTechDEHCShipSebastopolMortar1);
			addCardInfoToArrays(cTechDEHCShipNeftenya1);
			addCardInfoToArrays(cTechDEHCShipGascenya1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCMassLeviesAfrican);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipSebastopolMortar1);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipNeftenya1);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipGascenya1);
			break;
		}
		case cCivDEHausa:
		{	// Cards
			addCardInfoToArrays(cTechDEHCAdvancedLivestockMarket);
			addCardInfoToArrays(cTechDEHCKolaNutCultivation);
			addCardInfoToArrays(cTechDEHCMassinaMadrasahs);
			addCardInfoToArrays(cTechDEHCShipVillagers1Repeat);
			addCardInfoToArrays(cTechDEHCPalaceAmina);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechDEHCShipVillagers2);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCGobarauMinaret);
			addCardInfoToArrays(cTechDEHCAdvancedAgriculture);
			addCardInfoToArrays(cTechDEHCFasterTrainingUnitsAfrican);
			addCardInfoToArrays(cTechDEHCFodioTactics);
			addCardInfoToArrays(cTechDEHCDaneGuns);
			addCardInfoToArrays(cTechDEHCSarkinDogarai);
			addCardInfoToArrays(cTechDEHCDurbarParade);
			addCardInfoToArrays(cTechDEHCFulaniArcherCombat);
			addCardInfoToArrays(cTechDEHCCounterCavalry);
			addCardInfoToArrays(cTechDEHCHandCavalryHitpointsHausa);
			addCardInfoToArrays(cTechDEHCRanoIndigoProduction);
			addCardInfoToArrays(cTechDEHCFulaniCattleFertilizer);
			addCardInfoToArrays(cTechDEHCKoose);
			addCardInfoToArrays(cTechDEHCMassLeviesAfrican);
			addCardInfoToArrays(cTechDEHCShipJavelinRiders2);
			addCardInfoToArrays(cTechDEHCShipFulaWarriors2);
			addCardInfoToArrays(cTechDEHCShipFulaWarriors1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCMassLeviesAfrican);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipJavelinRiders2);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipFulaWarriors2);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipFulaWarriors1);
			break;
		}
	}
}


//==============================================================================
// Shipment Functions
//==============================================================================
bool getCardExtended(int cardTechID = -1)
{
	if (cMyCiv != cCivDEAmericans && cMyCiv != cCivDEMexicans)
		return(false);
	for (i = 0; < aiHCDeckGetNumberCards(aiHCGetExtendedDeck()))
		if (aiHCDeckGetCardTechID(aiHCGetExtendedDeck(), i) == cardTechID)
			return(true);
	return(false);
}

bool getCardSent(int cardTechID = -1)
{
	for (i = 0; < arrayGetSize(gSentCardList))
		if (arrayGetInt(gSentCardList, i) == cardTechID)
			return(true);
	return(false);
}

bool getCardAffordable(int cardTechID = -1)
{
	if ((kbResourceGet(cResourceFood) >= kbTechCostPerResource(cardTechID, cResourceFood)) &&
		(kbResourceGet(cResourceWood) >= kbTechCostPerResource(cardTechID, cResourceWood)) &&
		(kbResourceGet(cResourceGold) >= kbTechCostPerResource(cardTechID, cResourceGold)))
		return(true);
	return(false);
}

bool shouldSendCard(int cardTechID = -1)
{
	bool should = true;

	// The conditions are meant to prevent sending these cards prematurely.
	// For example, if we are lingering in age one (perhaps due to low difficulty),
	// it would be better to save the shipment for a better Age 2 card than to send
	// Improved Buildings. In this case, Improved Buildings was only considered
	// because the others weren't yet considered as we weren't aging to Age 2 or
	// already in Age 2.
	switch (cardTechID)
	{
		case cTechHCXPLandGrab:
		case cTechYPHCAdvancedRicePaddy:
		case cTechYPHCAdvancedRicePaddyIndians:
		case cTechDEHCAdvancedAgriculture:
		{
			should = gTimeToFarm | gTimeForPlantations;
			break;
		}
		case cTechHCTextileMills:
		{
			should = gTimeForPlantations;
			break;
		}
		case cTechHCImprovedBuildings:
		case cTechHCImprovedBuildingsGerman:
		case cTechYPHCImprovedBuildingsTeam:
		{
			should = kbGetAge() >= cAge2;
			break;
		}
		case cTechDEHCHouseOfTrastamara: // Age 2 card, but don't use it to age up to Age 3.
		{
			should = kbGetAge() >= cAge3;
			break;
		}
		case cTechDEHCMarvelousYear:
		{
			should = kbUnitCount(cMyID, cUnitTypeLogicalTypeSettlerBuildLimit, cUnitStateAlive) >= 30;
			break;
		}
		case cTechHCRoyalDecreeDutch:
		{
			should = (kbGetBuildLimit(cMyID, cUnitTypeBank) - kbUnitCount(cMyID, cUnitTypeBank, cUnitStateABQ)) < 2;
			echoMessage("Should send royal decree dutch? " + should);
			break;
		}
		case cTechHCBanks1:
		case cTechHCBanks2:
		{
			should = (kbGetBuildLimit(cMyID, cUnitTypeBank) - kbUnitCount(cMyID, cUnitTypeBank, cUnitStateABQ)) < 2;
			should |= (kbGetBuildLimit(cMyID, gEconUnit) - kbUnitCount(cMyID, gEconUnit, cUnitStateABQ)) < 6;
			break;
		}
		case cTechHCRoyalDecreeRussian:
		{
			should = getAgingUpAge() >= cAge3;
			break;
		}
		case cTechDEHCFedPlymouthSettlers:
		{
			should = kbUnitCount(cMyID, cUnitTypeTownCenter, cUnitStateAlive) >= 2;
			break;
		}
	}

	return(should);
}

rule updateNextShipmentTechID
inactive
minInterval 10
{
	int cardTechID = -1; // Signifies the card tech ID, for instance: "cTechHCUnlockFactory"
	bool isMilitaryUnit = false;
	bool isMilitaryUpgrade = false;
	bool extended = false; // Relevant for identifying which deck ID we should use.
	int cardIndex = -1; // Signifies the card tech ID's index within the given deck, such as 0, 1...
	int sentCount = 0; // Signifies how many times the card has been sent.
	int maxCount = -1; // Signifies how many times we can send this card. -1 for infinite.
	int deckID = -1; // The deck ID should be gDefaultDeck, otherwise for Americans and Mexicans,
					 // it should be aiHCGetExtendedDeck() for federal cards.
	int ageReq = -1; // Signifies the necessary age needed to send the card.
	int flags = -1; // Signifies certain tags associated with this card; can be multiple.
	string techName = "";

	// 0: Looking for Military Units to send.
	// 1: No valuable (lesser age/already sent) military unit shipments found.
	//    Search for other cards that improve stats.
	// 2: None of the previous two found, just go with a card as if we weren't under attack.
	static int defensiveCardSearchMode = 0;

	gNextShipmentTechID = -1;
	gNextShipmentIndexInArray = -1;

	for (i = 0; < arrayGetSize(gCardList))
	{
		cardTechID = arrayGetInt(gCardList, i);
		isMilitaryUnit = arrayGetBool(gCardListIsMilitaryUnit, i);
		isMilitaryUpgrade = arrayGetBool(gCardListIsMilitaryUpgrade, i);
		extended = arrayGetBool(gCardListIsExtended, i);
		cardIndex = arrayGetInt(gCardListIndexInDeck, i);
		sentCount = arrayGetInt(gCardListSentCount, i);
		if (extended == false) deckID = gDefaultDeck;
		else deckID = aiHCGetExtendedDeck();
		maxCount = aiHCDeckGetCardCount(deckID, cardIndex);
		ageReq = aiHCDeckGetCardAgePrereq(deckID, cardIndex);
		flags = aiHCDeckGetCardFlags(deckID, cardIndex);
		techName = kbGetTechName(cardTechID);

		// ==================================================
		// Check various conditions before choosing this card.
		if (cardIndex < 0)
			continue;

		if (maxCount - sentCount <= 0)
		{	// If the card is an infinite military shipment, it will still be considered.
			if (maxCount >= 0 || isMilitaryUnit == false)
				continue;
		}

		if (getCardAffordable(cardTechID) == false)
			continue;

		if (shouldSendCard(cardTechID) == false)
			continue;

		// Unless the card is an Age 4 or Federal military unit shipment 
		// while we are Age4+, ignore it.
		if (isMilitaryUnit)
		{
			if (kbGetAge() > ageReq && ageReq != -1 && ageReq < cAge4)
				continue;
		}

		if (gDefenseReflexBaseID == kbBaseGetMainID(cMyID))
		{
			switch (defensiveCardSearchMode)
			{
				case 0:
				{
					if (isMilitaryUnit == false)
						continue;
					break;
				}
				case 1:
				{
					if (isMilitaryUpgrade == false)
						continue;
					break;
				}
				case 2:
				{
					// Do nothing. Continue with evaluating shipments as if not under attack.
					break;
				}
			}
		}

		if (ageReq > kbGetAge())
		{
			// Check to see if we are aging up and can send this next-in-priority card
			// in the next age.
			if (agingUp() && ageReq == getAgingUpAge())
				return;
			// For the special case where we are in age 1, and the next
			// considered card that has met all previous checks is in age 2,
			// hold off shipping another card even if we aren't yet aging up.
			else if (agingUp() == false && 
					 ageReq == cAge2 &&
					 gNumberShipmentsSent > 0)
				return;
			// Not in the next age either, so skip it for now.
			else continue;
		}

		// If we have reached this point, we have met all
		// conditions without triggering a continue statement.
		// ==================================================

		gNextShipmentTechID = cardTechID;
		gNextShipmentIndexInArray = i;
		break;
	}

	// Looking for defensive cards and didn't find any.
	if (gNextShipmentTechID < 0 && kbGetAge() >= cAge2)
	{
		// In the rare case we are on 2 (shipping anything) and still have found
		// nothing, do not increment again.
		if (defensiveCardSearchMode < 2)
			defensiveCardSearchMode += 1;
	}
	else if (gNextShipmentTechID >= 0)
	{
		defensiveCardSearchMode = 0;
	}

}

void shipGrantedHandler(int parm = -1) // Event handler
{
	if (kbResourceGet(cResourceShips) < 1.0)
		return;

	bool insufficientResources = false;
	if (gNextShipmentTechID >= 0)
	{
		int indexInDeck = arrayGetInt(gCardListIndexInDeck, gNextShipmentIndexInArray);
		bool extended = arrayGetBool(gCardListIsExtended, gNextShipmentIndexInArray);
		if (kbTechCostPerResource(gNextShipmentTechID, cResourceFood) > kbResourceGet(cResourceFood))
			insufficientResources = true;
		if (kbTechCostPerResource(gNextShipmentTechID, cResourceWood) > kbResourceGet(cResourceWood))
			insufficientResources = true;
		if (kbTechCostPerResource(gNextShipmentTechID, cResourceGold) > kbResourceGet(cResourceGold))
			insufficientResources = true;
		// Influence shipments? Perhaps need to be added too.
		if (insufficientResources == false && aiHCDeckPlayCard(indexInDeck, extended))
		{
			echoMessage("Success: Card " + kbGetTechName(gNextShipmentTechID));
			gNumberShipmentsSent++;
			arraySetInt(
				gCardListSentCount,
				gNextShipmentIndexInArray,
				arrayGetInt(gCardListSentCount, gNextShipmentIndexInArray) + 1
			);
			updateNextShipmentTechID();
			updateResourceDistribution();
		}
		else
			echoMessage("Failed: Card " + kbGetTechName(gNextShipmentTechID));
	}
	else
	{
		updateNextShipmentTechID();
	}
}

rule extraShipMonitor
inactive
group tcComplete
minInterval 20
{
	if (kbResourceGet(cResourceShips) > 0)
		shipGrantedHandler(); // Spend the surplus
}

int getCardIndexFromDeck(int cardTechID = -1, bool extended = false)
{
	int deckID = gDefaultDeck;
	if (extended)
		deckID = aiHCGetExtendedDeck();

	for (i = 0; < aiHCDeckGetNumberCards(deckID))
		if (cardTechID == aiHCDeckGetCardTechID(deckID, i))
			return(i);
	return(-1);
}

rule initializeCardIndices
inactive
minInterval 2
{
	xsDisableSelf();

	for (i = 0; < arrayGetSize(gCardList))
	{	// Need to initialize if the value is still -1.
		// Won't be in extended deck as it would have been initialized manually.
		if (arrayGetInt(gCardListIndexInDeck, i) == -1)
		{
			arraySetInt(
				gCardListIndexInDeck,
				i,
				getCardIndexFromDeck(arrayGetInt(gCardList, i))
			);
		}
	}

	xsEnableRule("updateNextShipmentTechID");
	updateNextShipmentTechID();
}

void updateFederalCardIndices()
{
	for (i = 0; < arrayGetSize(gCardList))
	{	// Need to initialize if the value is still -1.
		// Won't be in extended deck as it would have been initialized manually.
		if (arrayGetBool(gCardListIsExtended, i) == true &&
			arrayGetInt(gCardListIndexInDeck, i) == -1)
		{
			arraySetInt(
				gCardListIndexInDeck,
				i,
				getCardIndexFromDeck(arrayGetInt(gCardList, i), true)
			);
		}
	}
}

void createDeck(void)
{
	selectCards();

	gDefaultDeck = aiHCDeckCreate("AI Deck");
	for (card = 0; < aiHCCardsGetTotal())
	{
		for (i = 0; < arrayGetSize(gCardList))
		{
			if (aiHCCardsGetCardTechID(card) == arrayGetInt(gCardList, i))
			{
				aiHCDeckAddCardToDeck(gDefaultDeck, card);
				break;
			}
		}
	}

	aiHCDeckActivate(gDefaultDeck);
	xsEnableRule("initializeCardIndices");
}