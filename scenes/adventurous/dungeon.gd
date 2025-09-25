class_name Dungeon
extends Resource

#地圖生成類
# 全域隨機生成器
var rng = RandomNumberGenerator.new()

# 擴展輸出參數：地圖尺寸、最小房間大小、隨機種子、BSP 深度
@export var map_width = 80
@export var map_height = 45
@export var min_room_size = 6
@export var seed: int = 12345
@export var bsp_depth: int = 4
@export var start_cell: Vector2i = Vector2i(0, 0)
@export var end_cell: Vector2i = Vector2(0, 0)
var map_strings: Array[String] = []


func _init(_seed: int = 12345, _width: int = 80, _height: int = 45,
		_min_room_size: int = 6, _bsp_depth: int = 4) -> void:
	# 初始化參數
	map_width = _width
	map_height = _height
	min_room_size = _min_room_size
	bsp_depth = _bsp_depth
	seed = _seed
	# 設定隨機種子
	rng.randomize()
	rng.seed = seed

	# 建立根葉節點並進行 BSP 分割
	var root = Leaf.new(0, 0, map_width, map_height)
	split_leaf(root, bsp_depth)

	# 獲取所有最終葉節點並為每個葉節點生成一個房間
	var leaves: Array[Leaf] = []
	gather_leaves(root, leaves)
	# 初始化全牆的地圖矩陣
	var dungeon: Array = []
	for y in range(map_height):
		var row: Array = []
		for x in range(map_width):
			row.append('#')
		dungeon.append(row)
	# 在每個葉節點內隨機挖出房間地板
	for leaf in leaves:
		leaf.room_w = rng.randi_range(min_room_size, leaf.w)
		leaf.room_h = rng.randi_range(min_room_size, leaf.h)
		leaf.room_x = rng.randi_range(leaf.x, leaf.x + leaf.w - leaf.room_w)
		leaf.room_y = rng.randi_range(leaf.y, leaf.y + leaf.h - leaf.room_h)
		for x in range(leaf.room_x, leaf.room_x + leaf.room_w):
			for y in range(leaf.room_y, leaf.room_y + leaf.room_h):
				dungeon[y][x] = '.'
	
	var start_room := leaves[rng.randi_range(0, leaves.size() - 1)]
	var end_room := leaves[rng.randi_range(0, leaves.size() - 1)]
	start_cell = Vector2i(rng.randi_range(start_room.room_x, start_room.room_x + start_room.room_w - 1),
			rng.randi_range(start_room.room_y, start_room.room_y + start_room.room_h - 1))
	end_cell = Vector2i(rng.randi_range(end_room.room_x, end_room.room_x + end_room.room_w - 1),
			rng.randi_range(end_room.room_y, end_room.room_y + end_room.room_h - 1))

	# 為每對兄弟分區生成走廊，確保所有房間連通
	connect_rooms(root, dungeon)

	# 將二維陣列轉成 Array[String]，並列印整個地圖
	map_strings.clear()
	for y in range(map_height):
		var line = ""
		for x in range(map_width):
			line += dungeon[y][x]
		map_strings.append(line)
	print(self)


func get_map() -> Array[String]:
	return map_strings


func _to_string() -> String:
	var result = "[Dungeon] Info\n"
	result += "Seed: %d\n" % seed
	result += "Map Size: %dx%d\n" % [map_width, map_height]
	result += "Min Room Size: %d\n" % min_room_size
	result += "BSP Depth: %d\n" % bsp_depth
	for line in map_strings:
		result += line + "\n"
	result += "[Dungeon] End\n"
	return result


# 將葉節點遞迴分割成子區域
func split_leaf(leaf: Leaf, depth: int) -> void:
	if depth <= 0:
		return
	# 檢查是否可以繼續分割
	var can_split_h = leaf.h >= min_room_size * 2
	var can_split_w = leaf.w >= min_room_size * 2
	if not can_split_h and not can_split_w:
		return
	# 隨機選擇分割方向；若某方向空間不足，則強制另一方向
	var split_h = false
	if can_split_w and not can_split_h:
		split_h = false
	elif can_split_h and not can_split_w:
		split_h = true
	else:
		split_h = (rng.randi_range(0, 1) == 0)
	# 執行分割
	if split_h:
		# 水平分割：高度方向切
		var split_y = rng.randi_range(min_room_size, leaf.h - min_room_size)
		leaf.left_child = Leaf.new(leaf.x, leaf.y, leaf.w, split_y)
		leaf.right_child = Leaf.new(leaf.x, leaf.y + split_y, leaf.w, leaf.h - split_y)
	else:
		# 垂直分割：寬度方向切
		var split_x = rng.randi_range(min_room_size, leaf.w - min_room_size)
		leaf.left_child = Leaf.new(leaf.x, leaf.y, split_x, leaf.h)
		leaf.right_child = Leaf.new(leaf.x + split_x, leaf.y, leaf.w - split_x, leaf.h)
	# 對子區域繼續遞迴分割
	split_leaf(leaf.left_child, depth - 1)
	split_leaf(leaf.right_child, depth - 1)


# 收集所有無子節點的葉節點（最終分區）
func gather_leaves(leaf: Leaf, leaves: Array) -> void:
	if leaf.left_child == null and leaf.right_child == null:
		leaves.append(leaf)
	else:
		if leaf.left_child:
			gather_leaves(leaf.left_child, leaves)
		if leaf.right_child:
			gather_leaves(leaf.right_child, leaves)


# 創建走廊：在內部節點處連接左右子樹的房間
func connect_rooms(leaf: Leaf, dungeon: Array) -> void:
	if leaf.left_child == null or leaf.right_child == null:
		return
	# 收集左右子樹中所有葉節點（房間），隨機選一個進行連接
	var left_leaves: Array = []
	var right_leaves: Array = []
	gather_leaves(leaf.left_child, left_leaves)
	gather_leaves(leaf.right_child, right_leaves)
	var a = left_leaves[rng.randi_range(0, left_leaves.size() - 1)]
	var b = right_leaves[rng.randi_range(0, right_leaves.size() - 1)]
	# 房間中心點座標
	var x1 = a.room_x + a.room_w / 2
	var y1 = a.room_y + a.room_h / 2
	var x2 = b.room_x + b.room_w / 2
	var y2 = b.room_y + b.room_h / 2
	# 隨機決定先水平還是先垂直挖走廊
	if rng.randi_range(0, 1) == 0:
		# 水平先挖
		for x in range(min(x1, x2), max(x1, x2) + 1):
			dungeon[y1][x] = '.'
		for y in range(min(y1, y2), max(y1, y2) + 1):
			dungeon[y][x2] = '.'
	else:
		# 垂直先挖
		for y in range(min(y1, y2), max(y1, y2) + 1):
			dungeon[y][x1] = '.'
		for x in range(min(x1, x2), max(x1, x2) + 1):
			dungeon[y2][x] = '.'
	# 遞迴連接子分區
	connect_rooms(leaf.left_child, dungeon)
	connect_rooms(leaf.right_child, dungeon)


# 定義分區葉節點類別
class Leaf:
	var x: int
	var y: int
	var w: int
	var h: int
	var left_child: Leaf = null
	var right_child: Leaf = null
	var room_x: int = 0
	var room_y: int = 0
	var room_w: int = 0
	var room_h: int = 0

	func _init(_x, _y, _w, _h):
		self.x = _x
		self.y = _y
		self.w = _w
		self.h = _h
