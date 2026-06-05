extends Object

func _ready(chain: ModLoaderHookChain):
	if !GameSettings.archipelagoEnabled:
		chain.execute_next()
	else:
		var reference := chain.reference_object as ItemCD
		var despawnIfUnlocked = reference.despawnIfUnlocked
		reference.despawnIfUnlocked = false
		chain.execute_next()
		var cdID = int(reference.cd_id.split("_")[1])
		if despawnIfUnlocked and GameSettings.collectedCDs.has(cdID):
			reference.queue_free()

func UnlockItem(chain: ModLoaderHookChain) -> void :
	if !GameSettings.archipelagoEnabled:
		chain.execute_next()
	else:
		#Intead of unlocking the item normally, send it to the server
		var collectedCD := chain.reference_object as ItemCD
		var cdID = int(collectedCD.cd_id.split("_")[1])
		GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 200 + cdID)
		
		GameSettings.collectedCDs.append(collectedCD.cdID)
