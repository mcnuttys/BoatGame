extends RigidBody3D

@export var explosionEffect : PackedScene

@export var bullet_force := 750.0
@export var max_age := 5

var age = 0.0
var ownerID

func shoot(dir, _ownerID):
	apply_central_force(dir * bullet_force)
	ownerID = _ownerID

func explode():
	var explosion = explosionEffect.instantiate()
	explosion.set_ownerID(ownerID)
	
	explosion.global_position = global_position
	
	get_tree().root.add_child(explosion)
	age = max_age
	
func _process(delta):
	age += delta
	
	if age >= max_age:
		get_tree().root.remove_child(self)
	
	if global_position.y <= -0.1:
		explode()

#func _physics_process(delta):
	#transform.basis.x = linear_velocity.normalized()

func _on_body_entered(body):
	if body is StaticBody3D or body is CSGBox3D:
		return
	
	if body.authority_id == ownerID:
		return
	
	explode()
