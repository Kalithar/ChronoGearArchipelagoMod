extends "res://Menu Assets/Scenes/menu_threads.gd"

func _ready() -> void :
	if(!GameSettings.archipelagoEnabled):
		super()
	else:
		if OS.is_debug_build() and _debug:
			push_warning("MenuThreads: Debug is on")
			var g: Array[bool] = []
			GameSettings.goldenGears.fill(true)
			GameSettings.threadsCollected.resize(_debug_threads)
			GameSettings.threadsCollected.fill(true)
			shop = _debug_shop
		super._ready()


		assert (shop != "", "No shop set. If starting from this scene, turn debug on in %s." % name)
		assert (shop in required_gear_count.keys(), "Shop not in required_gears_count")
		var pages_path: = NodePath("%" + shop.to_pascal_case())
		assert (has_node(pages_path), "Node not found: " + str(pages_path))
		pages = get_node(pages_path)
		page_cursor = %PageCursor
		current_thread = pages.get_child(page).get_node(^"Unlock1")
		page_cursor.position = current_thread.position

		update_side_panel()
		%Visualizer.menuJukebox = self
		%Visualizer.show()
		%PreviewArt.hide()
		pages.show()
		%PageName.text = tr("World of %s" % shop.capitalize())
		%ThreadCount.text = str(GameSettings.ArchipelagoThreadsAvailable(shop, page))

		var totalGears: int
		totalGears = GameSettings.archipelagoGearCount


		for i in pages.get_child_count():
			if (
				pages.get_child(i) is ThreadOption
				and totalGears >= required_gear_count[shop][i]
			):
				unlocked_page_count = i
		if required_gear_count[shop].size() > 1:
			if required_gear_count[shop][1] > totalGears:
				%RequiredGears.modulate = Color.WHITE
				%GearLabel.text = str(required_gear_count[shop][1])
		else:
			%PageLeft.visible = false
			%PageRight.visible = false


		if pages.get_child_count() == 1:
			%PageLeft.hide()
			%PageRight.hide()

func purchase() -> void:
	if !GameSettings.archipelagoEnabled: 
		super()
	else:
		if (
			GameSettings.ThreadsAvailable() < current_thread.price
			or current_thread.unlocked
			or current_thread.unlock_type not in [MUSIC, BORDER_ART]
		):
			PlaySound(sfx_deny)
			return

	%PurchaseEffect.global_position = current_thread.global_position
	for effect: GPUParticles2D in %PurchaseEffect.get_children():
		effect.restart()
	$Purchase.play()
	
	GameSettings.CheckShopLocation(shop, page, current_thread.get_index())
	
	%ThreadCount.text = str(GameSettings.ThreadsAvailable())
	FileManager.SaveGame()
