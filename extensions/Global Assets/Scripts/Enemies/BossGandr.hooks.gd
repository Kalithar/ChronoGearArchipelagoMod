extends Object

func _process(chain: ModLoaderHookChain, delta):
	chain.execute_next([delta])
	var ref = chain.reference_object
	if GameSettings.archipelagoEnabled and ref.activateCG:
		GameSettings.CheckLocation(751400) #Hard coded chrono gear ID
		if not GameSettings.archipelagoChronoGear:
			ref.targetPlayer.hasChronoGear = false
