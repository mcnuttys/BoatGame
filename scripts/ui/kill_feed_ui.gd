extends Control

@onready var message_prefab := load("res://prefabs/ui/kill_feed_message_ui.tscn")

@onready var kill_feed_holder := $"kill_feed_holder"

var max_message_count = 6

@rpc("any_peer", "call_local")
func add_message(message):
	message = "[right]" + message
	
	if kill_feed_holder.get_child_count() >= max_message_count:
		kill_feed_holder.get_child(0).queue_free()
	
	var newMessage = message_prefab.instantiate()
	newMessage.set_message(message)
	
	kill_feed_holder.add_child(newMessage)
