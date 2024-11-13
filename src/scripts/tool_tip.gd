extends Control

@export var text:String
@export var inputs = {
	"[left]":"left",
	"[right]":"right",
	"[up]":"up",
	"[down]":"down",
	"[attack]":"attack",
	"[jump]":"jump",
	"[dash]":"dash"
}

func _ready() -> void:
	add_to_group("input remap notified")
	on_input_remap()

func on_input_remap():
	interact_text_set_text()

func interact_text_set_text():
	$MarginContainer/Label.text = text
	
	for i_txt in inputs.keys():
		var action_event:InputEvent = InputMap.action_get_events(inputs[i_txt])[0]
		$MarginContainer/Label.text = $MarginContainer/Label.text.replace(i_txt, "["+action_event.as_text().replace("(Physical)", "")+"]")
