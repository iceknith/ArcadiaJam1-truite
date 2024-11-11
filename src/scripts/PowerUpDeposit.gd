class_name PowerUpDeposit extends InteractionArea2D

signal launch_dialogue(dialogue:DialogueData)

@export var DEPOSIT_DIALOGUE:DialogueData = load("res://assets/Levels/player_deposit_power_up_message.tres")
@export var POWER_UP_TO_DEPOSIT:String
#Possible values:
# Double Jump
# Wall Jump
# Grosee Épée
# 3ème Dash
# 2ème Dash
# Dash

func _ready() -> void:
	super._ready()
	
	add_to_group("PowerUpDeposit")
	add_to_group("DialogueLauncher")
	
	interracted_with.connect(on_interacted_with, CONNECT_DEFERRED)
	
	DEPOSIT_DIALOGUE.variables["power_up"] = { "type": TYPE_STRING, "value": POWER_UP_TO_DEPOSIT}

func interact_text_set_text():
	#Fonction à changer si on veux mettre d'autre texte de "interact with"
	var action_event:InputEvent = InputMap.action_get_events("interact")[0]
	interact_text_position.get_node("MarginContainer/Label").text = \
		"Appuyez sur " + action_event.as_text().replace("(Physical)", "") +\
		" pour déposer votre " + POWER_UP_TO_DEPOSIT


func on_interacted_with(player:Player):
	match POWER_UP_TO_DEPOSIT:
		"Double Jump":
			player.can_double_jump = false
		"Wall Jump":
			player.can_wall_jump = false
		"3ème Dash":
			player.max_dash_count = 2
			player.dash_count = 2
		"2ème Dash":
			player.max_dash_count = 1
			player.dash_count = 1
		"Dash":
			player.max_dash_count = 0
			player.dash_count = 0
		"Grosee Épée":
			player.has_big_sword = false
	
	launch_dialogue.emit(DEPOSIT_DIALOGUE)
	
	#Jouer une animation, puis disparaitre
	queue_free()
