extends CharacterBody3D


@onready var player_mesh := $MeshInstance3D
@onready var camera := $Camera3D

const current_speed = 5.0
const jump_velocity = 4.5

const mouse_sensitivity = 0.3
const min_look = -89
const max_look = 89

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var authority_id = -1

func _ready():
	authority_id = str(name).to_int()
	$MultiplayerSynchronizer.set_multiplayer_authority(authority_id)
	
	if authority_id != multiplayer.get_unique_id():
		camera.current = false
		player_mesh.visible = true

func _physics_process(delta):
	if authority_id != multiplayer.get_unique_id():
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

func set_player_data(username, color):
	# %UsernameLabel.text = "[center]" + username
	# %PlayerSprite.modulate = color
	pass

func _input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
			camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(min_look), deg_to_rad(max_look))
