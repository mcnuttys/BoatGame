extends Node3D

@export var PlayerScene : PackedScene

var playerObjects = {}

func _ready():
	var index = 0
	for i in game_manager.Players:
		var current_player = PlayerScene.instantiate()
		var playerdata = game_manager.Players[i]
		
		current_player.name = str(playerdata.id)
		current_player.set_player_data(playerdata.name, playerdata.color)
		
		add_child(current_player)
		
		playerObjects[i] = current_player
		
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoints"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1

func remove_player(id):
	if playerObjects.has(id):
		playerObjects[id].queue_free()
		game_manager.Players[id] = null
		playerObjects[id] = null
		
