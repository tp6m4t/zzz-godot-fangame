extends Camera2D

@export var zoom_step := 0.12
@export var min_zoom := 0.025
@export var max_zoom := 1
@export var smooth_speed := 10.0 # 越大越快

var is_dragging: bool = false # 是否正在拖曳
var last_mouse_pos: Vector2 # 上一次滑鼠座標


var target_zoom := 1.0

func _ready():
	target_zoom = zoom.x

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			set_target_zoom(1.0 - zoom_step)
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			set_target_zoom(1.0 + zoom_step)
		elif event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE: # 按下滾輪開始拖動
			is_dragging = true
			last_mouse_pos = event.position
			
	# 放開滾輪 → 停止拖曳
	elif event is InputEventMouseButton and not event.pressed:
		if event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
			is_dragging = false

	# 拖曳過程
	elif event is InputEventMouseMotion and is_dragging:
		var delta: Vector2 = event.position - last_mouse_pos
		global_position -= delta / zoom # 考慮縮放倍率，移動相機
		last_mouse_pos = event.position

func set_target_zoom(factor: float) -> void:
	var new_target: float = clamp(target_zoom * factor, min_zoom, max_zoom)
	# 為了在平滑過程中也能以游標為焦點，我們立即計算位置偏移（模擬瞬間新縮放的世界座標）
	var world_before := get_global_mouse_position()
	# 暫時直接把 zoom 設為 new_target 用來計算 world_after（但稍後會平滑回 target_zoom）
	zoom = Vector2(new_target, new_target)
	var world_after := get_global_mouse_position()
	global_position += world_before - world_after
	# 設定目標縮放（讓 _process 漸進）
	target_zoom = new_target

func _process(delta):
	if abs(zoom.x - target_zoom) > 0.0001:
		var z: float = lerp(zoom.x, target_zoom, clamp(smooth_speed * delta, 0, 1))
		zoom = Vector2(z, z)

func _set_zoom(factor: float) -> void:
	var z: float = clamp(zoom.x * factor, min_zoom, max_zoom)
	zoom = Vector2(z, z)
