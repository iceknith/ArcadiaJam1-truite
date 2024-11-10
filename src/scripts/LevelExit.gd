class_name LevelExit extends Area2D

signal load_level(level:PackedScene)
signal launch_dialogue(dialogue:DialogueData)
signal game_over()

@export var player_warning:bool = true
@export var PLAYER_WARN_DIALOGUE:DialogueData
@export var NEXT_LEVEL:PackedScene
@export var POWER_CONDITIONS:Array[String] = ["Wall Jump", "Double Jump", "3ème Dash", "2ème Dash", "Dash"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("LevelLauncher")
	add_to_group("DialogueLauncher")
	
	body_entered.connect(on_body_entered)
	
	#Change variables
	var power_up_text = ""
	for power_condtion in POWER_CONDITIONS:
		power_up_text += "mon " + power_condtion + ", "
	power_up_text = power_up_text.trim_suffix(", ")
	PLAYER_WARN_DIALOGUE.variables["power_up"] = { "type": TYPE_STRING, "value": power_up_text}

func on_body_entered(body:Node2D):
	if body as Player:
		if conditions_respected(body):
			load_level.emit(NEXT_LEVEL)
		else:
			if player_warning:
				player_warning = false
				launch_dialogue.emit(PLAYER_WARN_DIALOGUE)
			else:
				#À modifier plus tard...
				game_over.emit()

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
