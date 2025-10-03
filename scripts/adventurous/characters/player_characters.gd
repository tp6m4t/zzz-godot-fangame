extends CharactersBase

@export var move_cooldown := 0.2  # 後續連續移動間隔（秒）
var move_coolbown :int= 0
var holding_dir := Vector2i.ZERO  # 正在按住的方向

func _ready() -> void:
	super._ready()
	type = CharactersType.Player

func _process(delta: float) -> void:
	var directions := {
		"walk_left": Vector2i.LEFT,
		"walk_right": Vector2i.RIGHT,
		"walk_up": Vector2i.UP,
		"walk_down": Vector2i.DOWN,
	}

	# 如果沒有方向被按，清空狀態
	holding_dir = Vector2i.ZERO
	
	if move_coolbown < 0:
		# 偵測有沒有方向鍵被按下
		for action in directions.keys():
			if Input.is_action_pressed(action):
				holding_dir = directions[action]
				# 立即執行首步
				move_player(holding_dir, true)
				return
	else:
		move_coolbown-=1


func move_player(dir: Vector2i, immediate := false) -> void:
	var cell := tile.local_to_map(global_position)
	var target := cell + dir

	# 邊界檢查
	if target.y < 0 or target.y >= scene_manager.map.map_strings.size():
		return
	if target.x < 0 or target.x >= scene_manager.map.map_strings[target.y].length():
		return

	# 判斷是否可走
	if scene_manager.map.map_strings[target.y][target.x] == '.':
		var tile_size := tile.tile_set.tile_size
		global_position += Vector2(dir) * Vector2(tile_size)
		move_coolbown = 20
		scene_manager._player_turn_end()
