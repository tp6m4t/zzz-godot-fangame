extends Panel

func _ready() -> void:
	$Up.button_down.connect(_on_button_down.bind("up"))
	$Up.button_up.connect(_on_button_up.bind("up"))
	$Down.button_down.connect(_on_button_down.bind("down"))
	$Down.button_up.connect(_on_button_up.bind("down"))
	$Left.button_down.connect(_on_button_down.bind("left"))
	$Left.button_up.connect(_on_button_up.bind("left"))
	$Right.button_down.connect(_on_button_down.bind("right"))
	$Right.button_up.connect(_on_button_up.bind("right"))


var dir_map = {
	"up": "walk_up",
	"down": "walk_down",
	"left": "walk_left",
	"right": "walk_right"
}

func _on_button_down(direction: String) -> void:
	Input.action_press(dir_map[direction])

func _on_button_up(direction: String) -> void:
	Input.action_release(dir_map[direction])
