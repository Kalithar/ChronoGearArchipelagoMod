extends "res://Global Assets/Scripts/Items/GoldenGear.gd"

func _on_sensor_body_entered(body):
	if !GameSettings.archipelagoEnabled:
		super(body)
	else:
		if state == State_Default and not targetPlayer:
			if body.has_method("Action_Victory"):
				GameSettings.CheckLocation(GameSettings.GetStageInfo(goldenGearID)[9] + 100)
				GameSettings.UnlockCodec(codecID, false)
				GameSettings.currentGoldenGear = goldenGearID
				body.call("Action_Victory", true)
				var h: HUD = GameSettings.GetHud()
				h.call("PlayMusic", bgmCollect)
				if hudMessage:
					var b = hudMessage.instantiate() as Node
					h.add_child(b)
				$Audio.play()
				$Ambience.stop()

				GameSettings.SetILTimeEnabled(false)
				GameSettings.ilTimerCompleted = true
				if spawnOnCollect:
					var s = spawnOnCollect.instantiate() as Node2D
					add_child(s)
				if has_node(^"AnimationPlayer_Pulse"):
					$AnimationPlayer_Pulse.get_animation("Pulse").loop_mode = 0
				targetPlayer = body as CharacterBody2D

				GameSettings.loading_hub = true
				var destination: String = GameSettings.GetHubAccess(resetTargetHub)
				var new_hub: = GameSettings.GetTargetHub(goldenGearID)

				if resetTargetHub:
					if new_hub == GameSettings.targetHub.resource_path:
						if destination == "title_screen":
							new_hub = "res://Menu Assets/Scenes/title_screen.tscn"
						else:
							new_hub = "res://Maps/" + destination + ".tscn"

				match destination:
					"hub_sanctum.tscn":
						GameSettings.currentGoldenGear = 52
					"hub_starship.tscn":
						GameSettings.currentGoldenGear = 53
					"hub_garden.tscn":
						GameSettings.currentGoldenGear = 54
					"hub_city.tscn":
						GameSettings.currentGoldenGear = 55
					"hub_civ.tscn":
						GameSettings.currentGoldenGear = 56

				GameSettings.loadThreadedResource(new_hub)
				GameSettings.targetHubPath = new_hub
				GameSettings.finished_loading_resource.connect(
					func(res):
						GameSettings.targetHub = res
						GameSettings.loading_hub = false
				, CONNECT_ONE_SHOT
				)
