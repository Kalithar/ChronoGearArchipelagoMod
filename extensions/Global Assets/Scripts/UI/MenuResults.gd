extends "res://Global Assets/Scripts/UI/MenuResults.gd"

func _process(delta):
	if(!GameSettings.archipelagoEnabled): 
		super(delta)
	else:
		if state == 7:
			var skip: bool = false
			if Input.is_action_just_pressed("menu_confirm"):
				skip = true

			GameSettings.hud.SetPauseDelay(3)
			
			if stateTimer < 1:
				stateTimer += delta
				if stateTimer >= 1:
					$Visibility / Continue.visible = true
					if playVoice:
						PlayVoice(voice[randi() % voice.size()])
			if stateTimer >= 1 and skip:
				await get_tree().create_timer(1.0 / 60.0).timeout
				GameSettings.hud.RestorePlayerMovement()
				GameSettings.goldenGears[GameSettings.goldenGearAcquired] = true
				GameSettings.MarkLevelCompletion(GameSettings.goldenGearAcquired)
				if GameSettings.noteRecord[GameSettings.goldenGearAcquired] < GameSettings.currentNotes:
					GameSettings.noteRecord[GameSettings.goldenGearAcquired] = GameSettings.currentNotes
				if GameSettings.timeRecord[GameSettings.goldenGearAcquired] <= 0.0 or GameSettings.timeRecord[GameSettings.goldenGearAcquired] > GameSettings.currentStageTime:
					GameSettings.timeRecord[GameSettings.goldenGearAcquired] = GameSettings.currentStageTime
				if GameSettings.damageRecord[GameSettings.goldenGearAcquired] < 0 or GameSettings.damageRecord[GameSettings.goldenGearAcquired] > GameSettings.currentDamageTaken:
					GameSettings.damageRecord[GameSettings.goldenGearAcquired] = GameSettings.currentDamageTaken
				if GameSettings.scoreRecord[GameSettings.goldenGearAcquired] < percentTotal:
					GameSettings.scoreRecord[GameSettings.goldenGearAcquired] = percentTotal
				GameSettings.goldenGearAcquired = 0
				

				for i in GameSettings.GetHud().stageEnemyCodecs:
					GameSettings.UnlockCodec(i, false)

				if GameSettings.currentFileID > 0:
					FileManager.SaveGame()
				if parentCutscene:
					parentCutscene.call("EndResults")
					$Visibility.visible = false
					state += 1
				else:
					queue_free()
		else:
			super(delta)
