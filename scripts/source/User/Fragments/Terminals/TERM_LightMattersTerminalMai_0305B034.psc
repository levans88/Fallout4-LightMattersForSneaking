;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_LightMattersTerminalMai_0305B034 Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersGlobalToggle.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersGlobalToggle.SetValue(0)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property LightMattersGlobalToggle Auto Const Mandatory

GlobalVariable Property LightMattersPipboyLightOn = 0 Auto Const

GlobalVariable Property LightMattersPipboyLightOn = 0 Auto Const

GlobalVariable Property LightMattersPipboyLightOn Auto Const

GlobalVariable Property LightMattersPipboyLightOn Auto Const Mandatory
