extends Object

func UnlockItem(chain: ModLoaderHookChain) -> void :
	if !GameSettings.archipelagoEnabled:
		chain.execute_next()
	else:
		#Intead of unlocking the item normally, send it to the server
		var collectedThread := chain.reference_object as ThreadItem
		GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 300 + collectedThread.thread_id)
