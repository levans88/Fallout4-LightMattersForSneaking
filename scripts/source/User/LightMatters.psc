ScriptName LightMatters extends ReferenceAlias

Actor PlayerRef
float playerLightLevel
bool playerWasInInterior
bool playerIsInInterior
bool modEnabled
bool registeredForResyncKey
bool registeredForLightStatusKey
bool registeredForLightLevelKey
bool registeredForSneakControl
int resyncKey = 72	;H
int lightStatusKey = 66	;B
int lightLevelKey = 85	;U
bool playerGivenHolotape
float lightThreshold
int powerArmorSneakState
bool playerEnterExitPowerArmor
bool playerIsInPowerArmor
bool playerIsAiming
bool queueLightOffMessage
bool queueDisableSneakControl
float shaderOption
bool shaderIsPlaying
bool shuttingDown

InputEnableLayer crouchDisabledInputLayer

Spell Property LightMattersInvisibilitySpell Auto
Spell Property LightMattersHighlightSpell Auto
Perk Property LightMattersInvisibilityPerk Auto
ActorValue Property DetectionMovementMod Auto
holotape Property LightMattersHolotape Auto

GlobalVariable Property LightMattersGlobalToggle Auto
GlobalVariable Property LightMattersPipboyLightOn Auto

GlobalVariable Property LightMattersResyncHotkeyOn Auto
GlobalVariable Property LightMattersLightStatusHotkeyOn Auto
GlobalVariable Property LightMattersLightLevelHotkeyOn Auto

GlobalVariable Property LightMattersLightLevelThresholdInterior Auto
GlobalVariable Property LightMattersLightLevelThresholdExterior Auto
GlobalVariable Property LightMattersLightLevelMaxInterior Auto
GlobalVariable Property LightMattersLightLevelMaxExterior Auto

GlobalVariable Property LightMattersAllowCrouchingInPowerArmor Auto
GlobalVariable Property LightMattersAllowSneakingInPowerArmor Auto
GlobalVariable Property LightMattersAllowEffectInPowerArmor Auto

GlobalVariable Property LightMattersSettingsChanged Auto

GlobalVariable Property LightMattersShowDetectionEventCreatedMessages Auto
GlobalVariable Property LightMattersShowLightStatusMessages Auto
GlobalVariable Property LightMattersShowPlayerLightLevelMessages Auto

Message Property LightMattersPlayerLightLevelMessage Auto Const Mandatory
Message Property LightMattersLightStatusOnMessage Auto
Message Property LightMattersLightStatusOffMessage Auto
Message Property LightMattersDetectionEventCreatedMessage Auto Const Mandatory

Keyword Property FurnitureTypePowerArmor Auto Const

GlobalVariable Property LightMattersHighlightEffectShaderWVOn Auto
GlobalVariable Property LightMattersHighlightEffectShaderOption Auto

EffectShader Property StealthBoyInvisibilityEffect Auto Const

EffectShader Property LightMattersHighlightShaderShadow Auto Const
EffectShader Property LightMattersHighlightShaderShadowWV Auto Const

EffectShader Property LightMattersHighlightShaderShadowEdge Auto Const
EffectShader Property LightMattersHighlightShaderShadowEdgeWV Auto Const

EffectShader Property LightMattersHighlightShaderShadowEdgeColor Auto Const
EffectShader Property LightMattersHighlightShaderShadowEdgeColorWV Auto Const

EffectShader Property LightMattersHighlightShaderExperimentalDissolve Auto Const
EffectShader Property LightMattersHighlightShaderExperimentalDissolveWV Auto Const

Quest Property LightMattersQuest Auto

Event OnInit()
	Self.StartTimer(1 as float, 1)

	If (!playerGivenHolotape)
		RegisterForControl("Pipboy")
	EndIf
EndEvent

;Start the mod
Function Startup()
	PlayerRef = Self.GetActorReference()
	playerLightLevel = PlayerRef.GetLightLevel()

	SyncPipboyLightStatus(False)
	RegisterForPlayerTeleport()
	
	;List of control names for which you can register using F4SE can be found 
	;in the file "CustomControlMap.txt" that comes with F4SE, though they may not all fire:
	;https://forums.nexusmods.com/index.php?/topic/5556487-f4se-where-are-the-list-of-potential-controls-to-register-for/
	RegisterForControl("Pipboy")
	RegisterForControl("SecondaryAttack")

	If (LightMattersResyncHotkeyOn.GetValue() == 1)
		RegisterForKey(resyncKey)
		registeredForResyncKey = True
	Else
		registeredForResyncKey = False
	EndIf

	If (LightMattersLightStatusHotkeyOn.GetValue() == 1)
		RegisterForKey(lightStatusKey)
		registeredForLightStatusKey = True
	Else
		registeredForLightStatusKey = False
	EndIf

	If (LightMattersLightLevelHotkeyOn.GetValue() == 1)
		RegisterForKey(lightLevelKey)
		registeredForLightLevelKey = True
	Else
		registeredForLightLevelKey = False
	EndIf

	If (LightMattersPipboyLightOn.GetValue() == 1)
		Debug.Notification("Startup: Your light is ON")
	Else
		Debug.Notification("Startup: Your light is OFF")
	EndIf

	CheckPowerArmorSneakState()

	;If player is sneaking when they enable the mod, we don't wait for OnEnterSneaking(),
	;otherwise they would have to stand up and re-sneak to get things started.
	If (PlayerRef.IsSneaking())
		StopShader()
		PlayerEnteredSneaking()
	EndIf

	modEnabled = True
	Debug.Notification("Light Matters for Sneaking mod running.")
EndFunction

;Disable the mod
Function Shutdown()
	shuttingDown = True
	PlayerRef = Self.GetActorReference()

	UnregisterForPlayerTeleport()
	UnRegisterForControl("Pipboy")
	UnRegisterForControl("SecondaryAttack")

	UnRegisterForKey(resyncKey)
	registeredForResyncKey = False

	UnRegisterForKey(lightStatusKey)
	registeredForLightStatusKey = False

	UnRegisterForKey(lightLevelKey)
	registeredForLightLevelKey = False

	;Cancel everything that would prevent user from using their "Sneak" control
	queueDisableSneakControl = False

	LightMattersAllowCrouchingInPowerArmor.SetValue(1)
	CheckPowerArmorSneakState()

	UnRegisterForControl("Sneak")
	registeredForSneakControl = False

	crouchDisabledInputLayer = None

	Self.CancelTimer(0)
	
	If (PlayerRef.HasSpell(LightMattersHighlightSpell))
		PlayerRef.RemoveSpell(LightMattersHighlightSpell)

		;If we have the main spell, remove this one too just in case
		PlayerRef.RemoveSpell(LightMattersInvisibilitySpell)
	EndIf

	If (PlayerRef.HasPerk(LightMattersInvisibilityPerk))
		PlayerRef.RemovePerk(LightMattersInvisibilityPerk)
	EndIf

	StopShader()

	modEnabled = False
	shuttingDown = False
	Debug.Notification("Light Matters for Sneaking mod stopped.")
EndFunction

;Any time you see a loading screen, the player was teleported
Event OnPlayerTeleport()
	If (LightMattersGlobalToggle.GetValue() == 1)
		Debug.Notification("Player teleported.")
		SyncPipboyLightStatus(True)
	EndIf
EndEvent

;This event fires when player enters OR exits power armor. Additional notes: 
;OnGetup also fires when player enters OR exits PA. It fires once when 
;inserting a fusion core too. In testing it seemed like it didn't reliably fire though,
;unlike OnSit which seems reliable.
;
;Somewhat related info here:
;https://forums.nexusmods.com/index.php?/topic/4712595-exiting-power-armor-event/
Event OnSit(ObjectReference akFurniture)
	If (LightMattersGlobalToggle.GetValue() == 1)
		If (akFurniture.HasKeyword(FurnitureTypePowerArmor))
			playerEnterExitPowerArmor = True
			Debug.Notification("Player got in or out of power armor.")
	    ;Check if player got in furniture while sneaking and remove effects.
	    ;Note: OnSit is reliable for power armor but not other furniture. Check OnGetup too.
	    Else
    		PlayerEnteredSneaking()
	    EndIf
	EndIf
EndEvent

Event OnGetup(ObjectReference akFurniture)
	If (LightMattersGlobalToggle.GetValue() == 1)
		;Check if player got out of furniture while sneaking and remove effects.
		;We check this here and in OnSit, but both are unreliable for furniture other 
		;than power armor. Best I can do at this time.
	    PlayerEnteredSneaking()
	EndIf
EndEvent

Event OnControlDown(string control)
	If (control == "SecondaryAttack")
		playerIsAiming = True
	EndIf
EndEvent

Event OnControlUp(string control, float time)
	;If the player is missing the holotape, add it ONCE when they open the Pipboy.
	;We won't register for the "Pipboy" control again unless the mod is started.
	If (!playerGivenHolotape)
		If (control == "Pipboy" && time < 0.5)
			PlayerRef = Self.GetActorReference()

			If (PlayerRef.GetItemCount(LightMattersHolotape) == 0)
				PlayerRef.AddItem(LightMattersHolotape, 1, False)
			EndIf

			playerGivenHolotape = True
			UnRegisterForControl("Pipboy")
		EndIf
	EndIf

	If (LightMattersGlobalToggle.GetValue() == 1)
		If (control == "SecondaryAttack")
			playerIsAiming = False
		EndIf

		;Toggle PipBoy light on/off AND update its on/off status
		;(don't update if player is aiming because game won't turn on light while aiming)
		If (control == "Pipboy" && time >= 0.5 && !playerIsAiming)
			If (LightMattersPipboyLightOn.GetValue() == 1)
				LightMattersPipboyLightOn.SetValue(0)

				If (LightMattersShowLightStatusMessages.GetValue() == 1)
					LightMattersLightStatusOffMessage.Show()
				EndIf
				;Debug.Notification("OnControlUp: Your light is OFF")
			Else
				LightMattersPipboyLightOn.SetValue(1)

				If (LightMattersShowLightStatusMessages.GetValue() == 1)
					LightMattersLightStatusOnMessage.Show()
				EndIf
				;Debug.Notification("OnControlUp: Your light is ON")
			EndIf
		EndIf

		;Disable player's ability to crouch. If we're doing this here, it's because the 
		;user disabled that ability while they were already crouched. We need them to
		;stand up before we can disable the key.
		If (queueDisableSneakControl && !shuttingDown)
			queueDisableSneakControl = False

			;If player stands up...
			If (control == "Sneak")
				crouchDisabledInputLayer = InputEnableLayer.Create()
				crouchDisabledInputLayer.DisablePlayerControls(false, false, false, false, true, false, false, false, false, false, false)
				UnRegisterForControl("Sneak")
			EndIf
		EndIf
	EndIf
EndEvent

Event OnKeyUp(int keyCode, float time)
	If (LightMattersGlobalToggle.GetValue() == 1)

		;Hotkey to UPDATE Pipboy light on/off status
		If (keyCode == resyncKey && LightMattersResyncHotkeyOn.GetValue() == 1)
			If (LightMattersPipboyLightOn.GetValue() == 1)
				LightMattersPipboyLightOn.SetValue(0)
				LightMattersLightStatusOffMessage.Show()
				;Debug.Notification("OnKeyUp: Your light is OFF")
			Else
				LightMattersPipboyLightOn.SetValue(1)
				LightMattersLightStatusOnMessage.Show()
				;Debug.Notification("OnKeyUp: Your light is ON")
			EndIf
		EndIf

		;Hotkey to DISPLAY Pipboy light on/off status
		If (keyCode == lightStatusKey && LightMattersLightStatusHotkeyOn.GetValue() == 1)
			If (LightMattersPipboyLightOn.GetValue() == 1)
				LightMattersLightStatusOnMessage.Show()
			Else
				LightMattersLightStatusOffMessage.Show()
			EndIf
		EndIf

		;Hotkey to display player light level and interior/exterior thresholds
		If (keyCode == lightLevelKey && LightMattersLightLevelHotkeyOn.GetValue() == 1)
			PlayerRef = Self.GetActorReference()
			playerLightLevel = PlayerRef.GetLightLevel()

			DisplayLightLevels()
		EndIf
	EndIf
EndEvent

;Update PipBoy light on/off STATUS ONLY (used by Startup() and OnPlayerTeleport())
Function SyncPipboyLightStatus(bool playerTeleported)
	PlayerRef = Self.GetActorReference()
	playerLightLevel = PlayerRef.GetLightLevel()
	playerIsInPowerArmor = PlayerRef.IsInPowerArmor()

	;Player is in interior
	If (PlayerRef.IsInInterior())
		Debug.Notification("Player is in interior now.")

		;Player did NOT teleport, so they also WERE in interior space
		If (!playerTeleported)
			Debug.Notification("Player did not teleport.")
			playerWasInInterior = True

			If (playerLightLevel < LightMattersLightLevelMaxInterior.GetValue())
				LightMattersPipboyLightOn.SetValue(0)
			EndIf

		;Player DID teleport
		Else
			;Light is NOT at max
			If (playerLightLevel < LightMattersLightLevelMaxInterior.GetValue())
				
				;Interior -> Interior
				;Unknown behavior, haven't found nested interior teleport doors yet
				;Assuming game will leave light ON
				;So if we're not at max brightness here, light is OFF
				;EXCEPT if wearing PA helmet, then player light level is unaffected
				;It's not necessary to set light status here, so don't do it 
				;unless you check if PA helmet is worn.
				;
				If (playerWasInInterior)
					Debug.Notification("Player was in interior before.")
					
					If (!playerIsInPowerArmor)
						If (LightMattersShowLightStatusMessages.GetValue() == 1)
							LightMattersLightStatusOffMessage.Show()
						EndIf
					EndIf
				EndIf

				;Exterior -> Interior
				;Game will leave light ON
				;So if we're not at max brightness here, light is OFF
				;EXCEPT if wearing PA helmet, then player light level is unaffected
				;It's not necessary to set light status here, so don't do it 
				;unless you check if PA helmet is worn.
				;
				If (!playerWasInInterior)
					Debug.Notification("Player was in exterior before.")

					If (!playerIsInPowerArmor)
						If (LightMattersShowLightStatusMessages.GetValue() == 1)
							LightMattersLightStatusOffMessage.Show()
						EndIf
					EndIf
				EndIf

			;Light IS at max
			ElseIf (playerLightLevel == LightMattersLightLevelMaxInterior.GetValue())

				;Interior -> Interior
				;Unknown behavior, haven't found nested interior teleport doors yet
				;Assuming game will leave light ON
				;Since we are at max brightness here, light is *probably* ON
				;EXCEPT if wearing PA helmet, then player light level is unaffected
				;It's not necessary to set light status here, so don't do it 
				;unless you check if PA helmet is worn.
				;Don't display light status message here since we can't be sure.
				;
				If (playerWasInInterior)
					Debug.Notification("Player was in interior before.")
				EndIf

				;Exterior -> Interior
				;Game will leave light ON
				;Since we are at max brightness here, light is *probably* ON
				;EXCEPT if wearing PA helmet, then player light level is unaffected
				;It's not necessary to set light status here, so don't do it 
				;unless you check if PA helmet is worn.
				;Don't display light status message here since we can't be sure.
				;
				If (!playerWasInInterior)
					Debug.Notification("Player was in exterior before.")
				EndIf
			EndIf

			If (PlayerRef.IsSneaking())
				;Player teleported so let's check all the things.
				PlayerEnteredSneaking()
			EndIf
		EndIf

	;Player is in exterior
	Else
		Debug.Notification("Player is in exterior now.")

		;Player did NOT teleport, so they also WERE in exterior space
		If (!playerTeleported)
			Debug.Notification("Player did not teleport.")
			playerWasInInterior = False

		;Player DID teleport
		Else
			;Light NOT at max
			If (playerLightLevel < LightMattersLightLevelMaxExterior.GetValue())

				;Interior -> Exterior
				;Game will turn light OFF on its own
				;So regardless of brightness here, light is OFF
				;
				If (playerWasInInterior)
					Debug.Notification("Player was in interior before.")
					LightMattersPipboyLightOn.SetValue(0)
					
					If (LightMattersShowLightStatusMessages.GetValue() == 1)
						LightMattersLightStatusOffMessage.Show()
					EndIf
				EndIf

				;Exterior -> Exterior
				;Game will leave light ON
				;So if we are not at max brightness here, light is OFF
				;EXCEPT if wearing PA helmet, then player light level is unaffected
				;It's not necessary to set light status here, so don't do it 
				;unless you check if PA helmet is worn.
				;
				If (!playerWasInInterior)
					Debug.Notification("Player was in exterior before.")

					If (!playerIsInPowerArmor)

						If (LightMattersShowLightStatusMessages.GetValue() == 1)
							LightMattersLightStatusOffMessage.Show()
						EndIf
					EndIf
				EndIf

			;Light IS at max
			ElseIf (playerLightLevel == LightMattersLightLevelMaxExterior.GetValue())

				;Interior -> Exterior
				;Game will turn light OFF on its own
				;So regardless of brightness here, light is OFF
				;
				If (playerWasInInterior)
					Debug.Notification("Player was in interior before.")
					LightMattersPipboyLightOn.SetValue(0)

					If (LightMattersShowLightStatusMessages.GetValue() == 1)
						LightMattersLightStatusOffMessage.Show()
					EndIf
				EndIf

				;Exterior -> Exterior
				;Game will leave light ON
				;We don't know if LightMattersLightLevelMaxExterior is PipBoy or the sun, 
				;but we don't need to know because game leaves light alone.
				;Don't display light status message here since we can't be sure.
				;
			EndIf

			If (PlayerRef.IsSneaking())
				;Player teleported so let's check all the things.
				PlayerEnteredSneaking()
			EndIf
		EndIf
	EndIf
EndFunction

Event OnTimer(int aiTimerID)
	PlayerRef = Self.GetActorReference()

	;This loop starts up or shuts down the mod, is always running even if the mod is off, 
	;and maintains the state of some global variables and properties.
	If (aiTimerID == 1)
		Self.CancelTimer(1)

		;Monitor mod enabled/disabled status
		If (LightMattersGlobalToggle.GetValue() == 1 && modEnabled == False)
			Startup()
		EndIf

		If (LightMattersGlobalToggle.GetValue() == 0 && modEnabled == True)
			Shutdown()
		EndIf

		;Only monitor these variables and values if the mod is running
		If (LightMattersGlobalToggle.GetValue() == 1 && modEnabled == True)

			;If player is sneaking when they change settings, we don't wait for
			;the OnEnterSneaking() event because they would have to stand up and
			;re-sneak for some settings to take effect.
			If (LightMattersSettingsChanged.GetValue() == 1)
				LightMattersSettingsChanged.SetValue(0)
				
				If (PlayerRef.IsSneaking())
					StopShader()
					PlayerEnteredSneaking()
				EndIf
			EndIf

			;Monitor resync key enabled/disabled status
			If (LightMattersResyncHotkeyOn.GetValue() == 1 && registeredForResyncKey == False)
				RegisterForKey(resyncKey)
				registeredForResyncKey = True
			EndIf

			If (LightMattersResyncHotkeyOn.GetValue() == 0 && registeredForResyncKey == True)
				UnregisterForKey(resyncKey)
				registeredForResyncKey = False
			EndIf

			;Monitor light level key enabled/disabled status
			If (LightMattersLightStatusHotkeyOn.GetValue() == 1 && registeredForLightStatusKey == False)
				RegisterForKey(lightStatusKey)
				registeredForLightStatusKey = True
			EndIf

			If (LightMattersLightStatusHotkeyOn.GetValue() == 0 && registeredForLightStatusKey == True)
				UnregisterForKey(lightStatusKey)
				registeredForLightStatusKey = False
			EndIf

			;Monitor interior/exterior status of where the player *was previously*
			;(we can ask for "is" anytime, but we can't ask for "was", so we track it)
			If (PlayerRef.IsInInterior())
				playerWasInInterior = True
			Else
				playerWasInInterior = False
			EndIf

			;If player got in/out of PA, we display the pipboy light status message here.
			;We don't do it in the previous timer loop iteration because player can turn
			;their light on and exit power armor so fast that the message will be wrong
			;once even though setting is correct (it fixes itself but it causes confusion).
			If (queueLightOffMessage)
				If (LightMattersShowLightStatusMessages.GetValue() == 1)
					LightMattersLightStatusOffMessage.Show()
				EndIf
				queueLightOffMessage = False
			EndIf

			;Monitor whether player enters or exits power armor. Game always turns light
			;OFF when player enters/exits PA, so queue light to OFF as well.
			If (playerEnterExitPowerArmor)
				LightMattersPipboyLightOn.SetValue(0)
				playerEnterExitPowerArmor = False

				;We set this value to read it on the next loop through the timer. We are
				;delaying the display of the message until that point.
				queueLightOffMessage = True
			EndIf

			CheckPowerArmorSneakState()

			;Enable/disable the sneak control
			;
			;If player is wearing power armor and NOT allowed to crouch...
			If (powerArmorSneakState == 4)
				If (Game.IsSneakingControlsEnabled())
					If (PlayerRef.IsSneaking())
						RegisterForControl("Sneak")
						queueDisableSneakControl = True
					Else
						crouchDisabledInputLayer = InputEnableLayer.Create()
						crouchDisabledInputLayer.DisablePlayerControls(false, false, false, false, true, false, false, false, false, false, false)
					EndIf
				EndIf
			;If player IS allowed to crouch...
			Else
				;If player's sneak control is disabled, re-enable it
				crouchDisabledInputLayer = None
			EndIf

			;Broadcast detection event. If your light is on...
			If (LightMattersPipboyLightOn.GetValue() == 1)
				MakeSomeNoise()
			Else
				;If player is PA state 1
				If (powerArmorSneakState == 1)
					MakeSomeNoise()
				;If player is PA state 2 and not sneaking
				ElseIf (powerArmorSneakState == 2 && !PlayerRef.IsSneaking())
					MakeSomeNoise()
				;If player is PA state 3 and not sneaking
				ElseIf (powerArmorSneakState == 3 && !PlayerRef.IsSneaking())
					MakeSomeNoise()
				;If player is PA state 4
				ElseIf (powerArmorSneakState == 4)
					MakeSomeNoise()
				EndIf
			EndIf
		EndIf

		Self.StartTimer(1 as float, 1)
	EndIf

	;This loop applies and removes the stealth effect based on the player's light level.
	If (aiTimerID == 0)
		Self.CancelTimer(0)

		If (PlayerRef.IsSneaking())
			playerLightLevel = PlayerRef.GetLightLevel()

			;Determine which light level threshold we care about, interior or exterior.
			If (playerIsInInterior)
				lightThreshold = LightMattersLightLevelThresholdInterior.GetValue()
			Else
				lightThreshold = LightMattersLightLevelThresholdExterior.GetValue()
			EndIf

			;We do a seemingly redundant check to make sure the player's light isn't on 
			;because mining helmet and power armor light don't affect player light level.
			;
			;Enable effect
			If (playerLightLevel <= lightThreshold && LightMattersPipboyLightOn.GetValue() == 0 && powerArmorSneakState != 1 && powerArmorSneakState != 2 && powerArmorSneakState != 4)

				PlayShader()

				If (!PlayerRef.HasSpell(LightMattersHighlightSpell as Form))
					PlayerRef.AddSpell(LightMattersHighlightSpell, False)
				EndIf

				If (!PlayerRef.HasPerk(LightMattersInvisibilityPerk))
					PlayerRef.AddPerk(LightMattersInvisibilityPerk)
				EndIf

			;Disable effect
			Else
				StopShader()

				If (PlayerRef.HasSpell(LightMattersHighlightSpell as Form))
					PlayerRef.RemoveSpell(LightMattersHighlightSpell)
				EndIf

				If (PlayerRef.HasPerk(LightMattersInvisibilityPerk))
					PlayerRef.RemovePerk(LightMattersInvisibilityPerk)
				EndIf
			EndIf
			
			Self.StartTimer(1 as float, 0)
		Else
			StopShader()

			If (PlayerRef.HasSpell(LightMattersHighlightSpell as Form))
				PlayerRef.RemoveSpell(LightMattersHighlightSpell)
			EndIf

			If (PlayerRef.HasPerk(LightMattersInvisibilityPerk))
				PlayerRef.RemovePerk(LightMattersInvisibilityPerk)
			EndIf

			Self.CancelTimer(0)
		EndIf
	EndIf
EndEvent

;Make the player extremely "noisy". Values bigger than 100 are supposedly not used in
;vanilla scripts but they work.
Function MakeSomeNoise()
	PlayerRef = Self.GetActorReference()
	PlayerRef.CreateDetectionEvent(PlayerRef, 200)

	If (LightMattersShowDetectionEventCreatedMessages.GetValue() == 1)
		LightMattersDetectionEventCreatedMessage.Show()
	EndIf
EndFunction

;In all cases, your Pipboy/flashlight and wearing power armor without sneaking will still 
;broadcast the new detection events.
;
;0 = Player is NOT wearing power armor.
;1 = Player is wearing PA. Sneaking is NOT allowed in PA at all.
;2 = Player is wearing PA. Sneaking is allowed but light doesn't matter.
;3 = Player is wearing PA. Sneaking is allowed and light does matter.
;4 = Player is wearing PA. Crouching is NOT allowed in PA at all.
Function CheckPowerArmorSneakState()
;If you are not wearing power armor...
	If (!PlayerRef.IsInPowerArmor())
		powerArmorSneakState = 0
	;If you ARE wearing power armor...
	Else
		;If you're NOT allowed to sneak in it...
		If (LightMattersAllowSneakingInPowerArmor.GetValue() == 0)
			powerArmorSneakState = 1
		EndIf

		;If you ARE allowed to sneak in it...
		If (LightMattersAllowSneakingInPowerArmor.GetValue() == 1)
			;If light matters for sneaking in power armor...
			If (LightMattersAllowEffectInPowerArmor.GetValue() == 1)
				powerArmorSneakState = 3
			Else
				powerArmorSneakState = 2
			EndIf
		EndIf

		;If you're not allowed to crouch in it...
		If (LightMattersAllowCrouchingInPowerArmor.GetValue() == 0)
			powerArmorSneakState = 4
		EndIf
	EndIf
EndFunction

Function DisplayLightLevels()
	;Message format:
	;Light level: %.0f
	;Threshold/Max Interior:  %.0f/%.0f
	;Threshold/Max Exterior:  %.0f/%.0f
	LightMattersPlayerLightLevelMessage.Show(playerLightLevel, LightMattersLightLevelThresholdInterior.GetValue(), LightMattersLightLevelMaxInterior.GetValue(), LightMattersLightLevelThresholdExterior.GetValue(), LightMattersLightLevelMaxExterior.GetValue())
EndFunction

Function PlayerEnteredSneaking()
	If (LightMattersGlobalToggle.GetValue() == 1)
		
		;Decide if player is interior/exterior here so we don't check it every second 
		;when we apply the stealth effect. Interior/exterior can't change without 
		;teleport anyway. SyncPipboyLightStatus() function will catch it. 
		If (PlayerRef.IsInInterior())
			playerIsInInterior = True
		Else
			playerIsInInterior = False
		EndIf

		CheckPowerArmorSneakState()

		;Only show light level if we're allowed to sneak and light matters.
		If (powerArmorSneakState == 0 || powerArmorSneakState == 3)
			PlayerRef = Self.GetActorReference()
			playerLightLevel = PlayerRef.GetLightLevel()

			If (LightMattersShowPlayerLightLevelMessages.GetValue() == 1)
				DisplayLightLevels()
			EndIf

			Self.StartTimer(1 as float, 0)
		Else
			;Don't show light levels, just start the timer
			Self.StartTimer(1 as float, 0)
		EndIf
	EndIf
EndFunction

Event OnEnterSneaking()
	PlayerEnteredSneaking()
EndEvent

;Shaders
;0 - No Shader
;1 - Stealth Boy Invisibility (there is no weapons visible version)
;2 - Shadow
;3 - Shadow with Edge
;4 - Shadow with Color Edge
;5 - *Experimental* Dissolve

;Stop the shader playing on player
Function StopShader()

	If (shaderIsPlaying)
		PlayerRef = Self.GetActorReference()
	
		LightMattersHighlightShaderShadowWV.Stop(PlayerRef)
		LightMattersHighlightShaderShadowEdgeWV.Stop(PlayerRef)
		LightMattersHighlightShaderShadowEdgeColorWV.Stop(PlayerRef)
		LightMattersHighlightShaderExperimentalDissolveWV.Stop(PlayerRef)

		If (PlayerRef.HasSpell(LightMattersInvisibilitySpell as Form))
			PlayerRef.RemoveSpell(LightMattersInvisibilitySpell)
		EndIf

		LightMattersHighlightShaderShadow.Stop(PlayerRef)
		LightMattersHighlightShaderShadowEdge.Stop(PlayerRef)
		LightMattersHighlightShaderShadowEdgeColor.Stop(PlayerRef)
		LightMattersHighlightShaderExperimentalDissolve.Stop(PlayerRef)

		shaderIsPlaying = False
	EndIf
EndFunction

;Play appropriate shader on player
Function PlayShader()
	shaderOption = LightMattersHighlightEffectShaderOption.GetValue()

	;Start playing a shader but fail early if it's 0. No action is necessary for 0.
	;We already stopped all shaders before we got here and we won't start any for 0.
	If (!shaderIsPlaying && shaderOption != 0)
		PlayerRef = Self.GetActorReference()

		;If weapons should be visible (not shaded)...
		If (LightMattersHighlightEffectShaderWVOn.GetValue() == 1)
			If (shaderOption == 1)
				If (!PlayerRef.HasSpell(LightMattersInvisibilitySpell as Form))
					PlayerRef.AddSpell(LightMattersInvisibilitySpell, False)
				EndIf				
			ElseIf (shaderOption == 2)
				LightMattersHighlightShaderShadowWV.Play(PlayerRef)
			ElseIf (shaderOption == 3)
				LightMattersHighlightShaderShadowEdgeWV.Play(PlayerRef)
			ElseIf (shaderOption == 4)
				LightMattersHighlightShaderShadowEdgeColorWV.Play(PlayerRef)
			ElseIf (shaderOption == 5)
				LightMattersHighlightShaderExperimentalDissolveWV.Play(PlayerRef)
			EndIf
		;If weapons should be shaded...
		Else
			If (shaderOption == 1)
				If (!PlayerRef.HasSpell(LightMattersInvisibilitySpell as Form))
					PlayerRef.AddSpell(LightMattersInvisibilitySpell, False)
				EndIf
			ElseIf (shaderOption == 2)
				LightMattersHighlightShaderShadow.Play(PlayerRef)
			ElseIf (shaderOption == 3)
				LightMattersHighlightShaderShadowEdge.Play(PlayerRef)
			ElseIf (shaderOption == 4)
				LightMattersHighlightShaderShadowEdgeColor.Play(PlayerRef)
			ElseIf (shaderOption == 5)
				LightMattersHighlightShaderExperimentalDissolve.Play(PlayerRef)
			EndIf
		EndIf

		shaderIsPlaying = True
	EndIf

	If (shaderOption == 0)
		shaderIsPlaying = False
	EndIf
EndFunction
