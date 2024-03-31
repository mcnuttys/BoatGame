extends HBoxContainer

@onready var player_details_template = preload("res://prefabs/ui/playerlist_details.tscn")

@onready var player_list_holder = $PlayerList_panel/ScrollContainer/PlayerList_holder
@onready var start_game_button = $"GameInfo_panel/HBoxContainer/Start"

var player_list = {}

func _ready():
	MultiplayerManager.update_player_list_signal.connect(_on_update_player_list)
	MultiplayerManager.remove_player_signal.connect(_on_remove_player)

func enable_menu():
	start_game_button.visible = false
	
	if multiplayer.is_server():
		start_game_button.visible = true

func clear_player_list():
	for i in player_list_holder.get_children():
		player_list_holder.remove_child(i)
	
	player_list.clear()

func _on_update_player_list(player_data):
	if !player_list.has(player_data.id):
		create_new_player(player_data)
	else:
		update_player(player_data)

func _on_remove_player(player_id):
	player_list_holder.remove_child(player_list[player_id])
	player_list[player_id] = null

func create_new_player(player_data):
	var new_player = player_details_template.instantiate()
	
	player_list_holder.add_child(new_player)
	new_player.set_ship_name(player_data.name)
	
	player_list[player_data.id] = new_player

func update_player(player_data):
	var player_details = player_list[player_data.id]
	player_details.set_ship_name(player_data.name)
