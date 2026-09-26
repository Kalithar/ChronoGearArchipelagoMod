extends "res://Global Assets/Scripts/UI/DoorFlagCounter.gd"

func _process(_delta):
	if GameSettings.archipelagoEnabled:
		match GameSettings.currentGoldenGear:
			12:
				text = str(GameSettings.receivedAcorns) + " / 10"
			29:
				text = str(GameSettings.receivedMazeParts) + " / 10"
			49:
				text = str(GameSettings.receivedTowerKeys - GameSettings.usedTowerKeys)
			_:
				super(_delta)
	else:
		super(_delta)
