extends Object

func _ready(chain: ModLoaderHookChain):
	if !GameSettings.archipelagoEnabled:
		chain.execute_next()
	else:
		var reference := chain.reference_object as ThreadItem
		var despawnIfUnlocked = reference.despawnIfUnlocked
		reference.despawnIfUnlocked = false
		chain.execute_next()
		if despawnIfUnlocked and GameSettings.collectedThreads.has(reference.thread_id):
			reference.queue_free()

func UnlockItem(chain: ModLoaderHookChain) -> void :
	if !GameSettings.archipelagoEnabled:
		chain.execute_next()
	else:
		#Intead of unlocking the item normally, send it to the server
		var collectedThread := chain.reference_object as ThreadItem
		GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 300 + collectedThread.thread_id)
		#My array, not the base game's
		GameSettings.collectedThreads.append(collectedThread.thread_id)
