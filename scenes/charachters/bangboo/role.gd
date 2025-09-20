class_name Role
extends CharacterBody2D

@export
var grass: TileMapLayer
@export
var current_tool: DataTypes.Tools = DataTypes.Tools.None
@export var speed: int = 25

func get_player(): 
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return players[0]
	return null
	
func direction() -> Vector2:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		return (players[0].global_position - global_position).normalized()
	return Vector2.ZERO
