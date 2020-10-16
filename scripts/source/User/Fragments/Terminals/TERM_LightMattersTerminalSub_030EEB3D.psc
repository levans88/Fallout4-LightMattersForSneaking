;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM_LightMattersTerminalSub_030EEB3D Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderWVOn.SetValue(1)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_02
Function Fragment_Terminal_02(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderWVOn.SetValue(0)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_03
Function Fragment_Terminal_03(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderOption.SetValue(0)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_04
Function Fragment_Terminal_04(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderOption.SetValue(1)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_07
Function Fragment_Terminal_07(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderOption.SetValue(2)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_08
Function Fragment_Terminal_08(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderOption.SetValue(3)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderOption.SetValue(4)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersHighlightEffectShaderOption.SetValue(5)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property LightMattersHighlightEffectShaderWVOn Auto Const

GlobalVariable Property LightMattersHighlightEffectShaderOption Auto Const

GlobalVariable Property LightMattersSettingsChanged Auto Const
