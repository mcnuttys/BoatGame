extends Node3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node("/root/water_test/Water")

@onready var parent_rigidbody : RigidBody3D = get_parent()
@onready var probes = $probes.get_children()

var submerged := false

var center := Vector3.ZERO

func _ready():
	parent_rigidbody.gravity_scale = 0

	for p in probes:
		center += p.position
	center /= probes.size()
	parent_rigidbody.center_of_mass = center

func _buoyancy_process(delta):
	for p in probes:
		var normal = Vector3.UP
		var depth = -p.global_position.y
		if water != null:
			depth = water.get_height(p.global_position) - p.global_position.y
		
		if depth > 0:
			submerged = true
			parent_rigidbody.apply_force(normal * float_force * gravity * depth, p.global_position - get_center())
		
		parent_rigidbody.apply_force(Vector3(0, -gravity, 0) / probes.size(), p.global_position - get_center())
		
		p.get_child(0).text = str(roundf(depth*1000)/1000) + "\n" + str(round(p.global_position.y * 1000)/1000)

func _buoyancy_forces(state):
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag

func get_center():
	return global_position + center
