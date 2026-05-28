extends "res://Global Assets/Scripts/Objects/StageSelectPortal.gd"

func State_Default(_delta):
	if targetPlayer and not GameSettings.GetHud().cutscene:
		$ButtonPrompt.visible = true
		#var storyCheck: bool = false
		#if cutsceneInterruption:
			#if cutsceneInterruption.checkStoryFlag != "":
				#var sf = GameSettings.GetStoryFlag(cutsceneInterruption.checkStoryFlag)
				#if sf >= cutsceneInterruption.checkStoryFlagMin and sf <= cutsceneInterruption.checkStoryFlagMax:
					#storyCheck = true
			#else:
				#storyCheck = true

		if Input.is_action_just_pressed("up"):
			#if storyCheck:
				#cutsceneInterruption.get_node("CollisionShape2D").disabled = false
			#else:
				var h = GameSettings.GetHud() as HUD
				targetPlayer.call("SetGimmick", self)
				targetPlayer.call("DisableCollision", true)
				targetPlayer.call("SetAnimation", "intro")
				state = State_Open
				var b = effect.instantiate() as Node2D
				GameSettings.CurrentScene().add_child(b)
				b.global_position = global_position
				h.FadeMusic()
	else:
		$ButtonPrompt.visible = false
