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

func UpdateCollectList(chain: ModLoaderHookChain, target_mission: int) -> void :
	var ref = chain.reference_object
	var currentMissionInfo: Array
	if ref.missionList.size() > 0:
		currentMissionInfo = GameSettings.GetStageInfo(ref.missionList[target_mission])

	if currentMissionInfo.size() > 0:

		var cdIcons: Array = ref.find_child("CDList").get_child(0).get_children()
		var threadIcons: Array = ref.find_child("ThreadList").get_child(0).get_children()

		var validCDs: int
		var validThreads: int

		for cdIcon in cdIcons:
			cdIcon.visible = false
			cdIcon.icon.visible = false

		for threadIcon in threadIcons:
			threadIcon.visible = false
			threadIcon.icon.visible = false

		if currentMissionInfo[7] == 18:
			return

		ref.find_child("CDList").get_child(0).position.x = 10
		ref.find_child("ThreadList").get_child(0).position.x = 10
		for cd in currentMissionInfo[10]:
			cdIcons[validCDs].visible = true
			if GameSettings.checkedLocations.has(cd):
				cdIcons[validCDs].icon.visible = true
			else:
				cdIcons[validCDs].icon.visible = false
			if validCDs < cdIcons.size() - 1:
				validCDs += 1
				validThreads += 1
				ref.find_child("CDList").get_child(0).position.x -= 10
				ref.find_child("ThreadList").get_child(0).position.x -= 10
		while validCDs < cdIcons.size() - 1:
			cdIcons[validCDs].visible = false
			validCDs += 1

		for i in threadIcons:
			i.visible = false
		for thread in currentMissionInfo[11]:
			threadIcons[validThreads].visible = true
			if GameSettings.checkedLocations.has(thread):
				threadIcons[validThreads].icon.visible = true
			else:
				threadIcons[validThreads].icon.visible = false
			if validThreads < threadIcons.size() - 1:
				validThreads += 1
				ref.find_child("CDList").get_child(0).position.x -= 10
				ref.find_child("ThreadList").get_child(0).position.x -= 10
		while validThreads < threadIcons.size() - 1:
			threadIcons[validThreads].visible = false
			validThreads += 1
	else:
		ref.gearHighlight.global_position.x = -9999
