extends Object

func _process(chain: ModLoaderHookChain, delta):
	if(GameSettings.archipelagoEnabled):
		var ref = chain.reference_object
		if ref.state == 7:
			if ref.stateTimer >= 1 and Input.is_action_just_pressed("menu_confirm"):
				GameSettings.MarkLevelCompletion(GameSettings.goldenGearAcquired)
	chain.execute_next_async([delta])
