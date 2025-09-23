extends Panel

@export var camera: FocusCamera2D
@export var button_scene: PackedScene # 預製的圓形 Button

var tracked_buttons := {} # Dictionary: unit -> button
@export var focus_nodes: Array[Node2D]

func _ready() -> void:
	# 確保 Panel 填滿整個 Viewport，以便按鈕能正確顯示在邊緣
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta: float) -> void:
	if camera:
		for node in focus_nodes:
			_update_unit_button(node)

func _update_unit_button(unit: Node2D) -> void:
	# 獲取相機在世界座標中的可見矩形
	var camera_rect: Rect2 = camera.get_viewport_rect()
	# 將其轉換到相機的本地座標系
	var camera_local_rect = camera.get_canvas_transform().affine_inverse() * camera_rect

	# 檢查單位是否在相機視野內 (使用世界座標)
	if camera_local_rect.has_point(unit.global_position):
		# 單位在螢幕內 → 移除按鈕
		if tracked_buttons.has(unit):
			tracked_buttons[unit].queue_free()
			tracked_buttons.erase(unit)
	else:
		# 單位在螢幕外 → 顯示並更新按鈕位置
		if not tracked_buttons.has(unit):
			var btn: Button = button_scene.instantiate()
			add_child(btn)
			btn.pressed.connect(_on_unit_button_pressed.bind(unit))
			tracked_buttons[unit] = btn
			'''
			if unit is Sprite2D:
				btn.icon = unit.texture
				if unit is Sprite2D:
					if unit.hframes > 1 or unit.vframes > 1:
						btn.icon_region_enabled = true
						# 計算單一幀的大小
						var frame_size = unit.texture.get_size() / Vector2(unit.hframes, unit.vframes)
						# 根據當前幀數 (unit.frame) 計算其在精靈表中的位置
						var frame_x = unit.frame % unit.hframes
						var frame_y = unit.frame / unit.vframes
						# 設定 icon_region 來顯示當前幀
						btn.icon_region = Rect2(Vector2(frame_x, frame_y) * frame_size, frame_size)
			'''
						
		var btn: Button = tracked_buttons[unit]
		
		# 獲取 Panel (螢幕) 的邊界
		var screen_rect: Rect2 = get_rect()
		
		# 獲取按鈕的大小
		var button_size: Vector2 = btn.get_size()
		
		# 將世界座標轉換為螢幕座標
		var unit_screen_pos: Vector2 = camera.get_viewport().get_canvas_transform() * unit.global_position
		
		# 調整 clamp 範圍，為按鈕留出空間
		var clamp_min: Vector2 = screen_rect.position
		var clamp_max: Vector2 = screen_rect.end - button_size
		
		# 將螢幕座標限制在調整後的 Panel 邊界內
		var clamped_pos: Vector2 = unit_screen_pos.clamp(clamp_min, clamp_max)
		
		# 更新按鈕位置
		btn.position = clamped_pos
		
func _on_unit_button_pressed(unit: Node2D) -> void:
	camera._focus(unit)
