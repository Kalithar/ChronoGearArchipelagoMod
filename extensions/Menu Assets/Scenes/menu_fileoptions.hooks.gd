extends Object
const archipelagoLabel = preload("res://mods-unpacked/Kalithar-Archipelago/extensions/Menu Assets/Scenes/menu_archipelagooption.tscn")
var apLabel: Node

func _ready(chain: ModLoaderHookChain) -> void :
	if GameSettings.archipelagoEnabled:
		var title = chain.reference_object as TitleMenu
		apLabel = archipelagoLabel.instantiate()
		var startGame = title.find_child("Start")
		var extras = title.find_child("Extras")
		
		startGame.add_sibling(apLabel)
		
		#Set Neighbors
		apLabel.focus_neighbor_top = startGame.get_path()
		apLabel.focus_previous = startGame.get_path()
		apLabel.focus_neighbor_bottom = extras.get_path()
		apLabel.focus_next = extras.get_path()
		startGame.focus_neighbor_bottom = apLabel.get_path()
		startGame.focus_next = apLabel.get_path()
		extras.focus_neighbor_top = apLabel.get_path()
		extras.focus_previous = apLabel.get_path()
	
	chain.execute_next_async()

func CheckArchipelago() -> void:
	if GameSettings.archipelagoEnabled:
		apLabel.visible = true
	else:
		apLabel.visible = false
