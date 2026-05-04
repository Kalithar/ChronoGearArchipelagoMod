extends Object
const archipelagoLabel = preload("res://mods-unpacked/Kalithar-Archipelago/extensions/Menu Assets/Scenes/menu_archipelagooption.tscn")
var apLabel: Node

func _ready(chain: ModLoaderHookChain) -> void :
	var title = chain.reference_object as TitleMenu
	apLabel = archipelagoLabel.instantiate()
	var fileSelect = title.find_child("FileSelect")
	var settingsOption = title.find_child("Settings")
	
	fileSelect.add_sibling(apLabel)
	
	#Set Neighbors
	apLabel.focus_neighbor_top = fileSelect.get_path()
	apLabel.focus_previous = fileSelect.get_path()
	apLabel.focus_neighbor_bottom = settingsOption.get_path()
	apLabel.focus_next = settingsOption.get_path()
	fileSelect.focus_neighbor_bottom = apLabel.get_path()
	fileSelect.focus_next = apLabel.get_path()
	settingsOption.focus_neighbor_top = apLabel.get_path()
	settingsOption.focus_previous = apLabel.get_path()
	
	chain.execute_next_async()

func SetEnabled(chain: ModLoaderHookChain, state: bool, _option_focus: int = 0, fade: bool = false, delay: bool = true) -> void :
	apLabel.visible = GameSettings.archipelagoEnabled
	
	chain.execute_next([state, _option_focus, fade, delay])
