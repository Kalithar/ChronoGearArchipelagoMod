extends "res://Global Assets/Scripts/UI/MenuFileSelect.gd"

func State_EnterFile(delta):
	super(delta)
	if stateTimer == 0 and state == State_FileConfirm:
		menuFileOptions.CheckArchipelago()
