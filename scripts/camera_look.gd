extends Camera3D

@onready var target = get_parent()

@export var offset := Vector3(0.0, 2.0, 5.0)
@export var followSpeed := 5.0

func _process(delta):
	look_at(target.global_position)
	

func _physics_process(delta):	
	global_position = lerp(global_position, target.global_position + target.transform.basis * offset, followSpeed * delta)
