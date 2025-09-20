extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	match player.player_direction:
		Vector2.UP:
			animated_sprite_2d.play("walk_back")
		Vector2.DOWN:
			animated_sprite_2d.play("walk_front")
		Vector2.LEFT:
			animated_sprite_2d.play("walk_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("walk_right")
			
	player.velocity = player.player_direction * player.speed
	player.move_and_slide()
			
	pass


func _on_next_transitions() -> void:
	if !GameInputEvents.is_movement_input:
		transition.emit("Idle")


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
