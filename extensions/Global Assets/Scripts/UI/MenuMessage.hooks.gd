extends Object

func _ready(chain: ModLoaderHookChain):
	if(!GameSettings.archipelagoEnabled):
		chain.execute_next()
	else:
		var missionName = chain.reference_object.missionName
		if missionName:
			GameSettings.MarkLevelCompletion(GameSettings.goldenGearAcquired)
			GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.goldenGearAcquired)[9] + 100)
			chain.execute_next()
