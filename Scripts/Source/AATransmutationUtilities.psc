Scriptname AATransmutationUtilities Hidden

Import PO3_SKSEFunctions

;/ Gets the first ReferenceAlias with the provided Form. Returns None otherwise /;
ReferenceAlias Function GetAliasInArrayFromFormIfExists(ReferenceAlias[] aliasArray, Int searchFormID) Global
	Int i = 0
	While i < aliasArray.Length
		If aliasArray[i].GetReference().GetBaseObject().GetFormID() == searchFormID
			return aliasArray[i]
		EndIf

		i += 1
	EndWhile
EndFunction

;/ Gets the first ReferenceAlias with the provided searchKeyword and
;/ armorSlotMask. Returns None otherwise. /;
ReferenceAlias Function GetAliasInArrayFromKeywordAndSlotMaskIfExists(ReferenceAlias[] aliasArray, Int[] slotMaskArray, Keyword searchKeyword, Int armorSlotMask) Global
	Int i = 0
	While i < aliasArray.Length
		If aliasArray[i].GetReference().GetBaseObject().HasKeyword(searchKeyword)\
		&& (armorSlotMask == slotMaskArray[i])
			Return aliasArray[i]
		EndIf

		i += 1
	EndWhile
EndFunction

;/ Gets the first ReferenceAlias with the provided searchKeyword and
;/ weaponType. Returns None otherwise. /;
ReferenceAlias Function GetAliasInArrayFromKeywordAndWeaponTypeIfExists(ReferenceAlias[] aliasArray, Keyword searchKeyword, Int weaponType) Global
	Int i = 0
	While i < aliasArray.Length
		Form resultForm = aliasArray[i].GetReference().GetBaseObject()

		If resultForm.HasKeyword(searchKeyword)\
		&& ((resultForm as Weapon).GetWeaponType() == weaponType)
			Return aliasArray[i]
		EndIf

		i += 1
	EndWhile
EndFunction

;/ Gets the index of the array which contains the same ReferenceAlias.
;/ Returns -1 if no element contains the ReferenceAlias. /;
Int Function GetArrayIndexFromReferenceAliasIfExists(ReferenceAlias[] aliasArray, ReferenceAlias searchReferenceAlias) Global
	Int i = 0
	While i < aliasArray.Length
		If aliasArray[i].GetReference() == searchReferenceAlias.GetReference()
			Return i
		EndIf

		i += 1
	EndWhile

	Return -1
EndFunction

;/ Gets the first keyword in the array that both forms have,
;/ if secondForm is None this function operates on only firstForm.
;/ Returns None otherwise /;
Keyword Function GetFirstCommonKeywordInArrayIfAny(Keyword[] keywordsArray, Form firstForm, Form secondForm = None) Global
	Int i = 0
	While i < keywordsArray.Length
		If firstForm.HasKeyword(keywordsArray[i])\
		&& (secondForm.HasKeyword(keywordsArray[i]) || (secondForm == None))
			Return keywordsArray[i]
		EndIf

		i += 1
	EndWhile
EndFunction

;/ Removes all keywords on the form and returns the total numer of keywords
;/ removed /;
Int Function RemoveAllKeywords(Form targetForm) Global
	Int numKeywords = targetForm.GetNumKeywords()
	Int numKeywordsRemoved = numKeywords
	While numKeywords > 0
		RemoveKeywordOnForm(targetForm, targetForm.GetNthKeyword(numKeywords - 1))
		numKeywords -= 1
	EndWhile

	Return numKeywordsRemoved
EndFunction
