Scriptname AATransmutationManager Extends Quest

Import AATransmutationUtilities
Import PO3_SKSEFunctions

ReferenceAlias Property AACurrentTransmutationResult Auto
ReferenceAlias Property AATransmutationButton Auto
ReferenceAlias Property AATransmutationHoldingChest Auto
ReferenceAlias Property AATransmutationResultChest Auto
ReferenceAlias Property AATransmutationStatsChest Auto
ReferenceAlias Property AATransmutationVisualChest Auto
ReferenceAlias Property PlayerRef Auto

; Armor arrays: Relationally linked by index
ReferenceAlias[] Property AATransmutationResultArmors Auto ; Key Array
ReferenceAlias[] Property AATransmutationStatsArmors Auto
ReferenceAlias[] Property AATransmutationVisualArmors Auto

; Weapon arrays: Relationally linked by index
Keyword[] Property WeapTypeKeywords Auto
ReferenceAlias[] Property AATransmutationResultWeapons Auto ; Key Array
ReferenceAlias[] Property AATransmutationStatsWeapons Auto
ReferenceAlias[] Property AATransmutationVisualWeapons Auto

; Arrays used to determine armor type: Relationally linked by index
Int[] Property ResultArmorRelationalArraySlotMasks Auto
Keyword[] Property ResultArmorRelationalArrayKeywords Auto
ReferenceAlias[] Property ResultArmorRelationalArrayArmors Auto ; Key Array

;/ Called when the game is loaded,
refreshes transmutations as settings are not persistant across sessions /;
Function OnLoadTransmute()
	Actor player = PlayerRef.GetReference() as Actor

	Int i = 0
	While i < AATransmutationResultWeapons.Length
		If (AATransmutationStatsWeapons[i].GetReference() != None)\
		&& (AATransmutationVisualWeapons[i].GetReference() != None)
			Debug.Trace(\
				"AADebug OnLoadTransmute(): Refreshing transmutation of Weapon "\
				+ AATransmutationResultWeapons[i].GetReference().GetBaseObject().GetFormID()\
			)

			Weapon result = AATransmutationResultWeapons[i]\
				.GetReference()\
				.GetBaseObject() as Weapon

			ApplyWeaponTransmutation(\
				AATransmutationStatsWeapons[i].GetReference().GetBaseObject() as Weapon,\
				AATransmutationVisualWeapons[i].GetReference().GetBaseObject() as Weapon,\
				result\
			)

			If player.IsWeaponDrawn() \
			&& (\
				(player.GetEquippedWeapon(True) == result)\
				|| (player.GetEquippedWeapon(False) == result)\
			)
				Debug.Trace(\
					"AADebug OnLoadTransmute(): Detected drawn transmutation weapon"\
					+ " on game load. Forcing the player to re-draw it."\
				)
				player.SheatheWeapon()
				player.DrawWeapon()
			EndIf
		Endif

		i += 1
	EndWhile

	i = 0
	While i < AATransmutationResultArmors.Length
		If (AATransmutationStatsArmors[i].GetReference() != None)\
		&& (AATransmutationVisualArmors[i].GetReference() != None)
			Debug.Trace(\
				"AADebug OnLoadTransmute(): Refreshing transmutation of Armor "\
				+ AATransmutationResultArmors[i].GetReference().GetBaseObject().GetFormID()\
			)

			Armor result = AATransmutationResultArmors[i]\
				.GetReference()\
				.GetBaseObject() as Armor

			ApplyArmorTransmutation(\
				AATransmutationStatsArmors[i].GetReference().GetBaseObject() as Armor,\
				AATransmutationVisualArmors[i].GetReference().GetBaseObject() as Armor,\
				result\
			)

			If player.IsEquipped(result)
				Debug.Trace("AADebug OnLoadTransmute(): Detected equipped transmutation"\
					+ " armor on game load. Forcing the player to re-equip it."\
				)
				player.UnequipItem(result, False, True)
				player.EquipItem(result, False, True)
			EndIf
		EndIf

		i += 1
	EndWhile
EndFunction

;/ Called when items are added or removed from the transmutation chests. Updates
;/ the valid transmutation result and notifies the AATransmutationButton of state
;/ changes. /;
Function UpdateTransmutationConditions()
	If ChestItemsMatches(1, 1, 0)
		Debug.Trace(\
			"AADebug UpdateTransmutationConditions(): Valid chest configuration 1,1,0"\
		)

		ReferenceAlias result = CalculateCurrentTransmutationResultIfAny()
		Debug.Trace(\
			"AADebug UpdateTransmutationConditions(): Calculated result "\
			+ result\
		)

		If result
			AACurrentTransmutationResult.ForceRefTo(result.GetReference())

			(AATransmutationButton as AATransmutationButtonManager).Open()
			Return
		EndIf

	ElseIf ChestItemsMatches(0, 0, 1)
		Debug.Trace("AADebug UpdateTransmutationConditions(): Valid chest configuration 0,0,1")
		Form resultForm = AATransmutationResultChest.GetReference().GetNthForm(0)

		ReferenceAlias result

		If resultForm.GetType() == 41
			result = GetAliasInArrayFromFormIfExists(\
				AATransmutationResultWeapons,\
				resultForm.GetFormID()\
			)
			Debug.Trace(\
				"AADebug UpdateTransmutationConditions(): Calculated result "\
				+ result\
			)
		ElseIf resultForm.GetType() == 26
			result = GetAliasInArrayFromFormIfExists(\
				AATransmutationResultArmors,\
				resultForm.GetFormID()\
			)
			Debug.Trace(\
				"AADebug UpdateTransmutationConditions(): Calculated result "\
				+ result\
			)
		EndIf

		If result
			AACurrentTransmutationResult.ForceRefTo(result.GetReference())

			(AATransmutationButton as AATransmutationButtonManager).Open()
			Return
		EndIf
	EndIf

	(AATransmutationButton as AATransmutationButtonManager).Close()
EndFunction

ReferenceAlias Function CalculateCurrentTransmutationResultIfAny()
	Form statsForm = AATransmutationStatsChest.GetReference().GetNthForm(0)
	Form visualForm = AATransmutationVisualChest.GetReference().GetNthForm(0)

	If (statsForm.GetType() == 41) && (visualForm.GetType() == 41)
		Debug.Trace(\
			"AADebug CalculateCurrentTransmutationResultIfAny(): "\
			+ "chest configuration 1,1,0 contains Weapons"\
		)

		If GetAliasInArrayFromFormIfExists(\
			AATransmutationResultWeapons,\
			statsForm.GetFormID()\
		) != None
			Debug.Trace(\
				"AADebug CalculateCurrentTransmutationresultIfAny(): "\
				+ "The weapon in statsChest is the result of a previous transmutation"\
			)

			Return None
		ElseIf GetAliasInArrayFromFormIfExists(\
			AATransmutationResultWeapons,\
			visualForm.GetFormID()\
		) != None
			Debug.Trace(\
				"AADebug CalculateCurrentTransmutationresultIfAny(): "\
				+ "The weapon in visualChest is the result of a previous transmutation"\
			)

			Return None
		EndIf

		Keyword resultKeyword = GetFirstCommonKeywordInArrayIfAny(\
			WeapTypeKeywords,\
			statsForm,\
			visualForm\
		)
		Debug.Trace(\
			"AADebug CalculateCurrentTransmutationResultIfAny(): Got resultKeyword "\
			+ resultKeyword\
		)

		If !resultKeyword
			Return None
		EndIf

		Return GetAliasInArrayFromKeywordAndWeaponTypeIfExists(\
			AATransmutationResultWeapons,\
			resultKeyword,\
			(statsForm as Weapon).GetWeaponType()\
		)
	ElseIf (statsForm.GetType() == 26) && (visualForm.GetType() == 26)
		Debug.Trace(\
			"AADebug CalculateCurrentTransmutationResultIfAny(): "\
			+ "chest configuration 1,1,0 contains Armor"\
		)

		If GetAliasInArrayFromFormIfExists(\
			AATransmutationResultArmors,\
			statsForm.GetFormID()\
		) != None
			Debug.Trace(\
				"AADebug CalculateCurrentTransmutationresultIfAny(): "\
				+ "The weapon in statsChest is the result of a previous transmutation"\
			)

			Return None
		ElseIf GetAliasInArrayFromFormIfExists(\
			AATransmutationResultArmors,\
			visualForm.GetFormID()\
		)
			Debug.Trace(\
				"AADebug CalculateCurrentTransmutationresultIfAny(): "\
				+ "The weapon in visualChest is the result of a previous transmutation"\
			) != None

			Return None
		EndIf

		Keyword resultKeyword = GetFirstCommonKeywordInArrayIfAny(\
			ResultArmorRelationalArrayKeywords,\
			statsForm,\
			visualForm\
		)
		Debug.Trace(\
			"AADebug CalculateCurrentTransmutationResultIfAny(): Got resultKeyword "\
			+ resultKeyword\
		)

		If !resultKeyword
			Return None
		EndIf

		Return GetAliasInArrayFromKeywordAndSlotMaskIfExists(\
			ResultArmorRelationalArrayArmors,\
			ResultArmorRelationalArraySlotMasks,\
			resultKeyword,\
			(statsForm as Armor).GetSlotMask()\
		)
	EndIf
EndFunction

; Determine which transmutation method to call.
Function PreTransmute()
	AATransmutationStatsChest.GetReference().BlockActivation(True)
	AATransmutationVisualChest.GetReference().BlockActivation(True)
	AATransmutationResultChest.GetReference().BlockActivation(True)

	If ChestItemsMatches(1, 1, 0)
		Debug.Trace(\
			"AADebug PreTransmute(): Valid chest configuration 1,1,0"\
		)

		If AACurrentTransmutationResult.GetReference().GetBaseObject().GetType() == 41
			Debug.Trace(\
				"AADebug PreTransmute(): chest configuration 1,1,0 contains Weapons"\
			)

			Transmute(\
				AACurrentTransmutationResult,\
				AATransmutationStatsWeapons,\
				AATransmutationVisualWeapons,\
				AATransmutationResultWeapons\
			)
		ElseIf AACurrentTransmutationResult.GetReference().GetBaseObject().GetType() == 26
			Debug.Trace(\
				"AADebug PreTransmute(): chest configuration 1,1,0 contains Armor"\
			)

			Transmute(\
				AACurrentTransmutationResult,\
				AATransmutationStatsArmors,\
				AATransmutationVisualArmors,\
				AATransmutationResultArmors\
			)
		Else
			Debug.Trace(\
				"AADebug PreTransmute(): Invalid transmutation result type "\
				+ AACurrentTransmutationResult.GetReference().GetBaseObject().GetType()\
			)
		EndIf
	ElseIf ChestItemsMatches(0, 0, 1)
		Debug.Trace(\
			"AADebug PreTransmute(): Valid chest configuration 0,0,1"\
		)

		Form resultForm = AACurrentTransmutationResult.GetReference().GetBaseObject()

		If (resultForm.GetType() == 41) || (resultForm.GetType() == 26)
			ReverseTransmutation(AACurrentTransmutationResult)
		Else
			Debug.Trace(\
				"AADebug PreTransmute(): Invalid transmutation result type "\
				+ AACurrentTransmutationResult.GetReference().GetBaseObject().GetType()\
			)
		EndIf
	Else
		Debug.Trace(\
			"AADebug PreTransmute(): Invalid chest configuration"\
		)
	EndIf

	AATransmutationStatsChest.GetReference().BlockActivation(False)
	AATransmutationVisualChest.GetReference().BlockActivation(False)
	AATransmutationResultChest.GetReference().BlockActivation(False)
EndFunction

;/ Checks that the number of items in each chest corresponds to the passed
;/ in integers /;
Bool Function ChestItemsMatches(Int statsChestItems, Int visualChestItems, Int resultChestItems)
	If (AATransmutationStatsChest.GetReference().GetNumItems() == statsChestItems)\
	&& (AATransmutationVisualChest.GetReference().GetNumItems() == visualChestItems)\
	&& (AATransmutationResultChest.GetReference().GetNumItems() == resultChestItems)
		Return True
	EndIf

	Return False
EndFunction

Function Transmute(ReferenceAlias result, ReferenceAlias[] targetStatsArray, ReferenceAlias[] targetVisualArray, ReferenceAlias[] targetResultArray)
	Debug.Trace(\
		"AADebug: Beginning Transmute(" + result + ", " + targetStatsArray\
		+ ", " + targetVisualArray + ", " + targetResultArray + ")"\
	)

	Int armorsArrayIndex = GetArrayIndexFromReferenceAliasIfExists(\
		targetResultArray,\
		result\
	)

	If armorsArrayIndex == -1
		Debug.Trace("AADebug: " + result + " invalid")
		Debug.Trace("AADebug: Ending Transmute(" + result + ")")

		Return
	EndIf

	FillAliasAndMove(\
		AATransmutationStatsChest,\
		targetStatsArray,\
		armorsArrayIndex\
	)
	FillAliasAndMove(\
		AATransmutationVisualChest,\
		targetVisualArray,\
		armorsArrayIndex\
	)

	ReferenceAlias stats = targetStatsArray[armorsArrayIndex]
	ReferenceAlias visual = targetVisualArray[armorsArrayIndex]

	If result.GetReference().GetBaseObject().GetType() == 41
		Weapon statsWeapon = stats.GetReference().GetBaseObject() as Weapon
		Weapon visualWeapon = visual.GetReference().GetBaseObject() as Weapon
		Weapon resultWeapon = result.GetReference().GetBaseObject() as Weapon

		ApplyWeaponTransmutation(statsWeapon, visualWeapon, resultWeapon)
	ElseIf result.GetReference().GetBaseObject().GetType() == 26
		Armor statsArmor = stats.GetReference().GetBaseObject() as Armor
		Armor visualArmor = visual.GetReference().GetBaseObject() as Armor
		Armor resultArmor = result.GetReference().GetBaseObject() as Armor

		ApplyArmorTransmutation(statsArmor, visualArmor, resultArmor)
	EndIf

	AATransmutationHoldingChest.GetReference().RemoveItem(\
		result.GetReference().GetBaseObject(),\
		1,\
		False,\
		AATransmutationResultChest.GetReference()\
	)

	Debug.Trace(\
		"AADebug: Ending Transmute(" + result + ", " + targetStatsArray\
		+ ", " + targetVisualArray + ", " + targetResultArray + ")"\
	)
EndFunction

;/ Gets the first form targetChest and uses it to populate the ReferenceAlias
;/ at targetIndex in targetArray. Then moves the ReferenceAlias into the
;/ AATransmutationHoldingChest. /;
Function FillAliasAndMove(ReferenceAlias targetChest, ReferenceAlias[] targetArray, Int targetIndex)
	ObjectReference target = targetChest.GetReference().DropObject(\
		targetChest.GetReference().GetNthForm(0)\
	)
	target.MoveTo(AATransmutationHoldingChest.GetReference())

	targetArray[targetIndex].ForceRefTo(target)

	AATransmutationHoldingChest.GetReference().AddItem(target)
EndFunction

Function ReverseTransmutation(ReferenceAlias result)
	Debug.Trace("AADebug: Beginning ReverseTransmutation(" + result + ")")

	Int resultArrayIndex = -1
	ReferenceAlias stats
	ReferenceAlias visual

	If result.GetReference().GetBaseObject().GetType() == 41
		resultArrayIndex = GetArrayIndexFromReferenceAliasIfExists(\
			AATransmutationResultWeapons,\
			result\
		)

		If resultArrayIndex == -1
			Debug.Trace("AADebug: " + result + " invalid")
			Debug.Trace("AADebug: Ending ReverseTransmutation(" + result + ")")

			Return
		EndIf

		Int numRemovedKeywords = RemoveAllKeywords(result.GetReference().GetBaseObject())
		Debug.Trace("AADebug : Removed " + numRemovedKeywords + " keywords")

		AddKeywordToForm(\
			result.GetReference().GetBaseObject(),\
			WeapTypeKeywords[resultArrayIndex]\
		)
		Debug.Trace(\
			"AADebug : Added keyword " + WeapTypeKeywords[resultArrayIndex]\
			+ " to " + result\
		)

		stats = AATransmutationStatsWeapons[resultArrayIndex]
		visual = AATransmutationVisualWeapons[resultArrayIndex]

		AATransmutationHoldingChest.GetReference().RemoveItem(\
			stats.GetReference().GetBaseObject(),\
			1,\
			False,\
			AATransmutationStatsChest.GetReference()\
		)
		AATransmutationHoldingChest.GetReference().RemoveItem(\
			visual.GetReference().GetBaseObject(),\
			1,\
			False,\
			AATransmutationVisualChest.GetReference()\
		)

		AATransmutationStatsWeapons[resultArrayIndex].Clear()
		AATransmutationVisualWeapons[resultArrayIndex].Clear()
	ElseIf result.GetReference().GetBaseObject().GetType() == 26
		resultArrayIndex = GetArrayIndexFromReferenceAliasIfExists(\
			AATransmutationResultArmors,\
			result\
		)

		If resultArrayIndex == -1
			Debug.Trace("AADebug: " + result + " invalid")
			Debug.Trace("AADebug: Ending ReverseTransmutation(" + result + ")")

			Return
		EndIf

		Int numRemovedKeywords = RemoveAllKeywords(result.GetReference().GetBaseObject())
		Debug.Trace("AADebug : Removed " + numRemovedKeywords + " keywords")

		Int i = 0
		While i < ResultArmorRelationalArrayArmors.Length
			If result.GetReference() == ResultArmorRelationalArrayArmors[i].GetReference()
				AddKeywordToForm(\
					result.GetReference().GetBaseObject(),\
					ResultArmorRelationalArrayKeywords[i]\
				)
				Debug.Trace(\
					"AADebug : Added keyword "\
					+ ResultArmorRelationalArrayKeywords[i] + " to " + result\
				)
			EndIf

			i += 1
		EndWhile

		stats = AATransmutationStatsArmors[resultArrayIndex]
		visual = AATransmutationVisualArmors[resultArrayIndex]

		AATransmutationHoldingChest.GetReference().RemoveItem(\
			stats.GetReference().GetBaseObject(),\
			1,\
			False,\
			AATransmutationStatsChest.GetReference()\
		)
		AATransmutationHoldingChest.GetReference().RemoveItem(\
			visual.GetReference().GetBaseObject(),\
			1,\
			False,\
			AATransmutationVisualChest.GetReference()\
		)

		AATransmutationStatsArmors[resultArrayIndex].Clear()
		AATransmutationVisualArmors[resultArrayIndex].Clear()

	EndIf

	AATransmutationResultChest.GetReference().RemoveItem(\
		result.GetReference().GetBaseObject(),\
		1,\
		False,\
		AATransmutationHoldingChest.GetReference()\
	)
EndFunction

Function ApplyArmorTransmutation(Armor statsArmor, Armor visualArmor, Armor resultArmor)
	Debug.TraceStack(\
		"AADebug: Beginning ApplyArmorTransmutation(" + statsArmor + ", "\
		+ visualArmor + ", " + resultArmor + ")"\
	)

	Debug.Trace("AADebug: Applying visual updates")
	resultArmor.SetModelPath(visualArmor.GetModelPath(False), False)
	resultArmor.SetModelPath(visualArmor.GetModelPath(True), True)
	resultArmor.SetSlotMask(visualArmor.GetSlotMask())

	Debug.Trace("AADebug: Applying stats updates")
	resultArmor.SetName(statsArmor.GetName())
	resultArmor.SetWeight(statsArmor.GetWeight())
	resultArmor.SetGoldValue(statsArmor.GetGoldValue())
	resultArmor.SetArmorRating(statsArmor.GetArmorRating())
	resultArmor.SetWeightClass(statsArmor.GetWeightClass())
	resultArmor.SetEnchantment(statsArmor.GetEnchantment())

	Debug.Trace("AADebug: Applying ArmorAddon visual updates")
	Int i = 0
	While i < 4
		ArmorAddon resultAddon = resultArmor.GetNthArmorAddon(i)

		Int numArmorAddons = visualArmor.GetNumArmorAddons()
		While numArmorAddons > 0
			ArmorAddon visualAddon = visualArmor.GetNthArmorAddon(numArmorAddons - 1)
			Debug.Trace("AADebug: statsAddon: " + visualAddon)

			Int resultRaces = resultAddon.GetNumAdditionalRaces()
			Int visualRaces = visualAddon.GetNumAdditionalRaces()
			If visualRaces > resultRaces

				While (resultRaces > 0) && (visualRaces > 0)
					If resultAddon.GetNthAdditionalRace(resultRaces - 1)\
					== visualAddon.GetNthAdditionalRace(visualRaces - 1)
						resultRaces -= 1
					EndIf

					visualRaces -= 1
				EndWhile

				If resultRaces == 0
					Debug.Trace(\
						"AADebug: Matched result ArmorAddon " + (i + 1)\
						+ " to visual ArmorAddon " + visualAddon\
					)

					resultAddon.SetModelPath(\
						visualAddon.GetModelPath(False, False),\
						False,\
						False\
					)
					resultAddon.SetModelPath(\
						visualAddon.GetModelPath(False, True),\
						False,\
						True\
					)
					resultAddon.SetModelPath(\
						visualAddon.GetModelPath(True, False),\
						True,\
						False\
					)
					resultAddon.SetModelPath(\
						visualAddon.GetModelPath(True, True),\
						True,\
						True\
					)

					resultAddon.SetSlotMask(visualAddon.GetSlotMask())
					SetFootstepSet(resultAddon, GetFootstepSet(visualAddon))
				EndIf
			EndIf

			numArmorAddons -= 1
		EndWhile

		i+= 1
	EndWhile

	Int numRemovedKeywords = RemoveAllKeywords(resultArmor)
	Debug.Trace("AADebug : Removed " + numRemovedKeywords + " keywords")

	Int numKeywords = statsArmor.GetNumKeywords()
	While numKeywords > 0
		Keyword currentKeyword = statsArmor.GetNthKeyword(numKeywords - 1)

		AddKeywordToForm(resultArmor, statsArmor.GetNthKeyword(numKeywords - 1))
		Debug.Trace(\
			"AADebug : Added keyword " + currentKeyword + " to " + resultArmor\
		)

		numKeywords -= 1
	EndWhile

	Debug.TraceStack(\
		"AADebug: Ending ApplyArmorTransmutation(" + statsArmor + ", "\
		+ visualArmor + ", " + resultArmor + ")"\
	)
EndFunction

Function ApplyWeaponTransmutation(Weapon statsWeapon, Weapon visualWeapon, Weapon resultWeapon)
	Debug.TraceStack(\
		"AADebug: Beginning ApplyWeaponTransmutation(" + statsWeapon + ", "\
		+ visualWeapon + ", " + resultWeapon + ")"\
	)

	Debug.Trace("AADebug: Applying visual updates")
	resultWeapon.SetModelPath(visualWeapon.GetModelPath())
	resultWeapon.SetEquippedModel(visualWeapon.GetEquippedModel())

	Debug.Trace("AADebug: Applying stats updates")
	resultWeapon.SetName(statsWeapon.GetName())
	resultWeapon.SetWeight(statsWeapon.GetWeight())
	resultWeapon.SetGoldValue(statsWeapon.GetGoldValue())
	resultWeapon.SetBaseDamage(statsWeapon.GetBaseDamage())
	resultWeapon.SetCritDamage(statsWeapon.GetCritDamage())
	resultWeapon.SetReach(statsWeapon.GetReach())
	resultWeapon.SetMinRange(statsWeapon.GetMinRange())
	resultWeapon.SetMaxRange(statsWeapon.GetMaxRange())
	resultWeapon.SetSpeed(statsWeapon.GetSpeed())
	resultWeapon.SetStagger(statsWeapon.GetStagger())
	resultWeapon.SetEnchantment(statsWeapon.GetEnchantment())
	resultWeapon.SetEnchantmentValue(statsWeapon.GetEnchantmentValue())
	resultWeapon.SetSkill(statsWeapon.GetSkill())
	resultWeapon.SetResist(statsWeapon.GetResist())
	resultWeapon.SetCritEffect(statsWeapon.GetCritEffect())
	resultWeapon.SetCritEffectOnDeath(statsWeapon.GetCritEffectOnDeath())
	resultWeapon.SetCritMultiplier(statsWeapon.GetCritMultiplier())

	Int numRemovedKeywords = RemoveAllKeywords(resultWeapon)
	Debug.Trace("AADebug : Removed " + numRemovedKeywords + " keywords")

	Int numKeywords = statsWeapon.GetNumKeywords()
	While numKeywords > 0
		Keyword currentKeyword = statsWeapon.GetNthKeyword(numKeywords - 1)

		AddKeywordToForm(resultWeapon, statsWeapon.GetNthKeyword(numKeywords - 1))
		Debug.Trace(\
			"AADebug : Added keyword " + currentKeyword + " to " + resultWeapon\
		)

		numKeywords -= 1
	EndWhile

	Debug.Trace(\
		"AADebug: Ending ApplyWeaponTransmutation(" + statsWeapon + ", "\
		+ visualWeapon + ", " + resultWeapon + ")"\
	)
EndFunction
