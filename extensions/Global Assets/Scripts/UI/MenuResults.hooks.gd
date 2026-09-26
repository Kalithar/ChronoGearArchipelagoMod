extends Object

func _process(chain: ModLoaderHookChain, delta):
	if(GameSettings.archipelagoEnabled):
		var ref = chain.reference_object
		if ref.state == 7:
			if ref.stateTimer >= 1 and Input.is_action_just_pressed("menu_confirm"):
				GameSettings.MarkLevelCompletion(GameSettings.goldenGearAcquired)
				#This will send checks for levels like the hubs, but they don't have the actual
				#locations, so it's fine.
				var stage_info = GameSettings.GetStageInfo(GameSettings.currentGoldenGear)
				if ref.targetNotes != 0:
					if GameSettings.currentNotes >= ref.targetNotes:
						GameSettings.CheckLocation(stage_info[9] + 500)
				if GameSettings.currentStageTime <= ref.targetStageTime:
					GameSettings.CheckLocation(stage_info[9] + 501)
				if GameSettings.currentDamageTaken <= ref.targetDamageTaken:
					GameSettings.CheckLocation(stage_info[9] + 502)
				if ref.percentTotal >= 100:
					GameSettings.CheckLocation(stage_info[9] + 503)
	chain.execute_next_async([delta])
