extends Node3D

@onready var armature := $Armature
@onready var skeleton := $Armature/Skeleton3D

# Called when the node enters the scene tree for the first time.
func _ready():
	print()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var id = skeleton.find_bone("2")
	skeleton.get_bone_pose(id).rotated(Vector3(0,1,0), delta)
	pass
