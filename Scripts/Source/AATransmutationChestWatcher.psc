Scriptname AATransmutationChestWatcher extends ReferenceAlias

Quest Property AATransmutationManagerQuest Auto

Event OnItemAdded(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akSourceContainer)
	(AATransmutationManagerQuest as AATransmutationManager).UpdateTransmutationConditions()
EndEvent

Event OnItemRemoved(Form akBaseItem, Int aiItemCount, ObjectReference akItemReference, ObjectReference akDestContainer)
	(AATransmutationManagerQuest as AATransmutationManager).UpdateTransmutationConditions()
EndEvent
