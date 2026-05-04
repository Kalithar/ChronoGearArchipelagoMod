extends Object

var archipelago_new_game_options : PackedScene = preload("res://mods-unpacked/Kalithar-Archipelago/extensions/Menu Assets/Scenes/menu_archipelagonewgame.tscn")
var archipelago_file_options: PackedScene = preload("res://mods-unpacked/Kalithar-Archipelago/extensions/Menu Assets/Scenes/menu_archipelagofileoptions.tscn")

func _ready(chain: ModLoaderHookChain) -> void :
	chain.reference_object.new_game_options = archipelago_new_game_options
	#This does work, it just opens on top of the file menu and looks really ugly.
	#Can be worked around for now, and I will find a way to fix it later.
	#chain.reference_object.file_options = archipelago_file_options
	chain.execute_next()
	
func CreateNewGame(chain: ModLoaderHookChain, diff: GameSettings.DifficultyType, tutorial: bool = true, speedrun: bool = false, archipelagoEnabled = false) -> void :
	chain.execute_next([diff, tutorial, speedrun])

func DeleteGame(chain: ModLoaderHookChain) -> void :
	var file_id = chain.reference_object._selected_node.fileID
	
	if GameSettings.archipelagoEnabled:
		Archipelago.save_manager.open_save.clear()
		Archipelago.save_manager.delete_save(file_id)
	
	chain.execute_next()
