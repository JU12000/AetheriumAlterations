Scriptname AATransmutationScrollWatcher extends ReferenceAlias

Quest Property AATransmutationManagerQuest Auto

ReferenceAlias Property PlayerRef Auto

Event OnContainerChanged(ObjectReference akNewContainer, ObjectReference akOldContainer)
	If akNewContainer == PlayerRef.GetReference()\
	&& (\
		AATransmutationManagerQuest.GetStage() == 0\
		|| AATransmutationManagerQuest.GetStage() == 6\
	)
		AATransmutationManagerQuest.SetStage(5)
	ElseIf akOldContainer == PlayerRef.GetReference()\
	&& AATransmutationManagerQuest.GetStage() == 5
		AATransmutationManagerQuest.SetStage(6)
	EndIf
EndEvent
