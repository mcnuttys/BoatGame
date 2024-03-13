extends Node3D

var ownerID
func set_ownerID(_ownerID):
	ownerID = _ownerID

func _ready():
	$base_explosion.emitting = true
	
var maxAge = 3
var age = 0

var deletedArea2d := false
	
func _process(delta):
	age += delta
	
	if age > 0.1 and !deletedArea2d:
		delete_colliders()
	
	if age > maxAge:
		get_tree().root.remove_child(self)

func delete_colliders():
		remove_child($Area3D)
		remove_child($Water_Collision)
		deletedArea2d = true
	

func _on_area_3d_body_entered(body):
	if body is StaticBody3D or body is CSGBox3D:
		return
	
	if multiplayer and multiplayer.is_server():
		body.take_damage.rpc_id(body.authority_id, ownerID, global_position, 30)
	
	delete_colliders()
