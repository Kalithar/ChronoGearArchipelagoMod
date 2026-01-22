extends "res://Global Assets/Scripts/UI/MenuMessage.gd"


func _ready():
	if(!GameSettings.archipelagoEnabled):
		super()
	else:
		if missionName:
			GameSettings.MarkLevelCompletion(GameSettings.goldenGearAcquired)
			super()
