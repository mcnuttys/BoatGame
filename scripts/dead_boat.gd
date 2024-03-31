extends Node3D

var max_age = 30
var age = 0

func _process(delta):
	if !multiplayer.is_server():
		return
	
	age += delta
	
	if age > max_age:
		queue_free()

func set_material(material):
	apply_material($"pivot/boat_front", material)
	apply_material($"pivot/boat_back", material)

func apply_material(_ship_model, material):
	var models = _ship_model.get_children(true)
	for model in models:
		if model is MeshInstance3D:
			model.set_surface_override_material(0, material)
		
		if model.get_child_count() > 0:
			apply_material(model, material)
