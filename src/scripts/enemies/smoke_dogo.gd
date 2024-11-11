extends Enemy

@export var CHASE_VELOCITY:float = 100
@export var CHASE_FRICTION:float = 5.0
@export var CHASE_MAX_DISTANCE:float = 300.0

func _ready() -> void:
	super._ready()
	
	$DetectionRange.body_entered.connect(on_body_entered)

func on_body_entered(body:Node2D):
	if body as Player:
		player = body
		chase_player = true

func damage(damage_amount:float, damage_direction:Vector2, damage_source:Node2D):
	super.damage(damage_amount, damage_direction, damage_source)
	
	if damage_source as Player:
		player = damage_source
		chase_player = true

func chase(delta:float, target:Vector2)->void:
	if target.distance_to(global_position) > CHASE_MAX_DISTANCE:
		chase_player = false
		return
	
	animated_sprite.queue("attack", 1, true, true)
	
	var direction = signf((target - global_position).x)
	
	if direction != 0: scale.x = -direction * scale.y
	
	if $RayCast2D.is_colliding():
		if animated_sprite.frame < 3:
			velocity.x = CHASE_VELOCITY * direction
		else:
			velocity.x = lerp(velocity.x, .0, CHASE_FRICTION * delta)
	else:
		velocity.x = 0
