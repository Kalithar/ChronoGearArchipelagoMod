extends Object

func _ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	if GameSettings.archipelagoEnabled:
		var reference = chain.reference_object as MenuWorldSelect
		reference.find_child("ChronoGearPrompt").visible = GameSettings.archipelagoWorldAccess[6]
		reference.get_node("MenuWorldSelect/UI/GearCounter/Label").text = str(GameSettings.archipelagoGearCount)

func FindMissions(chain: ModLoaderHookChain, stageName: String):
	var ref = chain.reference_object as MenuWorldSelect
	
	ref.missionList.clear()
	var r: int = 0
	for i in GameSettings.MAX_GOLDEN_GEARS:
		if GameSettings.GetStageInfo(i)[0].contains(stageName) and not GameSettings.GetStageInfo(i)[0].contains(stageName + "_alt"):
			if GameSettings.storyFlag[GameSettings.GetStageInfo(i)[5]] >= GameSettings.GetStageInfo(i)[6]:
				ref.missionList.append(i)
				if r < ref.stageSelectGearRanks.size():

					if ref.get_node("MenuStageConfirm/Panel_Quest").visible:

						ref.stageSelectGearRanks[r].text = ""
					else:
						ref.stageSelectGearRanks[r].text = str(GameSettings.scoreRecord[i])



					r += 1

func Select_World(chain: ModLoaderHookChain, world: int) -> void :
	var ref = chain.reference_object
	
	if (world == 2 or world == 3) and GameSettings.GetStoryFlag("intermission") < 4:
		GameSettings.UpdateStoryFlag("intermission", 4)
	
	chain.execute_next([world])
