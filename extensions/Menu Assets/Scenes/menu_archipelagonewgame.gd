class_name ArchipelagoNewGameOptions
extends NewGameOptionsMenu

var _archipelago: bool = false

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

func _SetArchipelago(state: bool) -> void :
	_archipelago = state
	%ArchipelagoCheck.set_visible(state)
	%ArchipelagoLabel.text = tr("Yes") if state else tr("No")

func ToggleArchipelago() -> void:
	_SetArchipelago(not _archipelago)

func NewGame() -> void :
	GameSettings.archipelagoEnabled = _archipelago
	parentMenu.CreateNewGame(local_difficulty, _play_tutorial, _speedrun)
