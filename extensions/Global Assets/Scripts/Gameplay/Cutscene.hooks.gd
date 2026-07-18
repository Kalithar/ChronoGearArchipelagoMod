extends Object

func State_FinishScene(chain: ModLoaderHookChain, delta):
	var cutscene = chain.reference_object as CutsceneController
	if cutscene.changeSceneSafe:
		cutscene.changeSceneSafe = GameSettings.GetHubAccess(cutscene.changeSceneSafe)
	chain.execute_next([delta])
	#Cutscenes that send you back to the hub don't change the pointer to what gear you are currently on,
	#but I use that for location IDs, so doing that manually
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
