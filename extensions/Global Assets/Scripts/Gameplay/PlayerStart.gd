extends "res://Global Assets/Scripts/Gameplay/PlayerStart.gd"

func SpawnPlayer():
	super()
	if GameSettings.archipelagoEnabled:
		if GameSettings.archipelagoChronoGear:
			if (hub or startWithChronoGear or GameSettings.slotData["early_chrono_gear"] == 1) and not GameSettings.currentGoldenGear == 59: 
				targetPlayer.hasChronoGear = true
			else:
				targetPlayer.hasChronoGear = false
		else:
			targetPlayer.hasChronoGear = false
