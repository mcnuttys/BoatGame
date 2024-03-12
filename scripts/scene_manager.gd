extends Node3D

@export var PlayerScene : PackedScene

@onready var respawnCamera := $SpectateCamera
@onready var spawnPoints := get_tree().get_nodes_in_group("PlayerSpawnPoints")

var playerObjects = {}
var localPlayer

var spawnIndex = 0

var respawnTime = 1
var respawnTimer = 0
var playerDead = 0

func _ready():
	for i in game_manager.Players:
		var playerdata = game_manager.Players[i]
		
		if multiplayer.get_unique_id() == playerdata.id:
			respawnCamera.current = false
			localPlayer = playerdata
		
		spawnPlayer(playerdata)

func spawnPlayer(data):
	var current_player = PlayerScene.instantiate()
	current_player.name = str(data.id)
	current_player.set_player_data(data.name, data.color)
	
	add_child(current_player)
	
	playerObjects[data.id] = current_player
	
	var spawn = spawnPoints[spawnIndex]
	current_player.global_position = spawn.global_position
	spawnIndex += 1
	
	if spawnIndex >= spawnPoints.size():
		spawnIndex = 0

func _process(delta):
	if respawnTimer > 0:
		respawnTimer -= delta
	
	if respawnTimer <= 0 and playerDead:
		respawnCamera.current = false
		respawn_player.rpc(localPlayer.id)
		
		playerDead = false

func remove_player(id):
	if playerObjects.has(id):
		playerObjects[id].queue_free()
		game_manager.Players[id] = null
		playerObjects[id] = null

func player_died(id):
	respawnCamera.current = true
	respawnTimer = respawnTime
	playerDead = true
	
	kill_player.rpc(id)

@rpc("any_peer", "call_local")
func kill_player(id):
	playerObjects[id].queue_free()
	playerObjects[id] = null

@rpc("any_peer", "call_local")
func respawn_player(id):
	spawnPlayer(game_manager.Players[id])
