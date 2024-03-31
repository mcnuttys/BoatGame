extends RigidBody3D

@onready var buoyancy := $Buoyancy

@onready var quack_sound := $quack_sound_effect

func _ready():
	pass

func _integrate_forces(state):
	buoyancy.integrate_forces(state)

@rpc("any_peer", "call_local")
func take_damage(_sender_id, _amt):
	quack_sound.play()

func _on_body_entered(_body):
	quack_sound.play()
