extends Node3D

@onready var level_holder = $"level"

var loaded_level

func start_game():
	var spawned_map = preload("res://scenes/test_game_scene.tscn").instantiate()
	level_holder.add_child(spawned_map)
	
	loaded_level = spawned_map

func leave_game():
	loaded_level.queue_free()
