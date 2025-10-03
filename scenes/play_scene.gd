extends Node2D

var main_scene_path:= 'res://scenes/main_scene.tscn'
func _ready() -> void:
	$Control/Button.pressed.connect(get_tree().change_scene_to_file.bind(main_scene_path))
