class_name InteractionArea2D extends Area2D

signal interracted_with(player:Player)
signal player_entered_area()
signal player_exited_area()

var interact_text_position:Control
var player_in_area:bool = false
var player:Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)
	
	interact_text_position = get_node("InteractText")
	
	if !interact_text_position: 
		push_error("InteractionArea2D nodes should have a Control Node child named InteractText")
	
	interact_text_position.hide()

func _process(delta: float) -> void:
	if player_in_area && Input.is_action_pressed("interact"):
		interracted_with.emit(player)

func interact_text_set_text():
	#Fonction à changer si on veux mettre d'autre texte de "interact with"
	var action_event:InputEvent = InputMap.action_get_events("interact")[0]
	interact_text_position.get_node("MarginContainer/Label").text = "Appuyez sur " + action_event.as_text().replace("(Physical)", "") + " pour interragir"

func on_body_entered(body:Node2D):
	if body as Player:
		player_entered_area.emit()
		interact_text_set_text()
		interact_text_position.show()
		
		player = body
		player_in_area = true

func on_body_exited(body:Node2D):
	if body as Player:
		player_exited_area.emit()
		interact_text_position.hide()
		player_in_area = false
