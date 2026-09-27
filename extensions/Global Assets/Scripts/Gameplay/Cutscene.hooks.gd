extends Object

func _CanRunCutscene(chain: ModLoaderHookChain) -> bool:
	var ref = chain.reference_object as CutsceneController
	if GameSettings.archipelagoEnabled:
		if GameSettings.cinematicMode:
			return true
		match [ref.checkStoryFlag, ref.checkStoryFlagMax, ref.checkStoryFlagMin]:
			["anya", 1, 1]: #Anya cutscene in Eternity Sanctum
				return GameSettings.anyaCutsceneAvailable
			["roboco", 1, 1]: #Talking to Koyori
				return GameSettings.robocoCutsceneAvailable
			["civ_powerwash", 0, 0]: #Initial cutscene with Calli
				return GameSettings.koboCutsceneAvailable
		
		return chain.execute_next()
	else:
		return chain.execute_next()

func State_FinishScene(chain: ModLoaderHookChain, delta):
	var cutscene = chain.reference_object as CutsceneController
	if GameSettings.archipelagoEnabled:
		if cutscene.changeSceneSafe:
			cutscene.changeSceneSafe = GameSettings.GetHubAccess(cutscene.changeSceneSafe)
		match [cutscene.setStoryFlag, cutscene.setStoryFlagValue]:
				["anya", 1]: #Finding Anya in Gravity
					GameSettings.CheckLocation(140700)
				["fishing", 1]: #Getting fishing rod
					GameSettings.CheckLocation(200700)
					cutscene.setStoryFlag = ""
	
	chain.execute_next([delta])
	#Cutscenes that send you back to the hub don't change the pointer to what gear you are currently on,
	#but I use that for location IDs, so doing that manually
	if GameSettings.archipelagoEnabled:
		var destination
		if cutscene.changeSceneSafe == "targetHub":
			destination = GameSettings.targetHub.resource_path.get_file()
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
