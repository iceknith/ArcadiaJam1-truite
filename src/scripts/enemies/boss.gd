class_name Boss extends Enemy

signal die()

#WARNING: The run animation is used for idle

@export var falling_blocks:PackedScene = load("res://src/scenes/enemies/boss_falling_platforms.tscn")
@export var falling_force = 15
@export var attacks:Array[String] = ["grab_beam", "grab2beam"]
@export var attack_charge_time:Dictionary = {
	"grab_beam":0.75,
	"grab2beam": 0.75,
	"punch1": 0.75,
	"punch2": 0.75
	}
@export var attack_duration:Dictionary = {
	"punch1":0.25,
	"punch2":0.25
	}

var is_invulnerable:bool = true
var is_charging_attack:bool = false
var current_attack:String

@onready var boss_door:StaticBody2D = $BossDoor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	$DetectionRange.body_entered.connect(on_detection_range_body_entered)
	$AttackTimer.timeout.connect(charge_attack)
	die.connect(open_door)
	
	animated_sprite.queue("run", 1, true, true)
	
	$WeakSpotCollisionShape2D.disabled = false
	$Area2D/CollisionShape2D.disabled = false
	$VulnerableCollisionShape2D.disabled = true
	
	$Punch1Area2D/CollisionShape2D.disabled = true
	$Punch1Area2D2/CollisionShape2D.disabled = true
	$Punch1Area2D2/CollisionShape2D2.disabled = true
	
	$Punch1Area2D.body_entered.connect(on_damage_area_body_entered)
	$Punch1Area2D2.body_entered.connect(on_damage_area_body_entered)
	
	health = MAX_HEALTH

func _process(delta: float) -> void:
	if is_invulnerable:
		animated_sprite.queue("run", 1, true, true)
		
	else:
		animated_sprite.queue("vulnerable", 1, true, true)

func knockback_handler(delta:float)->void:
	return

func _physics_process(delta: float) -> void:
	return

func make_vulnerable():
	is_invulnerable = false
	
	animated_sprite.play("heart touched")
	animated_sprite.anim_repeat = false
	animated_sprite.anim_can_be_interupted = false
	
	$AttackTimer.stop()
	
	$WeakSpotCollisionShape2D.set_deferred("disabled", true)
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	$VulnerableCollisionShape2D.set_deferred("disabled", false)
	
func make_invulnerable():
	is_invulnerable = true
	
	animated_sprite.play("hurt")
	animated_sprite.anim_repeat = false
	animated_sprite.anim_can_be_interupted = false
	
	$AttackTimer.start()
	
	$WeakSpotCollisionShape2D.set_deferred("disabled", false)
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	$VulnerableCollisionShape2D.set_deferred("disabled", true)
	
func damage(damage_amount:float, damage_direction:Vector2, damage_source:Node2D):
	if !is_invulnerable:
		super.damage(damage_amount, damage_direction, damage_source)
		if health > 0: make_invulnerable()
		else: die.emit()
	else:
		make_vulnerable()

func charge_attack():
	if player:
		current_attack = attacks.pick_random()
		animated_sprite.queue(current_attack, 2, false, false)
		is_charging_attack = true
		get_tree().create_timer(attack_charge_time[current_attack]).connect("timeout", launch_attack)

func open_door():
	boss_door.queue_free()

func launch_attack():
	match current_attack:
		"grab_beam":
			spawn_falling_block($GrabBeamPosition.global_position)
		"grab2beam":
			spawn_falling_block($Grab2BeamPosition1.global_position)
			spawn_falling_block($Grab2BeamPosition2.global_position)
		"punch1":
			$Punch1Area2D/CollisionShape2D.disabled = false
			get_tree().create_timer(attack_duration[current_attack]).connect("timeout", end_attack)
		"punch2":
			$Punch1Area2D2/CollisionShape2D.disabled = false
			$Punch1Area2D2/CollisionShape2D2.disabled = false
			get_tree().create_timer(attack_duration[current_attack]).connect("timeout", end_attack)

func end_attack():
	$Punch1Area2D/CollisionShape2D.disabled = true
	$Punch1Area2D2/CollisionShape2D.disabled = true
	$Punch1Area2D2/CollisionShape2D2.disabled = true

func spawn_falling_block(fb_global_position:Vector2):
	var falling_block:BossFallingPlatform = falling_blocks.instantiate()
	falling_block.global_position = fb_global_position
	falling_block.add_constant_central_force(Vector2.DOWN * falling_force)
	get_parent().add_child(falling_block)

func on_detection_range_body_entered(body:Node2D):
	if body as Player && !player:
		player = body
		$AttackTimer.start()
