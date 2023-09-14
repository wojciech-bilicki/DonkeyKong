extends Node

class_name PointsManager

@onready var ui = $"../UI" as UI
@onready var player = $"../Player" as Player
@onready var points_label_scene = preload("res://Scenes/label.tscn")
@export var points_increment = 100

const points_label_offset = Vector2(0, -25)

var points = 0

func _ready():
	player.award_points.connect(on_award_points)

func on_award_points(position: Vector2):
	print(position)
	var label = points_label_scene.instantiate()
	add_child(label)
	label.position = position + points_label_offset
	label.text = "%d" % points_increment
	points += points_increment
	ui.set_points(points)
	
