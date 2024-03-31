extends Area3D

@export var explosion_force := 100.0
@export var explosion_damage := 10

@onready var collision_shape = $damage_area
@onready var damage_display = $display_mesh

@onready var particles = $display_particles
@onready var explosion_sfx = $explosion_sound

var explosion_radius := 1.0

var owner_node
var owner_id
var max_age = 1
var age = 0

var hurt_time = 0.1
var marked_hit := false

func _ready():
	particles.emitting = true
	
	collision_shape.shape.radius = explosion_radius
	damage_display.mesh.radius = explosion_radius
	damage_display.mesh.height = explosion_radius * 2
	
	particles.mesh.radius = (explosion_radius / 2.0)
	particles.mesh.height = explosion_radius
	
	explosion_sfx.pitch_scale = randf_range(0.8, 1.2)

func _process(delta):
	age += delta
	
	if age >= max_age:
		queue_free()
	
	if owner_id != multiplayer.get_unique_id():
		return
	
	if age > hurt_time and !marked_hit:
		owner_node.add_hit_marker(global_position, false)
		marked_hit = true

func _on_body_entered(body):
	if age > hurt_time:
		return
	
	if body is RigidBody3D:
		if body.get_parent() and body.get_parent().has_method("take_damage") and body.get_parent().authority_id != owner_id:
			if multiplayer.is_server():
				body.get_parent().take_damage.rpc(owner_id, explosion_damage, "explosion")
			
			owner_node.add_hit_marker(global_position, true)
			marked_hit = true
		
		if body.has_method("take_damage"):
			if multiplayer.is_server():
				body.take_damage.rpc(owner_id, explosion_damage)
			
			owner_node.add_hit_marker(global_position, true)
			marked_hit = true
		
		#var dist = body.global_position.distance_to(global_position)
		var force = explosion_force #(1.0 - (dist / 5.0)) * explosion_force
		body.apply_force((body.global_position - global_position).normalized() * force, body.global_position - global_position)
