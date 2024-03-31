extends DecoratedShip

@onready var buoyancy := $Buoyancy

@onready var front_gun_1 := $boat_model/boat_front/front_gun_1_pivot
@onready var front_gun_2 := $boat_model/boat_front/front_gun_2_pivot
@onready var back_gun_1 := $boat_model/boat_back/back_gun_1_pivot
@onready var back_gun_2 := $boat_model/boat_back/back_gun_2_pivot

@onready var front_gun_1_barrels := $boat_model/boat_front/front_gun_1_pivot/barrels_pivot
@onready var front_gun_2_barrels := $boat_model/boat_front/front_gun_2_pivot/barrels_pivot
@onready var back_gun_1_barrels := $boat_model/boat_back/back_gun_1_pivot/barrels_pivot
@onready var back_gun_2_barrels := $boat_model/boat_back/back_gun_2_pivot/barrels_pivot

@onready var back_gun_1_firepoint_1 := $boat_model/boat_back/back_gun_1_pivot/barrels_pivot/firepoint_1
@onready var back_gun_1_firepoint_2 := $boat_model/boat_back/back_gun_1_pivot/barrels_pivot/firepoint_2
@onready var back_gun_2_firepoint_1 := $boat_model/boat_back/back_gun_2_pivot/barrels_pivot/firepoint_1
@onready var back_gun_2_firepoint_2 := $boat_model/boat_back/back_gun_2_pivot/barrels_pivot/firepoint_2
@onready var front_gun_1_firepoint_1 := $boat_model/boat_front/front_gun_1_pivot/barrels_pivot/firepoint_1
@onready var front_gun_1_firepoint_2 := $boat_model/boat_front/front_gun_1_pivot/barrels_pivot/firepoint_2
@onready var front_gun_2_firepoint_1 := $boat_model/boat_front/front_gun_2_pivot/barrels_pivot/firepoint_1
@onready var front_gun_2_firepoint_2 := $boat_model/boat_front/front_gun_2_pivot/barrels_pivot/firepoint_2

@onready var drive_surface_audio := $audio_sources/drive_surface
@onready var drive_submerged_audio := $audio_sources/drive_submerged

@onready var front_firepoints = [
	front_gun_1_firepoint_1, front_gun_1_firepoint_2,
	front_gun_2_firepoint_1, front_gun_2_firepoint_2,
]

@onready var back_firepoints = [
	back_gun_1_firepoint_1, back_gun_1_firepoint_2,
	back_gun_2_firepoint_1, back_gun_2_firepoint_2,
]

@onready var debug_angle := $DEBUG_ANGLE

var max_thrust_speed := 5.0

var forward_speed := 10.0
var backward_speed := -4.0

var max_turn_rate := 1.0
var turn_rate = 0.05

var gun_rotate_speed := 5.0
var gun_lift_speed := 5.0

var max_gun_rotation := 115.0
var max_gun_lift := 45.0

var ram_damage := 10

var front_guns_sleep := false
var back_guns_sleep := false

@export var current_turn_rate := 0.0
@export var current_forward_speed := 0.0

@export var target_angle := 0.0
@export var target_lift_angle := 0.0

func _process(_delta):
	if current_forward_speed <= 0:
		drive_surface_audio.stop()
		drive_submerged_audio.stop()
	else:
		var pitch = (current_forward_speed / forward_speed)
		drive_surface_audio.pitch_scale = pitch
		drive_submerged_audio.pitch_scale = pitch
		
		if buoyancy.submerged and !drive_submerged_audio.playing:
			drive_submerged_audio.play()
		
		#  !buoyancy.submerged and 
		if !drive_surface_audio.playing:
			drive_surface_audio.play()
		
		#if buoyancy.submerged and drive_surface_audio.playing:
		#	drive_surface_audio.stop()
		
		if !buoyancy.submerged and drive_submerged_audio.playing:
			drive_submerged_audio.stop()

func _physics_process(_delta):
	if target_angle <= -180:
		target_angle += 360
	if target_angle >= 180:
		target_angle -= 360
	
	rotate_guns(deg_to_rad(target_angle), _delta)
	lift_guns(deg_to_rad(target_lift_angle), _delta)
	
	if !controller:
		return
	
	if !controller.local_ship:
		return
	
	#if not buoyancy.submerged:
	#	return
	
	var thrust = transform.basis.z * -current_forward_speed
	var proj = linear_velocity.project(thrust)
	
	# print(thrust.length(), " Proj: " , proj.length(), " Max: " , max_thrust_speed)
	
	if proj.length() > max_thrust_speed:
		thrust = Vector3.ZERO
	
	apply_central_force(thrust)
	rotate_y(deg_to_rad(current_turn_rate))
	
func _integrate_forces(state):
	buoyancy.integrate_forces(state)

func rotate_gun(gun, _target_angle, deltaTime):
	if _target_angle < deg_to_rad(-max_gun_rotation) or _target_angle > deg_to_rad(max_gun_rotation):
		_target_angle = 0
	
	var currentAngle = gun.rotation.y 
	var dir = clamp(_target_angle - currentAngle, -1, 1)
	
	gun.rotate_y(dir * gun_rotate_speed * deltaTime)
	# gun.rotation.y = clamp(gun.rotation.y, deg_to_rad(-max_gun_rotation), deg_to_rad(max_gun_rotation))

func rotate_guns(angle, deltaTime):
	var front_angle = angle
	var back_angle = angle + deg_to_rad(180 * sign(-angle))
	front_guns_sleep = false
	back_guns_sleep = false
	
	if front_angle < deg_to_rad(-max_gun_rotation) or front_angle > deg_to_rad(max_gun_rotation):
		front_angle = 0
		front_guns_sleep = true
	
	if back_angle < deg_to_rad(-max_gun_rotation) or back_angle > deg_to_rad(max_gun_rotation):
		back_angle = 0
		back_guns_sleep = true
	
	rotate_gun(front_gun_1, front_angle, deltaTime)
	rotate_gun(front_gun_2, front_angle, deltaTime)
	
	rotate_gun(back_gun_1, back_angle, deltaTime)
	rotate_gun(back_gun_2, back_angle, deltaTime)
	
	debug_angle.rotation.y = angle

func lift_gun(gun, _target_angle, deltaTime):
	var currentAngle = gun.rotation.z
	var dir = clamp(_target_angle - currentAngle, -1, 1)
	
	gun.rotate_z(dir * gun_lift_speed * deltaTime)

func lift_guns(target_lift, deltaTime):
	var front_lift = -target_lift
	var back_lift = target_lift
	
	if front_guns_sleep:
		front_lift = 0
	
	if back_guns_sleep:
		back_lift = 0
	
	lift_gun(front_gun_1_barrels, front_lift, deltaTime)
	lift_gun(front_gun_2_barrels, front_lift, deltaTime)
	lift_gun(back_gun_1_barrels, back_lift, deltaTime)
	lift_gun(back_gun_2_barrels, back_lift, deltaTime)

func _on_body_entered(body):
	if !multiplayer.is_server():
		return
	
	if body.has_method("take_damage"):
		body.take_damage.rpc(get_parent().authority_id, ram_damage)
		
	# if body.get_parent() and body.get_parent().has_method("take_damage"):
	# 	body.get_parent().take_damage.rpc(get_parent().authority_id, ram_damage)
