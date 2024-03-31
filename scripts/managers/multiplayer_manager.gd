extends Node

var Address = "127.0.0.1"
var Port = 7777

var peer
var Players = {}
var Local_Player

signal connection_failed_signal
signal host_failed_signal(error)
signal connected_to_server_signal

signal update_player_list_signal(player_data)
signal remove_player_signal(player_id)

signal disconnected_from_server_signal

func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)

#this gets called on server and clients when connect
func peer_connected(id):
	print("Peer Player Connected " + str(id))
	
#this gets called on server and clients when disconnect
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	Players.erase(id)
	remove_player_signal.emit(id)
	
	if id == 1:
		print("Lost Connection...")
		disconnected_from_server_signal.emit()

#this gets called only on client
func connected_to_server():
	print("Connected to Server")
	
	Local_Player = {
			"id": multiplayer.get_unique_id(),
			"name": GameManager.ship_name,
			"color": GameManager.ship_color,
			"decals": GameManager.ship_decals
		}
	
	send_player_information.rpc_id(
			1,
			Local_Player.id,
			Local_Player.name,
			Local_Player.color,
			Local_Player.decals
		)
	connected_to_server_signal.emit()

#this gets called only on clients
func connection_failed():
	print("Failed to connect")
	connection_failed_signal.emit()

func host_server(_port):
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_server(_port, 8)
	if error != OK:
		print("Cannot host: " + str(error))
		host_failed_signal.emit(error)
		return
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
	Local_Player = {
			"id": multiplayer.get_unique_id(),
			"name": GameManager.ship_name,
			"color": GameManager.ship_color,
			"decals": GameManager.ship_decals
		}
	
	send_player_information(
			Local_Player.id,
			Local_Player.name,
			Local_Player.color,
			Local_Player.decals
		)
	
	connected_to_server_signal.emit()
	print("Waiting for players...")

func join_server(_address, _port):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(_address, _port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)

func leave_server():
	peer.close()
	multiplayer.set_multiplayer_peer(null)
	Players.clear()

@rpc("any_peer")
func send_player_information(_id, _name, _color, _decals):
	print("Send Player Info")
	if !Players.has(_id):
		Players[_id] = {}
	
	Players[_id] = {
			"id": _id,
			"name": _name,
			"color": _color,
			"decals": _decals
		}
	
	update_player_list_signal.emit(Players[_id])
	
	if !multiplayer.is_server():
		return
	
	for i in Players:
		var playerData = Players[i]
		send_player_information.rpc(i, playerData.name, playerData.color, playerData.decals)
