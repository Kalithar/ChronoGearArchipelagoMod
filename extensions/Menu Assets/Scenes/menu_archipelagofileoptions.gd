class_name ArchipelagoFileOptions
extends FileOptionsMenu

func _ready() -> void:
	super()
	%MenuArchipelagoOption.visible = GameSettings.archipelagoEnabled
