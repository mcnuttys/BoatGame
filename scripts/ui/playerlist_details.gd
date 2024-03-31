extends Panel

@onready var label = $HBoxContainer/Label

func set_ship_name(ship_name):
	label.text = ship_name
