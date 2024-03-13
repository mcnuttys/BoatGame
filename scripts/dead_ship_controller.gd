extends Node3D

func set_ship_color(color):
	print(color)
	var newMat = StandardMaterial3D.new()
	newMat.albedo_color = color
	
	$front/boat_front.set_surface_override_material(0, newMat)
	$back/boat_back.set_surface_override_material(0, newMat)
