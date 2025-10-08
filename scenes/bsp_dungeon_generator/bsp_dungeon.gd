class_name BSPDungeon


enum Terrain {
	Floor,
	Wall
}

@export var terrain_map: Array[Array] = [] # 二維陣列 Array[Array[Terrain]] 0 = floor, 1 = wall
@export var item_heaps: Array
@export var mobs: Array
@export var stairs_up_pos: Vector2i = Vector2i(0, 0)
@export var stairs_down_pos: Vector2i = Vector2i(0, 0)


var _rng := RandomNumberGenerator.new()
var _max_splits: int = 5 # BSP 的最大遞迴深度（或次數）
var _corridor_radius: int = 0 # 走廊寬度（0 = 1 格）
var _rooms = [] # 房間陣列，每項為字典 {rect=Rect2i, center=Vector2i, is_special=false}
var _min_room_size: int = 5
var _max_room_size: int = 15
var _rng_seed: int = 0
var _map_width: int = 100
var _map_height: int = 100


func set_and_generate_dungeon(map_width: int = 100, map_height: int = 100,
		min_room_size: int = 5, max_room_size: int = 15,
		max_splits: int = 5, corridor_radius: int = 0, rng_seed: int = 0):
	if !rng_seed:
		_rng.randomize()
		_rng_seed = _rng.seed
	else:
		_rng_seed = rng_seed
		_rng.seed = rng_seed
	_max_splits = max_splits
	_corridor_radius = corridor_radius
	_min_room_size = min_room_size
	_max_room_size = max_room_size
	_map_width = map_width
	_map_height = map_height
	_generate_dungeon()


func _generate_dungeon():
	_init_map()
	var root_rect = Rect2i(0, 0, _map_width, _map_height)
	# BSP 切分產生房間候選
	_rooms.clear()
	_bsp_split(root_rect, 0)
	# 從候選中挑一部分作為實際房間，並 carve
	for r in _rooms:
		_carve_room(r.rect)
	# 用房間中心連接（簡單 MST 或依序連接）
	_connect_rooms()
	# 放入樓梯：第一個房間作為樓上，最後房間作為樓下（或隨機）
	_place_stairs()
	# 放置物品堆與怪物（僅標記位置或實體化）
	#_place_item_heaps()
	#_place_mobs()
	print("Dungeon generated: rooms=", _rooms.size(), " seed=", _rng.seed, " test rng: ", str(_rng.randi()))

func _init_map():
	terrain_map.clear()
	for y in range(_map_height):
		var row = []
		for x in range(_map_width):
			row.append(1) # 1 = wall（先全部為牆）
		terrain_map.append(row)


func _bsp_split(rect: Rect2i, depth: int):
	# 當深度超過或空間過小時，直接嘗試當房間
	if depth >= _max_splits or rect.size.x <= _max_room_size * 2 or rect.size.y <= _max_room_size * 2:
		_try_place_room(rect)
		return
	
	# 決定橫向 or 縱向切分（根據長寬比 + 隨機）
	var split_h = false
	if rect.size.x > rect.size.y + 3:
		split_h = false
	elif rect.size.y > rect.size.x + 3:
		split_h = true
	else:
		split_h = _rng.randi_range(0, 1) == 0
	
	if split_h:
		# 橫向切分（沿 y 軸分）
		var min_split := rect.position.y + _min_room_size
		var max_split := rect.position.y + rect.size.y - _min_room_size
		if max_split - min_split <= _min_room_size:
			_try_place_room(rect)
			return
		var split = _rng.randi_range(min_split + 1, max_split - 1)
		var top = Rect2i(rect.position.x, rect.position.y, rect.size.x, split - rect.position.y)
		var bottom = Rect2i(rect.position.x, split, rect.size.x, rect.position.y + rect.size.y - split)
		_bsp_split(top, depth + 1)
		_bsp_split(bottom, depth + 1)
	else:
		# 縱向切分
		var min_split_x := rect.position.x + _min_room_size
		var max_split_x := rect.position.x + rect.size.x - _min_room_size
		if max_split_x - min_split_x <= _min_room_size:
			_try_place_room(rect)
			return
		var splitx = _rng.randi_range(min_split_x + 1, max_split_x - 1)
		var left = Rect2i(rect.position.x, rect.position.y, splitx - rect.position.x, rect.size.y)
		var right = Rect2i(splitx, rect.position.y, rect.position.x + rect.size.x - splitx, rect.size.y)
		_bsp_split(left, depth + 1)
		_bsp_split(right, depth + 1)


# 嘗試在給定區域放一個房間（隨機房間大小與對齊）
func _try_place_room(area: Rect2i):
	# 隨機房間大小但不要超出 area
	var rw = _rng.randi_range(_min_room_size, min(_max_room_size, area.size.x - 2))
	var rh = _rng.randi_range(_min_room_size, min(_max_room_size, area.size.y - 2))
	var rx = _rng.randi_range(area.position.x + 1, area.position.x + area.size.x - rw - 1)
	var ry = _rng.randi_range(area.position.y + 1, area.position.y + area.size.y - rh - 1)
	var room_rect = Rect2i(rx, ry, rw, rh)
	# 檢查是否與既有房間過度接近（避免重疊）
	for ex in _rooms:
		if room_rect.grow(1).intersects(ex.rect):
			return # 放棄
	# 加入房間
	var center = Vector2i(room_rect.position.x + int(room_rect.size.x / 2), room_rect.position.y + int(room_rect.size.y / 2))
	_rooms.append({"rect": room_rect, "center": center, "is_special": false})

## 地形設定:將當前地圖在rect範圍設為地板
func _carve_room(rect: Rect2i):
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if _in_bounds(x, y):
				terrain_map[y][x] = 0 # 0 = floor


## 檢查：檢查座標是否在當前地圖設定範圍內
func _in_bounds(x: int, y: int) -> bool:
	return x >= 0 and x < _map_width and y >= 0 and y < _map_height


## 連接房間：使用簡單的連接法（依據房間中心排序然後連接相鄰）
## 也可改為 Prim/Kruskal 生成最小生成樹
func _connect_rooms():
	if _rooms.size() == 0:
		return
	# 先排序（例如按 x），再依序連接
	_rooms.sort_custom(_sort_room_by_x)
	for i in range(_rooms.size() - 1):
		var a = _rooms[i].center
		var b = _rooms[i + 1].center
		_create_tunnel(a, b)

## 房間的排序規則 
func _sort_room_by_x(a, b) -> int:
	return int(a.center.x - b.center.x)

## 地形設定:放置 L 形走廊（或隨機先橫後直 / 先直後橫）
func _create_tunnel(a: Vector2i, b: Vector2i):
	if _rng.randi_range(0, 1) == 0:
		_create_h_corridor(a.x, b.x, a.y)
		_create_v_corridor(a.y, b.y, b.x)
	else:
		_create_v_corridor(a.y, b.y, a.x)
		_create_h_corridor(a.x, b.x, b.y)


## 地形設定:放置指定寬度的一條垂直地面
func _create_h_corridor(x1: int, x2: int, y: int):
	var sx = min(x1, x2)
	var ex = max(x1, x2)
	for x in range(sx, ex + 1):
		for oy in range(-_corridor_radius, _corridor_radius + 1):
			var yy = y + oy
			if _in_bounds(x, yy):
				terrain_map[yy][x] = 0


## 地形設定:放置指定寬度的一條水平地面
func _create_v_corridor(y1: int, y2: int, x: int):
	var sy = min(y1, y2)
	var ey = max(y1, y2)
	for y in range(sy, ey + 1):
		for ox in range(-_corridor_radius, _corridor_radius + 1):
			var xx = x + ox
			if _in_bounds(xx, y):
				terrain_map[y][xx] = 0

## 地形設定:放置樓梯（簡單版：第一間房為上樓，最後一間為下樓）
func _place_stairs():
	if _rooms.size() == 0:
		return
	# 入口：第一個房間中心
	stairs_up_pos = _rooms[0].center
	terrain_map[stairs_up_pos.y][stairs_up_pos.x] = 2 # tile index for up stairs
	_rooms[0].is_special = true
	# 出口：最後一個房間（或隨機一個離起點較遠的房間）
	var last = _rooms[_rooms.size() - 1]
	stairs_down_pos = last.center
	terrain_map[stairs_down_pos.y][stairs_down_pos.x] = 3 # tile index for down stairs
	last.is_special = true

'''
# -------------------------
# 放置物品堆（只選 floor 格，避免在 special 房或牆上）
# 你可以在這裡實例化道具場景（PackedScene）
# -------------------------
func _place_item_heaps():
	var placed = 0
	var tries = 0
	while placed < num_item_heaps and tries < num_item_heaps * 20:
		tries += 1
		var rx = rng.randi_range(1, map_width - 2)
		var ry = rng.randi_range(1, map_height - 2)
		if map[ry][rx] == 0 and not _is_special_tile(rx, ry):
			# 標記為 item heap (we'll use tile 4 as marker or instantiate scene)
			# 這裡僅示範放 tile 值 = 4，實際請用實體化 PackedScene
			# map[ry][rx] = 4
			# 或呼叫 _spawn_item_heap_at(Vector2(rx, ry))
			_spawn_item_heap_at(Vector2i(rx, ry))
			placed += 1

func _spawn_item_heap_at(pos: Vector2i):
	# 範例：如果你有 PackedScene "res://scenes/ItemHeap.tscn"
	# var scene = preload("res://scenes/ItemHeap.tscn")
	# var inst = scene.instance()
	# inst.position = Vector2(pos.x * tilemap.cell_size.x, pos.y * tilemap.cell_size.y)
	# add_child(inst)
	# 目前用 print 示範
	print("Place item heap at ", pos)

# -------------------------
# 放置怪物（同理）
# -------------------------
func _place_mobs():
	var placed = 0
	var tries = 0
	while placed < num_mobs and tries < num_mobs * 30:
		tries += 1
		var rx = rng.randi_range(1, map_width - 2)
		var ry = rng.randi_range(1, map_height - 2)
		if map[ry][rx] == 0 and not _is_special_tile(rx, ry):
			_spawn_mob_at(Vector2i(rx, ry))
			placed += 1

func _spawn_mob_at(pos: Vector2i):
	# 範例：如有怪物場景 "res://scenes/mob/Goblin.tscn"
	# var m = preload("res://scenes/mob/Goblin.tscn").instance()
	# m.position = Vector2(pos.x * tilemap.cell_size.x, pos.y * tilemap.cell_size.y)
	# add_child(m)
	print("Spawn mob at ", pos)

# 是否為 special 房間或樓梯位置，避免在這放物品/怪
func _is_special_tile(x: int, y: int) -> bool:
	# 檢查是否靠近 stairs_up/down 或 special 房
	if stairs_up_pos != Vector2i.ZERO and x == stairs_up_pos.x and y == stairs_up_pos.y:
		return true
	if stairs_down_pos != Vector2i.ZERO and x == stairs_down_pos.x and y == stairs_down_pos.y:
		return true
	for r in rooms:
		if r.is_special:
			var rect: Rect2i = r.rect
			if x >= rect.position.x and x < rect.position.x + rect.size.x and y >= rect.position.y and y < rect.position.y + rect.size.y:
				return true
	return false
'''
