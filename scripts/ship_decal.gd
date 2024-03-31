extends Node3D

@onready var decal = $decal

func set_decal_texture(texture):
	decal.texture_albedo = texture

func set_decal_size(size):
	decal.size = size
