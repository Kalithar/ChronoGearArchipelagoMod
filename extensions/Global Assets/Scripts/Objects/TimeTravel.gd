extends "res://Global Assets/Scripts/Objects/TimeTravel.gd"


func State_Default(_delta):
	if (GameSettings.currentGoldenGear == 12 or GameSettings.currentGoldenGear == 29) and GameSettings.archipelagoEnabled:
		match int(GameSettings.currentGoldenGear):
			12:
				if GameSettings.receivedAcorns >= 10:
					Activate()
			29:
				if GameSettings.receivedMazeParts >= 10:
					Activate()
