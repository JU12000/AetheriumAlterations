Scriptname AATransmutationButtonManager extends ReferenceAlias

Quest Property AATransmutationManagerQuest Auto

ReferenceAlias Property PlayerRef Auto

; Empty state function stubs
Function Open()
EndFunction
Function Close()
EndFunction

Auto State Closed
	Event OnBeginState()
		GetReference().BlockActivation(True)
		GetReference().PlayAnimation("Close")
	EndEvent

	Function Open()
		GoToState("Opened")
	EndFunction
EndState

State Opened
	Event OnBeginState()
		GetReference().BlockActivation(False)
		GetReference().PlayAnimation("Open")
	EndEvent

	Event OnActivate(ObjectReference akActivator)
		If akActivator == PlayerRef.GetReference()
			GoToState("")
			GetReference().PlayAnimationAndWait("Trigger01", "Done")
			(AATransmutationManagerQuest as AATransmutationManager).PreTransmute()
			GoToState("Opened")
		EndIf
	EndEvent

	Function Close()
		GoToState("Closed")
	EndFunction
EndState
