class_name MovingPlatform extends AnimatableBody2D

const STOP_TRESHOLD:float = 0.01

@export var IS_ACTIVATED_BY_PLAYER:bool = false
@export var SPEED:float = 50.0
@export var ACCELERATION:float = 10.0

var detection_area:Area2D
var path_follow:PathFollow2D
var path_prev_pos:Vector2
var is_moving:bool = false
var stop_moving:bool = false
var speed:float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sync_to_physics = false
	
	#definition des variables
	for child in get_children():
		#detection_area
		if IS_ACTIVATED_BY_PLAYER && (child as Area2D): detection_area = child
		#path_follow
		if child as Path2D: for child2 in child.get_children(): if child2 as PathFollow2D: path_follow = child2
	
	path_follow.loop = true
	path_follow.progress = 0
	
	if IS_ACTIVATED_BY_PLAYER:
		if !detection_area: push_error("Player-activated MovingPlatforms should have an Area2D for player detection")
		
		detection_area.body_entered.connect(body_entered)
		detection_area.body_exited.connect(body_leave)


func _physics_process(delta: float) -> void:
	if !IS_ACTIVATED_BY_PLAYER || is_moving:
		path_prev_pos = path_follow.position
		if stop_moving:
			if path_follow.progress_ratio < 0.5:
				speed = lerpf(speed, -SPEED * delta, ACCELERATION * delta)
			if abs(path_follow.progress_ratio) < STOP_TRESHOLD:
				is_moving = false
				stop_moving = false
		else:
			speed = lerpf(speed, SPEED * delta, ACCELERATION * delta)
		path_follow.progress += speed
		
		
		
		var velocity = path_follow.position - path_prev_pos
		
		move_and_collide(velocity)

func body_entered(body:Node2D) -> void:
	if body as Player:
		is_moving = true

func body_leave(body:Node2D) -> void:
	if body as Player:
		stop_moving = true
