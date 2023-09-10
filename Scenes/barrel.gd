extends RigidBody2D

class_name Barrel

const VELOCITY_BREAK_POINT = 300
const BUMP_FORCE_Y = 200
const BUMP_FORCE_X = 100

const FALL_DOWN_THE_LADDER_LIMIT = 48
var fall_down_the_ladder_y_position

@onready var collision_shape_2d = $CollisionShape2D

var speed = 200

var velocity_direciton = 1
var should_switch_direction = true
var is_going_down_the_ladder = false


func _physics_process(delta):
	if is_going_down_the_ladder:
		var current_y_pos = position.y
		if current_y_pos - fall_down_the_ladder_y_position > FALL_DOWN_THE_LADDER_LIMIT:
			is_going_down_the_ladder = false
			set_collision_mask_value(4, true)
		return
	
	
	if linear_velocity.y < 200:
		linear_velocity.x = speed  * velocity_direciton
	else:
		linear_velocity.x = 0 

	if linear_velocity.y > VELOCITY_BREAK_POINT && should_switch_direction:
		velocity_direciton *= -1
		should_switch_direction = false
	elif !should_switch_direction && linear_velocity.y < 0.1:
		should_switch_direction = true
		apply_impulse(Vector2(velocity_direciton*BUMP_FORCE_X, -BUMP_FORCE_Y))
	

func fall_down_the_ladder():
	if is_going_down_the_ladder:
		return
	linear_velocity.x = 0
	fall_down_the_ladder_y_position = position.y
	set_collision_mask_value(4, false)
	is_going_down_the_ladder = true
