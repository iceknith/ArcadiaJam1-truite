extends CanvasLayer

signal launch_cutscene(file_name:String)

@onready var dialogue_box:DialogueBox = $Control/DialogueBox

func _ready() -> void:
	add_to_group("CutsceneLauncher")
	dialogue_box.dialogue_signal.connect(dialogue_consequences)

func launch_dialogue(dialogue:DialogueData, dialogue_start:String = "START"):
	dialogue_box.data = dialogue
	dialogue_box.start(dialogue_start)

func dialogue_consequences(options:String):
	match options:
		"ending_use":
			launch_cutscene.emit("res://assets/Cutscenes/ending_use.ogv")
		"ending_destroy":
			launch_cutscene.emit("res://assets/Cutscenes/ending_destroy.ogv")
