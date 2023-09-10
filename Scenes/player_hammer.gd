extends Area2D

class_name PlayerHammer

signal hammer_collided(collision_position: Vector2)

func _on_body_entered(body):
	print(body)
	hammer_collided.emit(body.global_position)
	body.queue_free()
