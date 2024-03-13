extends Node3D

@export var phase := 0.2
@export var attenuation := 0.999
@export var deltaUV := 3.0

@export var simulationSize := 512

@onready var sim_viewport: SubViewport = $Simulation
@onready var sim_viewport_buffer: SubViewport = $SimulationBuffer
@onready var sim_material: ShaderMaterial = $Simulation/ColorRect.material
@onready var sim_buffer_material: ShaderMaterial = $SimulationBuffer/ColorRect.material

# Called when the node enters the scene tree for the first time.
func _ready():
	var col_viewport = $SimulationCollision
	
	setSimulationSettings()

	sim_material.set_shader_parameter("sim_tex", sim_viewport_buffer.get_texture())
	sim_material.set_shader_parameter("col_tex", col_viewport.get_texture())
	sim_buffer_material.set_shader_parameter("sim_tex", sim_viewport.get_texture())
	
	var water = $Water
	var sim_tex = $Simulation.get_texture()
	water.mesh.surface_get_material(0).set_shader_parameter('Simulation', sim_tex)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setSimulationSettings():
	print('Setting Settings')
	sim_viewport.size.x = simulationSize
	sim_viewport.size.y = simulationSize
	sim_viewport_buffer.size.x = simulationSize
	sim_viewport_buffer.size.y = simulationSize
	
	sim_material.set_shader_parameter("phase", phase)
	sim_material.set_shader_parameter("attenuation", attenuation)
	sim_material.set_shader_parameter("deltaUV", deltaUV)
	sim_material.set_shader_parameter("simulationSize", simulationSize)
