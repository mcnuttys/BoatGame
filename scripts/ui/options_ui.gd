extends Panel

@onready var sliding_ui = $sliding_ui
@onready var ui_scale_slider = $"ScrollContainer/VBoxContainer/UI Scale/ui_scale_slider"
@onready var ui_scale_line_edit = $"ScrollContainer/VBoxContainer/UI Scale/ui_scale_line_edit"

var is_open := false

var ui_scale := 0.0

func open():
	sliding_ui.open()
	is_open = true

func close():
	sliding_ui.close()
	is_open = false

func _on_close_button_pressed():
	close()

func _on_ui_scale_slider_value_changed(value):
	ui_scale = value
	ui_scale_line_edit.text = str(ui_scale)

func _on_ui_scale_value_changed(value):
	value = float(value)
	
	value = clamp(value, 0.1, 2)
	ui_scale_line_edit.text = str(value)
	
	ui_scale_slider.value = value
	GameManager.set_ui_scale(value)

func _on_ui_scale_slider_drag_ended(_value_changed):
	GameManager.set_ui_scale(ui_scale)
