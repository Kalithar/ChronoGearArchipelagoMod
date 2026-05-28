extends Object

func State_FinishScene(chain: ModLoaderHookChain, delta):
	var cutscene = chain.reference_object as CutsceneController
	#if cutscene.changeSceneSafe:
		#A bunch of stuff to say "if it's trying to send you somewhere that isn't unlocked, you get sent to sanctum instead"
		#for i in range(1, 62):
			#if cutscene.changeSceneSafe == GameSettings.GetStageInfo(i)[1]:
				#if GameSettings.storyFlag[GameSettings.GetStageInfo(i)[5]] != 1:
					#cutscene.changeSceneSafe = "hub_sanctum"
	chain.execute_next([delta])
	#Cutscenes that send you back to the hub don't change the pointer to what gear you are currently on,
	#but I use that for location IDs, so doing that manually
	if cutscene.changeGoldenGearID == 0:
		var destination
		if cutscene.changeSceneSafe == "targetHub":
			destination = GameSettings.targetHub.resource_path.get_basename().get_file()
		else:
			destination = cutscene.changeSceneSafe + ".tscn"
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
