extends Node

@export var player_prefab := preload("res://prefabs/player_ship.tscn")
@export var duck_prefab := preload("res://prefabs/duck.tscn")
@export var dead_ship_prefab := preload("res://prefabs/dead_boat.tscn")

@onready var spectate_camera := $spectate_camera
@onready var players_holder := $players_holder
@onready var dead_ships_holder := $dead_ships_holder
@onready var kill_feed := $"game_ui/kill_feed_ui"
@onready var leaderboard_ui := $"game_ui/leaderboard"

@onready var main_menu := $"/root/game/main_menu"

@onready var player_spawner := $"player_spawner"
@onready var dead_ship_spawner := $"dead_ship_spawner"

@onready var duck_holder := $"ducks_holder"

@onready var game = get_parent().get_parent().get_parent()
@onready var game_ui = $game_ui

var min_x = -10
var max_x = 10
var min_z = -10
var max_z = 10

var player_ships = {}
var local_player

var leaderboard = {}

var player_dead := false
var respawn_timer := 0.0
var respawn_time := 5.0

func _ready():
	local_player = MultiplayerManager.Local_Player
	
	main_menu.disable_main_menu()
	player_spawner.spawn_function = spawn_player
	dead_ship_spawner.spawn_function = spawn_dead_ship
	
	game_ui.leave_server_signal.connect(leave_game)
	MultiplayerManager.disconnected_from_server_signal.connect(_on_disconnected)
	
	if not multiplayer.is_server():
		return
	
	MultiplayerManager.remove_player_signal.connect(_on_player_removed)
	MultiplayerManager.update_player_list_signal.connect(_on_player_connected)
	
	for player in MultiplayerManager.Players:
		var player_data = MultiplayerManager.Players[player]
		request_spawn(player_data)
		
		leaderboard[player] = {
			"id" = player,
			"name" = player_data.name,
			"kills" = 0,
			"deaths" = 0
		}
		leaderboard_ui.add_entry(leaderboard[player_data.id])

func _process(delta):
	#if multiplayer.is_server() and Input.is_action_just_pressed("space"):
	#	var new_duck = duck_prefab.instantiate()
	#	
	#	var spawn_position = Vector3(randf_range(min_x, max_x),0,randf_range(min_z, max_z))
	#	var spawn_rotation = randf_range(0.0, 360.0)
	#	new_duck.name = str(spawn_position)
	#	new_duck.position = spawn_position
	#	new_duck.rotation_degrees.y = spawn_rotation
	#	
	#	duck_holder.add_child(new_duck)
	#	
	#	kill_feed.add_message.rpc("[rainbow][wave]Duck[/wave][/rainbow] has spawned!")
	
	if !player_dead:
		return
	
	if respawn_timer >= 0:
		respawn_timer -= delta
	
	if respawn_timer <= 0:
		player_dead = false
		spectate_camera.current = false
		
		if multiplayer.is_server():
			request_spawn(local_player)
		else:
			request_spawn_rpc.rpc_id(1, local_player)

func _on_player_connected(player_data):
	request_spawn(player_data)
	kill_feed.add_message.rpc(player_data.name + " has joined!")
	
	if multiplayer.is_server():
		leaderboard[player_data.id] = {
			"id" = player_data.id,
			"name" = player_data.name,
			"kills" = 0,
			"deaths" = 0
		}
		leaderboard_ui.add_entry(leaderboard[player_data.id])

func _on_player_removed(id):
	despawn_player(id)
	
	leaderboard_ui.remove_entry(id)

func _on_disconnected():
	leave_game()

func leave_game():
	MultiplayerManager.leave_server()
	game.leave_game()
	main_menu.enable_main_menu()

@rpc("any_peer", "call_local")
func request_spawn_rpc(player_data):
	if !multiplayer.is_server():
		return
		
	request_spawn(player_data)
	
func request_spawn(player_data):
	var spawn_position = Vector3(randf_range(min_x, max_x),0,randf_range(min_z, max_z))
	var spawn_rotation = randf_range(0.0, 360.0)
	
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	if spawn_points.size() > 0:
		spawn_position = spawn_points[randi_range(0, spawn_points.size()-1)].global_position
	
	var spawn_data = {
		"player_data" = player_data,
		"position" = spawn_position,
		"rotation" = spawn_rotation
	}
	
	player_spawner.spawn(spawn_data)

func spawn_player(spawn_data):
	var player_data = spawn_data.player_data
	var new_player = player_prefab.instantiate()
	new_player.name = str(player_data.id)
	new_player.set_authoirity(player_data.id)
	new_player.set_player_data(player_data)
	new_player.set_controller(self)
	
	new_player.set_ship_position(spawn_data.position)
	new_player.set_ship_rotation(spawn_data.rotation)
	
	player_ships[player_data.id] = new_player
	return new_player

func spawn_dead_ship(spawn_data):
	var player_model = players_holder.get_node(str(spawn_data.id))
	
	if !player_model:
		return
	
	var player_ship = player_model.get_node("default_ship")
	
	var dead_ship = dead_ship_prefab.instantiate()
	dead_ship.name = "random " + str(randf_range(10000, 100000))
	dead_ship.position = player_ship.global_position
	dead_ship.rotation = player_ship.global_rotation
	dead_ship.set_material(player_ship.display_ship_material)
	
	return dead_ship

@rpc("any_peer", "call_local")
func despawn_player(id):
	if !players_holder.has_node(str(id)):
		return
	
	players_holder.get_node(str(id)).queue_free()
	
	dead_ship_spawner.spawn({ "id": id })

@rpc("any_peer", "call_local")
func update_leaderboard_server(dead_id, killer_id):
	leaderboard[dead_id].deaths += 1
	leaderboard[killer_id].kills += 1
	
	leaderboard_ui.update_entry(leaderboard[dead_id])
	leaderboard_ui.update_entry(leaderboard[killer_id])

func player_died(id, killer_id, damage_type):
	despawn_player.rpc_id(1, id)
	
	player_dead = true
	spectate_camera.current = true
	respawn_timer = respawn_time
	
	update_leaderboard_server.rpc_id(1, id, killer_id)
	
	if damage_type == "unsert":
		var username = MultiplayerManager.Players[id].name
		var message = username + " unset"
		
		kill_feed.add_message.rpc(message)
	
	if damage_type == "flipped":
		var username = MultiplayerManager.Players[id].name
		var message = username + " flipped!"
		
		kill_feed.add_message.rpc(message)
	
	if damage_type == "explosion":
		var username1 = MultiplayerManager.Players[id].name
		var username2 = MultiplayerManager.Players[killer_id].name
		var message = username2 + " sunk " + username1 + "!"
		
		kill_feed.add_message.rpc(message)
