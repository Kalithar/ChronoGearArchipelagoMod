extends Object

var archipelago_new_game_options : PackedScene = preload("res://mods-unpacked/Kalithar-Archipelago/extensions/Menu Assets/Scenes/menu_archipelagonewgame.tscn")

func _ready(chain: ModLoaderHookChain) -> void :
	chain.reference_object.new_game_options = archipelago_new_game_options
	chain.execute_next()
