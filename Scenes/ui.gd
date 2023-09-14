extends CanvasLayer

class_name UI

@onready var label = $MarginContainer/HBoxContainer/Label
@onready var lose_container = $LoseContainer
@onready var win_label = $MarginContainer/HBoxContainer/WinLabel

func show_lose_ui():
	lose_container.show()

func show_win_ui():
	win_label.show()
	
func set_points(points: int):
	label.text = "Points: %d" % points

func _on_button_pressed():
	get_tree().reload_current_scene()
