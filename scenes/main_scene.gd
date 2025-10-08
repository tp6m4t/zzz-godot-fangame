extends Node2D

var play_scene_path := 'res://scenes\bsp_dungeon_generator\bsp_dungeon_generator.tscn'
var gallery_scene_path := 'res://scenes/gallery_scene.tscn'
var delegation_scene_path := 'res://scenes/delegation/delegation_scene.tscn'


func _ready() -> void:
	$Control/menu/quit.pressed.connect(get_tree().quit)
	$Control/menu/play.pressed.connect(get_tree().change_scene_to_file.bind(play_scene_path))
	$Control/menu/gallery.pressed.connect(get_tree().change_scene_to_file.bind(gallery_scene_path))
	$Control/menu/delegation.pressed.connect(get_tree().change_scene_to_file.bind(gallery_scene_path))
