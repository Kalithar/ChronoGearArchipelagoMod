extends "res://Global Assets/Scripts/Items/GoldenGear.gd"

func _on_sensor_body_entered(body):
	if !GameSettings.archipelagoEnabled:
		super(body)
	else:
		if state == State_Default and not targetPlayer:
			if body.has_method("Action_Victory"):
				GameSettings.CheckLocation(GameSettings.GetStageInfo(goldenGearID)[9] + 100)
				super(body)
