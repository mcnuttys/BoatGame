extends Control

@onready var main_menu_scene = $".."
@onready var main_menu_ui = $"."

@onready var main_menu := $Main_Menu
@onready var join_menu := $Join_Menu
@onready var host_menu := $Host_Menu
@onready var multiplayer_menu := $Multiplayer_Menu

@onready var connection_failed_menu := $ConnectionFailed_Menu
@onready var host_failed_menu := $HostFailed_Menu

@onready var join_ip_field := $Join_Menu/IP_HBox/TextEdit
@onready var join_port_field := $Join_Menu/Port_HBox/TextEdit

@onready var host_port_field := $Host_Menu/Port_HBox/TextEdit

@onready var join_active_button := $Multiplayer_Menu/GameInfo_panel/HBoxContainer/Join

@onready var game := get_parent().get_parent()

var game_started := false

func _ready():
	main_menu.visible = true
	join_menu.visible = false
	host_menu.visible = false
	
	MultiplayerManager.connection_failed_signal.connect(_on_connection_failed)
	MultiplayerManager.host_failed_signal.connect(_on_host_failed)
	MultiplayerManager.connected_to_server_signal.connect(_on_connected_to_server)

func _on_join_menu_button_pressed():
	main_menu.visible = false
	join_menu.visible = true
	host_menu.visible = false
	
func _on_host_menu_button_pressed():
	main_menu.visible = false
	join_menu.visible = false
	host_menu.visible = true
	
func _on_back_button_pressed():
	main_menu.visible = true
	join_menu.visible = false
	host_menu.visible = false
	
	connection_failed_menu.visible = false
	host_failed_menu.visible = false

func _on_quit_button_pressed():
	get_tree().quit()

func _on_host_multiplayer_pressed():
	print("Host Multiplayer")
	
	MultiplayerManager.host_server(host_port_field.text.to_int())
	host_menu.visible = false

func _on_join_multiplayer_pressed():
	print("Join Multiplayer")
	
	MultiplayerManager.join_server(join_ip_field.text, join_port_field.text.to_int())
	join_menu.visible = false

func _on_leave_multiplayer_pressed():
	print("Leave Multiplayer")
	
	MultiplayerManager.leave_server()
	multiplayer_menu.clear_player_list()
	multiplayer_menu.visible = false
	main_menu.visible = true

func _on_connection_failed():
	connection_failed_menu.visible = true
	multiplayer_menu.visible = false

func _on_host_failed(_error):
	host_failed_menu.visible = true
	multiplayer_menu.visible = false

func _on_connected_to_server():
	#multiplayer_menu.visible = true
	#multiplayer_menu.enable_menu()
	
	start_game()

func _on_start_game_pressed():
	start_game()
	game_started = true

func _on_join_button_pressed():
	start_game()

func start_game():
	game.start_game()
	
	for player in MultiplayerManager.Players:
		game_start.rpc_id(player)

@rpc("any_peer", "call_local")
func game_start():
	multiplayer_menu.visible = false
	main_menu_scene.visible = false
	main_menu_ui.visible = false
