extends TextureProgressBar

@export var gradient := Gradient.new()

var health := 0

func _process(delta):
	value = lerpf(value, health, delta * 3)
	tint_progress = gradient.sample(value / max_value)

func set_health_value(_health):
	health = _health
