extends "res://Global Assets/Scripts/UI/MenuWorldSelect.gd"

func _ready() -> void:
	super()
	if GameSettings.archipelagoEnabled:
		%ChronoGearPrompt.visible = GameSettings.archipelagoWorldAccess[6]

func Select_World(world: int) -> void:
	if !GameSettings.archipelagoEnabled:
		super(world)
	else:
		if GameSettings.archipelagoWorldAccess[world]:

			$MenuWorldSelect / UI.visible = false
			$MenuWorldSelect / AnimationPlayer.play("ZoomIn")
			$MenuStageSelect / Panel / Name.text = get_world_name()
			menuStageSelect.visible = true
			menuStageSelect.process_mode = Node.PROCESS_MODE_INHERIT
			menuStageSelect.currentOption = 0
			get_node(stageData[world].get("icons")).visible = true
			stageSelectIcons[world].visible = true
			currentWorldIcons = get_node(stageData[world].get("icons")).get_children()
			_local_enable = false
			_stage_enable = false
			menuStageSelect._local_enable = true
			state = State_StageSelect
			UpdateGearList()
			$MenuStageSelect / Notification.visible = false
			var numberOfStages = stageData[world].get("level_id").size()
			for i in numberOfStages:
				var p = stageListPanels[i].get_child(0) as TextureProgressBar
				var g = GetStageGearList(stageData[world].get("level_id")[i])
				var totalGears: int = 0
				var hasGears: bool = false
				for j in g.size():
					if GameSettings.goldenGears[g[j]]:
						totalGears += 1
					if GameSettings.IsGoldenGear(g[j]) or GameSettings.IsDarkGear(g[j]):
						hasGears = true
				if g.size() == 0:
					p.texture_under = checkmarkTextureUnder
					p.texture_progress = checkmarkTextureProgress
					p.value = 1
				else:
					if hasGears:
						p.texture_under = gearTextureUnder
						p.texture_progress = gearTextureProgress
					else:
						p.texture_under = checkmarkTextureUnder
						p.texture_progress = checkmarkTextureProgress
					p.value = float(totalGears) / max(1.0, g.size())


				for j in alwaysUnlockedMissions.size():
					if g.has(alwaysUnlockedMissions[j]) and GameSettings.goldenGears[alwaysUnlockedMissions[j]] == false and GameSettings.storyFlag[GameSettings.GetStageInfo(alwaysUnlockedMissions[j])[5]] >= GameSettings.GetStageInfo(alwaysUnlockedMissions[j])[6]:
						$MenuStageSelect / Notification.global_position.y = stageListPanels[i].global_position.y
						$MenuStageSelect / Notification.visible = true
						break
			for i in menuStageSelect.disabledOptions.size():
				if i < numberOfStages:
					menuStageSelect.disabledOptions[i] = false
				else:
					menuStageSelect.disabledOptions[i] = true

			PlayConfirmSound(sfxZoomIn)
		else:
			PlayConfirmSound(sfxDeny)
