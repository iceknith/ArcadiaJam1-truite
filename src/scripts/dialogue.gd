extends CanvasLayer

@onready var dialogue_box:DialogueBox = $Control/DialogueBox

func launch_dialogue(dialogue:DialogueData, dialogue_start:String = "START"):
	dialogue_box.data = dialogue
	dialogue_box.start(dialogue_start)
