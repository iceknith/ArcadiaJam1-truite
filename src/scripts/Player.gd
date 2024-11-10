class_name Player
extends CharacterBody2D

#Signals
signal death()
signal health_change(health_percent:float)

#Exported constants
#Movement
@export var GROUND_SPEED:float = 100.0
@export var AIR_SPEED:float = 115.0
@export var GROUND_ACCELERATION:float = 6.0
@export var AIR_ACCELERATION:float = 12.0
@export var SPEED_CONVERT_RATIO:float = 0.45
@export var EXTERNAL_VELOCITY_FRICTION:float = 5.0
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
#Attack
@export var MAX_HEALTH:float = 6.0
@export var ATTACK_DAMAGE:float = 5.0
@export var ATTACK_DELAY_TIME:float = 0.15
#Hit
@export var KNOCKBACK_FORCE:float = 40.0
@export var KNOCKBACK_TIME:float = 0.2
@export var Y_KNOCKBACK_REDUCE:float = 10.0
@export var INVINCIBILITY_TIME:float = 0.5
#Ability vars
@export var has_wall_jump:bool = true
@export var can_double_jump:bool = true
@export var max_dash_count:int = 3

#Movement variables
var gravity:Vector2
var external_velocity:Vector2

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
var dash_count:int = max_dash_count
var pre_dash_x_velocity:float = 0
var dash_direction:Vector2 = Vector2.ZERO

#Attack vars
var is_attacking:bool = false

#Hit vars
var health = MAX_HEALTH
var is_dead:bool = false
var is_invincible:bool = false
var is_knocked_back:bool = false


func _ready() -> void:
	add_to_group("Player")
	
	#Animation
	$AnimatedSprite2D.play("idle")
	$AnimatedSprite2D.animation_looped.connect(on_animation_looped)
	
	#Attack
	$DamageArea.hide()
	$DamageArea.body_entered.connect(on_damage_area_body_entered)
	
	#Set life
	health_change.emit(1)
	
	#Set camera boundaries
	for child in get_parent().get_children():
		if child as TileMapLayer:
			var map_limits:Rect2 = child.get_used_rect()
			var map_cellsize:Vector2 = child.tile_set.tile_size
			$Camera2D.limit_left = map_limits.position.x * map_cellsize.x
			$Camera2D.limit_right = map_limits.end.x * map_cellsize.x
			$Camera2D.limit_top = map_limits.position.y * map_cellsize.y
			$Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y

func _process(delta: float) -> void:
	if is_dead: return
	
	if Input.is_action_just_pressed("attack"):
		$AnimatedSprite2D.play("attack")
		$AnimatedSprite2D.anim_unstopable = true
		get_tree().create_timer(ATTACK_DELAY_TIME).connect("timeout", start_attack)

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	wall_slide_handler()
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity * delta
		$AnimatedSprite2D.queue("in_air", 1, true, false)

	if has_wall_jump: wall_jump_handler(delta)
	if max_dash_count > 0: dash_handler(delta)
	jump_handler(delta)
	movement_handler(delta)
	
	move_and_slide()

func damage(damage_amount:float, damage_direction:Vector2) -> void:
	if is_invincible || is_dead: return
	
	health = max(0, health - damage_amount)
	health_change.emit(health/MAX_HEALTH)
	
	if health == 0:
		is_dead = true
		
		$AnimatedSprite2D.play("die")
		$AnimatedSprite2D.anim_unstopable = true
		
	else:
		is_invincible = true
		is_knocked_back = true
		external_velocity = damage_direction.normalized() * KNOCKBACK_FORCE
		external_velocity.y /= Y_KNOCKBACK_REDUCE
		
		get_tree().create_timer(INVINCIBILITY_TIME).connect("timeout", end_invincibility)
		get_tree().create_timer(KNOCKBACK_TIME).connect("timeout", end_knockback)
		
		$AnimatedSprite2D.play("hurt")
		$AnimatedSprite2D.anim_unstopable = true

func wall_slide_handler() -> void:
	gravity = get_gravity()
	if is_on_wall() && velocity.y > 0:
		gravity /= WALL_SLIDE_GRAVITY_REDUCE

func jump_handler(delta:float) -> void:
	#Coyote jump
	if !can_jump && is_on_floor(): 
		can_jump = true
		has_double_jump = true
		dash_count = max_dash_count
	elif can_jump && !is_on_floor() && !coyote_timer_started:
		get_tree().create_timer(COYOTE_TIME_DURATION).connect("timeout", stop_coyote_time)
		
	#Simple jump
	if Input.is_action_just_pressed("jump") && can_jump:
		velocity.y = JUMP_VELOCITY
		can_jump = false
		is_dashing = false
		
		#Jump animation
		$AnimatedSprite2D.queue("jump", 1, false, false)
		
	#Double jump
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

func movement_handler(delta:float) -> void:
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
	
	if !is_knocked_back:
		if direction == -signf(external_velocity.x):
			external_velocity = lerp(external_velocity, Vector2.ZERO, EXTERNAL_VELOCITY_FRICTION*delta)
		else:
			external_velocity = Vector2.ZERO

func dash_handler(delta:float) -> void:
	if Input.is_action_just_pressed("dash") && dash_count > 0:
		dash_count -= 1
		is_dashing = true
		get_tree().create_timer(DASH_TIME).connect("timeout", end_dash)
		dash_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
		if dash_direction.x != 0: dash_direction.y /= 1.2
		pre_dash_x_velocity = abs(velocity.x)
	
	if is_dashing:
		velocity = (pre_dash_x_velocity + DASH_VELOCITY) * dash_direction

func wall_jump_handler(delta:float) -> void:
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

func stop_coyote_time() -> void:
	can_jump = false
	coyote_timer_started = false

func stop_wall_jump_coyote_time() -> void:
	can_wall_jump = false

func start_attack() -> void:
	is_attacking = true
	$DamageArea.show()

func end_dash() -> void:
	if is_dashing:
		is_dashing = false

func end_invincibility()->void:
	is_invincible = false
	$AnimatedSprite2D.play("idle")
	$AnimatedSprite2D.anim_unstopable = false
	$AnimatedSprite2D.anim_can_be_interupted = true
	$AnimatedSprite2D.anim_repeat = true

func end_knockback()->void:
	is_knocked_back = false
	$AnimatedSprite2D.play("invincible")

func on_animation_looped()->void:
	if $AnimatedSprite2D.animation == "attack":
		is_attacking = false
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.anim_unstopable = false
		$AnimatedSprite2D.anim_repeat = true
		$AnimatedSprite2D.anim_can_be_interupted = true
		$DamageArea.hide()
	if $AnimatedSprite2D.animation == "die":
		death.emit()

func on_damage_area_body_entered(body:Node2D)->void:
	if is_attacking && (body as Enemy):
		body.damage(ATTACK_DAMAGE, body.global_position - global_position)
