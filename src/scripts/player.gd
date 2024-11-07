class_name Player
extends CharacterBody2D

#Exported constants
#Movement
@export var GROUND_SPEED:float = 100.0
@export var AIR_SPEED:float = 115.0
@export var GROUND_ACCELERATION:float = 6.0
@export var AIR_ACCELERATION:float = 12.0
@export var SPEED_CONVERT_RATIO:float = 0.45
@export var EXTERNAL_VELOCITY_SOFT_FRICTION:float = 5.0
#Jump
@export var JUMP_VELOCITY:float = -150.0
@export var COYOTE_TIME_DURATION:float = 0.3
#Wall Slide
@export var WALL_SLIDE_GRAVITY_REDUCE:float = 3.0
#Wall Jump
@export var WALL_JUMP_VELOCITY:float = -115.0
@export var WALL_JUMP_REPULSE:float = 50.0
@export var WALL_JUMP_COYOTE_TIME_DURATION:float = 0.15
#Dash
@export var DASH_VELOCITY:float = 200.0
@export var DASH_TIME:float = 0.15

#Movement variables
var gravity:Vector2
var external_velocity:Vector2

#Ability vars
var has_wall_jump:bool = true
var can_double_jump:bool = true
var can_dash:bool = true

#jump vars
var can_jump:bool = false
var coyote_timer_started:bool = false

#Wall jump vars
var can_wall_jump:bool = false
var wall_jump_coyote_timer_started:bool = false
var coyote_wall_normal:Vector2

#Double jump vars
var has_double_jump:bool = true

#Dash var
var is_dashing:bool = false
var max_dash_count:int = 3
var dash_count:int = max_dash_count
var pre_dash_x_velocity:float = 0
var dash_direction:Vector2 = Vector2.ZERO

func _ready() -> void:
	$AnimatedSprite2D.play("idle")

func _physics_process(delta: float) -> void:
	wall_slide_handler()
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta
		$AnimatedSprite2D.queue("in_air", 1, true, false)

	if has_wall_jump: wall_jump_handler(delta)
	if can_dash: dash_handler(delta)
	jump_handler(delta)
	movement_handler(delta)
	
	move_and_slide()

func wall_slide_handler():
	gravity = get_gravity()
	if is_on_wall() && velocity.y > 0:
		gravity /= WALL_SLIDE_GRAVITY_REDUCE

func jump_handler(delta:float):
	#coyote jump
	if !can_jump && is_on_floor(): 
		can_jump = true
		has_double_jump = true
		dash_count = max_dash_count
	elif can_jump && !is_on_floor() && !coyote_timer_started:
		get_tree().create_timer(COYOTE_TIME_DURATION).connect("timeout", stop_coyote_time)
		
	#simple jump
	if Input.is_action_just_pressed("jump") && can_jump:
		velocity.y = JUMP_VELOCITY
		can_jump = false
		is_dashing = false
		
		#Jump animation
		$AnimatedSprite2D.play("jump")
		$AnimatedSprite2D.anim_repeat = false
		$AnimatedSprite2D.anim_can_be_interupted = false
		
	#double jump
	elif Input.is_action_just_pressed("jump") && can_double_jump && has_double_jump && velocity.y > WALL_JUMP_VELOCITY:
		velocity.y = JUMP_VELOCITY
		has_double_jump = false
		is_dashing = false
		
		#Jump animation
		$AnimatedSprite2D.play("jump")
		$AnimatedSprite2D.anim_repeat = false
		$AnimatedSprite2D.anim_can_be_interupted = false
	
	#Stop jump
	if Input.is_action_just_released("jump") and velocity.y < -1:
		velocity.y /= 2

func movement_handler(delta:float):
	if is_dashing: return
	
	var direction:int = Input.get_axis("left", "right")
	var acceleration:float
	var speed:float
	# Change acceleration depending on where the player is
	if is_on_floor(): 
		acceleration = GROUND_ACCELERATION
		speed = GROUND_SPEED
	else:
		acceleration = AIR_ACCELERATION
		speed = AIR_SPEED
	
	# Animation logic
	if is_on_floor():
		if direction != 0:
			$AnimatedSprite2D.queue("run", 0, true, true)
		else:
			$AnimatedSprite2D.queue("idle", 0, true, true)
	
	#Flip Sprite
	if direction != 0: $AnimatedSprite2D.flip_h = direction < 0 
	
	# Moving the player
	if direction == - signf(velocity.x) && external_velocity == Vector2.ZERO:
		velocity.x = -SPEED_CONVERT_RATIO * velocity.x
	elif !is_dashing:
		velocity.x = lerp(velocity.x, direction*speed, acceleration*delta)
	
	#External velocity handler
	velocity += external_velocity
	
	if direction == -signf(external_velocity.x):
		external_velocity = lerp(external_velocity, Vector2.ZERO, EXTERNAL_VELOCITY_SOFT_FRICTION*delta)
	else:
		external_velocity = Vector2.ZERO

func dash_handler(delta:float):
	if Input.is_action_just_pressed("dash") && dash_count > 0:
		dash_count -= 1
		is_dashing = true
		get_tree().create_timer(DASH_TIME).connect("timeout", end_dash)
		dash_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
		if dash_direction.x != 0: dash_direction.y /= 1.2
		pre_dash_x_velocity = abs(velocity.x)
	
	if is_dashing:
		velocity = (pre_dash_x_velocity + DASH_VELOCITY) * dash_direction

func wall_jump_handler(delta:float):
	if is_on_floor(): return
	
	#coyote jump
	if !can_jump && is_on_wall():
		can_wall_jump = true
		coyote_wall_normal = get_wall_normal()
	elif can_wall_jump && !is_on_wall() && !wall_jump_coyote_timer_started:
		get_tree().create_timer(WALL_JUMP_COYOTE_TIME_DURATION).connect("timeout", stop_wall_jump_coyote_time)
	
	if Input.is_action_just_pressed("jump") && can_wall_jump:
		velocity.y = WALL_JUMP_VELOCITY
		external_velocity +=  Vector2(WALL_JUMP_REPULSE * coyote_wall_normal.x, 0)
		can_wall_jump = false
		is_dashing = false
		
		#Jump animation
		$AnimatedSprite2D.play("jump")
		$AnimatedSprite2D.anim_repeat = false
		$AnimatedSprite2D.anim_can_be_interupted = false

func stop_coyote_time():
	can_jump = false
	coyote_timer_started = false

func stop_wall_jump_coyote_time():
	can_wall_jump = false

func end_dash():
	if is_dashing:
		is_dashing = false
