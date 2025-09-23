class_name FocusCamera2D
extends Camera2D

@export var zoom_step := 0.12
@export var min_zoom := 0.025
@export var max_zoom := 1
@export var smooth_speed := 10.0
@export var follow_speed := 5.0

var focus_node: Node2D = null
var is_focused: bool = false

var is_dragging: bool = false
var last_mouse_pos: Vector2

# 觸控相關變數
var touch_positions := {} # Dictionary: touch_index -> Vector2
var last_touch_distance: float = 0.0

var target_zoom := 1.0
var target_position: Vector2

func _ready():
	target_zoom = zoom.x
	target_position = global_position
	
	# 啟用多點觸控
	Input.set_use_accumulated_input(false)
	
func _focus(node: Node2D):
	focus_node = node
	is_focused = true
	target_position = node.get_global_position()
	target_zoom = 1.0

func _unhandled_input(event):
	# --- 滑鼠事件 ---
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			set_target_zoom(1.0 - zoom_step, event.position)
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			set_target_zoom(1.0 + zoom_step, event.position)
		elif event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			if is_dragging:
				print('is_dragging_MOUSE_BUTTON_LEFT')
				last_mouse_pos = event.position
				is_focused = false

	# --- 觸控事件 ---
	elif event is InputEventScreenTouch:
		# 儲存每個觸控點的位置
		if event.is_pressed():
			touch_positions[event.index] = event.position
		else:
			touch_positions.erase(event.index)
		
		# 處理雙指縮放
		if touch_positions.size() == 2:
			var touch1_pos = touch_positions.values()[0]
			var touch2_pos = touch_positions.values()[1]
			var current_distance = touch1_pos.distance_to(touch2_pos)

			if last_touch_distance > 0:
				var pinch_factor = current_distance / last_touch_distance
				set_target_zoom(1.0 / pinch_factor, (touch1_pos + touch2_pos) / 2.0)
			
			last_touch_distance = current_distance
			is_focused = false
		else:
			last_touch_distance = 0
			# 處理單指拖曳
			if touch_positions.size() == 1:
				is_dragging = true
				last_mouse_pos = event.position
				is_focused = false
			else:
				is_dragging = false

	# 拖曳過程
	elif is_dragging:
		is_focused = false
		if event is InputEventScreenDrag or event is InputEventMouseMotion:
			var delta: Vector2 = event.position - last_mouse_pos
			global_position -= delta / zoom # 考慮縮放倍率，移動相機
			last_mouse_pos = event.position

func set_target_zoom(factor: float, mouse_screen_pos: Vector2) -> void:
	is_focused = false
	
	var world_pos_before_zoom = get_viewport().get_canvas_transform().affine_inverse() * mouse_screen_pos

	var new_target_zoom = clamp(target_zoom * factor, min_zoom, max_zoom)
	target_zoom = new_target_zoom

	var world_pos_after_zoom = get_viewport().get_canvas_transform().affine_inverse() * mouse_screen_pos

	target_position += world_pos_before_zoom - world_pos_after_zoom

func _process(delta):
	if is_focused and focus_node:
		target_position = focus_node.get_global_position()
		global_position = global_position.lerp(target_position, clamp(follow_speed * delta, 0, 1))


	if abs(zoom.x - target_zoom) > 0.0001:
		var z = lerp(zoom.x, target_zoom, clamp(smooth_speed * delta, 0, 1))
		zoom = Vector2(z, z)
