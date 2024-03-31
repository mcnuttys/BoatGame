extends Area3D

@export var destinations : Array[Node3D]

func _on_body_entered(body):
	if not body is RigidBody3D:
		return
		
	if destinations.size() <= 0:
		return
	
	var destination := destinations[randi_range(0, destinations.size() - 1)]
	body.global_position = destination.global_position
	body.global_rotation = destination.global_rotation
