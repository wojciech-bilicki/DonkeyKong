extends Timer

class_name SpawnTimer

@export var min: float = 2
@export var max: float = 5

func _ready():
	setup()
	
func setup():
	var timeout_time = randf_range(min, max)
	self.wait_time = timeout_time
	start()
