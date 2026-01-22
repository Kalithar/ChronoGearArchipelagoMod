extends "res://Global Assets/Scripts/Gameplay/PlayerStart.gd"

func SpawnPlayer():
	super()
	if GameSettings.archipleagoEnabled:
		if GameSettings.archipelagoChronoGear:
			if hub or startWithChronoGear or GameSettings.apEarlyChronoGear:
				targetPlayer.hasChronoGear = true
			else:
				targetPlayer.hasChronoGear = false
		else:
			targetPlayer.hasChronoGear = false
