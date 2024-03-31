extends Panel

@onready var decal_prefab : PackedScene = preload("res://prefabs/ui/decal_ui.tscn") 
@onready var decal_holder := $ScrollContainer/GridContainer

@onready var display_viewport = $"../../../ShipDisplay_viewport"
@onready var display_ship = $"../../../ShipDisplay_viewport/default_ship"
@onready var display_camera = $"../../../ShipDisplay_viewport/CameraPivot/RotPivot/Camera3D"
@onready var display_texture = $"../../Panel/TextureRect"

@onready var decal_ship_raycast = $"../../../ShipDisplay_viewport/decal_ship_raycast"

@onready var decal_preview_ui := $decal_ui
@onready var decal_preview = $"../../../ShipDisplay_viewport/decal_preview"
@onready var decal_preview_decal = $"../../../ShipDisplay_viewport/decal_preview/decal"

var decals = [
	{
		"name": "Godot Icon",
		"path": "res://textures/decals/icon.svg",
		"size":  Vector3(0.15, 0.15, 0.15)
	},
	{
		"name": "Steering Wheel",
		"path": "res://textures/decals/wheel.png",
		"size": Vector3(0.15, 0.15, 0.15)
	}
]

var dragging := false
var offset := Vector2.ZERO

var current_decal
var decal_raycast_point = Vector3.ZERO
var decal_raycast_normal = Vector3.ZERO

func _ready():
	for decal in decals:
		var new_decal_ui = decal_prefab.instantiate()
		var decal_texture = load(decal.path)
		
		new_decal_ui.set_controller(self)
		new_decal_ui.set_texture(decal_texture)
		new_decal_ui.set_label(decal.name)
		new_decal_ui.set_decal_size(decal.size)
		
		decal_holder.add_child(new_decal_ui)

func _physics_process(_delta):
	if !dragging:
		return
	
	var mousepos = (display_texture.get_local_mouse_position() / display_texture.size.x) * display_viewport.size.x
	
	var from = display_camera.project_ray_origin(mousepos)
	var to = from + display_camera.project_ray_normal(mousepos) * 10
		
	decal_ship_raycast.global_position = from
	decal_ship_raycast.target_position = to - from
	
	if decal_ship_raycast.is_colliding():
		decal_preview.visible = true
		decal_preview_ui.visible = false
		
		decal_raycast_point = decal_ship_raycast.get_collision_point()
		decal_raycast_normal = decal_ship_raycast.get_collision_normal()
		
		decal_preview.look_at(decal_raycast_point + decal_raycast_normal, Vector3.UP)
		decal_preview.global_position = decal_raycast_point
	else:
		decal_preview.visible = false
		decal_preview_ui.visible = true

func begin_drag(decal, mouse_pos, _offset):
	current_decal = decal
	offset = _offset
	
	decal_preview_ui.set_texture(decal.texture)
	decal_preview_ui.set_label(decal.label)
	decal_preview_ui.global_position = mouse_pos - _offset
	decal_preview_ui.visible = true
	
	decal_preview_decal.texture_albedo = decal.texture
	decal_preview_decal.size = decal.decal_size
	
	dragging = true

func end_drag():
	decal_preview_ui.visible = false
	decal_preview.visible = false
	offset = Vector2.ZERO
	dragging = false
	
	if !decal_ship_raycast.is_colliding():
		current_decal = null
		return
		
	var local_position = decal_preview.global_position - display_ship.global_position
	var local_rotation = decal_preview.global_rotation
	display_ship.add_decal(current_decal, local_position, local_rotation)
	
	decal_ship_raycast.global_position = Vector3.ZERO
	decal_ship_raycast.target_position = Vector3.ZERO
	current_decal = null

func _input(event):
	if dragging and event is InputEventMouseButton:
		if !event.is_pressed():
			end_drag()
	
	if dragging and event is InputEventMouseMotion:
		decal_preview_ui.global_position = event.position - offset
