extends "res://Global Assets/Scripts/Items/ItemChest.gd"

func _ready():
	if GameSettings.archipelagoEnabled:
		startPosition = global_position
		itemStart = $Item.global_position
		state = State_Closed
		if setDoorFlag >= 1:
			if GameSettings.sentMazePartLocations[setDoorFlag] == true:
				$AnimatedSprite2D.play("open")
				$SensorHitbox / CollisionShape2D.disabled = true
				state = State_Done
		$Item.visible = false
	else: super()

func State_Closed(_delta):
	if GameSettings.archipelagoEnabled:
		if shaderMaterial:
			if setDoorFlag >= 1:
				var glowing = true
				var h: HUD = GameSettings.GetHud()
				for i in GameSettings.sentMazePartLocations.size():
					if GameSettings.sentMazePartLocations[i] == true:
						glowing = false
						break
				if glowing:
					glowAmt = fmod(glowAmt + 2.5 * _delta, 2 * PI)
					shaderMaterial.set_shader_parameter("amount", 0.1 * sin(glowAmt) + 0.1)
				else:
					shaderMaterial.set_shader_parameter("amount", 0)

		if iframes > 0:
			state = State_Open
			$SensorHitbox / CollisionShape2D.disabled = true
			$AnimatedSprite2D.play("open")
			PlaySound(sfxOpen)
			$treasureGlow.visible = true
			$treasureGlow / AnimationPlayer.play("glow")
	else: super(_delta)

func State_Item(delta):
	if GameSettings.archipelagoEnabled:
		if not targetPlayer:
			return

		if targetPlayer.state != targetPlayer.State_Gimmick_Damageable:
			state = State_Open
			return

		targetPlayer.call("PositionSnap", (global_position + playerOffset))
		targetPlayer.velocity = Vector2.ZERO
		targetPlayer.inv_flash_time = 0

		if stateTimer < 1.0:
			if holdItem and stateTimer > 0.5 and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("action")):
				stateTimer = 1.0

			stateTimer += delta
			if stateTimer >= 1.0:
				$Item.visible = true
				$Item / sparkle.emitting = true

				if setDoorFlag >= 0:
					var doors: int
					for i in GameSettings.sentMazePartLocations:
						if i:
							doors += 1

					PlaySound(sfxCollect[min(sfxCollect.size() - 1, doors)])
					if doors >= sfxCollect.size() and note != null:
						DropNotes()
				else:
					PlaySound(sfxCollect[0])

				if setDoorFlag >= 0:
					if self.find_child("NPC_Chest"):
						#Not sure why the interactable chest uses the same door flag as one of the real chests
						GameSettings.sentMazePartLocations[16] = true
						GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 600 + 16)
					else:
						GameSettings.sentMazePartLocations[setDoorFlag] = true
						GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 600 + setDoorFlag)
				else:
					var id = int(name.split("")[-1]) + 16
					GameSettings.sentMazePartLocations[id] = true
					GameSettings.CheckLocation(GameSettings.GetStageInfo(GameSettings.currentGoldenGear)[9] + 600 + id)

				if holdItem:
					targetPlayer.SetAnimation("pose_raise")
				else:
					state = State_DropItem
					stateTimer = 0
					targetPlayer.SetGimmick(null)
					return
		else:
			stateTimer += delta
			if stateTimer >= 1.9:
				$Item.global_position = $Item.global_position.move_toward(targetPlayer.global_position, 200 * delta)
			else:
				if $Item.global_position != targetPlayer.global_position + itemOffset:
					$Item.global_position = $Item.global_position.move_toward(targetPlayer.global_position + itemOffset, 300 * delta)
					if $Item.global_position == targetPlayer.global_position + itemOffset and get_node_or_null("Item/Label"):
						$Item / Label.global_scale = Vector2.ONE
						$Item / Label.global_rotation = 0
						$Item / Label / text / AnimationPlayer.play("Flash")
				if stateTimer > 1.3 and (Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("action")):
					stateTimer = 1.9
			if stateTimer > 2.0:
				$Item.visible = false
				targetPlayer.SetGimmick(null)
				state = State_Done
	else: super(delta)
