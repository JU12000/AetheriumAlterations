;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
;NEXT FRAGMENT INDEX 4
Scriptname TIF__060C5F92 Extends TopicInfo Hidden

;BEGIN FRAGMENT Fragment_0
Function Fragment_0(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
pFDS.Persuade(akSpeaker)

PlayerRef.GetReference().RemoveItem(\
	AATransmutationMysteriousDwarvenScroll.GetReference(),\
	1,\
	False,\
	akSpeaker\
)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_3
Function Fragment_3(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN CODE
PlayerRef.GetReference().AddItem(\
	AATransmutationInstructionBook\
)

GetOwningQuest().SetStage(10)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

Book Property AATransmutationInstructionBook Auto

FavorDialogueScript Property pFDS  Auto

ReferenceAlias Property AATransmutationMysteriousDwarvenScroll Auto
ReferenceAlias Property PlayerRef Auto
