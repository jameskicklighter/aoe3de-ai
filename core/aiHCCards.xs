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
		case cCivDEItalians:
		{
			addCardInfoToArrays(cTechHCRobberBarons);
			addCardInfoToArrays(cTechDEHCAdvancedPoliticians);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechDEHCFlorentineFinancers);
			addCardInfoToArrays(cTechDEHCGenoeseFinancers);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechDEHCFreemasonry);
			addCardInfoToArrays(cTechDEHCAdvancedLombard);
			addCardInfoToArrays(cTechDEHCUsury);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechDEHCUffizi);
			addCardInfoToArrays(cTechDEHCMonteDiPieta);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCShipPavisiers1, true);
			addCardInfoToArrays(cTechDEHCMilaneseArsenal);
			addCardInfoToArrays(cTechDEHCAlpini, false, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechDEHCCavalryCombatItalian, false, true);
			addCardInfoToArrays(cTechDEHCSchiavoniSwords, false, true);
			addCardInfoToArrays(cTechDEHCShipBersaglieriRepeat, true);
			break;
		}
		case cCivDEMaltese:
		{
			addCardInfoToArrays(cTechHCUnlockFactory);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechDEHCFrenchTongue, true);
			addCardInfoToArrays(cTechHCUnlockFort);
			addCardInfoToArrays(cTechDEHCMilitaryOutposts);
			addCardInfoToArrays(cTechDEHCVictoriousCity);
			addCardInfoToArrays(cTechDEHCFireTowers, false, true);
			addCardInfoToArrays(cTechDEHCShipHoopThrowers1, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechHCShipSettlers3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechDEHCWignacourtConstructions);
			addCardInfoToArrays(cTechDEHCHospitality);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCShipCrossbowmen1, true);
			addCardInfoToArrays(cTechYPHCImprovedBuildingsTeam, false, true);
			addCardInfoToArrays(cTechDEHCSquires, false, true);
			addCardInfoToArrays(cTechDEHCMalteseCombat, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechDEHCRocketThrowers, false, true);
			addCardInfoToArrays(cTechDEHCFlintlockRockets, false, true);
			addCardInfoToArrays(cTechDEHCDignitaries, false, true);
			addCardInfoToArrays(cTechDEHCFlameThrowers, false, true);
			addCardInfoToArrays(cTechHCShipFalconets2, true);
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
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCShipFalconets3, true);
			addCardInfoToArrays(cTechDEHCFedMXElBajio); // Federal Card
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCTextileMills);
			addCardInfoToArrays(cTechDEHCFedMXTonalaCeramics); // Federal Card
			addCardInfoToArrays(cTechDEHCFedMXOurLadyOfLight); // Federal Card
			addCardInfoToArrays(cTechDEHCAlhondigaDeGranaditas);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipSettlers4);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCIturbidePalace, false, true);
			addCardInfoToArrays(cTechDEHCShipInsurgente1, true);
			addCardInfoToArrays(cTechDEHCSevenLaws);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechDEHCLiberationMarch, false, true);
			addCardInfoToArrays(cTechHCAdvancedArsenal);
			addCardInfoToArrays(cTechDEHCPresidialLancers, false, true);
			addCardInfoToArrays(cTechDEHCObservers, false, true);
			addCardInfoToArrays(cTechHCCaballeros, false, true);
			addCardInfoToArrays(cTechDEHCCavalryCombatMexican, false, true);
			addCardInfoToArrays(cTechHCShipFalconets2, true);
			break;
		}
		case cCivXPIroquois:
		{	// Cards
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCXPShipLightCannon2, true);
			addCardInfoToArrays(cTechHCXPFrenchAllies1, true);
			addCardInfoToArrays(cTechHCXPShipMusketWarriors3, true);
			addCardInfoToArrays(cTechHCSustainableAgriculture);
			addCardInfoToArrays(cTechHCRumDistillery);
			addCardInfoToArrays(cTechHCXPShipVillagers3);
			addCardInfoToArrays(cTechHCShipWoodCrates2);
			addCardInfoToArrays(cTechHCXPShipVillagers4);
			addCardInfoToArrays(cTechHCShipCoinCrates2);
			addCardInfoToArrays(cTechHCXPShipTomahawk1, true);
			addCardInfoToArrays(cTechHCXPTownDance, false, true);
			addCardInfoToArrays(cTechHCXPNewWaysIroquois);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCXPWarHutTrainingIroquois, false, true);
			addCardInfoToArrays(cTechHCXPInfantryCombatIroquois, false, true);
			addCardInfoToArrays(cTechHCXPInfantryLOSTeam, false, true);
			addCardInfoToArrays(cTechHCXPWarChiefIroquois1, false, true);
			addCardInfoToArrays(cTechHCXPWarChiefIroquois2, false, true);
			addCardInfoToArrays(cTechHCXPSiegeDiscipline, false, true);
			addCardInfoToArrays(cTechHCEngineeringSchool, false, true);
			addCardInfoToArrays(cTechHCXPSiegeCombat, false, true);
			addCardInfoToArrays(cTechHCXPConservativeTactics, false, true);
			addCardInfoToArrays(cTechHCXPShipMixedCratesRepeat);
			addCardInfoToArrays(cTechHCXPShipMantletsRepeat, true);
			break;
		}
		case cCivXPSioux:
		{	// Cards
			addCardInfoToArrays(cTechHCXPAdoption);
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCFoodSilos);
			addCardInfoToArrays(cTechHCXPCommandSkill, false, true);
			addCardInfoToArrays(cTechHCXPSiouxTwoKettleSupport, true);
			addCardInfoToArrays(cTechHCXPSiouxSanteeSupport, true);
			addCardInfoToArrays(cTechHCXPShipWarRifles1, true);
			addCardInfoToArrays(cTechHCXPShipVillagers2);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCXPGreatHunter);
			addCardInfoToArrays(cTechHCXPShipVillagers4);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCXPShipAxeRiders3, true);
			addCardInfoToArrays(cTechHCXPTownDance, false, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCXPMustangs, false, true);
			addCardInfoToArrays(cTechHCRidingSchool, false, true);
			addCardInfoToArrays(cTechHCXPFriendlyTerritory, false, true);
			addCardInfoToArrays(cTechHCXPNewWaysSioux);
			addCardInfoToArrays(cTechHCXPNomadicExpansion);
			addCardInfoToArrays(cTechHCXPWindRunner, false, true);
			addCardInfoToArrays(cTechHCXPCavalryCombatSioux, false, true);
			addCardInfoToArrays(cTechHCXPOnikare, false, true);
			addCardInfoToArrays(cTechHCXPBuffalo2, true);
			addCardInfoToArrays(cTechHCXPShipAxeRidersRepeat, true);
			break;
		}
		case cCivXPAztec:
		{	// Cards
			addCardInfoToArrays(cTechHCXPLandGrab);
			addCardInfoToArrays(cTechHCXPChinampa2);
			addCardInfoToArrays(cTechHCXPAztecMining);
			addCardInfoToArrays(cTechHCXPTempleXolotl);
			addCardInfoToArrays(cTechHCXPTempleCenteotl, true);
			addCardInfoToArrays(cTechHCXPTempleXipeTotec, true);
			addCardInfoToArrays(cTechHCXPTempleTlaloc, true);
			addCardInfoToArrays(cTechHCGrainMarket);
			addCardInfoToArrays(cTechHCXPChinampa1);
			addCardInfoToArrays(cTechHCFoodSilos);
			addCardInfoToArrays(cTechHCXPShipVillagers3);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCXPShipMedicineMen2Aztec);
			addCardInfoToArrays(cTechHCXPShipVillagers4);
			addCardInfoToArrays(cTechHCXPCoinCratesAztec3);
			addCardInfoToArrays(cTechHCXPShipMacehualtins3, true);
			addCardInfoToArrays(cTechHCXPTownDance, false, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechHCFencingSchool, false, true);
			addCardInfoToArrays(cTechHCXPWarHutTraining, false, true);
			addCardInfoToArrays(cTechHCXPScorchedEarth, false, true);
			addCardInfoToArrays(cTechHCXPKnightCombat, false, true);
			addCardInfoToArrays(cTechHCXPCoyoteCombat, false, true);
			addCardInfoToArrays(cTechHCXPExtensiveFortificationsAztec);
			addCardInfoToArrays(cTechHCXPShipMacehualtinsRepeat, true);
			break;
		}
		case cCivDEInca:
		{	// Cards
			addCardInfoToArrays(cTechDEHCTerraceFarming);
			addCardInfoToArrays(cTechDEHCMachuPicchu);
			addCardInfoToArrays(cTechDEHCCollaSupport, true);
			addCardInfoToArrays(cTechDEHCCajamarcaSupport, true);
			addCardInfoToArrays(cTechDEHCChimuSupport, true);
			addCardInfoToArrays(cTechHCFoodSilos);
			addCardInfoToArrays(cTechDEHCIncaFortifications, false, true);
			addCardInfoToArrays(cTechHCXPShipVillagers3);
			addCardInfoToArrays(cTechDEHCHuankaSupport);
			addCardInfoToArrays(cTechDEHCChichaBrewing);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechHCXPShipVillagers4);
			addCardInfoToArrays(cTechDEHCShipWoodCratesInfInca);
			addCardInfoToArrays(cTechDEHCShipJungleBowmen1, true);
			addCardInfoToArrays(cTechDEHCMonumentalArchitecture, false, true);
			addCardInfoToArrays(cTechDEHCChasquisMessengers, false, true);
			addCardInfoToArrays(cTechYPHCImprovedBuildingsTeam, false, true);
			addCardInfoToArrays(cTechDEHCCurare, false, true);
			addCardInfoToArrays(cTechDEHCMeleeInfCombatInca, false, true);
			addCardInfoToArrays(cTechDEHCRangedInfDamageInca, false, true);
			addCardInfoToArrays(cTechDEHCRoadBuilding, false, true);
			addCardInfoToArrays(cTechDEHCIncaBridgesTeam, false, true);
			addCardInfoToArrays(cTechDEHCWarChiefInca2, false, true);
			addCardInfoToArrays(cTechDEHCWarChiefInca1, false, true);
			addCardInfoToArrays(cTechDEHCShipJungleBowmenRepeat, true);
			break;
		}
		case cCivJapanese:
		{	// Cards
			addCardInfoToArrays(cTechYPHCAdvancedRicePaddy);
			addCardInfoToArrays(cTechYPHCCheapUnitUpgradesTeam);
			addCardInfoToArrays(cTechYPHCShipFlamingArrow3, true);
			addCardInfoToArrays(cTechYPHCShipFlamingArrow1, true);
			addCardInfoToArrays(cTechYPHCShipAshigaru4, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechYPHCIncreasedTribute);
			addCardInfoToArrays(cTechYPHCShipSettlersAsian2);
			addCardInfoToArrays(cTechypHCShipWoodCrates2);
			addCardInfoToArrays(cTechypHCShipCoinCrates2);
			addCardInfoToArrays(cTechYPHCShipAshigaru2, true);
			addCardInfoToArrays(cTechYPHCShipBerryWagon2);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechYPHCBakufu, false, true);
			addCardInfoToArrays(cTechYPHCAshigaruAntiCavalryDamage, false, true);
			addCardInfoToArrays(cTechYPHCAshigaruDamage, false, true);
			addCardInfoToArrays(cTechYPHCArtilleryCostJapanese, false, true);
			addCardInfoToArrays(cTechYPHCNaginataAntiInfantryDamage, false, true);
			addCardInfoToArrays(cTechYPHCYumiRange, false, true);
			addCardInfoToArrays(cTechYPHCJapaneseSiege, false, true);
			addCardInfoToArrays(cTechYPHCArtilleryHitpointsJapanese, false, true);
			addCardInfoToArrays(cTechYPHCAdvancedConsulate); // Make Viable.
			addCardInfoToArrays(cTechYPHCSmoothRelations); // Make Viable.
			addCardInfoToArrays(cTechYPHCShipNaginataRider1, true);
			break;
		}
		case cCivChinese:
		{	// Cards
			addCardInfoToArrays(cTechYPHCAdvancedRicePaddy);
			addCardInfoToArrays(cTechYPHCConfusciousGift);
			addCardInfoToArrays(cTechYPHCShipArquebusier1, true);
			addCardInfoToArrays(cTechYPHCShipChangdao2, true);
			addCardInfoToArrays(cTechYPHCShipChuKoNu2, true);
			addCardInfoToArrays(cTechHCRefrigeration);
			addCardInfoToArrays(cTechHCRoyalMint);
			addCardInfoToArrays(cTechYPHCSpawnRefugees1);
			addCardInfoToArrays(cTechHCShipWoodCrates3);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechYPHCVillageShooty, false, true);
			addCardInfoToArrays(cTechYPHCAdvancedConsulate); // Make Viable.
			addCardInfoToArrays(cTechYPHCSmoothRelations); // Make Viable.
			addCardInfoToArrays(cTechYPHCShipChuKoNu1, true);
			addCardInfoToArrays(cTechYPHCAdvancedIrregulars, false, true);
			addCardInfoToArrays(cTechHCImprovedBuildings, false, true);
			addCardInfoToArrays(cTechYPHCBannerSchool, false, true);
			addCardInfoToArrays(cTechYPHCAccupuncture, false, true);
			addCardInfoToArrays(cTechYPHCOldHanArmyReforms, false, true);
			addCardInfoToArrays(cTechYPHCHanAntiCavalryBonus, false, true);
			addCardInfoToArrays(cTechYPHCWesternReforms, false, true);
			addCardInfoToArrays(cTechYPHCTerritorialArmyCombat, false, true);
			addCardInfoToArrays(cTechYPHCEngineeringSchoolTeam, false, true);
			addCardInfoToArrays(cTechYPHCArtilleryCombatChinese, false, true);
			addCardInfoToArrays(cTechYPHCShipFlyingCrow2, true);
			break;
		}
		case cCivIndians:
		{	// Cards
			addCardInfoToArrays(cTechYPHCAdvancedRicePaddyIndians);
			addCardInfoToArrays(cTechYPHCShipUrumiRegiment, true);
			addCardInfoToArrays(cTechYPHCShipSepoy3, true);
			addCardInfoToArrays(cTechYPHCShipUrumi1, true);
			addCardInfoToArrays(cTechYPHCRoyalMintIndians);
			addCardInfoToArrays(cTechYPHCSustainableAgricultureIndians);
			addCardInfoToArrays(cTechYPHCFoodSilosIndians);
			addCardInfoToArrays(cTechYPHCGurkhaAid, false, true);
			addCardInfoToArrays(cTechYPHCAgrarianism);
			addCardInfoToArrays(cTechYPHCForeignLogging);
			addCardInfoToArrays(cTechYPHCShipWoodCrates2Indians);
			addCardInfoToArrays(cTechYPHCShipCoinCrates2Indians);
			addCardInfoToArrays(cTechYPHCShipSepoy1, true);
			addCardInfoToArrays(cTechYPHCAdvancedConsulateIndians);
			addCardInfoToArrays(cTechYPHCGoraksha);
			addCardInfoToArrays(cTechYPHCImprovedBuildingsTeam, false, true);
			addCardInfoToArrays(cTechYPHCFencingSchoolIndians, false, true);
			addCardInfoToArrays(cTechYPHCRidingSchoolIndians, false, true);
			addCardInfoToArrays(cTechYPHCElephantTrampling, false, true);
			addCardInfoToArrays(cTechYPHCElephantCombatIndians, false, true);
			addCardInfoToArrays(cTechYPHCEastIndiaCompany, false, true);
			addCardInfoToArrays(cTechYPHCInfantrySpeedHitpointsTeam, false, true);
			addCardInfoToArrays(cTechYPHCCamelDamageIndians, false, true);
			addCardInfoToArrays(cTechYPHCCamelFrightening, false, true);
			addCardInfoToArrays(cTechYPHCShipUrumi2, true);
			break;
		}
		case cCivDEEthiopians:
		{	// Cards
			addCardInfoToArrays(cTechDEHCAdvancedAgriculture);
			addCardInfoToArrays(cTechDEHCAdvancedLivestockMarket);
			addCardInfoToArrays(cTechDEHCShipSebastopolMortar1, true);
			addCardInfoToArrays(cTechDEHCShipNeftenya1, true);
			addCardInfoToArrays(cTechDEHCRoofAfrica);
			addCardInfoToArrays(cTechDEHCIyasuReforms);
			addCardInfoToArrays(cTechDEHCFazogli);
			addCardInfoToArrays(cTechDEHCBeekeepers);
			addCardInfoToArrays(cTechDEHCShipVillagersAbunRepeat);
			addCardInfoToArrays(cTechDEHCFasilidesCastle);
			addCardInfoToArrays(cTechDEHCJesuitInfluence);
			addCardInfoToArrays(cTechDEHCShipChonkyCattle);
			addCardInfoToArrays(cTechDEHCShipVillagers2);
			addCardInfoToArrays(cTechDEHCShipGascenya1, true);
			addCardInfoToArrays(cTechDEHCLalibelaRockChurch);
			addCardInfoToArrays(cTechDEHCMassLeviesAfrican, false, true);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCHeyWat);
			addCardInfoToArrays(cTechDEHCFasterTrainingUnitsAfrican, false, true);
			addCardInfoToArrays(cTechDEHCChewaWarriors, false, true);
			addCardInfoToArrays(cTechDEHCCartridgeCurrency, false, true);
			addCardInfoToArrays(cTechDEHCZebenyas, false, true);
			addCardInfoToArrays(cTechDEHCTigrayMekonnen, false, true);
			addCardInfoToArrays(cTechDEHCShewaRiders, false, true);
			addCardInfoToArrays(cTechDEHCGascenyaRepeat, true);
			break;
		}
		case cCivDEHausa:
		{	// Cards
			addCardInfoToArrays(cTechDEHCAdvancedAgriculture);
			addCardInfoToArrays(cTechDEHCAdvancedLivestockMarket);
			addCardInfoToArrays(cTechDEHCMassinaMadrasahs);
			addCardInfoToArrays(cTechDEHCKolaNutCultivation);
			addCardInfoToArrays(cTechDEHCRanoIndigoProduction);
			addCardInfoToArrays(cTechDEHCFulaniCattleFertilizer);
			addCardInfoToArrays(cTechDEHCKoose);
			addCardInfoToArrays(cTechDEHCShipFulaWarriors2, true);
			addCardInfoToArrays(cTechDEHCShipVillagers1Repeat);
			addCardInfoToArrays(cTechDEHCPalaceAmina);
			addCardInfoToArrays(cTechDEHCShipVillagers2);
			addCardInfoToArrays(cTechDEHCFulaniCrossingFestival);
			addCardInfoToArrays(cTechHCShipCoinCrates3);
			addCardInfoToArrays(cTechDEHCShipFulaWarriors1, true);
			addCardInfoToArrays(cTechDEHCMassLeviesAfrican, false, true);
			addCardInfoToArrays(cTechDEHCGobarauMinaret);
			addCardInfoToArrays(cTechDEHCFasterTrainingUnitsAfrican, false, true);
			addCardInfoToArrays(cTechDEHCDurbarParade, false, true);
			addCardInfoToArrays(cTechDEHCFodioTactics, false, true);
			addCardInfoToArrays(cTechDEHCDaneGuns, false, true);
			addCardInfoToArrays(cTechDEHCSarkinDogarai, false, true);
			addCardInfoToArrays(cTechDEHCFulaniArcherCombat, false, true);
			addCardInfoToArrays(cTechDEHCCounterCavalry, false, true);
			addCardInfoToArrays(cTechDEHCHandCavalryHitpointsHausa, false, true);
			addCardInfoToArrays(cTechDEHCShipLifidiKnightsRepeat, true);
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
		case cTechHCShipFoodCrates3:
		case cTechHCShipWoodCrates2:
		case cTechHCShipWoodCrates3:
		case cTechHCShipWoodCrates3German:
		case cTechDEHCShipWoodCratesInfInca:
		case cTechypHCShipWoodCrates2:
		case cTechYPHCShipWoodCrates2Indians:
		case cTechHCShipCoinCrates2:
		case cTechHCShipCoinCrates3:
		case cTechHCShipCoinCrates3German:
		case cTechypHCShipCoinCrates2:
		case cTechYPHCShipCoinCrates2Indians:
		case cTechHCShipSettlers3:
		case cTechHCShipSettlers4:
		case cTechHCShipCoureurs2:
		case cTechHCShipCoureurs3:
		case cTechHCShipSettlerWagons3:
		case cTechHCShipSettlerWagons4:
		case cTechHCXPShipVillagers2:
		case cTechHCXPShipVillagers3:
		case cTechHCXPShipVillagers4:
		case cTechYPHCShipSettlersAsian2:
		case cTechDEHCShipVillagers1Repeat:
		case cTechDEHCShipVillagers2:
		case cTechDEHCShipVillagersAbunRepeat:
		{
			should = getAgingUpAge() <= cAge2;
			break;
		}
		case cTechHCXPLandGrab:
		case cTechYPHCAdvancedRicePaddy:
		case cTechYPHCAdvancedRicePaddyIndians:
		case cTechDEHCAdvancedAgriculture:
		case cTechHCXPChinampa1:
		case cTechHCXPChinampa2:
		case cTechDEHCTerraceFarming:
		{
			should = gTimeToFarm | gTimeForPlantations;
			break;
		}
		case cTechHCFoodSilos:
		case cTechHCSustainableAgriculture:
		case cTechHCGrainMarket:
		case cTechYPHCFoodSilosIndians:
		case cTechYPHCSustainableAgricultureIndians:
		case cTechDEHCFulaniCattleFertilizer:
		case cTechDEHCKoose:
		{
			should = gTimeToFarm;
			break;
		}
		case cTechHCRumDistillery:
		case cTechHCTextileMills:
		case cTechDEHCFedMXTonalaCeramics:
		case cTechDEHCRanoIndigoProduction:
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
			break;
		}
		case cTechHCBanks1:
		case cTechHCBanks2:
		{
			should = (kbGetBuildLimit(cMyID, cUnitTypeBank) - kbUnitCount(cMyID, cUnitTypeBank, cUnitStateABQ)) < 2;
			should |= (kbGetBuildLimit(cMyID, gEconUnit) - kbUnitCount(cMyID, gEconUnit, cUnitStateABQ)) < 6;
			break;
		}
		case cTechHCBetterBanks:
		{
			should = kbUnitCount(cMyID, cUnitTypeBank, cUnitStateABQ) >= 4;
			break;
		}
		case cTechHCRoyalDecreeRussian:
		{
			should = getAgingUpAge() >= cAge3;
			break;
		}
		case cTechDEHCAdvancedLombard:
		case cTechDEHCGenoeseFinancers:
		case cTechDEHCFlorentineFinancers:
		{
			should = kbUnitCount(cMyID, cUnitTypedeLombard, cUnitStateAlive) >= 1;
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
		// while we are Age4+, ignore it. Don't ignore "support" cards
		// that increase unit stats.
		if (isMilitaryUnit)
		{
			if (kbGetAge() > ageReq && ageReq != -1 && ageReq < cAge4 &&
				(kbTechCostPerResource(cardTechID, cResourceFood) +
				 kbTechCostPerResource(cardTechID, cResourceFood) +
				 kbTechCostPerResource(cardTechID, cResourceGold) <= 0))
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