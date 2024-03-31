extends Node

var ship_name := "Unset Name"
var ship_color := Color.WHITE
var ship_decals = []

var options = {
	"UI_SCALE": 1.0
}

signal ui_scale_changed_signal()

func set_ui_scale(scale):
	options.UI_SCALE = scale
	ui_scale_changed_signal.emit()

func get_ui_scale():
	return options.UI_SCALE
