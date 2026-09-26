extends "res://Global Assets/Scripts/Objects/TimeSwitch.gd"

func _ready():
	if GameSettings.archipelagoEnabled and requiresKey:
		iframes = 0.1

		match setDoorFlag:
			21:
				if GameSettings.openedTowerLocks[0] == true:
						stateTimer = time
						opened = true
			22:
				if GameSettings.openedTowerLocks[1] == true:
						stateTimer = time
						opened = true
			23:
				if GameSettings.openedTowerLocks[2] == true:
						stateTimer = time
						opened = true
	else:
		super()

func Unlock(doorAnimation: String = "on", switchAnimation: String = "on"):
	super()
	if GameSettings.archipelagoEnabled and requiresKey:
		match setDoorFlag:
			21:
				GameSettings.openedTowerLocks[0] = true
				GameSettings. usedTowerKeys += 1
			22:
				GameSettings.openedTowerLocks[1] = true
				GameSettings. usedTowerKeys += 1
			23:
				GameSettings.openedTowerLocks[2] = true
				GameSettings. usedTowerKeys += 1

func _HasRequiredKeys(player: Player) -> bool:
	if GameSettings.archipelagoEnabled:
		return (GameSettings.receivedTowerKeys - GameSettings.usedTowerKeys) > 0
	else: 
		return super(player)
