class_name ExtendedAnimatedSprite2D extends AnimatedSprite2D

var default_animation = "idle"

var queue_anim:String = ""
var queue_weight:int = 0
var queue_repeat:bool = true
var queue_can_be_interupted:bool = false
var anim_repeat:bool = true
var anim_can_be_interupted:bool = false
var anim_unstopable:bool = false


func _ready() -> void:
	connect("animation_looped", loop)

func queue(animation_name:String, weight:int = 1, repeat:bool = true, can_be_interupted:bool = false) -> void:
	if animation != animation_name && weight >= queue_weight:
		queue_anim = animation_name
		queue_weight = weight
		queue_repeat = repeat
		queue_can_be_interupted = can_be_interupted
		
		if anim_can_be_interupted: loop()

func loop():
	if anim_unstopable: return
	
	if queue_anim != "":
		animation = queue_anim
		anim_repeat = queue_repeat
		anim_can_be_interupted = queue_can_be_interupted
		
		queue_anim = ""
		queue_weight = 0

	elif !anim_repeat:
		animation = default_animation
