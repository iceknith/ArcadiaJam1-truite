class_name LevelExit extends InteractionArea2D

signal load_level(level:PackedScene)

@export var player_warning:bool = true
@export var NEXT_LEVEL:PackedScene
@export var POWER_CONDITIONS:Array[String] = ["Wall Jump", "Double Jump", "3ème Dash", "2ème Dash", "Dash"]

var sprite:ExtendedAnimatedSprite2D
var is_open:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	add_to_group("LevelExit")
	add_to_group("LevelLauncher")
	
	sprite = get_node("ExtendedAnimatedSprite2D")
	sprite.animation = "closed"
	
	interracted_with.connect(on_interacted_with)
	
	await get_tree().process_frame
	for deposit in get_tree().get_nodes_in_group("PowerUpDeposit"):
		deposit.interracted_with.connect(on_power_up_change)

func on_body_entered(body:Node2D):
	if is_open:
		super.on_body_entered(body)

func interact_text_set_text():
	#Fonction à changer si on veux mettre d'autre texte de "interact with"
	var action_event:InputEvent = InputMap.action_get_events("interact")[0]
	interact_text_position.get_node("MarginContainer/Label").text = \
		"Appuyez sur " + action_event.as_text().replace("(Physical)", "") +\
		" pour passer au niveau précédant"

func conditions_respected(player:Player):
	
	if "Wall Jump" in POWER_CONDITIONS && player.can_wall_jump:
		return false
	if "Double Jump" in POWER_CONDITIONS && player.can_double_jump:
		return false
	if "Dash" in POWER_CONDITIONS && player.max_dash_count > 0:
		return false
	if "2ème Dash" in POWER_CONDITIONS && player.max_dash_count > 1:
		return false
	if "3ème Dash" in POWER_CONDITIONS && player.max_dash_count > 2:
		return false
	
	return true
	
func on_interacted_with(player:Player):
	load_level.emit(NEXT_LEVEL)
	
func on_power_up_change(player:Player):
	await get_tree().process_frame
	is_open = conditions_respected(player)
	if is_open:
		sprite.animation = "opened"
