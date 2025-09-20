extends NodeState

@export var NPC: Role
@export var animated_sprite_2d: AnimatedSprite2D

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	var player =  NPC.get_player()
	if player :
		NPC.velocity = (player.global_position - NPC.global_position).normalized() * NPC.speed
		NPC.move_and_slide()
		print('NPC move')
	else :
		print('can\'t find player')
	
	var dir = NPC.direction()
	animated_sprite_2d.play(get_facing_direction(dir))
	pass


func _on_next_transitions() -> void:
	if !Input.is_action_pressed("test_key"):
		transition.emit("Idle")
	pass


func _on_enter() -> void:
	print('enter npc walk')
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
	pass
	

func get_facing_direction(dir: Vector2) -> String:
	if dir == Vector2.ZERO:
		return "idle_front"  # 沒有方向 → 預設正面

	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			return "idle_right"
		else:
			return "idle_left"
	else:
		if dir.y > 0:
			return "idle_front"
		else:
			return "idle_back"
