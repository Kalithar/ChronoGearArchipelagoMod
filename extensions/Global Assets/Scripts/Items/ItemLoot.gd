extends "res://Global Assets/Scripts/Items/ItemLoot.gd"

func _ready():
	if (GameSettings.currentGoldenGear == 12 or GameSettings.currentGoldenGear == 29 or GameSettings.currentGoldenGear == 49) and GameSettings.archipelagoEnabled:
		itemStart = global_position
		if setDoorFlag >= 1:
			match GameSettings.currentGoldenGear:
				12:
					if GameSettings.sentAcornLocations[setDoorFlag - 1] == true:
						queue_free()
				29:
					if GameSettings.sentMazePartLocations[setDoorFlag - 1] == true:
						queue_free()
				49:
					match setDoorFlag:
						11:
							if GameSettings.sentTowerKeyLocations[0] == true:
								queue_free()
						17:
							if GameSettings.sentTowerKeyLocations[1] == true:
								queue_free()
						20:
							if GameSettings.sentTowerKeyLocations[2] == true:
								queue_free()
	else: super()

func _on_body_entered(body):
	if (GameSettings.currentGoldenGear == 12 or GameSettings.currentGoldenGear == 29 or GameSettings.currentGoldenGear == 49) and GameSettings.archipelagoEnabled:
		if collected:
			return

		if body is Player:
			targetPlayer = body

		if setDoorFlag >= 0:
			var h: HUD = GameSettings.GetHud()
			GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 600 + setDoorFlag - 1)
			match GameSettings.currentGoldenGear:
				12:
					GameSettings.sentAcornLocations[setDoorFlag - 1] = true
				29:
					GameSettings.sentMazePartLocations[setDoorFlag - 1] = true
				49:
					match setDoorFlag:
						11:
							GameSettings.sentTowerKeyLocations[0] = true
						17:
							GameSettings.sentTowerKeyLocations[1] = true
						20:
							GameSettings.sentTowerKeyLocations[2] = true
					

			var doors: int
			match GameSettings.currentGoldenGear:
				12:
					for i in GameSettings.sentAcornLocations:
						if i:
							doors += 1
				29:
					for i in GameSettings.sentMazePartLocations:
						if i:
							doors += 1
				49:
					for i in GameSettings.sentTowerKeyLocations:
						if i:
							doors += 1
			

			$CollectAudio.stream = sfxCollect[min(sfxCollect.size() - 1, doors)]
			if targetPlayer && snapToPlayerOnCollect:
				itemStart = targetPlayer.global_position

			if doors >= sfxCollect.size() and note != null:
				DropNotes()

		$CollectAudio.play()
		collected = true
	else: super(body)
