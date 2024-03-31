extends TextureRect

@export var hit_texture : Texture2D

var world_pos : Vector3
var viewport : Viewport
var camera : Camera3D

var age := 0.0
var max_age := 0.25

func setup_hit_mark(_world_pos, is_hit, _viewport, _camera):
	world_pos = _world_pos
	viewport = _viewport
	camera = _camera
	
	if is_hit:
		texture = hit_texture

func _process(delta):
	if !viewport:
		return
	
	var screen_pos = camera.unproject_position(world_pos)
	position = screen_pos
	
	age += delta
	if age > max_age:
		queue_free()
