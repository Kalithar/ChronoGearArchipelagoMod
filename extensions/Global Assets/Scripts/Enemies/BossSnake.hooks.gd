extends Object

func State_KO(chain: ModLoaderHookChain, delta):
	if chain.reference_object.state_timer == 0:
		GameSettings.MarkLevelCompletion(61)
	chain.execute_next()
