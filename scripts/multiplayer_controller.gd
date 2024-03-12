extends Control

@export var Address = '127.0.0.1'
@export var Port = 7777

var peer

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	
	$username_field.text = "Player " + str(randi_range(1, 1000))
	$ColorPicker.color = Color(randf(), randf(), randf())
	
	var ip_address = "Im lazy and decided not to find it"
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),	IP.TYPE_IPV4)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), IP.TYPE_IPV4)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), IP.TYPE_IPV4)
	elif OS.has_feature("android"):
		var addresses = []
		for ip in IP.get_local_addresses():
			if ip.begins_with("10.") or ip.begins_with("172.16.") or ip.begins_with("192.168."):
				addresses.push_back(ip)
		ip_address = addresses[0]

	$localIP_label.text = ip_address
	
#this gets called on server and clients when connect
func peer_connected(id):
	print("Player Connected " + str(id))
	
#this gets called on server and clients when disconnect
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	$"/root/Game".remove_player(id)

#this gets called only on client
func connected_to_server():
	print("Connected to Server")
	send_player_information.rpc_id(1, multiplayer.get_unique_id(), $username_field.text, $ColorPicker.color)
	
#this gets called only on clients
func connection_failed():
	print("Failed to connect")

@rpc("any_peer")
func send_player_information(id, name, color):
	if !game_manager.Players.has(id):
		game_manager.Players[id] = {
			"id": id,
			"name": name,
			"color": color
		}
	
	if multiplayer.is_server():
		for i in game_manager.Players:
			var playerData = game_manager.Players[i]
			send_player_information.rpc(i, playerData.name, playerData.color)

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(scene)
	
	var ripple = load("res://scenes/ripples_test.tscn").instantiate()
	get_tree().root.add_child(ripple)
	
	self.hide()

func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, 8)
	
	if error != OK:
		print("Cannot host: " + error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print('Waiting for players...')
	send_player_information(multiplayer.get_unique_id(), $username_field.text, $ColorPicker.color)
	pass # Replace with function body.


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)	
	pass # Replace with function body.


func _on_start_game_button_down():
	start_game.rpc()
	pass # Replace with function body.



func _on_ip_field_text_changed(new_text):
	Address = new_text
	pass # Replace with function body.


func _on_port_field_text_changed(new_text):
	Port = new_text.to_int()
	pass # Replace with function body.
