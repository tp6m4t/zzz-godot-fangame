class_name CharactersBase
extends Node2D

@export var hp: int
@export var attack: int
@export var scene_manager: AdventurousManager
@export var tile: TileMapLayer
@export var type: CharactersType = CharactersType.NPC
enum CharactersType {Player, Enemy, NPC}

func _ready() -> void:
	scene_manager = get_tree().current_scene
	tile = scene_manager.tile

func your_turn() -> void:
	pass
