extends RigidBody3D

@export var explosion_effect : PackedScene

@onready var ray_cast_3d = $RayCast3D

var owner_node
var owner_id

var max_age = 5
var age = 0

func _process(delta):
	age += delta
	
	if age >= max_age:
		queue_free()
	
	if position.y <= 0:
		explode()
	
	if ray_cast_3d.is_colliding():
		process_raycast()

func _physics_process(_delta):
	if linear_velocity.length_squared() > 0:
		look_at(global_position + linear_velocity)
		ray_cast_3d.global_position = global_position
		ray_cast_3d.target_position = global_position + linear_velocity

func process_raycast():
	var body = ray_cast_3d.get_collider()
	if "authority_id" in body.get_parent() and body.get_parent().authority_id == owner_id:
		return
	
	# explode()

func _on_body_entered(body):
	if "authority_id" in body.get_parent() and body.get_parent().authority_id == owner_id:
		return
	
	explode()

func explode():
	var new_explosion = explosion_effect.instantiate()
	new_explosion.owner_node = owner_node
	new_explosion.owner_id = owner_id
	new_explosion.transform.origin = global_position
	
	get_tree().root.add_child(new_explosion)

	queue_free()
