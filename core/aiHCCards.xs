// ================================================================================
//	aiHCCards.xs
// ================================================================================

void selectCards(void)
{
	gCardList = arrayCreateInt(1, "The AI Deck");
	gSentCardList = arrayCreateInt(30, "Sent Card TechIDs");
	gPriorityCards = arrayCreateInt(1, "Priority Cards");
	gMilitaryDefensiveCards = arrayCreateInt(1, "Military Defensive Cards"); // To be used when the main base is under threat.
	// gResourceDependentCards = arrayCreateInt(1, "Resource Dependent Cards"); // To be used next update.

	switch (cMyCiv)
	{
		// Card order is indicative of general priority, with more specific checks to be
		// implemented in shipGrantedHandler() itself (such as not sending 700f in Age 4).
		case cCivSpanish:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCXPIndustrialRevolution);
			arrayPushInt(gCardList, cTechHCXPSpanishGold);
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechHCShipSettlers3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipSettlers4);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCXPEconomicTheory);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCRoyalDecreeSpanish);
			arrayPushInt(gCardList, cTechHCCaballeros);
			arrayPushInt(gCardList, cTechHCHandCavalryCombatSpanish);
			arrayPushInt(gCardList, cTechHCHandInfantryCombatSpanish);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechHCShipFalconets3);
			arrayPushInt(gCardList, cTechHCShipFalconets2);
			arrayPushInt(gCardList, cTechHCShipLancers3);
			arrayPushInt(gCardList, cTechHCShipRodeleros5);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipLancers3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipRodeleros5);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivBritish:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCRobberBarons);
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechHCShipSettlers3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipSettlers4);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCRoyalDecreeBritish);
			arrayPushInt(gCardList, cTechHCMusketeerGrenadierCombatBritish);
			arrayPushInt(gCardList, cTechHCCavalryCombatBritish);
			arrayPushInt(gCardList, cTechHCMusketeerGrenadierHitpointsBritishTeam);
			arrayPushInt(gCardList, cTechHCMusketeerGrenadierDamageBritish);
			arrayPushInt(gCardList, cTechHCImprovedLongbows);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechHCXPShipRocketsRepeat);
			arrayPushInt(gCardList, cTechHCShipFalconets3);
			arrayPushInt(gCardList, cTechHCShipMusketeers4);
			arrayPushInt(gCardList, cTechHCShipMusketeers1);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipRocketsRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipMusketeers4);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipMusketeers1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivFrench:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCRobberBarons);
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechHCShipCoureurs3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipCoureurs2);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCXPEconomicTheory);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCXPThoroughbreds);
			arrayPushInt(gCardList, cTechHCCavalryCombatFrench);
			arrayPushInt(gCardList, cTechHCRangedInfantryDamageFrenchTeam);
			arrayPushInt(gCardList, cTechHCRangedInfantryHitpointsFrench);
			arrayPushInt(gCardList, cTechHCWildernessWarfare);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechHCShipFalconets3);
			arrayPushInt(gCardList, cTechHCShipFalconets2);
			arrayPushInt(gCardList, cTechHCShipCuirassiers3);
			arrayPushInt(gCardList, cTechHCShipCrossbowmen1);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipCuirassiers3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipCrossbowmen1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivPortuguese:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCRobberBarons);
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechHCXPEconomicTheory);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCTeamWoodCrates);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCRoyalDecreePortuguese);
			arrayPushInt(gCardList, cTechHCRangedInfantryCombatPortuguese);
			arrayPushInt(gCardList, cTechHCXPGenitours);
			arrayPushInt(gCardList, cTechHCDragoonCombatPortuguese);
			arrayPushInt(gCardList, cTechHCRangedInfantryDamagePortuguese);
			arrayPushInt(gCardList, cTechHCRangedInfantryHitpointsPortugueseTeam);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechHCXPShipMusketeersRepeat);
			arrayPushInt(gCardList, cTechHCShipOrganGuns1);
			arrayPushInt(gCardList, cTechHCShipCacadores3);
			arrayPushInt(gCardList, cTechHCShipMusketeers1);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipMusketeersRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipOrganGuns1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipCacadores3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipMusketeers1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivDutch:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCRobberBarons);
			arrayPushInt(gCardList, cTechHCBetterBanks);
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechHCXPBankWagon);
			arrayPushInt(gCardList, cTechHCShipSettlers3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCRoyalDecreeDutch);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCBanks1);
			arrayPushInt(gCardList, cTechHCBanks2);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCCavalryCombatDutch);
			arrayPushInt(gCardList, cTechHCInfantryCombatDutch);
			arrayPushInt(gCardList, cTechHCInfantryHitpointsDutchTeam);
			arrayPushInt(gCardList, cTechHCXPMilitaryReforms);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechHCShipFalconets2);
			arrayPushInt(gCardList, cTechHCShipSkirmishers3);
			arrayPushInt(gCardList, cTechHCShipPikemen1);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipSkirmishers3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipPikemen1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivRussians:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCXPIndustrialRevolution);
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechHCXPDistributivism);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCXPEconomicTheory);
			arrayPushInt(gCardList, cTechHCRoyalDecreeRussian);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCDuelingSchoolTeam);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCRansack);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCUniqueCombatRussian);
			arrayPushInt(gCardList, cTechHCCavalryCombatRussian);
			arrayPushInt(gCardList, cTechHCStreletsCombatRussian);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechHCShipFalconets2);
			arrayPushInt(gCardList, cTechHCShipFalconets3);
			arrayPushInt(gCardList, cTechHCShipMusketeersRussian2);
			arrayPushInt(gCardList, cTechHCShipCossacks4);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipMusketeersRussian2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipCossacks4);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivGermans:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactoryGerman);
			arrayPushInt(gCardList, cTechHCRobberBaronsGerman);
			arrayPushInt(gCardList, cTechHCUnlockFortGerman);
			arrayPushInt(gCardList, cTechHCGuildArtisans);
			arrayPushInt(gCardList, cTechHCRefrigerationGerman);
			arrayPushInt(gCardList, cTechHCRoyalMintGerman);
			arrayPushInt(gCardList, cTechHCShipSettlerWagons3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3German);
			arrayPushInt(gCardList, cTechHCShipSettlerWagons4);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3German);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCGermantownFarmers);
			arrayPushInt(gCardList, cTechHCXPEconomicTheory);
			arrayPushInt(gCardList, cTechHCImprovedBuildingsGerman);
			arrayPushInt(gCardList, cTechHCFencingSchoolGerman);
			arrayPushInt(gCardList, cTechHCRidingSchoolGerman);
			arrayPushInt(gCardList, cTechHCAdvancedArsenalGerman);
			arrayPushInt(gCardList, cTechHCRoyalDecreeGerman);
			arrayPushInt(gCardList, cTechHCCavalryCombatGerman);
			arrayPushInt(gCardList, cTechHCUhlanCombatGerman);
			arrayPushInt(gCardList, cTechHCRangedInfantryHitpointsGerman);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechHCXPShipCannonsRepeat);
			arrayPushInt(gCardList, cTechHCShipSkirmishers3German);
			arrayPushInt(gCardList, cTechHCShipUhlans1);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCXPShipCannonsRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipSkirmishers3German);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipUhlans1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildingsGerman);
			break;
		}
		case cCivOttomans:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCRobberBarons);
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechHCShipSettlers3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipSettlers4);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCXPEconomicTheory);
			arrayPushInt(gCardList, cTechHCRoyalDecreeOttoman);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCJanissaryCost);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCEngineeringSchool);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCJanissaryCombatOttoman);
			arrayPushInt(gCardList, cTechHCCavalryCombatOttoman);
			arrayPushInt(gCardList, cTechHCShipJanissaries1);
			arrayPushInt(gCardList, cTechHCShipGreatBombards1);
			arrayPushInt(gCardList, cTechHCShipSpahis3);
			arrayPushInt(gCardList, cTechHCShipFalconets3);
			arrayPushInt(gCardList, cTechHCShipSpahis2);
			arrayPushInt(gCardList, cTechHCColonialMilitia);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipGreatBombards1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipSpahis3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipSpahis2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivDESwedish:
		{	// Cards
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechHCXPIndustrialRevolution);
			arrayPushInt(gCardList, cTechDEHCKalmarCastle);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechDEHCBlackberries);
			arrayPushInt(gCardList, cTechHCShipSettlers3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechDEHCDominions);
			arrayPushInt(gCardList, cTechDEHCEngelsbergIronworks);
			arrayPushInt(gCardList, cTechDEHCBlueberries);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechDEHCSveaLifeguard);
			arrayPushInt(gCardList, cTechDEHCPlatoonFire);
			arrayPushInt(gCardList, cTechDEHCSnaplocks);
			arrayPushInt(gCardList, cTechDEHCHeavyInfHitpointsTeam);
			arrayPushInt(gCardList, cTechHCColonialMilitia);
			arrayPushInt(gCardList, cTechDEHCShipCaroleansRepeat);
			arrayPushInt(gCardList, cTechHCShipFalconets3);
			arrayPushInt(gCardList, cTechDEHCShipCaroleans2);
			arrayPushInt(gCardList, cTechHCShipPikemen1);

			arrayPushInt(gMilitaryDefensiveCards, cTechHCColonialMilitia);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipCaroleansRepeat);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipCaroleans2);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipPikemen1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		// For Americans and Mexicans, include some Federal Cards for priority reasons,
		// but they won't be added to the deck when gCardList is called because they are not
		// standard cards, but gained through age-ups.
		case cCivDEAmericans:
		{	// Cards
			arrayPushInt(gCardList, cTechDEHCFedNewHampshireManufacturing); // Federal Card
			arrayPushInt(gCardList, cTechDEHCFedVermontCoppers); // Federal Card)
			arrayPushInt(gCardList, cTechDEHCFedAlamo); // Federal Card
			arrayPushInt(gCardList, cTechHCUnlockFort);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCTextileMills);
			arrayPushInt(gCardList, cTechDEHCImmigrantsIrish);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechDEHCImmigrantsFrench);
			arrayPushInt(gCardList, cTechDEHCFedPlymouthSettlers); // Federal Card
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechDEHCImmigrantsDutch);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechDEHCSpringfieldArmory);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechDEHCTrainTimeUS);
			arrayPushInt(gCardList, cTechDEHCLongRifles);
			arrayPushInt(gCardList, cTechDEHCRegularCombat);
			arrayPushInt(gCardList, cTechDEHCContinentalRangers);
			arrayPushInt(gCardList, cTechDEHCBuffaloSoldiers);
			arrayPushInt(gCardList, cTechDEHCCoffeeMillGun);
			arrayPushInt(gCardList, cTechDEHCUSMarines);
			arrayPushInt(gCardList, cTechHCShipCannons1);
			arrayPushInt(gCardList, cTechDEHCShipStateMilitia2);
			arrayPushInt(gCardList, cTechDEHCShipStateMilitia1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCUSMarines);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipCannons1);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipStateMilitia2);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipStateMilitia1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivDEMexicans:
		{	// Cards
			arrayPushInt(gCardList, cTechDEHCPorfiriato);
			arrayPushInt(gCardList, cTechHCUnlockFactory);
			arrayPushInt(gCardList, cTechDEHCFedMXElBajio); // Federal Card
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechDEHCMexicanMint);
			arrayPushInt(gCardList, cTechDEHCFedMXTonalaCeramics); // Federal Card
			arrayPushInt(gCardList, cTechDEHCFedMXOurLadyOfLight); // Federal Card
			arrayPushInt(gCardList, cTechDEHCAlhondigaDeGranaditas);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipSettlers2);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechDEHCIturbidePalace);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechDEHCPresidialLancers);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechDEHCLiberationMarch);
			arrayPushInt(gCardList, cTechHCAdvancedArsenal);
			arrayPushInt(gCardList, cTechHCCaballeros);
			arrayPushInt(gCardList, cTechHCDuelingSchoolTeam);
			arrayPushInt(gCardList, cTechDEHCObservers);
			arrayPushInt(gCardList, cTechDEHCCavalryCombatMexican);
			arrayPushInt(gCardList, cTechHCShipFalconets3);
			arrayPushInt(gCardList, cTechDEHCShipSoldado1);
			arrayPushInt(gCardList, cTechDEHCShipInsurgente1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCIturbidePalace);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCShipFalconets3);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipSoldado1);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipInsurgente1);
			arrayPushInt(gMilitaryDefensiveCards, cTechHCImprovedBuildings);
			break;
		}
		case cCivXPIroquois:
		{	// Cards
			arrayPushInt(gCardList, cTechHCXPShipVillagers3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates2);
			arrayPushInt(gCardList, cTechHCXPShipVillagers4);
			arrayPushInt(gCardList, cTechHCShipCoinCrates2);
			arrayPushInt(gCardList, cTechHCXPTownDance);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCSustainableAgriculture);
			arrayPushInt(gCardList, cTechHCRumDistillery);
			arrayPushInt(gCardList, cTechHCXPNewWaysIroquois);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCXPInfantryCombatIroquois);
			arrayPushInt(gCardList, cTechHCXPWarHutTrainingIroquois);
			arrayPushInt(gCardList, cTechHCXPInfantryLOSTeam);
			arrayPushInt(gCardList, cTechHCXPWarChiefIroquois1);
			arrayPushInt(gCardList, cTechHCXPWarChiefIroquois2);
			arrayPushInt(gCardList, cTechHCXPSiegeDiscipline);
			arrayPushInt(gCardList, cTechHCEngineeringSchool);
			arrayPushInt(gCardList, cTechHCXPSiegeCombat);
			arrayPushInt(gCardList, cTechHCXPConservativeTactics);
			arrayPushInt(gCardList, cTechHCXPShipMixedCratesRepeat);
			arrayPushInt(gCardList, cTechHCXPShipLightCannon2);
			arrayPushInt(gCardList, cTechHCXPShipMantletsRepeat);
			arrayPushInt(gCardList, cTechHCXPFrenchAllies1);
			arrayPushInt(gCardList, cTechHCXPShipMusketWarriors3);
			arrayPushInt(gCardList, cTechHCXPShipTomahawk1);

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
			arrayPushInt(gCardList, cTechHCXPCommandSkill);
			arrayPushInt(gCardList, cTechHCXPAdoption);
			arrayPushInt(gCardList, cTechHCXPShipVillagers2);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCXPShipVillagers4);
			arrayPushInt(gCardList, cTechHCXPGreatHunter);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechHCXPTownDance);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCFoodSilos);
			arrayPushInt(gCardList, cTechHCXPNewWaysSioux);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCRidingSchool);
			arrayPushInt(gCardList, cTechHCXPFriendlyTerritory);
			arrayPushInt(gCardList, cTechHCXPNomadicExpansion);
			arrayPushInt(gCardList, cTechHCXPMustangs);
			arrayPushInt(gCardList, cTechHCXPWindRunner);
			arrayPushInt(gCardList, cTechHCXPCavalryCombatSioux);
			arrayPushInt(gCardList, cTechHCXPSiouxTwoKettleSupport);
			arrayPushInt(gCardList, cTechHCXPSiouxSanteeSupport);
			arrayPushInt(gCardList, cTechHCXPOnikare);
			arrayPushInt(gCardList, cTechHCXPBuffalo2);
			arrayPushInt(gCardList, cTechHCXPShipAxeRidersRepeat);
			arrayPushInt(gCardList, cTechHCXPShipWarRifles1);
			arrayPushInt(gCardList, cTechHCXPShipAxeRiders3);

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
			arrayPushInt(gCardList, cTechHCXPChinampa2);
			arrayPushInt(gCardList, cTechHCXPTempleXolotl);
			arrayPushInt(gCardList, cTechHCXPAztecMining);
			arrayPushInt(gCardList, cTechHCXPShipVillagers3);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCXPShipMedicineMen2Aztec);
			arrayPushInt(gCardList, cTechHCXPShipVillagers4);
			arrayPushInt(gCardList, cTechHCXPCoinCratesAztec3);
			arrayPushInt(gCardList, cTechHCXPTownDance);
			arrayPushInt(gCardList, cTechHCXPLandGrab);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechHCFencingSchool);
			arrayPushInt(gCardList, cTechHCXPWarHutTraining);
			arrayPushInt(gCardList, cTechHCXPScorchedEarth);
			arrayPushInt(gCardList, cTechHCXPChinampa1);
			arrayPushInt(gCardList, cTechHCXPTempleCenteotl);
			arrayPushInt(gCardList, cTechHCXPTempleXipeTotec);
			arrayPushInt(gCardList, cTechHCXPTempleTlaloc);
			arrayPushInt(gCardList, cTechHCXPKnightCombat);
			arrayPushInt(gCardList, cTechHCXPCoyoteCombat);
			arrayPushInt(gCardList, cTechHCGrainMarket);
			arrayPushInt(gCardList, cTechHCFoodSilos);
			arrayPushInt(gCardList, cTechHCXPExtensiveFortificationsAztec);
			arrayPushInt(gCardList, cTechHCXPShipMacehualtinsRepeat);
			arrayPushInt(gCardList, cTechHCXPShipMacehualtins3);

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
			arrayPushInt(gCardList, cTechDEHCTerraceFarming);
			arrayPushInt(gCardList, cTechDEHCChichaBrewing);
			arrayPushInt(gCardList, cTechDEHCMachuPicchu);
			arrayPushInt(gCardList, cTechDEHCHuankaSupport);
			arrayPushInt(gCardList, cTechDEHCIncaFortifications);
			arrayPushInt(gCardList, cTechHCXPShipVillagers3);
			arrayPushInt(gCardList, cTechDEHCShipWoodCratesInfInca);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechDEHCMonumentalArchitecture);
			arrayPushInt(gCardList, cTechDEHCChasquisMessengers);
			arrayPushInt(gCardList, cTechDEHCRoadBuilding);
			arrayPushInt(gCardList, cTechDEHCCurare);
			arrayPushInt(gCardList, cTechYPHCImprovedBuildingsTeam);
			arrayPushInt(gCardList, cTechHCFoodSilos);
			arrayPushInt(gCardList, cTechDEHCMeleeInfCombatInca);
			arrayPushInt(gCardList, cTechDEHCIncaBridgesTeam);
			arrayPushInt(gCardList, cTechDEHCRangedInfDamageInca);
			arrayPushInt(gCardList, cTechDEHCRangedInfHitpointsInca);
			arrayPushInt(gCardList, cTechDEHCWarChiefInca2);
			arrayPushInt(gCardList, cTechDEHCWarChiefInca1);
			arrayPushInt(gCardList, cTechDEHCCollaSupport);
			arrayPushInt(gCardList, cTechDEHCCajamarcaSupport);
			arrayPushInt(gCardList, cTechDEHCChimuSupport);
			arrayPushInt(gCardList, cTechDEHCShipJungleBowmenRepeat);
			arrayPushInt(gCardList, cTechDEHCShipJungleBowmen1);

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
			arrayPushInt(gCardList, cTechYPHCIncreasedTribute);
			arrayPushInt(gCardList, cTechYPHCCheapUnitUpgradesTeam);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechypHCShipWoodCrates2);
			arrayPushInt(gCardList, cTechYPHCShipSettlersAsian2);
			arrayPushInt(gCardList, cTechypHCShipCoinCrates2);
			arrayPushInt(gCardList, cTechYPHCAdvancedConsulate);
			arrayPushInt(gCardList, cTechYPHCAdvancedRicePaddy);
			arrayPushInt(gCardList, cTechYPHCShipBerryWagon2);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechYPHCBakufu);
			arrayPushInt(gCardList, cTechYPHCJapaneseSiege);
			arrayPushInt(gCardList, cTechYPHCAshigaruAntiCavalryDamage);
			arrayPushInt(gCardList, cTechYPHCArtilleryCostJapanese);
			arrayPushInt(gCardList, cTechYPHCNaginataAntiInfantryDamage);
			arrayPushInt(gCardList, cTechYPHCYumiRange);
			arrayPushInt(gCardList, cTechYPHCArtilleryHitpointsJapanese);
			arrayPushInt(gCardList, cTechYPHCSmoothRelations); // Probably removable.
			arrayPushInt(gCardList, cTechYPHCEnlistIrregulars);
			arrayPushInt(gCardList, cTechYPHCShipFlamingArrow3);
			arrayPushInt(gCardList, cTechYPHCShipNaginataRider1);
			arrayPushInt(gCardList, cTechYPHCShipFlamingArrow1);
			arrayPushInt(gCardList, cTechYPHCShipAshigaru4);
			arrayPushInt(gCardList, cTechYPHCShipAshigaru2);

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
			arrayPushInt(gCardList, cTechYPHCConfusciousGift);
			arrayPushInt(gCardList, cTechHCRefrigeration);
			arrayPushInt(gCardList, cTechHCRoyalMint);
			arrayPushInt(gCardList, cTechYPHCSpawnRefugees1);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechYPHCAdvancedConsulate);
			arrayPushInt(gCardList, cTechYPHCAdvancedRicePaddy);
			arrayPushInt(gCardList, cTechHCImprovedBuildings);
			arrayPushInt(gCardList, cTechYPHCBannerSchool);
			arrayPushInt(gCardList, cTechYPHCAccupuncture);
			arrayPushInt(gCardList, cTechYPHCOldHanArmyReforms);
			arrayPushInt(gCardList, cTechYPHCHanAntiCavalryBonus);
			arrayPushInt(gCardList, cTechYPHCWesternReforms);
			arrayPushInt(gCardList, cTechYPHCTerritorialArmyCombat);
			arrayPushInt(gCardList, cTechYPHCEngineeringSchoolTeam);
			arrayPushInt(gCardList, cTechYPHCArtilleryCombatChinese);
			arrayPushInt(gCardList, cTechYPHCSmoothRelations); // Probably removable.
			arrayPushInt(gCardList, cTechYPHCAdvancedIrregulars);
			arrayPushInt(gCardList, cTechYPHCVillageShooty);
			arrayPushInt(gCardList, cTechYPHCShipFlyingCrow2);
			arrayPushInt(gCardList, cTechYPHCShipArquebusier1);
			arrayPushInt(gCardList, cTechYPHCShipChangdao2);
			arrayPushInt(gCardList, cTechYPHCShipChuKoNu2);
			arrayPushInt(gCardList, cTechYPHCShipChuKoNu1);

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
			arrayPushInt(gCardList, cTechYPHCRoyalMintIndians);
			arrayPushInt(gCardList, cTechYPHCGurkhaAid);
			arrayPushInt(gCardList, cTechYPHCAgrarianism);
			arrayPushInt(gCardList, cTechYPHCForeignLogging);
			arrayPushInt(gCardList, cTechYPHCShipWoodCrates2Indians);
			arrayPushInt(gCardList, cTechYPHCShipCoinCrates2Indians);
			arrayPushInt(gCardList, cTechYPHCAdvancedConsulateIndians);
			arrayPushInt(gCardList, cTechYPHCAdvancedRicePaddyIndians);
			arrayPushInt(gCardList, cTechYPHCGoraksha);
			arrayPushInt(gCardList, cTechYPHCImprovedBuildingsTeam);
			arrayPushInt(gCardList, cTechYPHCFencingSchoolIndians);
			arrayPushInt(gCardList, cTechYPHCRidingSchoolIndians);
			arrayPushInt(gCardList, cTechYPHCSustainableAgricultureIndians);
			arrayPushInt(gCardList, cTechYPHCInfantrySpeedHitpointsTeam);
			arrayPushInt(gCardList, cTechYPHCEastIndiaCompany);
			arrayPushInt(gCardList, cTechYPHCCamelDamageIndians);
			arrayPushInt(gCardList, cTechYPHCCamelFrightening);
			arrayPushInt(gCardList, cTechYPHCIndianMonkFrighten);
			arrayPushInt(gCardList, cTechYPHCSmoothRelationsIndians);
			arrayPushInt(gCardList, cTechYPHCEnlistIrregularsIndians);
			arrayPushInt(gCardList, cTechYPHCShipUrumiRegiment);
			arrayPushInt(gCardList, cTechYPHCShipUrumi2);
			arrayPushInt(gCardList, cTechYPHCShipSepoy3);
			arrayPushInt(gCardList, cTechYPHCShipUrumi1);
			arrayPushInt(gCardList, cTechYPHCShipSepoy1);

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
			arrayPushInt(gCardList, cTechDEHCAdvancedLivestockMarket);
			arrayPushInt(gCardList, cTechDEHCRoofAfrica);
			arrayPushInt(gCardList, cTechDEHCIyasuReforms);
			arrayPushInt(gCardList, cTechDEHCShipVillagersAbunRepeat);
			arrayPushInt(gCardList, cTechDEHCFasilidesCastle);
			arrayPushInt(gCardList, cTechDEHCJesuitInfluence);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechDEHCLalibelaRockChurch);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechDEHCHeyWat);
			arrayPushInt(gCardList, cTechDEHCAdvancedAgriculture);
			arrayPushInt(gCardList, cTechDEHCBeekeepers);
			arrayPushInt(gCardList, cTechDEHCFazogli);
			arrayPushInt(gCardList, cTechDEHCFasterTrainingUnitsAfrican);
			arrayPushInt(gCardList, cTechDEHCJesuitSpirituality);
			arrayPushInt(gCardList, cTechDEHCCoffeeConsumption);
			arrayPushInt(gCardList, cTechDEHCZebenyas);
			arrayPushInt(gCardList, cTechDEHCTigrayMekonnen);
			arrayPushInt(gCardList, cTechDEHCCartridgeCurrency);
			arrayPushInt(gCardList, cTechDEHCChewaWarriors);
			arrayPushInt(gCardList, cTechDEHCShewaRiders);
			arrayPushInt(gCardList, cTechDEHCMassLeviesAfrican);
			arrayPushInt(gCardList, cTechDEHCShipSebastopolMortar1);
			arrayPushInt(gCardList, cTechDEHCShipNeftenya1);
			arrayPushInt(gCardList, cTechDEHCShipGascenya1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCMassLeviesAfrican);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipSebastopolMortar1);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipNeftenya1);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipGascenya1);
			break;
		}
		case cCivDEHausa:
		{	// Cards
			arrayPushInt(gCardList, cTechDEHCAdvancedLivestockMarket);
			arrayPushInt(gCardList, cTechDEHCKolaNutCultivation);
			arrayPushInt(gCardList, cTechDEHCMassinaMadrasahs);
			arrayPushInt(gCardList, cTechDEHCShipVillagers1Repeat);
			arrayPushInt(gCardList, cTechDEHCPalaceAmina);
			arrayPushInt(gCardList, cTechHCShipWoodCrates3);
			arrayPushInt(gCardList, cTechDEHCShipVillagers2);
			arrayPushInt(gCardList, cTechHCShipCoinCrates3);
			arrayPushInt(gCardList, cTechDEHCGobarauMinaret);
			arrayPushInt(gCardList, cTechDEHCAdvancedAgriculture);
			arrayPushInt(gCardList, cTechDEHCFasterTrainingUnitsAfrican);
			arrayPushInt(gCardList, cTechDEHCFodioTactics);
			arrayPushInt(gCardList, cTechDEHCDaneGuns);
			arrayPushInt(gCardList, cTechDEHCSarkinDogarai);
			arrayPushInt(gCardList, cTechDEHCDurbarParade);
			arrayPushInt(gCardList, cTechDEHCFulaniArcherCombat);
			arrayPushInt(gCardList, cTechDEHCCounterCavalry);
			arrayPushInt(gCardList, cTechDEHCHandCavalryHitpointsHausa);
			arrayPushInt(gCardList, cTechDEHCRanoIndigoProduction);
			arrayPushInt(gCardList, cTechDEHCFulaniCattleFertilizer);
			arrayPushInt(gCardList, cTechDEHCKoose);
			arrayPushInt(gCardList, cTechDEHCMassLeviesAfrican);
			arrayPushInt(gCardList, cTechDEHCShipJavelinRiders2);
			arrayPushInt(gCardList, cTechDEHCShipFulaWarriors2);
			arrayPushInt(gCardList, cTechDEHCShipFulaWarriors1);

			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCMassLeviesAfrican);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipJavelinRiders2);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipFulaWarriors2);
			arrayPushInt(gMilitaryDefensiveCards, cTechDEHCShipFulaWarriors1);
			break;
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


int getCardIndexFromDeck(int cardTechID = -1)
{
	int deckID = -1;
	if (getCardExtended(cardTechID) == false) deckID = gDefaultDeck;
	else deckID = aiHCGetExtendedDeck();
	for (i = 0; < aiHCDeckGetNumberCards(deckID))
		if (cardTechID == aiHCDeckGetCardTechID(deckID, i))
			return(i);
	return(-1);
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


rule updateNextShipmentTechID
inactive
minInterval 20
{
	int cardTechID = -1; // Signifies the card tech ID, for instance: "cTechHCUnlockFactory"
	int cardIndex = -1; // Signifies the card tech ID's index within the given deck, such as 0, 1...
	int deckID = -1; // The deck ID should be gDefaultDeck, otherwise for Americans and Mexicans,
					 // it should be aiHCGetExtendedDeck().
	int ageReq = -1; // Signifies the necessary age needed to send the card.
	int flags = -1; // Signifies certain tags associated with this card; can be multiple.
	bool extended = false; // Relevant for identifying which deck ID we should use.
	int unitType = -1;
	string techName = "";

	if (arrayGetSize(gPriorityCards) > 0)
	{
		for (i = 0; < arrayGetSize(gPriorityCards))
		{
			cardTechID = arrayGetInt(gPriorityCards, i);
			cardIndex = getCardIndexFromDeck(cardTechID);
			extended = getCardExtended(cardTechID);
			techName = kbGetTechName(cardTechID);
			if (extended == false) deckID = gDefaultDeck;
			else deckID = aiHCGetExtendedDeck();
			ageReq = aiHCDeckGetCardAgePrereq(deckID, cardIndex);

			// This should eliminate trying to send repeat cards,
			// except Japan which has many that can be sent twice,
			// as well as Imperial Age-up unlocking cards again.
			if (cardIndex < 0)
				continue;
			if (getCardSent(cardTechID))
				continue;
			if (getCardAffordable(cardTechID) == false)
				continue;
			if (ageReq > kbGetAge())
			{
				// Check to see if we are aging up and can send this next-in-priority card
				// in the next age.
				if (agingUp() && ageReq == getAgingUpAge())
					return;
				// Not in the next age either, so skip it for now.
				else continue;
			}

			gNextShipmentTechID = cardTechID;
			return;
		}
	}

	if (aiGetWorldDifficulty() >= cDifficultyHard && kbGetAge() == cAge1 &&
		arrayGetSize(gSentCardList) > 0)
	{
		gNextShipmentTechID = -1;
		return;
	}

	if (getHomeBaseThreatened() == true)
	{
		for (i = 0; < arrayGetSize(gMilitaryDefensiveCards))
		{
			cardTechID = arrayGetInt(gMilitaryDefensiveCards, i);
			cardIndex = getCardIndexFromDeck(cardTechID);
			extended = getCardExtended(cardTechID);
			if (extended == false) deckID = gDefaultDeck;
			else deckID = aiHCGetExtendedDeck();
			ageReq = aiHCDeckGetCardAgePrereq(deckID, cardIndex);
			flags = aiHCDeckGetCardFlags(deckID, cardIndex);
			unitType = aiHCDeckGetCardUnitType(deckID, cardIndex);
			techName = kbGetTechName(cardTechID);

			if (cardIndex < 0)
				continue;
			if (ageReq > kbGetAge())
				continue;
			// Infinite Military Cards should still be considered.
			if (getCardSent(cardTechID) && aiHCDeckGetCardCount(deckID, cardIndex) >= 0)
				continue;
			if (getCardAffordable(cardTechID) == false)
				continue;

			// For most civs, do not worry about Colonial Militia or some equivalent past a certain point.
			// But Marines for Americans and Iturbide Palce for Mexicans is always helpful so do send it.
			if (cardTechID == gColonialMilitiaCard && cardTechID != cTechDEHCUSMarines &&
				cardTechID != cTechDEHCIturbidePalace && kbGetAge() > ageReq + 1)
				continue;

			// For standard military shipment cards, ignore sending them if they are not of the current age.
			/* bool isMilitaryUnit = (((flags & cHCCardFlagMilitary) == cHCCardFlagMilitary) &&
				((flags & cHCCardFlagUnit) == cHCCardFlagUnit) && ((flags & cHCCardFlagWater) == 0) ||
				kbProtoUnitIsType(cMyID, unitType, cUnitTypeLogicalTypeLandMilitary)); */
			if (((flags & cHCCardFlagMilitary) == cHCCardFlagMilitary) &&
				((flags & cHCCardFlagUnit) == cHCCardFlagUnit) && ((flags & cHCCardFlagWater) == 0) ||
				kbProtoUnitIsType(cMyID, unitType, cUnitTypeLogicalTypeLandMilitary))
			{	// Unless the card is age 4 military card while we are Age4+, ignore it.
				if (kbGetAge() > ageReq && ageReq < cAge4)
					continue;
			}

			gNextShipmentTechID = cardTechID;
			// echoMessage("defensive card ready to send: " + kbGetTechName(cardTechID));
			return;
		}
	}

	for (i = 0; < arrayGetSize(gCardList))
	{
		cardTechID = arrayGetInt(gCardList, i);
		cardIndex = getCardIndexFromDeck(cardTechID);
		extended = getCardExtended(cardTechID);
		if (extended == false) deckID = gDefaultDeck;
		else deckID = aiHCGetExtendedDeck();
		ageReq = aiHCDeckGetCardAgePrereq(deckID, cardIndex);
		flags = aiHCDeckGetCardFlags(deckID, cardIndex);
		techName = kbGetTechName(cardTechID);
		if (cardIndex < 0)
			continue;
		if (getCardSent(cardTechID))
			continue;
		if (getCardAffordable(cardTechID) == false)
			continue;
		if (ageReq > kbGetAge())
		{
			// Check to see if we are aging up and can send this next-in-priority card
			// in the next age.
			if (agingUp() && ageReq == getAgingUpAge())
				return;
			// Not in the next age either, so skip it for now.
			else continue;
		}
		
		// Check for obsolete Vill/Crate cards that would be better to pass over in higher
		// ages, but are listed before other cards in gCardList.
		if (ageReq >= 0) // Not Federal Cards
		{
			if (((flags & cHCCardFlagVillager) == cHCCardFlagVillager && cardTechID != cTechDEHCImmigrantsIrish) ||
				(flags & cHCCardFlagResourceCrate) == cHCCardFlagResourceCrate)
			{
				if (kbGetAge() > ageReq)
				{	// Act as though we have sent it, so that we ignore it.
					arrayPushInt(gSentCardList, cardTechID);
					continue;
				}
			}
		}
		gNextShipmentTechID = cardTechID;
		return;
	}
}


void shipGrantedHandler(int parm = -1) // Event handler
{
	if (kbResourceGet(cResourceShips) < 1.0)
		return;

	bool extended = false;
	bool insufficientResources = false;
	int cardIndex = -1;
	if (gNextShipmentTechID >= 0)
	{
		extended = getCardExtended(gNextShipmentTechID);
		cardIndex = getCardIndexFromDeck(gNextShipmentTechID);
		if (kbTechCostPerResource(gNextShipmentTechID, cResourceFood) > kbResourceGet(cResourceFood))
			insufficientResources = true;
		if (kbTechCostPerResource(gNextShipmentTechID, cResourceWood) > kbResourceGet(cResourceWood))
			insufficientResources = true;
		if (kbTechCostPerResource(gNextShipmentTechID, cResourceGold) > kbResourceGet(cResourceGold))
			insufficientResources = true;
		// Influence shipments? Perhaps need to be added too.
		if (aiHCDeckPlayCard(cardIndex, extended) && insufficientResources == false)
		{
			echoMessage("Success: Card " + kbGetTechName(gNextShipmentTechID));
			arrayPushInt(gSentCardList, gNextShipmentTechID);
			updateNextShipmentTechID();
			updateResourceDistribution();
		}
		// else
		// 	echoMessage("Failed: Card " + kbGetTechName(gNextShipmentTechID));
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