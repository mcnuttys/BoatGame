extends RigidBody3D

@onready var buoyancy := $Buoyancy

func _process(delta):
	for probe in buoyancy.probes:
		if probe.float_force > 0:
			probe.float_force -= delta * 0.05
		
		if probe.float_force < 0:
			probe.float_force = 0

func _integrate_forces(state):
	buoyancy.integrate_forces(state)
