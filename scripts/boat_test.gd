extends RigidBody3D

@export var float_force := 1.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@export var turn_rate := 0.01
@export var max_turn_rate := 2.0

@export var forward_speed = 10
@export var backward_speed = 2

@export var bullet : PackedScene
@export var shoot_effect : PackedScene

@export var gun_rotate_speed := 1.0
@export var gun_lift_speed := 1.0
@export var min_gun_rotation := -115.0
@export var max_gun_rotation := 115.0
@export var min_gun_lift := 5.0
@export var max_gun_lift := -45.0
@export var gun_power = 8

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = get_node("/root/water_test/Water")

@onready var probes = $BuoyancyProbes.get_children()
@onready var camera := $Camera3D

@onready var front_gun_1 = $boat_split/front_gun_1
@onready var front_gun_2 = $boat_split/front_gun_2
@onready var back_gun_1 = $boat_split/back_gun_1
@onready var back_gun_2 = $boat_split/back_gun_2
@onready var front_gun_1_barrel = $boat_split/front_gun_1/barrel
@onready var front_gun_2_barrel = $boat_split/front_gun_2/barrel
@onready var back_gun_1_barrel = $boat_split/back_gun_1/barrel
@onready var back_gun_2_barrel = $boat_split/back_gun_2/barrel

@onready var front_gun_1_fire_point_1 = $boat_split/front_gun_1/barrel/firepoint1
@onready var front_gun_1_fire_point_2 = $boat_split/front_gun_1/barrel/firepoint2

@onready var front_gun_2_fire_point_1 = $boat_split/front_gun_2/barrel/firepoint1
@onready var front_gun_2_fire_point_2 = $boat_split/front_gun_2/barrel/firepoint2

@onready var back_gun_1_fire_point_1 = $boat_split/back_gun_1/barrel/firepoint1
@onready var back_gun_1_fire_point_2 = $boat_split/back_gun_1/barrel/firepoint2

@onready var back_gun_2_fire_point_1 = $boat_split/back_gun_2/barrel/firepoint1
@onready var back_gun_2_fire_point_2 = $boat_split/back_gun_2/barrel/firepoint2

@onready var firepoints = [
	front_gun_1_fire_point_1,
	front_gun_1_fire_point_2,
	front_gun_2_fire_point_1,
	front_gun_2_fire_point_2,
	back_gun_1_fire_point_1,
	back_gun_1_fire_point_2,
	back_gun_2_fire_point_1,
	back_gun_2_fire_point_2,
]

var current_turn_rate := 0.0
var current_forward_speed := 0.0

const water_height := 0.0

var submerged := false

var aim_angle := 0.0
var current_angle := 0.0
var current_lift := 0.0

var authority_id = -1

func _ready():
	authority_id = str(name).to_int()
	$MultiplayerSynchronizer.set_multiplayer_authority(authority_id)
	
	if authority_id != multiplayer.get_unique_id():
		camera.current = false
		gravity_scale = 0
		
		remove_child($Control)
	else:
		camera.current = true

func rotate_gun(gun, target_angle, deltaTime):
	var currentAngle = gun.rotation.y 
	var dir = target_angle - currentAngle
	
	gun.rotate_y(sign(dir) * gun_rotate_speed * deltaTime)
	gun.rotation.y = clamp(gun.rotation.y, deg_to_rad(min_gun_rotation), deg_to_rad(max_gun_rotation))

func rotate_guns(angle, deltaTime):
	rotate_gun(front_gun_1, angle, deltaTime)
	rotate_gun(front_gun_2, angle, deltaTime)
	rotate_gun(back_gun_1, angle + deg_to_rad(180 * sign(-angle)), deltaTime)
	rotate_gun(back_gun_2, angle + deg_to_rad(180 * sign(-angle)), deltaTime)

func lift_gun(gun, target_angle, deltaTime):
	var currentAngle = gun.rotation.z
	var dir = target_angle - currentAngle
	
	var angle = sign(dir) * gun_lift_speed * deltaTime
	gun.rotation.z = target_angle

func lift_guns(target_angle, deltaTime):
	lift_gun(front_gun_1_barrel, target_angle, deltaTime)
	lift_gun(front_gun_2_barrel, target_angle, deltaTime)
	lift_gun(back_gun_1_barrel, -target_angle, deltaTime)
	lift_gun(back_gun_2_barrel, -target_angle, deltaTime)

@rpc("any_peer", "call_local")
func shoot_guns(owner_id):
	for firepoint in firepoints:
		apply_force(-firepoint.global_transform.basis.x * gun_power, firepoint.global_position - global_position)
		
		var bullet = bullet.instantiate() 
		get_tree().root.add_child(bullet)
		
		bullet.global_transform.origin = firepoint.global_position
		bullet.global_transform.basis = firepoint.global_transform.basis
		bullet.shoot(firepoint.global_transform.basis.x, owner_id)
		
		var explosion_effect = shoot_effect.instantiate()
		get_tree().root.add_child(explosion_effect)
		
		explosion_effect.global_transform.basis = firepoint.global_transform.basis
		explosion_effect.global_transform.origin = firepoint.global_position
		explosion_effect.get_child(0).emitting = true

func shoot():
	shoot_guns.rpc(authority_id)

func _process(delta):
	if authority_id != multiplayer.get_unique_id():
		return
		
	#if Input.is_action_pressed("ui_left"):
	#	aim_angle += gun_rotate_speed * delta
	
	#if Input.is_action_pressed("ui_right"):
	#	aim_angle += -gun_rotate_speed * delta
	
	rotate_guns(aim_angle, delta)
	lift_guns(current_lift, delta)
	
	#if Input.is_action_pressed("ui_up"):
	#	lift_guns(gun_lift_speed * delta)
		
	#if Input.is_action_pressed("ui_down"):
	#	lift_guns(-gun_lift_speed * delta)
		
	#if Input.is_action_just_pressed("jump"):
	#	shoot_guns.rpc(authority_id)

func _physics_process(delta):
	if authority_id != multiplayer.get_unique_id():
		return

	submerged = false
	for p in probes:
		var depth = -p.global_position.y
		var normal = Vector3.UP
		if water != null:
			depth = water.get_height(p.global_position) - p.global_position.y
			#normal = water.get_normal(p.global_position)
	
		if depth > 0:
			submerged = true
			apply_force(normal * float_force * gravity * depth, p.global_position - global_position)
		p.get_child(0).text = str(roundf(depth*1000)/1000) + "\n" + str(round(p.global_position.y * 1000)/1000)
	
	#current_turn_rate = lerpf(current_turn_rate, 0, delta)
	
	#if Input.is_action_pressed("move_left"):
	#	current_turn_rate += turn_rate
	#	
	#if Input.is_action_pressed("move_right"):
	#	current_turn_rate -= turn_rate
	
	#current_turn_rate = clamp(current_turn_rate, -max_turn_rate, max_turn_rate)
	rotate_y(deg_to_rad(current_turn_rate))
	
	if !submerged:
		return
		
	#if Input.is_action_pressed("move_up"):
	#	apply_central_force(transform.basis.z * -forward_speed)
	#if Input.is_action_pressed("move_down"):
	#	apply_central_force(transform.basis.z * backward_speed)
	apply_central_force(transform.basis.z * -current_forward_speed)

func _integrate_forces(state):
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag

func set_player_data(username, color):
	$UsernameLabel.text = username
	
	var newMat = StandardMaterial3D.new()
	newMat.albedo_color = color
	
	$boat_split/boat_front.set_surface_override_material(0, newMat)
	$boat_split/boat_back.set_surface_override_material(0, newMat)
	pass

@rpc("any_peer", "call_local")
func take_damage(sender, position, power):	
	apply_force((global_position - position).normalized() * power, position - global_position)
