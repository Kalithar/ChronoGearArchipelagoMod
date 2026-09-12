extends Object

#This just doesn't work with how the apples are handled
#Some levels have them as part of the scene, some use the tile map,
#and they aren't always named the same thing.
#I would basically have to go through and match every single instance
#of an apple with a specific case to make this work

func _on_sensor_touch_body_entered(chain: ModLoaderHookChain, body):
	var ref = chain.reference_object
	chain.execute_next([body])
	
	if body.has_method("Action_Heal"):
		if body.has_method("GetKOState"):
			if body.call("GetKOState"):
				return
		
		if ref.state != ref.State_Respawn and ref.state != ref.State_Drop and ref.state != ref.State_DelayedSummon:
			if ref.name.begins_with("JadeApple"):
				var nameSplit = ref.name.split("")
				var appleID
				if nameSplit[-1] == "e":
					appleID = 1
				else:
					appleID = nameSplit[-1] as int
				
				GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 400 + appleID)
				
		
		
