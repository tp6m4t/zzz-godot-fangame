class_name AdventurousManager
extends Node


@export var tile: TileMapLayer
var map: Dungeon
var node_on_map: Array[Node] = []
var astar_grid: AStarGrid2D = AStarGrid2D.new()


func _load_bangboo(bangboo_name: String) -> Sprite2D:
	var bangboo_sprite := Sprite2D.new()
	var bangboo_texture = AtlasTexture.new()

	var image_path := "res://assets/images/bangboo/%s_spritesheet.png" % bangboo_name
	bangboo_texture.atlas = load(image_path)
	if not bangboo_texture.atlas:
		push_warning("can't find player texture: %s ues nomal bangboo instead" % image_path)
		bangboo_texture.atlas = load("res://assets/images/bangboo/bangboo_spritesheet.png")
	bangboo_texture.region = Rect2(Vector2.ZERO, Vector2(64, 64))
	bangboo_sprite.texture = bangboo_texture
	return bangboo_sprite

func _load_enemies(enemies_name: String) -> Sprite2D:
	var enemies_sprite := Sprite2D.new()
	var enemies_texture = AtlasTexture.new()

	var image_path := "res://assets/images/enemies/%s.png" % enemies_name
	enemies_texture.atlas = load(image_path)
	if not enemies_texture.atlas:
		push_warning("can't find player texture: %s ues nomal bangboo instead" % image_path)
		enemies_texture.atlas = load("res://assets/images/bangboo/bangboo_spritesheet.png")
	enemies_texture.region = Rect2(Vector2.ZERO, Vector2(64, 64))
	enemies_sprite.texture = enemies_texture
	return enemies_sprite

func _player_turn_end() -> void:
	print("player turn end")
	for node: Node in node_on_map:
		if node is CharactersBase:
			node.your_turn()

var player_name: String = "eous"
func _ready() -> void:
	map = Dungeon.new()
	_use_map_set_tile_map()
	_set_astar_grid()

	# 載入玩家資源
	var player_sprite := _load_bangboo(player_name)
	# 將玩家放在起始位置
	player_sprite.global_position = tile.map_to_local(map.start_cell)
	player_sprite.set_script(load("res://scripts/adventurous/characters/player_characters.gd"))
	$characters/player.add_child(player_sprite)
	# 讓相機跟隨玩家
	$Camera2D._focus(player_sprite)

	# 載入敵人資源
	var enemy_sprite := _load_enemies("blastcrawler")
	# 將敵人放在結束位置
	enemy_sprite.global_position = tile.map_to_local(map.end_cell)
	enemy_sprite.set_script(load("res://scripts/adventurous/characters/blastcrawler.gd"))
	$characters/enemies.add_child(enemy_sprite)

	node_on_map.append(enemy_sprite)
	node_on_map.append(player_sprite)

	'''
	player = $characters/player
	# 將玩家放在起始位置
	player = $characters/player
	player.get_node('Sprite2D').global_position = starting_position
	# 讓相機跟隨玩家
	$Camera2D._focus(player.get_node('Sprite2D'))
'''
	tile.set_cell(tile.map_to_local(map.end_cell), 0, Vector2i(4, 0))

	#相機 跟隨相關UI
	$CanvasLayer/InteractiveUI.camera = $Camera2D
	$CanvasLayer/InteractiveUI.focus_nodes.append(player_sprite)
	$CanvasLayer/InteractiveUI.focus_nodes.append(enemy_sprite)

	'''
	var _d: int = 10
	for d in range(_d):
		for x in range(-d, d + 1):
			for y in range(-d, d + 1):
				if max(abs(x), abs(y)) == d:
					var cell_pos = map.start_cell + Vector2i(x, y)
					if cell_pos.x >= 0 and cell_pos.y >= 0 and cell_pos.x < map.map_width and cell_pos.y < map.map_height:
						if map.map_strings[cell_pos.y][cell_pos.x] == '.' and cell_pos != map.start_cell and cell_pos != map.end_cell:
							var npc = preload("res://scenes/adventurous/characters/blastcrawler.tscn").instantiate()
							npc.tile = tile
							npc.scene_manager = self
							npc.global_position = tile.map_to_local(cell_pos)
							add_child(npc)
							node_on_map.append(npc)
							break
							'''
	
	"""
	tile.set_cell(Vector2i(0, 0), 0, Vector2i(4, 0))
	$Node2D2/Sprite2D2.global_position = tile.map_to_local(Vector2i(0, 0))
	print(tile.map_to_local(Vector2i(1, 1)))
	"""


func _use_map_set_tile_map() -> void:
	tile.clear()
	var set_terrain: Array[Vector2i] = []
	for y in range(map.map_height):
		for x in range(map.map_width):
			match map.map_strings[y][x]:
				'.':
					tile.set_cell(Vector2i(x, y), 0, Vector2i(7, 0))
					for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT,
							Vector2i(1, 1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(-1, -1)]:
						var np = Vector2i(x, y) + dir
						if (np.y < 0 || np.y >= map.map_height
								|| np.x < 0 || np.x >= map.map_width
								|| map.map_strings[np.y][np.x] == '#'):
							set_terrain.append(np)
	tile.set_cells_terrain_connect(set_terrain, 0, 0)


func _set_astar_grid() -> void:
	astar_grid.region = Rect2i(0, 0, map.map_width, map.map_height)
	astar_grid.cell_size = Vector2(1, 1)
	astar_grid.update()

	# 把牆壁設為 solid
	for y in range(map.map_height):
		for x in range(map.map_width):
			if map.map_strings[y][x] != ".":
				astar_grid.set_point_solid(Vector2i(x, y))


func get_node_on(cell_pos: Vector2i) -> Node:
	for node in node_on_map:
		var node_cell = tile.local_to_map(node.global_position)
		if node_cell == cell_pos:
			return node
	return null
