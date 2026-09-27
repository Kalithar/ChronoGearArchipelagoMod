extends Object

func ExitStage(chain: ModLoaderHookChain):
	var ref = chain.reference_object as MenuOptionNew
	
	if GameSettings.archipelagoEnabled:
		var destination = GameSettings.targetHub.resource_path.get_file()
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
	
	chain.execute_next()
