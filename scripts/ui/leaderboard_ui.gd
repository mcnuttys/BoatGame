extends Panel

const LEADERBOARD_ENTRY_PREFAB = preload("res://prefabs/ui/leaderboard_entry.tscn")

@onready var leaderboard_entrys_holder = $ScrollContainer/leaderboard_entrys_holder
@onready var multiplayer_spawner = $MultiplayerSpawner
@onready var sliding_ui = $sliding_ui

var is_open := false

func _ready():
	multiplayer_spawner.spawn_function = spawn_leaderboard_entry

func _process(_delta):
	sort_leaderboard()

func open():
	sliding_ui.open()
	is_open = true

func close():
	sliding_ui.close()
	is_open = false

func spawn_leaderboard_entry(player_data):
	var new_leaderboard_entry = LEADERBOARD_ENTRY_PREFAB.instantiate()
	new_leaderboard_entry.name = str(player_data.id)
	new_leaderboard_entry.set_username(player_data.name)
	new_leaderboard_entry.set_kills(0)
	new_leaderboard_entry.set_deaths(0)
	
	return new_leaderboard_entry

func add_entry(player_data):
	multiplayer_spawner.spawn(player_data)

func update_entry(player_data):
	var entry = leaderboard_entrys_holder.get_node(str(player_data.id))
	entry.set_kills(player_data.kills)
	entry.set_deaths(player_data.deaths)

func remove_entry(player_id):
	var entry = leaderboard_entrys_holder.get_node(str(player_id))
	entry.queue_free()

func sort_decending(a, b):
	return a.kills - b.kills > 0

func sort_leaderboard():
	var sorted = leaderboard_entrys_holder.get_children()
	sorted.sort_custom(sort_decending)
	
	for n in range(sorted.size()):
		leaderboard_entrys_holder.move_child(sorted[n], n)

func _on_close_button_pressed():
	close()
