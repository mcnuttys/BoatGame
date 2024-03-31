extends Node3D

@export var shell_prefab : PackedScene
@export var shoot_effect_prefab : PackedScene

@onready var ship := $default_ship
@onready var player_camera := $player_camera_pivot/player_camera
@onready var player_camera_pivot := $player_camera_pivot
@onready var radar_camera := $radar_viewport/radar_camera
@onready var player_ui := $player_ui
@onready var multiplayer_sync := $MultiplayerSynchronizer

@onready var player_details := $default_ship/player_details
@onready var username_label := $"player_details_viewport/VBoxContainer/username_label"
@onready var health_bar := $"player_details_viewport/VBoxContainer/health_bar"

@onready var radar_viewport = $radar_viewport

@onready var hit_sound_player := $"hit_sound_effect"

var gun_power := 5.0
var gun_force := 750.0 * 1.5

var firerate := 1.0
var fire_timer := 0.0

var ship_data = {
	"name": "unset",
	"color": Color.WHITE,
	"decals": []
}

@export var authority_id := -1
var local_ship := false

var camera_offset := Vector3(0, 2, 6)
var camera_lerp_speed := 5.0

var camera_rotation := 0.0

var radar_camera_offset := Vector3(0, 5, 0)
var radar_camera_lerp_speed := 5.0

var health := 100.0
var fire_button_down := false

var controller

var sunk := false

func set_controller(_controller):
	controller = _controller

func set_authoirity(id):
	authority_id = id
	$MultiplayerSynchronizer.set_multiplayer_authority(authority_id)

func _ready():
	ship.set_controller(self)
	ship.set_ship_name(ship_data.name)
	ship.set_ship_color(ship_data.color)
	ship.set_ship_decals(ship_data.decals)
	
	username_label.text = "[center]" + ship_data.name
	health_bar.setup(health, health)
	
	if authority_id == multiplayer.get_unique_id():
		setup_local_ship()
	else:
		setup_network_ship()
	
	player_ui.rotate_steering_wheel_signal.connect(on_ui_rotate_wheel)
	player_ui.change_drive_slider_signal.connect(on_ui_change_drive)
	player_ui.rotate_radar_signal.connect(on_ui_rotate_radar)
	player_ui.change_lift_slider_signal.connect(on_ui_change_lift)
	player_ui.press_fire_button_signal.connect(on_ui_fire)
	player_ui.rotate_camera_signal.connect(on_ui_rotate_camera)

func _process(delta):
	health_bar.set_health(health)
	
	if !local_ship:
		return
	
	player_ui.tint_camera(player_camera.global_position.y < 0)
	
	if fire_timer > 0:
		fire_timer -= delta
	
	if fire_button_down and fire_timer <= 0:
		fire_timer = firerate
		shoot_guns.rpc(authority_id)
	
	player_ui.fire_timeout = clamp(fire_timer / firerate, 0, 1)
	
	var ship_up = ship.transform.basis.y
	var a = ship_up.project(Vector3.UP)
	
	if a.y < -0.5 and ship.buoyancy.submerged:
		take_damage.rpc(authority_id, 100, "flipped")

func _physics_process(delta):
	if !local_ship:
		return

	player_camera.look_at(ship.global_position)
	
	player_camera_pivot.global_position = ship.global_position
	player_camera_pivot.transform.basis = ship.transform.basis
	player_camera_pivot.rotate_y(deg_to_rad(camera_rotation))
	player_camera.global_position = lerp(
		player_camera.global_position, 
		player_camera_pivot.global_position + player_camera_pivot.transform.basis * camera_offset, 
		delta * camera_lerp_speed
	)
	
	radar_camera.global_position = ship.global_position + radar_camera_offset
	radar_camera.rotation_degrees.y = ship.rotation_degrees.y

func setup_network_ship():
	ship.gravity_scale = 0
	player_camera_pivot.queue_free()
	player_ui.queue_free()
	
	local_ship = false

func setup_local_ship():
	player_ui.setup_ship_data(ship_data.name, health, health, radar_viewport)
	
	player_camera.current = true
	player_camera_pivot.global_position = ship.global_position
	player_camera.position = ship.transform.basis * camera_offset
	
	player_details.visible = false
	
	local_ship = true

func set_player_data(player_data):
	ship_data = player_data

func set_ship_position(_position):
	#if authority_id == multiplayer.get_unique_id():
	$default_ship.position = _position

func set_ship_rotation(_rotation):
	#if authority_id == multiplayer.get_unique_id():
	$default_ship.rotation_degrees.y = _rotation

func on_ui_rotate_wheel(_rotation):
	ship.current_turn_rate = -(_rotation / (PI/2)) * ship.max_turn_rate

func on_ui_change_drive(_drive):
	ship.current_forward_speed = _drive * ship.forward_speed

func on_ui_rotate_radar(_rotation):
	ship.target_angle = rad_to_deg(-_rotation)

func on_ui_change_lift(_lift):
	ship.target_lift_angle = (1.0 - _lift) * ship.max_gun_lift

func on_ui_fire(button_down):
	if !local_ship:
		return
	
	fire_button_down = button_down

func on_ui_rotate_camera(_camera_rotation):
	camera_rotation = _camera_rotation

@rpc("any_peer", "call_local")
func shoot_guns(owner_id):
	if not ship.front_guns_sleep:
		for firepoint in ship.front_firepoints:
			fire_gun(firepoint, owner_id)
	
	if not ship.back_guns_sleep:
		for firepoint in ship.back_firepoints:
			fire_gun(firepoint, owner_id)

func fire_gun(firepoint, owner_id):
	ship.apply_force(firepoint.global_transform.basis.x * gun_power, firepoint.global_position - ship.global_position)
	
	var shoot_effect = shoot_effect_prefab.instantiate()
	shoot_effect.position = firepoint.global_position
	get_tree().root.add_child(shoot_effect)
	
	var new_shell = shell_prefab.instantiate()
	new_shell.owner_node = self
	new_shell.owner_id = owner_id
	
	new_shell.position = firepoint.global_position
	
	get_tree().root.add_child(new_shell)

	new_shell.global_transform.basis = firepoint.global_transform.basis
	
	var force = randf_range(gun_force - 50, gun_force + 50)
	new_shell.apply_central_force(-firepoint.global_transform.basis.x * force)

@rpc("any_peer", "call_local")
func take_damage(sender_id, amt, damage_type):
	health -= amt
	
	if health < 0:
		health = 0
	
	if health <= 0 and local_ship and !sunk:
		controller.player_died(authority_id, sender_id, damage_type)
		sunk = true
	
	if local_ship:
		player_ui.set_health(health)

func add_hit_marker(marker_position, is_hit):
	if local_ship:
		player_ui.add_hit_mark(marker_position, is_hit, radar_viewport, radar_camera)
		
		if is_hit:
			if hit_sound_player.playing:
				hit_sound_player.stop()
			
			hit_sound_player.play()
