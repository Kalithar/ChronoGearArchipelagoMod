extends "res://Global Assets/Scripts/Enemies/BossGandr.gd"

func _process(delta):
	super(delta)
	if GameSettings.archipelagoEnabled and activateCG:
		GameSettings.CheckLocation(751400) #Hard coded chrono gear ID
		if !GameSettings.archipelagoChronoGear:
			targetPlayer.hasChronoGear = false
