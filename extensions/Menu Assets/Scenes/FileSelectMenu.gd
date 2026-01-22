extends "res://Menu Assets/Scenes/FileSelectMenu.gd"


func CreateNewGame(diff: GameSettings.DifficultyType, tutorial: bool = true, speedrun: bool = false) -> void :
	if readOnly:
		return
	var newGamePath: String = FileManager.SAVE_DIR + "file" + str(fake_node.fileID) + ".cg"
	GameSettings.dateCreated = int(Time.get_unix_time_from_system())
	GameSettings.systemTime = 0.0
	GameSettings.DisableRTA()
	GameSettings.runTime = 0.0
	GameSettings.ClearGameData()
	GameSettings.currentFileID = fake_node.fileID
	GameSettings.play_tutorial = tutorial
	GameSettings.ApplyPendingDifficulty()
	GameSettings.speedrun = speedrun
	
	if GameSettings.archipelagoEnabled:
		#Hard coded Time Hub and first level unlock, will need to change
		GameSettings.CheckLocation(1)
		GameSettings.CheckLocation(110000)
	
	FileManager.SaveGame()
	if is_instance_valid(fake_node):
		_ReadGame(fake_node, newGamePath)
	_LoadGame(fake_node)
