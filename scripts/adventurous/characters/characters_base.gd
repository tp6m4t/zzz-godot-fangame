class_name CharactersBase
extends Node2D

@export var hp: int=10:
	set(val):
		$Control/hp_label.text = str(val)
		hp=val
	get:
		return hp
@export var attack: int = 1:
	set(val):
		$Crontrol/attack_label.text = str(val)
		hp=val
	get:
		return attack
@export var scene_manager: AdventurousManager
@export var tile: TileMapLayer
@export var type: CharactersType = CharactersType.NPC
enum CharactersType {Player, Enemy, NPC}


func _ready() -> void:
	$Control/hp_label.text = str(hp)
	$Control/attack_label.text = str(attack)
	scene_manager = get_tree().current_scene
	tile = scene_manager.tile

	

func your_turn() -> void:
	pass
