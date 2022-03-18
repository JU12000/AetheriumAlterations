;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 3
Scriptname TIF__060C5F95 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_2
Function Fragment_2(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
PlayerRef.GetReference().AddItem(\
	AATransmutationInstructionBook\
)

GetOwningQuest().SetStage(10)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
PlayerRef.GetReference().RemoveItem(\
	Gold,\
	100,\
	False,\
	akSpeaker\
)

PlayerRef.GetReference().RemoveItem(\
	AATransmutationMysteriousDwarvenScroll.GetReference(),\
	1,\
	False,\
	akSpeaker\
)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Book Property AATransmutationInstructionBook Auto

MiscObject Property Gold Auto

ReferenceAlias Property AATransmutationMysteriousDwarvenScroll Auto
ReferenceAlias Property PlayerRef Auto
