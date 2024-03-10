extends Node3D

@onready var mesh = $WaterMesh.mesh

var material: ShaderMaterial
var noise: Image
var noise2: Image

var noise_scale: float
var wave_speed: float
var height_scale: float

var time: float

# Called when the node enters the scene tree for the first time.
func _ready():
	material = mesh.surface_get_material(0)
	noise = material.get_shader_parameter("WaveNoise1").noise.get_seamless_image(512, 512)
	noise2 = material.get_shader_parameter("WaveNoise2").noise.get_seamless_image(512, 512)
	noise_scale = mesh.size.x
	wave_speed = material.get_shader_parameter("WaveSpeed")
	height_scale = material.get_shader_parameter("HeightScale")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	material.set_shader_parameter("WaveTime", time)


func get_height(world_position) -> float:
	var uv_x = wrapf((world_position.x - (noise_scale / 2))  / noise_scale + time * wave_speed, 0, 1)
	var uv_y = wrapf((world_position.z - (noise_scale / 2))  / noise_scale + time * wave_speed, 0, 1)
	var uv_x2 = wrapf((world_position.x - (noise_scale / 2))  / noise_scale + time * -wave_speed, 0, 1)
	var uv_y2 = wrapf((world_position.z - (noise_scale / 2))  / noise_scale + time * -wave_speed, 0, 1)
	
	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	var pixel_pos2 = Vector2(uv_x2 * noise.get_width(), uv_y2 * noise.get_height())
	var r = noise2.get_pixelv(pixel_pos2).r * noise.get_pixelv(pixel_pos).r
	return global_position.y + r * height_scale
	
func get_normal(world_position):
	var h1 = Vector3(world_position.x, get_height(world_position), 						world_position.z)
	var h2 = Vector3(world_position.x, get_height(world_position + Vector3.FORWARD * 0.1), 	world_position.z + 0.1)
	var h3 = Vector3(world_position.x + 0.1, get_height(world_position + Vector3.LEFT * 0.1), 		world_position.z)
	
	var normal = (h2 - h1).cross(h3 - h1).normalized()
	return normal
