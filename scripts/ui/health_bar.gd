extends TextureProgressBar

@export var health_gradient : Gradient

@onready var health_bar_label := $health_bar_value

var max_health = 0
var health = 0

func setup(_health, _max_health):
	health = _health
	max_health = _max_health
	
	max_value = max_health
	value = health

func set_health(_health):
	health = _health
	
	value = health
	health_bar_label.text = str(health) + "/" + str(max_health)
	
	var t = health / max_health
	tint_progress = health_gradient.sample(t)
