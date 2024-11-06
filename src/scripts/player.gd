class_name Player
extends CharacterBody2D

#Exported constants
@export var GROUND_SPEED:float = 400.0
@export var AIR_SPEED:float = 450.0
@export var GROUND_ACCELERATION:float = 25.0
@export var AIR_ACCELERATION:float = 50.0
@export var SPEED_CONVERT_RATIO:float = 0.45
@export var JUMP_VELOCITY:float = -600.0
@export var COYOTE_TIME_DURATION:float = 0.3
@export var DASH_VELOCITY:float = 750.0
@export var DASH_TIME:float = 0.2
@export var WAVEDASH_TIME_INTERVAL:float = 0.3
@export var WAVEDASH_VELOCITY:float = 850.0

var can_jump:bool = false
var coyote_timer_started:bool = false

var can_wavedash:bool
var is_dashing:bool = false
var soft_cap_speed:bool = false
var pre_dash_x_velocity:float = 0
var dash_direction:Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	jump_handler(delta)
	movement_handler(delta)
	dash_handler(delta)
	
	move_and_slide()

func jump_handler(delta:float):
	if !can_jump && is_on_floor(): 
		can_jump = true
	elif can_jump && !is_on_floor() && !coyote_timer_started:
		get_tree().create_timer(COYOTE_TIME_DURATION).connect("timeout", stop_coyote_time)
		
	
	if Input.is_action_just_pressed("jump") && can_jump:
		velocity.y = JUMP_VELOCITY
		can_jump = false
		
		if is_dashing:
			if can_wavedash:
				is_dashing = false
				can_wavedash = false
				velocity.x += WAVEDASH_VELOCITY * Input.get_axis("left", "right")
			else:
				is_dashing = false
				soft_cap_speed = true
		
	if Input.is_action_just_released("jump") and velocity.y < -1:
		velocity.y /= 2
		
func movement_handler(delta:float):
	if is_dashing: return
	
	var direction:int = Input.get_axis("left", "right")
	var acceleration:float
	var speed:float
	if is_on_floor(): 
		acceleration = GROUND_ACCELERATION
		speed = GROUND_SPEED
	else:
		acceleration = AIR_ACCELERATION
		speed = AIR_SPEED
	
	if direction == - signf(velocity.x):
		velocity.x = -SPEED_CONVERT_RATIO * velocity.x
	elif abs(velocity.x) < speed || direction == 0 || soft_cap_speed:
		velocity.x = lerp(velocity.x, direction*speed, acceleration*delta)
		
		if soft_cap_speed && velocity.x <= speed:
			soft_cap_speed = false

func dash_handler(delta:float):
	if Input.is_action_just_pressed("dash"):
		is_dashing = true
		can_wavedash = true
		get_tree().create_timer(DASH_TIME).connect("timeout", end_dash)
		get_tree().create_timer(WAVEDASH_TIME_INTERVAL).connect("timeout", stop_wavedash_interval)
		dash_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
		dash_direction.y /= 1.2
		pre_dash_x_velocity = abs(velocity.x)
	
	if is_dashing:
		velocity = (pre_dash_x_velocity + DASH_VELOCITY) * dash_direction

func stop_coyote_time():
	can_jump = false
	coyote_timer_started = false

func end_dash():
	if is_dashing:
		is_dashing = false
		soft_cap_speed = true

func stop_wavedash_interval():
	can_wavedash = false
