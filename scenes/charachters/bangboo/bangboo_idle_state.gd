extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	if (GameInputEvents.is_movement_input):
		player.velocity = player.player_direction * player.speed
		player.move_and_slide()
	match player.player_direction:
		Vector2.UP:
			animated_sprite_2d.play("idle_back")
		Vector2.DOWN:
			animated_sprite_2d.play("idle_front")
		Vector2.LEFT:
			animated_sprite_2d.play("idle_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("idle_right")
		_:
			animated_sprite_2d.play("idle_front")
	pass


func _on_next_transitions() -> void:
	pass


func _on_enter() -> void:
	print('enter bangboo idle')
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
	pass
