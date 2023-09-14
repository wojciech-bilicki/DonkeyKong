extends Area2D

class_name Princess

@export var ui: UI


func _on_body_entered(body):
	if body is Player:
		ui.show_win_ui()
