extends Control

@onready var burger_menu = $burger_menu
@onready var burger_menu_sliding_ui = $burger_menu/sliding_ui

@onready var leaderboard = $leaderboard
@onready var options_ui = $options_ui

var burger_menu_open := false

signal leave_server_signal()

func _ready():
	GameManager.ui_scale_changed_signal.connect(scale_ui)
	scale_ui()

func _process(_delta):
	if Input.is_action_just_pressed("tab"):
		leaderboard.open()
		close_ui(true, false, true)
	
	if Input.is_action_just_released("tab"):
		leaderboard.close()

func scale_ui():
	var ui_scale = GameManager.get_ui_scale()
	
	for element in get_children():
		element.scale = Vector2(ui_scale, ui_scale)

func close_ui(close_burger_menu = true, close_leaderboard = true, close_options_ui = true):
	if close_burger_menu:
		burger_menu_sliding_ui.close()
		burger_menu_open = false
	
	if close_leaderboard:
		leaderboard.close()
	
	if close_options_ui:
		options_ui.close()

func _on_leaderboard_button_pressed():
	close_ui(true, false, true)
	
	if leaderboard.is_open:
		leaderboard.close()
	elif !leaderboard.is_open:
		leaderboard.open()

func _on_hamburger_button_pressed():
	close_ui(false, true, true)
	
	if !burger_menu_open:
		burger_menu_sliding_ui.open()
		burger_menu_open = true
	elif burger_menu_open:
		burger_menu_sliding_ui.close()
		burger_menu_open = false


func _on_options_button_pressed():
	close_ui(true, true, false)
	
	if options_ui.is_open:
		options_ui.close()
	elif !options_ui.is_open:
		options_ui.open()

func _on_leave_server_button_pressed():
	leave_server_signal.emit()

func _on_quit_button_pressed():
	get_tree().quit()
