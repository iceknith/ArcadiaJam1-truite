class_name Enemy extends CharacterBody2D

#Movements
@export var LOOP_MOVEMENTS:bool = false
@export var SPEED:float = 50.0
@export var ACCELERATION:float = 5.0
@export var CHASE_PLAYER:bool = false
#Damage
@export var MAX_HEALTH:float = 10.0
@export var KNOCKBACK_FORCE:float = 75.0
@export var KNOCKBACK_DECELERATION:float = 1.0
@export var INVINCIBILITY_TIME:float = 0.5
#Attack
@export var ATTACK_DAMAGE:float = 1.0

#Child vars
var path_follow:PathFollow2D
var animated_sprite:ExtendedAnimatedSprite2D
var damage_area:Area2D

#Damage vars
var health:float = MAX_HEALTH
var is_dead:bool = false
var is_invincible:bool = false
var knockback_direction:Vector2 = Vector2.ZERO

#Chase vars
var chase_player:bool = false
var player:Player = null

#Movement vars
var path_prev_pos:Vector2
var speed:float


func _ready() -> void:
	#define children
	for child in get_children():
		if child as ExtendedAnimatedSprite2D: animated_sprite = child
		elif child as Area2D: damage_area = child
		elif child as Path2D: for child2 in child.get_children(): if child2 as PathFollow2D: path_follow = child2
	
	#check if every key childs are present
	if !path_follow: push_error("Enemy nodes should have an PathFollow child")
	if !animated_sprite: push_error("Enemy nodes should have an AnimatedSprite2D child")
	if !damage_area: push_error("Enemy nodes should have an Area2D child")
	else: 
		for anim_name in ["hurt", "run", "die"]: 
			if  !anim_name in animated_sprite.sprite_frames.get_animation_names():
				push_error("Enemy nodes should a \"" + anim_name + "\" animation")
	
	#connect signals
	animated_sprite.animation_looped.connect(on_animation_loop)
	damage_area.body_entered.connect(on_damage_area_body_entered)
	
	#Select animation
	animated_sprite.play("run")

func _physics_process(delta:float) -> void:
	if !path_follow || !animated_sprite || is_dead: return
	
	if is_invincible: knockback_handler(delta)
	else:
		if chase_player && CHASE_PLAYER: chase(delta, player.global_position)
		else: patroll_movement(delta)
	
	animated_sprite.queue("run", 0, true, true)
	move_and_slide()

func patroll_movement(delta:float):
	path_prev_pos = path_follow.position
	speed = lerpf(speed, SPEED * delta, ACCELERATION * delta)
	path_follow.progress += speed
	velocity = (path_follow.position - path_prev_pos)/delta

func chase(delta:float, target:Vector2)->void:
	# Chase logic, is overwritten in enemies definition
	pass

func knockback_handler(delta:float)->void:
	velocity = lerp(velocity, (path_follow.position - path_prev_pos)/delta, KNOCKBACK_DECELERATION * delta)

func detect_player(delta:float) -> void:
	# Player detection logic, is overwritten in enemies definition
	pass

func damage(damage_amount:float, damage_direction:Vector2):
	if is_invincible || is_dead: return
	
	health = max(0, health-damage_amount)
		
	knockback_direction = damage_direction.normalized()
	if health == 0: 
		is_dead = true
		animated_sprite.play("die")
		animated_sprite.anim_unstopable = true
	else:
		is_invincible = true
		get_tree().create_timer(INVINCIBILITY_TIME).connect("timeout", stop_invincibility)
		animated_sprite.play("hurt")
		animated_sprite.anim_unstopable = true
		
	velocity = KNOCKBACK_FORCE * knockback_direction

func stop_invincibility():
	is_invincible = false
	animated_sprite.animation = "run"
	animated_sprite.anim_unstopable = false

func on_animation_loop():
	if animated_sprite.animation == "die":
		queue_free()

func on_damage_area_body_entered(body:Node2D):
	if body as Player:
		body.damage(ATTACK_DAMAGE, Vector2((body.global_position - global_position).x, 0))
