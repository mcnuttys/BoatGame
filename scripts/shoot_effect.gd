extends Node3D

@onready var shoot_sfx = $shoot_sound

var max_age = 1
var age = 0

func _ready():
	shoot_sfx.pitch_scale = randf_range(0.8, 1.2)

func _process(delta):
	age += delta
	
	if age >= max_age:
		queue_free()
