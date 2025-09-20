class_name Player
extends CharacterBody2D

var player_direction: Vector2 = Vector2.ZERO
@export
var grass: TileMapLayer
@export
var current_tool: DataTypes.Tools = DataTypes.Tools.None
@export var speed: int = 50


func _physics_process(_delta: float) -> void:
	player_direction = GameInputEvents.movement_input()
