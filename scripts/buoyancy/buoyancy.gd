extends Node3D

@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# @onready var water = %water

@onready var parent_rigidbody : RigidBody3D = get_parent()
@onready var probes = get_children()

var submerged := false
var submerged_count := 0

var center := Vector3.ZERO

func _ready():
	parent_rigidbody.gravity_scale = 0
	for p in probes:
		center += p.position
	center /= probes.size()
	
	parent_rigidbody.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	parent_rigidbody.center_of_mass = center

func _physics_process(_delta):
	submerged = false
	submerged_count = 0
	for p in probes:
		var normal = Vector3.UP
		var depth = -p.global_position.y
		
		#if water != null:
		#	depth = water.get_height(p.global_position) - p.global_position.y
		
		if depth > 0:
			submerged = true
			submerged_count += 1
			
			parent_rigidbody.apply_force(normal * p.float_force * gravity * depth, p.global_position - get_center())
		
		parent_rigidbody.apply_force(Vector3(0, -gravity, 0) / probes.size(), p.global_position - get_center())

func integrate_forces(state):
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag

func get_center():
	return global_position + center
