extends NodeState

@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D


func _on_process(_delta: float) -> void:
	pass


func _on_physics_process(_delta: float) -> void:
	pass


func _on_next_transitions() -> void:
	if !animated_sprite_2d.is_playing():
		transition.emit("Idle")


func _on_enter() -> void:
	match player.player_direction:
		Vector2.UP:
			animated_sprite_2d.play("chopping_back")
		Vector2.DOWN:
			animated_sprite_2d.play("chopping_front")
		Vector2.LEFT:
			animated_sprite_2d.play("chopping_left")
		Vector2.RIGHT:
			animated_sprite_2d.play("chopping_right")
		_:
			animated_sprite_2d.play("choppint_front")
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
