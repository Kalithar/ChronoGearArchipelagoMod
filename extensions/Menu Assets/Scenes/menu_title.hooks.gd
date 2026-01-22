extends Object
const archipelagoLabel = preload("res://mods-unpacked/Kalithar-Archipelago/extensions/Menu Assets/Scenes/menu_archipelagooption.tscn")

func _ready(chain: ModLoaderHookChain) -> void :
	var title = chain.reference_object as TitleMenu
	var apLabel = archipelagoLabel.instantiate()
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
