extends CharactersBase


func _ready() -> void:
	super._ready()
	type = CharactersType.Player


func _physics_process(_delta: float) -> void:
	var cell := tile.local_to_map(global_position)
	if Input.is_action_just_pressed("walk_left"):
		if scene_manager.map.map_strings[cell.y][cell.x - 1] == '.':
			global_position += Vector2.LEFT * tile.tile_set.tile_size.x
			scene_manager._player_turn_end()
	elif Input.is_action_just_pressed("walk_right"):
		if scene_manager.map.map_strings[cell.y][cell.x + 1] == '.':
			global_position += Vector2.RIGHT * tile.tile_set.tile_size.x
			scene_manager._player_turn_end()
	elif Input.is_action_just_pressed("walk_up"):
		if scene_manager.map.map_strings[cell.y - 1][cell.x] == '.':
			global_position += Vector2.UP * tile.tile_set.tile_size.y
			scene_manager._player_turn_end()
	elif Input.is_action_just_pressed("walk_down"):
		if scene_manager.map.map_strings[cell.y + 1][cell.x] == '.':
			global_position += Vector2.DOWN * tile.tile_set.tile_size.y
			scene_manager._player_turn_end()
