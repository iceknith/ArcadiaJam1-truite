class_name KeyChangeButton extends Control

@export var key_name:String = "placeholder"

var is_waiting_for_key:bool = false

func _ready() -> void:
	add_to_group("KeyChangeButton")
	
	change_label_text()
	change_button_text()
	
	$Button.pressed.connect(button_pressed)

func _unhandled_key_input(event: InputEvent) -> void:
	if is_waiting_for_key:
		InputMap.action_erase_events(key_name)
		InputMap.action_add_event(key_name, event)
		button_unpress()

func set_disabled(value:bool):
	$Button.disabled = value

func change_label_text():
	$Label.text = key_name.replace("_", " ")

func change_button_text():
	var action_events = InputMap.action_get_events(key_name)
	var action_event:InputEvent = action_events[0]
	$Button.text = action_event.as_text().replace("(Physical)", "")

func button_pressed():
	is_waiting_for_key = true
	$Button.text = "..."
	$Button.button_pressed = false
	
	for button:KeyChangeButton in get_tree().get_nodes_in_group("KeyChangeButton"):
		button.set_disabled(true)

func button_unpress():
	change_button_text()
	is_waiting_for_key = false
	
	for button:KeyChangeButton in get_tree().get_nodes_in_group("KeyChangeButton"):
		button.set_disabled(false)
