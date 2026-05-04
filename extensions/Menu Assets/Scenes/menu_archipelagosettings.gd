class_name ArchipelagoMenu
extends GameMenu

var connectionInProgress: bool = false

func _ready() -> void:
	%ServerAddressBox.text = ""
	%SlotNameBox.text = ""
	%PasswordBox.text = ""
	Archipelago.connect_step.connect(UpdateConnectionStatus)
	Archipelago.connectionrefused.connect(OnConnectRefused)
	Archipelago.connected.connect(OnConnect)
	Archipelago.disconnected.connect(OnDisconnect)
	Archipelago.roominfo.connect(OnRoomInfo)
	super._ready()

func _input(event: InputEvent):
	if (
		not enabled or 
		not _local_enable or 
		not GameSettings.input_enabled or 
		(GameSettings.hud and GameSettings.hud.pauseDelay > 0) or 
		(visibility and not visibility.visible)
	):
		return

	if (
		parentMenu
		and "enabled" in parentMenu
		and parentMenu.enabled
	):
		return



	if (
		is_pause_menu
		and event.is_action_pressed("pause")
		and parentMenu.pauseDelay <= 0
	):
		var frame_advance: = false
		for device in range(Input.get_connected_joypads().size()):
			if Input.is_joy_button_pressed(device, JOY_BUTTON_BACK):
				frame_advance = true
		if Input.is_key_pressed(KEY_TAB):
			frame_advance = true
		call_deferred("FrameUnpause", frame_advance)
		return

	if (
		event.is_action_pressed("menu_cancel")
		or (
			event is InputEventKey
			and event.is_pressed()
			and not event.is_echo()
			and event.get_keycode() == KEY_ESCAPE
		) or (
			event is InputEventMouseButton
			and event.is_pressed()
			and event.get_button_index() == MOUSE_BUTTON_RIGHT
		)
	):
		if _return and _node_focus != _return:
			#Something needs to be here, but need this branch of the if to do nothing
			_node_focus = _node_focus
		elif _node_focus == _return:
			if _return.returnOnCancelInput:
				call_deferred("_Return")
			else:
				_ProcessAction(_return)
		elif parentMenu is not DialogBox:
			call_deferred("_Return")



	_last_input_is_mouse = event is InputEventMouse




	if not _node_focus:
		prints(self, "has no focus node")


		if option_tree_size:
			for option in option_tree_children:
				if option.enabled:
					MoveCursorToNode(option)
					break
		return

	var target_node: Node = null

	for device in range(Input.get_connected_joypads().size()):
		if Input.is_joy_button_pressed(0, JOY_BUTTON_BACK):
			return
	if Input.is_key_pressed(KEY_TAB):
		return

	if (
		event.is_action_pressed("menu_confirm")
		and Input.is_action_just_pressed("menu_confirm")
	):
		if _node_focus:
			_ProcessAction(_node_focus)
	else:
		target_node = _ProcessDirection(event)

	if target_node:
		MoveCursorToNode(target_node)


		_input_delay = GameSettings.SCROLL_TIMING

func SetEnabled(state: bool, _option_focus: int = 0, fade: bool = false, delay: bool = true) -> void :
	if enabled:
		%ServerAddressBox.text = ""
		%SlotNameBox.text = ""
		%PasswordBox.text = ""
	super(state, _option_focus, fade, delay)

func _ProcessAction(node: Node, left_right: = 0, play_sound: = true) -> void :
	var sfx_override = null
	if (
		not node or 
		not node.enabled or 
		node.get_script() not in [MenuOptionNew, DifficultyOption, BorderOption, CodecOption, LanguageOption, MenuOptionArchipelago]
	):
		PlaySound(sfx_deny)
		return

	if "sound_on_selection" in node:
		play_sound = node.sound_on_selection

	if (
		"sfx_override" in node
		and node.sfx_override
	):
		sfx_override = node.sfx_override
		play_sound = true

	match node.call_type:
		GameSettings.CallType.NONE when play_sound:
			PlaySound(sfx_deny)
		GameSettings.CallType.RETURN:
			exited.emit()
			_Return.call_deferred(node.call_on_selection == "Save")
			return
		GameSettings.CallType.CALLABLE:
			if play_sound:
				PlaySound(sfx_override if sfx_override else sfx_confirm)
			_Call(node, left_right)
			if node.call_on_selection in ["ReloadScene", "SkipCutscene", "ExitStage", "ExitToTitle"]:
				SetEnabled(false, current_option, true, false)
			exited.emit()
			option_selected.emit(node.call_on_selection)
			return
		GameSettings.CallType.PACKED_SCENE:
			if play_sound:
				PlaySound(sfx_override if sfx_override else sfx_confirm)
			last_node = node
			exited.emit()
			option_selected.emit(node.name)
			_LoadNewMenu(node)
			return
		GameSettings.CallType.PARENT:
			if play_sound:
				PlaySound(sfx_override if sfx_override else sfx_confirm)
			option_selected.emit(node.name)
			exited.emit()
			_Call(node, left_right, true)
			return
		_:
			printerr("GameSettings CallType %d not recognized" % node.call_type)
	PlaySound(sfx_deny)
	
func _BuildOptionTree() -> void :
	if option_tree:
		option_tree_children = option_tree.get_children()
		option_tree_size = option_tree_children.size()

	for option in option_tree_children:


			if option.mouse_entered.is_connected(_HoverHandler):
				option.mouse_entered.disconnect(_HoverHandler)
			option.mouse_entered.connect(_HoverHandler.bind(option))

			if option.gui_input.is_connected(_ClickHandler):
				option.gui_input.disconnect(_ClickHandler)
			option.gui_input.connect(_ClickHandler.bind(option))

	_return = %Return

	if %Return.mouse_entered.is_connected(_HoverHandler):
		%Return.mouse_entered.disconnect(_HoverHandler)
	%Return.mouse_entered.connect(_HoverHandler.bind( %Return))

	if %Return.gui_input.is_connected(_ClickHandler):
		%Return.gui_input.disconnect(_ClickHandler)
	%Return.gui_input.connect(_ClickHandler.bind( %Return))

	option_tree_children.append( %Return)
	option_tree_size += 1

	if description_tree:
		description_tree_children = description_tree.get_children()
		description_tree_size = description_tree_children.size()

func ConnectToArchipelago() -> void :
	var connectionString = %ServerAddressBox.text.split(":")
	
	connectionInProgress = true
	Archipelago.ap_connect(connectionString[0], connectionString[1], %SlotNameBox.text, %PasswordBox.text)

func DisconnectFromArchipelago() -> void :
	connectionInProgress = true
	Archipelago.ap_disconnect()

func UpdateDescription() -> void :
	if !connectionInProgress:
		super()

func UpdateConnectionStatus(msg: String) -> void:
	%ConnectionInfo.text = msg

func OnConnect(conn: ConnectionInfo, json: Dictionary):
	connectionInProgress = false
	%ConnectButton.visible = false
	%Disconnect.visible = true
	
	#Every shop location needs to be scouted
	for i in [1000, 1001, 1002, 1003, 1004, 1100, 1101, 1102, 1103, 1104, 1200, 1201, 1202, 1203, 1204, 1205, 1206, 1207, 1208, 1209, 1210, 1211, 1212,
			  2000, 2001, 2002, 2003, 3000, 3001, 3002, 3003, 3100, 3101, 3102, 3103, 4000, 4001, 4002, 4003, 4004, 4005, 4006, 
			  5000, 5001, 5002, 5003, 5004, 5006, 5006, 5007, 5008]:
		Archipelago.conn.scout(i, 0, GameSettings.StoreShopItem)
	
	#Send archipelago the list of collected items in case anything was collected while disconnected
	#Server handles all duplicates, don't need to worry here
	var locationsToSend: Array[int]
	for i in GameSettings.checkedLocations:
		locationsToSend.append(i)
	Archipelago.collect_locations(locationsToSend)
	GameSettings.slotData = conn.slot_data
	
func OnConnectRefused(conn: ConnectionInfo, json: Dictionary):
	connectionInProgress = false

func OnRoomInfo(conn: ConnectionInfo, json: Dictionary):
	Archipelago.conn.received_items = GameSettings.receivedItems
	Archipelago.conn.obtained_item.connect(GameSettings.ReceiveServerItem)
	Archipelago.conn.refresh_items.connect(GameSettings.RefreshItems)

func OnDisconnect():
	connectionInProgress = false
	%ConnectButton.visible = true
	%Disconnect.visible = false

#I deleted a thing I shouldn't have, the bit that changes the description to show the %ConnectionInfo is gone
