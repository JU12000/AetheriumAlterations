Scriptname AATransmutationOnLoadScript extends ReferenceAlias

Quest Property AATransmutationManagerQuest Auto

Event OnPlayerLoadGame()
	(AATransmutationManagerQuest as AATransmutationManager).OnLoadTransmute()
EndEvent