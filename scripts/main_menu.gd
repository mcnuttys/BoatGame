extends Node3D

@onready var display_ship := $Ship
@onready var ui = $Main_Menu_UI

func _ready():
	display_ship.set_ship_name(GameManager.ship_name)
	display_ship.set_ship_color(GameManager.ship_color)
	display_ship.set_ship_decals(GameManager.ship_decals)

func disable_main_menu():
	visible = false
	ui.visible = false

func enable_main_menu():
	visible = true
	ui.visible = true
	ui._on_connection_failed()
