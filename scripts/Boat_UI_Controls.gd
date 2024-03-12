extends Control

@onready var boat := get_parent()

var wheel_active := false
var slider_active := false
var angle_active := false
var aim_slider_active := false

var max_angle = 90
var min_angle = -90
var angle = 0.0

var min_slider = -240
var max_slider = -60
var slider = 0.0

func _process(delta):
	var mouseVel = Input.get_last_mouse_velocity()
	
	if wheel_active:
		angle += mouseVel.x * delta * 0.3
		
		angle = clamp(angle, min_angle, max_angle)
		
		var turn_rate = angle / max_angle
		turn_rate *= (boat.max_turn_rate * 2) - boat.max_turn_rate
		boat.current_turn_rate = -turn_rate
		
		$WheelDisplay.rotation_degrees = angle
	
	if slider_active:
		slider += mouseVel.y * delta
		slider = clamp(slider, min_slider, max_slider)
		
		var drive_force = 1 - -(slider - min_slider) / (min_slider - max_slider)
		boat.current_forward_speed = drive_force * boat.forward_speed
		
		$DriveSlider/Slider.position.y = slider
		
	if aim_slider_active:
		slider += mouseVel.y * delta
		slider = clamp(slider, min_slider, max_slider)
		
		var lift_angle = 1 - -(slider - min_slider) / (min_slider - max_slider)
		lift_angle = lift_angle * boat.max_gun_lift
	
		boat.current_lift = deg_to_rad(lift_angle)
		
		$LiftSlider/Slider.position.y = slider
	
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		wheel_active = false
		slider_active = false
		angle_active = false
		aim_slider_active = false

func calculate_radar_angle(event):
	var dir = event.position - ($RadarAngle.size / 2)

	var angle = dir.angle() + PI/2
	
	if angle > PI:
		angle -= PI * 2
	
	$RadarAngle/AimAngle.rotation = angle 
	
	var aim_angle = -angle
	boat.aim_angle = aim_angle
	

func _on_wheel_click_detect_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		wheel_active = true

func _on_drive_slider_detect_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		slider_active = true

func _on_radar_detect_gui_input(event):
	if event is InputEventMouseMotion and angle_active:
		calculate_radar_angle(event)
		
	if event is InputEventMouseButton and event.is_pressed():
		angle_active = true
		
		calculate_radar_angle(event)


func _on_button_pressed():
	boat.shoot()


func _on_lift_slider_detect_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		aim_slider_active = true
