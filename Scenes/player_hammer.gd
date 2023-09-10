extends Area2D

class_name PlayerHammer

signal hammer_collided

func _on_body_entered(body):
	body.queue_free()
	hammer_collided.emit()
