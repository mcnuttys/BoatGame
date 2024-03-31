extends Panel

@export var username := ""
@export var kills := 0
@export var deaths := 0

func set_username(_username):
	username = _username

func set_kills(_kills):
	kills = _kills

func set_deaths(_deaths):
	deaths = _deaths

func _process(_delta):
	$HBoxContainer/VBoxContainer/username_label.text = username
	$HBoxContainer/kills_label.text = str(kills)
	$HBoxContainer/deaths_label.text = str(deaths)
