extends CharacterBody2D

class_name Player

signal award_points

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var climbing_speed = 200

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var ray_cast_2d = $RayCast2D
@onready var hammer = $Hammer as PlayerHammer
@onready var hammer_timer = $HammerTimer

var hammer_rotation_point = Vector2(0, -3)
var last_barrel_id = null
var can_climb = false
var is_on_ladder = false
var snap_to_ladder_position_x = null
var current_direction = 1
var hammer_start_position 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var platform_underneath_the_player: Platform = null
var has_hammer = false

func _ready():
	hammer.hammer_collided.connect(on_hammer_collided)
	hammer_timer.timeout.connect(on_hammer_timer_timeout)
	hammer_start_position = hammer.position
	animated_sprite_2d.frame_changed.connect(on_sprite_frames_changed)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor() && !is_on_ladder:
		velocity.y += gravity * delta
		

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		last_barrel_id = null
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	
	if direction && !is_on_ladder:
		velocity.x = direction * SPEED
		if direction != current_direction:
			current_direction = direction
		if direction > 0:
			animated_sprite_2d.flip_h = false
		elif direction < 0:
			animated_sprite_2d.flip_h = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if velocity.x != 0:
		var running_animation_name = "default" if !has_hammer else "default_hammer"
		
		animated_sprite_2d.play(running_animation_name)
	else:
		var idle_animation_name = "idle" if !has_hammer else "idle_hammer"
		animated_sprite_2d.play(idle_animation_name)
	
	move_and_slide()
	
	var collision = handle_movement_collision()

	handle_ladder_climbing(collision, delta)
		
	if is_on_ladder && is_on_floor():
		is_on_ladder = false
		var idle_animation_name = "idle" if !has_hammer else "idle_hammer"
		animated_sprite_2d.play(idle_animation_name)
	
	if not is_on_floor():
		check_barrel_collision()		

func handle_ladder_climbing(collision, delta):
	if can_climb:
		var climb_direction = Input.get_axis("down", "up")
		
		if climb_direction != 0:
			is_on_ladder = true
			animated_sprite_2d.play("climb")
			position.x = snap_to_ladder_position_x
		
		if climb_direction == -1 && collision:
			var platform = collision.get_collider() as Platform
			if platform.can_be_disabled:
				platform_underneath_the_player = collision.get_collider()
				platform_underneath_the_player.disable_collision()


		if climb_direction == 1 && platform_underneath_the_player:
			platform_underneath_the_player.enable_collision()
			platform_underneath_the_player = null
		
		position.y -= climb_direction * climbing_speed * delta 

func handle_movement_collision():
	var collision = get_last_slide_collision() as KinematicCollision2D
	if !collision:
		return
	var collider = collision.get_collider()
	
	if collider is Platform:
		var collision_degree = roundf(rad_to_deg(collision.get_angle()))
		if collision_degree == 90:
			position.y -= 8
			
	if collider is Barrel:
		print("DIE")
	
	return collision
	
func check_barrel_collision():
	var collider = ray_cast_2d.get_collider()
	
	if collider is Barrel:
		var barrel_id = collider.get_rid()
		if last_barrel_id == null:
			last_barrel_id = barrel_id
			print("AWARD POINTS")
				
	
func _on_stair_detector_body_entered(body):
	position.y += 8

func start_climbing(ladder_position_x):
	snap_to_ladder_position_x = ladder_position_x 
	can_climb = true

func stop_climbing():
	snap_to_ladder_position_x = null
	can_climb = false
	is_on_ladder = false


func on_sprite_frames_changed():
	if !has_hammer or is_on_ladder:
		return
		
	var frame_index = animated_sprite_2d.frame
	var hammer_rotation_angle = get_hammer_rotation_angle(frame_index)
	hammer.position = hammer_rotation_point + (hammer_start_position - hammer_rotation_point).rotated(hammer_rotation_angle)

	hammer.rotation_degrees  = hammer_rotation_angle
	

func get_hammer_rotation_angle(frame_index):
	if animated_sprite_2d.animation == "idle_hammer":
		return 	90 * sign(current_direction) if frame_index == 0 else 0
	elif animated_sprite_2d.animation == "default_hammer":
		return 90 * sign(current_direction) if [1,3].has(frame_index) else 0 

func hammer_fetched():
	has_hammer = true
	hammer.visible = true
	hammer.set_process(true)
	hammer_timer.start()

func on_hammer_timer_timeout():
	has_hammer = false
	hammer.visible = false
	hammer.set_process(false)

func on_hammer_collided():
	award_points.emit()

func die():
	print("DIE")
