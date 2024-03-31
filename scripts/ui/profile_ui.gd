extends Control

@onready var username_input := $HBoxContainer/VBoxContainer/Username/Input
@onready var color_picker := $HBoxContainer/VBoxContainer/ColorSelector/Picker

@onready var rotation_slider := $HBoxContainer/Panel/rotation_slider
@onready var zoom_slider := $HBoxContainer/Panel/zoom_slider
@onready var offset_slider := $HBoxContainer/Panel/offset_slider

@onready var display_ship := $ShipDisplay_viewport/default_ship
@onready var display_texture := $HBoxContainer/Panel/TextureRect

@onready var display_viewport := $ShipDisplay_viewport
@onready var display_camera_pivot := $ShipDisplay_viewport/CameraPivot
@onready var display_camera := $ShipDisplay_viewport/CameraPivot/RotPivot/Camera3D
@onready var display_ship_rotation_animation := $ShipDisplay_viewport/AnimationPlayer

var min_zoom = Vector3(0, 0.25, 1)
var max_zoom = Vector3(0, 1, 4)

var min_offset = Vector3(1.5, 0, 0)
var max_offset = Vector3(-1.65, 0, 0)

var zoom := 1.0
var offset := 0.5

var anim_pause_time = 999
var anim_timer = 999

func _ready():
	username_input.text = "User #" + str(randi_range(0, 1000))
	color_picker.color = Color(randf(), randf(), randf())
	
	display_ship.set_ship_name("[outline_size=8][outline_color=black]" + username_input.text)
	display_ship.set_ship_color(color_picker.color)
	
	display_ship_rotation_animation.pause()

func _process(delta):
	rotation_slider.set_value_no_signal((roundi(display_camera_pivot.rotation_degrees.y) / 360.0) * rotation_slider.max_value)
	
	if anim_timer > 0:
		anim_timer -= delta
		
	if anim_timer <= 0 and !display_ship_rotation_animation.is_playing():
		var time = rotation_slider.value / rotation_slider.max_value
		time *= display_ship_rotation_animation.current_animation_length
		
		display_ship_rotation_animation.play()
		display_ship_rotation_animation.seek(time, true)

func set_display_rotation(value):
	var rot = value / rotation_slider.max_value
	rot *= 360
	
	display_camera_pivot.rotation_degrees.y = rot

func set_offset_zoom():
	display_camera.position = lerp(min_offset, max_offset, offset) + lerp(min_zoom, max_zoom, zoom)

func _on_input_text_changed(_new_text):
	display_ship.set_ship_name("[outline_size=8][outline_color=black]" + username_input.text)

func _on_picker_color_changed(color):
	display_ship.set_ship_color(color)

func _on_rotation_slider_value_changed(value):
	display_ship_rotation_animation.pause()
	anim_timer = anim_pause_time
	
	set_display_rotation(value)

func _on_zoom_slider_value_changed(value):
	display_ship_rotation_animation.pause()
	anim_timer = anim_pause_time
	
	zoom = 1.0 - (value / zoom_slider.max_value)
	set_offset_zoom()
	set_display_rotation(rotation_slider.value)

func _on_offset_slider_value_changed(value):
	display_ship_rotation_animation.pause()
	anim_timer = anim_pause_time
	
	offset = 1.0 - (value / offset_slider.max_value)
	set_offset_zoom()
	set_display_rotation(rotation_slider.value)

func _on_launch_ship_button_pressed():
	GameManager.ship_name = "[outline_size=8][outline_color=black]" + username_input.text
	GameManager.ship_color = color_picker.color
	GameManager.ship_decals = display_ship.decals
	
	var scene = preload("res://scenes/game.tscn").instantiate()
	
	get_tree().root.add_child(scene)
	
	self.queue_free()
