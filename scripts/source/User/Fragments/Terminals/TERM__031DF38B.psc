;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname Fragments:Terminals:TERM__031DF38B Extends Terminal Hidden Const

;BEGIN FRAGMENT Fragment_Terminal_01
Function Fragment_Terminal_01(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersGlobalToggle.SetValue(1)
LightMattersSettingsChanged.SetValue(1)
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

;BEGIN FRAGMENT Fragment_Terminal_05
Function Fragment_Terminal_05(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersAllowSneakingInPowerArmor.SetValue(1)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_06
Function Fragment_Terminal_06(ObjectReference akTerminalRef)
;BEGIN CODE
If (LightMattersPipboyLightOn.GetValue() == 1)
LightMattersPipboyLightOn.SetValue(0)
LightMattersLightStatusOffMessage.Show()
;Debug.Notification("Holotape: Pip boy light set to OFF")
Else
LightMattersPipboyLightOn.SetValue(1)
LightMattersLightStatusOnMessage.Show()
;Debug.Notification("Holotape: Pip boy light set to ON")
EndIf
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_09
Function Fragment_Terminal_09(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersAllowEffectInPowerArmor.SetValue(1)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_10
Function Fragment_Terminal_10(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersAllowSneakingInPowerArmor.SetValue(0)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_11
Function Fragment_Terminal_11(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersAllowEffectInPowerArmor.SetValue(0)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_13
Function Fragment_Terminal_13(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersAllowCrouchingInPowerArmor.SetValue(1)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;BEGIN FRAGMENT Fragment_Terminal_14
Function Fragment_Terminal_14(ObjectReference akTerminalRef)
;BEGIN CODE
LightMattersAllowCrouchingInPowerArmor.SetValue(0)
LightMattersSettingsChanged.SetValue(1)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment

GlobalVariable Property LightMattersGlobalToggle Auto Const

GlobalVariable Property LightMattersPipboyLightOn Auto Const Mandatory

GlobalVariable Property LightMattersResyncHotkeyOn Auto Const Mandatory

Quest Property LightMattersQuest Auto Const

Message Property LightMattersLightStatusOnMessage Auto Const Mandatory

Message Property LightMattersLightStatusOffMessage Auto Const Mandatory

GlobalVariable Property LightMattersAllowSneakingInPowerArmor Auto Const

GlobalVariable Property LightMattersAllowEffectInPowerArmor Auto Const

GlobalVariable Property LightMattersSettingsChanged Auto Const

GlobalVariable Property LightMattersAllowCrouchingInPowerArmor Auto Const

GlobalVariable Property LightMattersLightStatusHotkeyOn Auto Const

GlobalVariable Property LightMattersLightLevelHotkeyOn Auto Const
