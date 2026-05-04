extends Object

func SaveGame(chain: ModLoaderHookChain):
	var path = FileManager.SAVE_DIR + "file" + str(GameSettings.currentFileID) + ".cg"
	if GameSettings.currentFileID == 0:
		return

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return

	var data = {
		"date": Time.get_datetime_string_from_system(false, true), 
		"dateCreated": GameSettings.dateCreated, 
		"goldenGears": GameSettings.goldenGears, 
		"noteRecord": GameSettings.noteRecord, 
		"timeRecord": GameSettings.timeRecord, 
		"damageRecord": GameSettings.damageRecord, 
		"scoreRecord": GameSettings.scoreRecord, 
		"assistRecord": GameSettings.assistRecord, 
		"previousMap": GameSettings.previousMap, 
		"currentMap": GameSettings.currentMap, 
		"storyFlag": GameSettings.storyFlag, 
		"dialogRead": FileManager.array_unique(GameSettings.dialogRead), 
		"codecsUnlocked": FileManager.array_unique(GameSettings.codecsUnlocked), 
		"codecsViewed": FileManager.array_unique(GameSettings.codecsViewed), \
		"borderArtUnlocked": FileManager.array_unique(GameSettings.borderArtUnlocked), 
		"cdsUnlocked": FileManager.array_unique(GameSettings.cdsUnlocked), 
		"cdsViewed": FileManager.array_unique(GameSettings.cdsViewed), 
		"threadsCollected": FileManager.array_unique(GameSettings.threadsCollected), 
		"cutscenesUnlocked": FileManager.array_unique(GameSettings.cutscenesUnlocked), 
		"achievementsUnlocked": FileManager.array_unique(GameSettings.achievementsUnlocked), 
		"systemTime": GameSettings.systemTime, 
		"difficulty": Difficulty.get_save_difficulty().type, 
		"play_tutorial": GameSettings.play_tutorial, 
		"speedrun": GameSettings.speedrun, 
		"runTime": GameSettings.runTime, 
		"fishRecord": GameSettings.fishRecord, 
		"trypleJumps": GameSettings.trypleJumps, 
		"ddcs": GameSettings.ddcs, 
		"tdcs": GameSettings.tdcs, 
		"boops": GameSettings.boops, 
		"faceplants": GameSettings.faceplants, 
		"teleports": GameSettings.teleports, 
		"timeDancing": GameSettings.timeDancing, 
		"totalRewinds": GameSettings.totalRewinds, 
		"timesHit": GameSettings.timesHit, 
		"totalDamage": GameSettings.totalDamage, 
		"stasisDamageAbsorbed": GameSettings.stasisDamageAbsorbed, 
		"faunaDamageAbsorbed": GameSettings.faunaDamageAbsorbed, 
		"totalBaeDamage": GameSettings.totalBaeDamage, 
		"countStasis": GameSettings.countStasis, 
		"timeStasis": GameSettings.timeStasis, 
		"countHaste": GameSettings.countHaste, 
		"timeHaste": GameSettings.timeHaste, 
		"countCG": GameSettings.countCG, 
		"timeCG": GameSettings.timeCG, 
		"totalEnemiesDefeated": GameSettings.totalEnemiesDefeated, 
		"totalAttacksParried": GameSettings.totalAttacksParried, 
		"totalHealthRecovered": GameSettings.totalHealthRecovered, 
		"borderArtChanged": GameSettings.borderArtChanged, 
	}

	if Difficulty.get_save_difficulty().type >= Difficulty.TYPE_CUSTOM:
		data["difficultyCustom"] = Difficulty.get_save_difficulty().toDict()

	if GameSettings.trypleJumps:
		data["trypleJumps"] = GameSettings.trypleJumps

	if GameSettings.ddcs:
		data["ddcs"] = GameSettings.ddcs

	if GameSettings.tdcs:
		data["tdcs"] = GameSettings.tdcs

	if GameSettings.boops:
		data["boops"] = GameSettings.boops

	if GameSettings.faceplants:
		data["faceplants"] = GameSettings.faceplants
		
	if GameSettings.archipelagoEnabled:
		data["archipelagoEnabled"] = true
		data["slotData"] = GameSettings.slotData
		data["archipelagoData"] = GameSettings.PackArchipelagoData()

	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()



static func LoadGame(chain: ModLoaderHookChain):
	var path = FileManager.SAVE_DIR + "file" + str(GameSettings.currentFileID) + ".cg"
	if not FileAccess.file_exists(path):
		printerr("Cannot open non-existent file at %s." % [path])
		return

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr(FileAccess.get_open_error())
		return

	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content) as Dictionary
	if data == null:
		printerr("Cannot parse %s as a json_string: (%s)" % [path, content])
		return
	if data.has("SaveData"):
		data = data["SaveData"]

	if data.has("dateCreated"):
		GameSettings.dateCreated = data.dateCreated

	for i in GameSettings.MAX_GOLDEN_GEARS:
		if i < min(GameSettings.goldenGears.size(), data.goldenGears.size()):
			GameSettings.goldenGears[i] = data.goldenGears[i]
		if i < min(GameSettings.noteRecord.size(), data.noteRecord.size()):
			GameSettings.noteRecord[i] = int(data.noteRecord[i])
		if i < min(GameSettings.timeRecord.size(), data.timeRecord.size()):
			GameSettings.timeRecord[i] = float(data.timeRecord[i])
		if i < min(GameSettings.damageRecord.size(), data.damageRecord.size()):
			GameSettings.damageRecord[i] = int(data.damageRecord[i])
		if i < min(GameSettings.scoreRecord.size(), data.scoreRecord.size()):
			GameSettings.scoreRecord[i] = int(data.scoreRecord[i])
		if (
			data.has("assistRecord")
			and (i < min(GameSettings.assistRecord.size(), data.assistRecord.size()))
		):
			GameSettings.assistRecord[i] = int(data.assistRecord[i])

	GameSettings.previousMap = data.previousMap
	GameSettings.currentMap = data.currentMap


	for i in GameSettings.storyFlagNames.size():
		if data.storyFlag.has(GameSettings.storyFlagNames[i]) == false:
			data.storyFlag[GameSettings.storyFlagNames[i]] = int(0)

	GameSettings.storyFlag = data.storyFlag

	if data.has("dialogRead"):
		GameSettings.dialogRead.assign(FileManager.array_unique(data.dialogRead))

	GameSettings.fishRecord = [
	{"count": 0, "min": 0.0, "max": 0.0}, 
	{"count": 0, "min": 0.0, "max": 0.0}, 
	{"count": 0, "min": 0.0, "max": 0.0}, 
	{"count": 0, "min": 0.0, "max": 0.0}, 
	{"count": 0, "min": 0.0, "max": 0.0}, 
	{"count": 0, "min": 0.0, "max": 0.0}, 
	{"count": 0, "min": 0.0, "max": 0.0}, 
	]
	if data.has("fishRecord"):
		for i in data.fishRecord.size():
			GameSettings.fishRecord[i] = data.fishRecord[i]

	var codec_ids: = GameSettings.codecs.values().map(
		func(codec: CodecResource): return codec.codec_id)
	var cd_ids: = GameSettings.cds.values().map(
		func(cd: CDResource): return cd.cd_id)

	if data.has("codecsUnlocked"):
		GameSettings.codecsUnlocked\
.assign(FileManager.array_unique(data.codecsUnlocked)
		.filter(codec_ids.has))

	if data.has("codecsViewed"):
		GameSettings.codecsViewed\
.assign(FileManager.array_unique(data.codecsViewed)
		.filter(codec_ids.has))

	if data.has("cdsUnlocked"):
		GameSettings.cdsUnlocked\
.assign(FileManager.array_unique(data.cdsUnlocked)
		.filter(cd_ids.has))

	if data.has("cdsViewed"):
		GameSettings.cdsViewed\
.assign(FileManager.array_unique(data.cdsViewed)
		.filter(cd_ids.has))

	if data.has("borderArtUnlocked"):
		GameSettings.borderArtUnlocked\
.assign(FileManager.array_unique(data.borderArtUnlocked)
		.filter(GameSettings.borderArt.keys().has))

	if data.has("threadsCollected"):
		GameSettings.threadsCollected.assign(FileManager.array_unique(data.threadsCollected))

	if data.has("cutscenesUnlocked"):
		GameSettings.cutscenesUnlocked.assign(FileManager.array_unique(data.cutscenesUnlocked))

	if data.has("achievementsUnlocked"):
		GameSettings.achievementsUnlocked.assign(FileManager.array_unique(data.achievementsUnlocked))

	if data.has("difficulty"):

		GameSettings.difficultyPreset = data.difficulty
		if GameSettings.difficultyPreset < Difficulty.TYPE_CUSTOM:
			Difficulty.current = Difficulty.fromPreset(data.difficulty)
		else:
			Difficulty.current = Difficulty.fromDict(data.difficultyCustom)
	else:
		Difficulty.current = Difficulty.fromPreset(Difficulty.TYPE_BRAVE)

	if data.has("play_tutorial"):
		GameSettings.play_tutorial = data.play_tutorial

	if data.has("speedrun"):
		GameSettings.speedrun = data.speedrun

	if data.has("trypleJumps"):
		GameSettings.trypleJumps = data["trypleJumps"]

	if data.has("ddcs"):
		GameSettings.ddcs = data["ddcs"]

	if data.has("tdcs"):
		GameSettings.ddcs = data["tdcs"]

	if data.has("boops"):
		GameSettings.boops = data["boops"]

	if data.has("faceplants"):
		GameSettings.faceplants = data["faceplants"]

	if data.has("teleports"):
		GameSettings.teleports = data["teleports"]
	if data.has("timeDancing"):
		GameSettings.timeDancing = data["timeDancing"]
	if data.has("totalRewinds"):
		GameSettings.totalRewinds = data["totalRewinds"]
	if data.has("timesHit"):
		GameSettings.timesHit = data["timesHit"]
	if data.has("totalDamage"):
		GameSettings.totalDamage = data["totalDamage"]
	if data.has("stasisDamageAbsorbed"):
		GameSettings.stasisDamageAbsorbed = data["stasisDamageAbsorbed"]
	if data.has("faunaDamageAbsorbed"):
		GameSettings.faunaDamageAbsorbed = data["faunaDamageAbsorbed"]
	if data.has("totalBaeDamage"):
		GameSettings.totalBaeDamage = data["totalBaeDamage"]
	if data.has("countStasis"):
		GameSettings.countStasis = data["countStasis"]
	if data.has("timeStasis"):
		GameSettings.timeStasis = data["timeStasis"]
	if data.has("countHaste"):
		GameSettings.countHaste = data["countHaste"]
	if data.has("timeHaste"):
		GameSettings.timeHaste = data["timeHaste"]
	if data.has("countCG"):
		GameSettings.countCG = data["countCG"]
	if data.has("timeCG"):
		GameSettings.timeCG = data["timeCG"]
	if data.has("totalEnemiesDefeated"):
		GameSettings.totalEnemiesDefeated = data["totalEnemiesDefeated"]
	if data.has("totalAttacksParried"):
		GameSettings.totalAttacksParried = data["totalAttacksParried"]
	if data.has("totalHealthRecovered"):
		GameSettings.totalHealthRecovered = data["totalHealthRecovered"]
	if data.has("borderArtChanged"):
		GameSettings.borderArtChanged = data["borderArtChanged"]

	GameSettings.runTime = 0
	if data.has("runTime"):
		GameSettings.runTime = data.runTime

	GameSettings.systemTime = data.systemTime
	
	if data.has("archipelagoEnabled"):
		GameSettings.archipelagoEnabled = true
		GameSettings.slotData = data["slotData"]
		GameSettings.UnpackArchipelagoData(data["archipelagoData"])
		match data["currentMap"]:
			"hub_sanctum":
				GameSettings.currentGoldenGear = 52
			"hub_starship":
				GameSettings.currentGoldenGear = 53
			"hub_garden":
				GameSettings.currentGoldenGear = 54
			"hub_city":
				GameSettings.currentGoldenGear = 55
			"hub_civ":
				GameSettings.currentGoldenGear = 56
	else: 
		GameSettings.archipelagoEnabled = false
