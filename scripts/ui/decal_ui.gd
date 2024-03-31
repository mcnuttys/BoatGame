extends Control

var controller
var texture : Texture2D
var label : String
var decal_size : Vector3

func set_controller(_controller):
	controller = _controller

func set_texture(_texture):
	$TextureRect.texture = _texture
	texture = _texture

func set_label(_label):
	$Label.text = _label
	label = _label

func set_decal_size(_decal_size):
	decal_size = _decal_size

func _on_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		controller.begin_drag(self, event.global_position, event.position)
