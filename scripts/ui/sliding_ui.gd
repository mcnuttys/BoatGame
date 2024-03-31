extends Control

@export var sliding_target : Control
@export var open_position : Vector2
@export var close_position : Vector2

@export var open_durration := 0.2
@export var close_durration := 0.2
@export var slide_curve : Curve

@export var slide_on_ready := false

var sliding := false
var slide_timer := 0.0
var slide_durration := 0.0

var target_position
var start_position

func _ready():
	if slide_on_ready:
		open()

func _process(delta):
	if not sliding:
		return
	
	if not open_position or not close_position or not slide_curve:
		sliding = false
		return 
	
	if not start_position or not target_position:
		sliding = false
		return
	
	slide_timer += delta
	sliding_target.position = lerp(start_position, target_position, slide_curve.sample(slide_timer / slide_durration))
	
	if sliding_target.position == target_position:
		sliding = false

func open():
	start_position = sliding_target.position
	target_position = open_position
	slide_timer = 0
	slide_durration = open_durration
	
	sliding = true

func close():
	start_position = sliding_target.position
	target_position = close_position
	slide_timer = 0
	slide_durration = close_durration
	
	sliding = true
