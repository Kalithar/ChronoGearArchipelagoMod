extends Object

func UnlockItem(chain: ModLoaderHookChain) -> void :
	if !GameSettings.archipelagoEnabled:
		chain.execute_next()
	else:
		#Intead of unlocking the item normally, send it to the server
		var collectedCD := chain.reference_object as ItemCD
		var cdID = GameSettings.cds.find_key(collectedCD.cd_id)
		GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 200 + cdID)
