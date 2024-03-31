class_name DecoratedShip

extends RigidBody3D

@onready var decal_prefab := preload("res://prefabs/ship_decal.tscn")
@onready var AO_texture := preload("res://models/boat_split_AO.png")

@onready var ship_model := $boat_model
@onready var ship_label := $Ship_Label/ShipLabel_viewport/ShipLabel
@onready var ship_decals := $Ship_Decals

var ship_name = "Default Name"
var ship_color = Color.LIGHT_GRAY
var controller = null

var display_ship_material : Material
var decals = []

func _ready():
	display_ship_material = StandardMaterial3D.new()
	display_ship_material.albedo_texture = AO_texture
	apply_material(ship_model, display_ship_material)
	
	set_ship_name(ship_name)
	set_ship_color(ship_color)

func apply_material(_ship_model, material):
	var models = _ship_model.get_children(true)
	for model in models:
		if model is MeshInstance3D:
			model.set_surface_override_material(0, material)
		
		if model.get_child_count() > 0:
			apply_material(model, material)

func set_controller(_controller):
	controller = _controller

func set_ship_name(_name):
	ship_label.text = _name
	ship_name = _name

func set_ship_color(color):
	display_ship_material.albedo_color = color
	ship_color = color

func set_ship_decals(_decals):
	for decal in _decals:
		add_decal(decal, decal.position, decal.rotation)

func add_decal(decal, _position, _rotation):
	if ship_decals.get_child_count() >= 7:
		ship_decals.remove_child(ship_decals.get_child(0))
		decals.pop_back()
	
	var new_decal = decal_prefab.instantiate()
	
	new_decal.position = _position
	new_decal.rotation = _rotation
	
	ship_decals.add_child(new_decal)
	
	new_decal.set_decal_texture(decal.texture)
	new_decal.set_decal_size(decal.decal_size)
	
	decals.append({
		"texture" = decal.texture,
		"decal_size" = decal.decal_size,
		"position" = _position,
		"rotation" = _rotation
	})
