class_name PNJ extends InteractionArea2D

signal launch_dialogue(dialogue:DialogueData)

@export var NOTIF_AMPLITUDE:float = 2.0
@export var notif:bool = false
#Dialogue
@export var DEFAULT_DIALOGUE:DialogueData

#Nodes
var notif_sprite:Sprite2D
var animated_sprite:ExtendedAnimatedSprite2D
#Player detection
var player_in_range:bool
#Animated notif
var notif_time:float
#Dialogue variables
var next_dialogue:DialogueData

func _ready() -> void:
	super._ready()
	
	add_to_group("DialogueLauncher")
	
	next_dialogue = DEFAULT_DIALOGUE
	
	interracted_with.connect(on_interacted_with)
	
	notif_sprite = get_node("NotifSprite")
	animated_sprite = get_node("ExtendedAnimatedSprite2D")
	
	animated_sprite.play("idle")

func _process(delta: float) -> void:
	super._process(delta)
	
	if notif_sprite:
		if !notif_sprite.visible: notif_sprite.show()
		
		notif_time += delta
		notif_sprite.position.y += sin(notif_time) * NOTIF_AMPLITUDE * delta
		
		if notif_time > 2*PI:
			notif_time = 0
	else:
		if notif_sprite.visible: notif_sprite.hide()
	

func on_interacted_with(player:Player):
	launch_dialogue.emit(next_dialogue)
