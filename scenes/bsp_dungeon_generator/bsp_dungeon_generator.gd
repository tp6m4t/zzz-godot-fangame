# File: bsp_dungeon_generator.gd
# 掛在 Node2D 上，scene 中需有一個 TileMapLayer 節點命名為 "TileMapLayer"
# TileMapLayer 要先設定好 tile 0 = floor, 1 = wall, 2 = stairs_down, 3 = stairs_up（或依你 tileset 調整）
extends Node2D

class_name BSPDungeonGenerator

# 地圖參數
@export var map_width: int = 80
@export var map_height: int = 50
@export var min_room_size: int = 5
@export var max_room_size: int = 14
@export var max_splits: int = 5 # BSP 的最大遞迴深度（或次數）
@export var corridor_radius: int = 0 # 走廊寬度（0 = 1 格）


# 產物數量設定
@export var num_item_heaps: int = 10
@export var num_mobs: int = 18

# 內部資料
var rng := RandomNumberGenerator.new()
var _dungeons: Array[BSPDungeon]
var _level := 0:
	get:
		return _level
	set(value):
		_level = value
		_draw_to_tilemap()
	

# 參考 TileMapLayer
@onready var floor_tilemap: TileMapLayer = $"TileMapLayers/FloorTileMapLayer"
@onready var wall_tilemap: TileMapLayer = $"TileMapLayers/WallTileMapLayer"

func _ready():
	rng.randomize()
	generate_new_dungeon()
	_draw_to_tilemap()
	var main_scene_path := 'res://scenes/main_scene.tscn'
	$CanvasLayer/back.pressed.connect(get_tree().change_scene_to_file.bind(main_scene_path))


func generate_new_dungeon():
	var level := BSPDungeon.new()
	level.set_and_generate_dungeon(map_width, map_height,
		min_room_size, max_room_size,
		max_splits, corridor_radius, rng.randi()
	)
	_dungeons.push_back(level)
	_set_level_ui()

func _set_level_ui():
	var level_btn_group = $CanvasLayer/ScrollContainer/VBoxContainer
	if level_btn_group:
		for child in level_btn_group.get_children():
			child.queue_free()
		var btn = Button.new()
		btn.text = "new level"
		btn.pressed.connect(generate_new_dungeon)
		level_btn_group.add_child(btn)
		for i in range(len(_dungeons)):
			var level_btn = Button.new()
			level_btn.text = "level " + str(i)
			level_btn.pressed.connect(func(): _level = i)
			level_btn_group.add_child(level_btn)

			
func get_level_dungeon() -> BSPDungeon:
	if (_level in _dungeons):
		return _dungeons[_level]
	return _dungeons[0]


# -------------------------
# 最後將 map 繪到 TileMap（或改成 instancing nodes）
# TileMap 的 tile index 對應請自行調整
# -------------------------
func _draw_to_tilemap():
	print('draw dungeon level: ', _level)
	if floor_tilemap == null or wall_tilemap == null:
		push_error("TileMap not found!")
		return
	floor_tilemap.clear()
	wall_tilemap.clear()
	var floor_set: Array[Vector2i] = []
	var wall_set: Array[Vector2i] = []
	for y in range(map_height):
		for x in range(map_width):
			var t: BSPDungeon.Terrain = _dungeons[_level].terrain_map[y][x]
			var pos := Vector2i(x, y)
			if t == BSPDungeon.Terrain.Floor:
				floor_tilemap.set_cell(pos, 0, Vector2i(0, 0))
				floor_set.append(pos) # floor tile index
			elif t == BSPDungeon.Terrain.Wall:
				wall_set.append(pos) # wall tile index
			elif t == 2:
				floor_tilemap.set_cell(pos, 0, Vector2i(0, 2)) # stairs up tile index
			elif t == 3:
				floor_tilemap.set_cell(pos, 0, Vector2i(0, 4)) # stairs down tile index
			# 其餘值可表示特殊 marker
	wall_tilemap.set_cells_terrain_connect(wall_set, 0, 0)
