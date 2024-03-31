extends RichTextLabel

@export var curve : Curve

var message := ""
var age := 0.0
var max_age := 5.0

var max_x := 0.0

var insert_time := 0.25
var exit_time := 0.25

var fully_inserted := false

func set_message(_message):
	message = _message
	text = message

func exit_message():
	age = max_age - exit_time

func _ready():
	max_x = size.x + 10

func _process(delta):
	age += delta
	
	if age <= insert_time:
		position.x = lerpf(max_x, 0, curve.sample(age / insert_time))
	elif !fully_inserted:
		position.x = 0
		fully_inserted = true
	
	if age >= max_age - exit_time:
		position.x = lerpf(0, max_x, 1.0 - curve.sample((max_age - age) / exit_time))
	
	if age >= max_age:
		queue_free()
