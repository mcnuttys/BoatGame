extends Control

@onready var hit_marker_prefab = load("res://prefabs/ui/hit_mark.tscn")

@onready var steering_wheel_pivot := $steering_wheel
@onready var steering_wheel := $steering_wheel/TextureRect
@onready var drive_slider_handle := $thrust_slider/slider
@onready var radar_pivot := $radar/pivot
@onready var radar_handle_pivot := $radar/dial_pivot
@onready var radar_texture = $radar/radar_mask/radar_texture
@onready var lift_slider_handle := $lift_slider/slider
@onready var fire_button := $fire_button
@onready var fire_button_progress := $fire_button/progress_bar

@onready var lift2_slider_pivot := $"lift_slider_2/slider_pivot"

@onready var username_label := $"ship_data/VBoxContainer/username_label"
@onready var health_bar := $"ship_data/VBoxContainer/health_bar"

@onready var submerged_tint := $"submerged_tint"

@onready var debug_label := $DEBUG_LABEL

var wheel_rotate := false
var wheel_angle := 0.0
var last_wheel_angle := 0.0
var max_wheel_angle := 90.0
var min_wheel_angle := -90.0

var changing_drive := false
var drive_value := 0.0
var min_drive_value := 8
var max_drive_value := 160

var radar_rotate := false
var radar_angle := 0.0

var changing_lift := false
var lift_value := 0.0
var min_lift_value := 32 
var max_lift_value := 192
var min_lift_angle := -45.0
var max_lift_angle := 45.0

var rotating_camera := false
var camera_rotation := 0.0

var fire_timeout := 0.0

signal rotate_steering_wheel_signal(_rotation)
signal change_drive_slider_signal(_drive)
signal rotate_radar_signal(_rotation)
signal change_lift_slider_signal(_lift)
signal rotate_camera_signal(_rotation)
signal press_fire_button_signal(button_down)

func _ready():
	GameManager.ui_scale_changed_signal.connect(scale_ui)
	scale_ui()

func _process(delta):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		check_player_input(delta)
	
	fire_button_progress.value = (1.0 - fire_timeout) * 100.0

func scale_ui():
	var ui_scale = GameManager.get_ui_scale()
	
	for element in get_children():
		element.scale = Vector2(ui_scale, ui_scale)

func setup_ship_data(ship_name, health, max_health, viewport):
	username_label.text = "[right]" + ship_name
	health_bar.setup(health, max_health)
	
	radar_texture.texture.viewport_path = viewport.get_path()

func check_player_input(delta):
	if Input.is_action_pressed("left"):
		rotate_wheel_angle(wheel_angle - 2.5 * delta)
		
	if Input.is_action_pressed("right"):
		rotate_wheel_angle(wheel_angle + 2.5 * delta)
	
	if Input.is_action_pressed("forward"):
		change_drive_slider((drive_slider_handle.position.y + 16) - 256 *  delta)
	
	if Input.is_action_pressed("backward"):
		change_drive_slider((drive_slider_handle.position.y + 16) + 256 *  delta)
	
	if Input.is_action_pressed("arrow_left"):
		rotate_radar_angle(radar_angle - (PI / 2) * delta)
		
	if Input.is_action_pressed("arrow_right"):
		rotate_radar_angle(radar_angle + (PI / 2) * delta)
	
	if Input.is_action_pressed("arrow_up"):
		rotate_lift_slider_valie(lift_value + 1.0 * delta)
	
	if Input.is_action_pressed("arrow_down"):
		rotate_lift_slider_valie(lift_value - 1.0 * delta)
	
	if Input.is_action_just_pressed("space") or Input.is_action_just_released("space"):
		press_fire_button_signal.emit(Input.is_action_pressed("space"))

func calculate_angle(_position, _pivot_offset):
		var center = _pivot_offset
		var angle = _position - center
		return atan2(angle.y, angle.x)

func rotate_wheel(_position):
		var angle = calculate_angle(_position, steering_wheel_pivot.pivot_offset)
		wheel_angle += angle - last_wheel_angle
		
		# There is a funny behavior when rotating to the left off screen so it should be ok?
		wheel_angle = clamp(wheel_angle, deg_to_rad(min_wheel_angle), deg_to_rad(max_wheel_angle))
		
		rotate_wheel_angle(wheel_angle)
		last_wheel_angle = angle

func rotate_wheel_angle(angle):
		wheel_angle = angle
		wheel_angle = clamp(wheel_angle, deg_to_rad(min_wheel_angle), deg_to_rad(max_wheel_angle))
		
		rotate_steering_wheel_signal.emit(angle)
		steering_wheel.rotation = angle

func _on_steering_wheel_gui_input(event):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		if event is InputEventMouseButton:
			wheel_rotate = event.is_pressed()
			last_wheel_angle = calculate_angle(event.position, steering_wheel_pivot.pivot_offset)
			
			if event.is_double_click():
				rotate_wheel_angle(0)
	
		if event is InputEventMouseMotion and wheel_rotate:
			rotate_wheel(event.position)
	
	if OS.has_feature("android") or OS.has_feature("ios"):
		if event is InputEventScreenTouch:
			wheel_rotate = event.is_pressed()
			last_wheel_angle = calculate_angle(event.position, steering_wheel_pivot.pivot_offset)
			
			if event.is_double_tap():
				rotate_wheel_angle(0)
	
		if event is InputEventScreenDrag and wheel_rotate:
			rotate_wheel(event.position)
			debug_label.text = event

func change_drive_slider(_position_y):
	drive_value = _position_y - 16
	drive_value = clamp(drive_value, min_drive_value, max_drive_value)
	
	var drive_value01 = 1 - (drive_value - min_drive_value) / (max_drive_value - min_drive_value)
	change_drive_slider_signal.emit(drive_value01)
	drive_slider_handle.position.y = drive_value

func _on_drive_slider_gui_input(event):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		if event is InputEventMouseButton:
			changing_drive = event.is_pressed()
			
			if event.is_double_click():
				change_drive_slider(max_drive_value + 16)
	
		if event is InputEventMouseMotion and changing_drive:
			change_drive_slider(event.position.y)
	
	if OS.has_feature("android") or OS.has_feature("ios"):
		if event is InputEventScreenTouch:
			changing_drive = event.is_pressed()
			
			if event.is_double_tap():
				change_drive_slider(max_drive_value + 16)
	
		if event is InputEventScreenDrag and changing_drive:
			change_drive_slider(event.position.y)

func rotate_radar(_position):
	var angle = calculate_angle(_position, radar_pivot.pivot_offset)
	radar_angle = angle + (PI / 2)
	
	if radar_angle > PI:
		radar_angle -= 2 * PI
	
	rotate_radar_signal.emit(radar_angle)
	radar_handle_pivot.rotation = radar_angle

func rotate_radar_angle(angle):
	radar_angle = angle
	
	rotate_radar_signal.emit(radar_angle)
	radar_handle_pivot.rotation = radar_angle

func _on_radar_gui_input(event):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		if event is InputEventMouseButton:
			radar_rotate = event.is_pressed()
			rotate_radar(event.position)
	
		if event is InputEventMouseMotion and radar_rotate:
			rotate_radar(event.position)
	
	if OS.has_feature("android") or OS.has_feature("ios"):
		if event is InputEventScreenTouch:
			radar_rotate = event.is_pressed()
			rotate_radar(event.position)
	
		if event is InputEventScreenDrag and radar_rotate:
			rotate_radar(event.position)
			debug_label.text = event

func change_lift_slider(_position):
		lift_value = _position.y + 12
		lift_value = clamp(lift_value, min_lift_value, max_lift_value)
		
		var lift_value01 = (lift_value - min_lift_value) / (max_lift_value - min_lift_value) 
		change_lift_slider_signal.emit(lift_value01)
		lift_slider_handle.position.y = lift_value

func rotate_lift_slider(_position):
	var angle = calculate_angle(_position, lift2_slider_pivot.pivot_offset) + PI
	
	if angle > deg_to_rad(180):
		angle -= deg_to_rad(360)
	
	angle = clamp(angle, deg_to_rad(min_lift_angle), deg_to_rad(max_lift_angle))
	lift2_slider_pivot.rotation = angle - PI
	
	lift_value = (rad_to_deg(angle) - min_lift_angle) / (max_lift_angle - min_lift_angle)
	change_lift_slider_signal.emit(1 - lift_value)

func rotate_lift_slider_valie(value):
	value = clamp(value, 0.0, 1.0)
	
	var angle = value * (max_lift_angle - min_lift_angle) + min_lift_angle
	lift2_slider_pivot.rotation = deg_to_rad(angle) - PI
	
	lift_value = value
	change_lift_slider_signal.emit(1 - lift_value)

func _on_lift_slider_gui_input(event):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		if event is InputEventMouseButton:
			changing_lift = event.is_pressed()
	
		if event is InputEventMouseMotion and changing_lift:
			change_lift_slider(event.position)
			
	if OS.has_feature("android") or OS.has_feature("ios"):
		if event is InputEventScreenTouch:
			changing_lift = event.is_pressed()
	
		if event is InputEventScreenDrag and changing_lift:
			change_lift_slider(event.position)
			debug_label.text = event

func _on_lift_slider_2_gui_input(event):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		if event is InputEventMouseButton:
			changing_lift = event.is_pressed()
		
		if event is InputEventMouseMotion and changing_lift:
			rotate_lift_slider(event.position)
	
	if OS.has_feature("android") or OS.has_feature("ios"):
		if event is InputEventScreenTouch:
			changing_lift = event.is_pressed()
	
		if event is InputEventScreenDrag and changing_lift:
			rotate_lift_slider(event.position)
			debug_label.text = event

func _on_fire_button_gui_input(event):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MASK_LEFT:
			press_fire_button_signal.emit(event.is_pressed())
	
	if OS.has_feature("android") or OS.has_feature("ios"):
		if event is InputEventScreenTouch:
			press_fire_button_signal.emit(event.is_pressed())

func set_health(health):
	health_bar.set_health(health)

func _on_camera_rotate_slider_gui_input(event):
	if OS.has_feature("windows") or OS.has_feature("macos"):
		if event is InputEventMouseButton:
			rotating_camera = event.is_pressed()
			
			if event.is_double_click():
				camera_rotation = 0
				rotate_camera_signal.emit(camera_rotation)
	
		if event is InputEventMouseMotion and rotating_camera:
			camera_rotation += -event.velocity.x * 0.001
			
			if camera_rotation > 360:
				camera_rotation -= 360 * 2
			
			if camera_rotation < -360:
				camera_rotation += 360 * 2
			
			rotate_camera_signal.emit(camera_rotation)
	
	if OS.has_feature("android") or OS.has_feature("ios"):
		if event is InputEventScreenTouch:
			rotating_camera = event.is_pressed()
			
			if event.is_double_tap():
				camera_rotation = 0
				rotate_camera_signal.emit(camera_rotation)
	
		if event is InputEventScreenDrag and rotating_camera:
			camera_rotation += event.velocity.x * 0.001
			
			if camera_rotation > 360:
				camera_rotation -= 360 * 2
			
			if camera_rotation < -360:
				camera_rotation += 360 * 2
			
			rotate_camera_signal.emit(camera_rotation)

func add_hit_mark(world_position, is_hit, viewport, camera):
	var hit_mark = hit_marker_prefab.instantiate()
	hit_mark.setup_hit_mark(world_position, is_hit, viewport, camera)
	
	radar_texture.add_child(hit_mark)

func tint_camera(submerged):
	submerged_tint.visible = submerged
