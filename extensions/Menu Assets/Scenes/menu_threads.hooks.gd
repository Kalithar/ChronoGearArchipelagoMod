extends Object

func _ready(chain: ModLoaderHookChain) -> void :
	chain.execute_next()
	if GameSettings.archipelagoEnabled:
		var ref = chain.reference_object
		ref.find_child("ThreadCount").text = str(int(GameSettings.ArchipelagoThreadsAvailable(ref.shop, ref.page)))
	
		for p in ref.pages.get_children():
			for option: Node in p.get_children():
				if option is ThreadOption:
					option.unlocked = GameSettings.archipelagoItemsPurchased[ref.shop][p.get_index()][option.get_index()]

func purchase(chain: ModLoaderHookChain) -> void:
	if !GameSettings.archipelagoEnabled: 
		chain.execute_next()
	else:
		var ref = chain.reference_object
		if (
			GameSettings.ArchipelagoThreadsAvailable(ref.shop, ref.page) < ref.current_thread.price
			or ref.current_thread.unlocked
			or ref.current_thread.unlock_type not in [ref.MUSIC, ref.BORDER_ART]
		):
			ref.PlaySound(ref.sfx_deny)
			return
			
		ref.find_child("PurchaseEffect").global_position = ref.current_thread.global_position
		for effect: GPUParticles2D in ref.find_child("PurchaseEffect").get_children():
			effect.restart()
		ref.find_child("Purchase").play()
		
		GameSettings.CheckShopLocation(ref.shop, ref.page, ref.current_thread.get_index())
		
		ref.current_thread.unlocked = true
		ref.find_child("ThreadCount").text = str(int(GameSettings.ArchipelagoThreadsAvailable(ref.shop, ref.page)))
		FileManager.SaveGame()

func move_page(chain: ModLoaderHookChain, side: Side) -> void :
	if !GameSettings.archipelagoEnabled:
		chain.execute_next([side])
	else:
		var ref = chain.reference_object
		var totalGears: int = GameSettings.archipelagoGearCount

		if ref.required_gear_count[ref.shop].size() <= 1:
			return
		var new_page: int
		var p: int = min(ref.unlocked_page_count + 1, ref.pages.get_children().size())
		match side:
			SIDE_LEFT: new_page = clamp(ref.page - 1, 0, p)
			SIDE_RIGHT: new_page = clamp(ref.page + 1, 0, p)


		if (
			totalGears < ref.required_gear_count[ref.shop][new_page] or 
			new_page == ref.page or 
			new_page >= ref.pages.get_child_count() or 
			not ref.pages.get_child(new_page)
		):
			ref.PlaySound(ref.sfx_deny)
			return


		ref.page = new_page
		ref.current_thread = ref.pages.get_child(new_page).get_child(0)
		ref.update_side_panel()
		ref.PlaySound(ref.sfx_scroll)
		ref.find_child("PreviewArt").hide()


		if ref._page_tweener: ref._page_tweener.kill()
		ref._page_tweener = ref.create_tween()
		ref._page_tweener.set_parallel()
		ref._page_tweener.tween_property(ref.pages, ^"position:x", ref.page * - ref.pages.size.x, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)

		ref._page_tweener.tween_property(ref.page_cursor, ^"position", ref.current_thread.position, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)


		if (
			ref.page + 1 < len(ref.required_gear_count[ref.shop])
			and ref.totalGears < ref.required_gear_count[ref.shop][ref.page + 1]
		):
			ref._page_tweener.tween_property( ref.find_child("RequiredGears"), ^"modulate", Color.WHITE, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
			ref.find_child("RequiredGears").text = str(ref.required_gear_count[ref.shop][ref.page + 1])
		else:
			ref._page_tweener.tween_property( ref.find_child("RequiredGears"), ^"modulate", Color.TRANSPARENT, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)

		ref.get_tree().create_timer(0.1).timeout.connect(set.bind(&"_lock", false))
		ref._lock = true

func update_side_panel(chain: ModLoaderHookChain) -> void:
	if !GameSettings.archipelagoEnabled: 
		chain.execute_next()
	else:
		var ref = chain.reference_object
		match ref.current_thread.unlock_type:
			ref.MUSIC, ref.BORDER_ART:
				var shopLocation
				match ref.shop:
					"time":
						shopLocation = 1000 + 100 * ref.page + ref.current_thread.get_index()
					"nature":
						shopLocation = 2000 + 100 * ref.page + ref.current_thread.get_index()
					"space":
						shopLocation = 3000 + 100 * ref.page + ref.current_thread.get_index()
					"civilization":
						shopLocation = 4000 + 100 * ref.page + ref.current_thread.get_index()
					"chaos":
						shopLocation = 5000 + 100 * ref.page + ref.current_thread.get_index()
				var shopItem = GameSettings.archipelagoShopItems[shopLocation]
				ref.find_child("Music").show()
				ref.find_child("MusicName").text = shopItem.get_name()
				ref.find_child("ArtistLabel").text = "For: " + Archipelago.conn.get_player_name(shopItem.dest_player_id)
				ref.find_child("OriginalLabel").text = shopItem.get_classification()
				
				ref.find_child("ThreadPrice").text = str(ref.current_thread.price)
				ref.reset_pan()
			_:
				chain.execute_next()
		
