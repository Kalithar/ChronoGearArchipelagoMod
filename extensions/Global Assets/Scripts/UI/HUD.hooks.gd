extends Object

func _ready(chain: ModLoaderHookChain):
	chain.execute_next()
	var reference = chain.reference_object as HUD
	var textBoxLabel = reference.find_child("Description") as Label
	textBoxLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
