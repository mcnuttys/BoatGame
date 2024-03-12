extends RigidBody3D

@export var max_float_force := 4.0
@export var float_curve := Curve.new()

@onready var buoyancy = $Buoyancy

var max_age := 10.0
var age := 0.0

func _process(delta):
	age += delta
	
	buoyancy.float_force = (1.0 - float_curve.sample(age / max_age)) * max_float_force
	
	if age >= max_age:
		queue_free()

func _physics_process(delta):
	if buoyancy:
		buoyancy._buoyancy_process(delta)

func _integrate_forces(state):
	if buoyancy:
		buoyancy._buoyancy_forces(state)
