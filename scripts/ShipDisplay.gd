extends Sprite3D

func set_username(username):
	$SubViewport/VBoxContainer/RichUsernameLabel.text = username

func set_health_value(health):
	$SubViewport/VBoxContainer/Healthbar.set_health_value(health)
