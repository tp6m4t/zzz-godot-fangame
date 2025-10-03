extends Node2D

var play_scene_path:='res://scenes/play_scene.tscn'
var gallery_scene_path:='res://scenes/gallery_scene.tscn'



func _ready() -> void:
	$Control/menu/quit.pressed.connect(get_tree().quit)
	$Control/menu/play.pressed.connect(get_tree().change_scene_to_file.bind(play_scene_path))
	$Control/menu/gallery.pressed.connect(get_tree().change_scene_to_file.bind(gallery_scene_path))
