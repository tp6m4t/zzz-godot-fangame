class_name GameInputEvents

static var direction: Vector2 = Vector2.ZERO
static var is_movement_input: bool = false


static func movement_input() -> Vector2:
	if Input.is_action_pressed("walk_left"):
		direction = Vector2.LEFT
		is_movement_input = true
	elif Input.is_action_pressed("walk_right"):
		direction = Vector2.RIGHT
		is_movement_input = true
	elif Input.is_action_pressed("walk_up"):
		direction = Vector2.UP
		is_movement_input = true
	elif Input.is_action_pressed("walk_down"):
		direction = Vector2.DOWN
		is_movement_input = true
	else:
		is_movement_input = false
	return direction
	
static func use_tool() -> bool:
	var use_tool_value: bool = Input.is_action_just_pressed("hit")
	return use_tool_value
