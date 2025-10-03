extends CharactersBase

var Explode_remaining_rounds: int = 10
var is_action: bool = false
var player: Node = null

func your_turn() -> void:
	print("blastcrawler turn")

	if !is_action:
		var cell_pos = scene_manager.tile.local_to_map(global_position)
		for x in range(-2, 3):
			for y in range(-2, 3):
				var node: Node = scene_manager.get_node_on(cell_pos + Vector2i(x, y))
				if node is CharactersBase and node.type == CharactersBase.CharactersType.Player:
					is_action = true
					player = node
	
	
	if is_action:
		Explode_remaining_rounds -= 1
		var my_cell: Vector2i = scene_manager.tile.local_to_map(global_position)
		if Explode_remaining_rounds <= 0:
			for x in range(-1, 2):
				for y in range(-1, 2):
					var node: Node = scene_manager.get_node_on(Vector2i(my_cell.x + x, my_cell.y + y))
					if node is CharactersBase:
						node.hp -= attack
			hp = 0

		if hp > 0:
			var player_cell: Vector2i = scene_manager.tile.local_to_map(player.global_position)
			var path := scene_manager.astar_grid.get_point_path(my_cell, player_cell)
			if path.size() > 2:
				global_position = scene_manager.tile.map_to_local(path[1])
			else:
				print("can't find path (%d, %d) to (%d, %d)" % [my_cell.x, my_cell.y, player_cell.x, player_cell.y])

func _process(delta: float) -> void:
	if is_action and Explode_remaining_rounds < 3:
		# 閃爍頻率：回合數越少 → 越快
		var frequency := 4.0 * (4 - Explode_remaining_rounds) # 1 回合剩下 → 頻率最大
		var intensity := (sin(Time.get_ticks_msec() / 1000.0 * PI * frequency) + 1.0) / 2.0
		# 用紅色閃爍
		modulate = Color(1, intensity, intensity)
	else:
		# 恢復正常顏色
		modulate = Color(1, 1, 1)
