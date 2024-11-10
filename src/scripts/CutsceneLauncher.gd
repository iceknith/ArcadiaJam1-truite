class_name CutsceneLauncher extends Area2D

signal launch_cutscene(file_name:String)

@export var is_active:bool = true
@export var cutscene_path:String

func _ready() -> void:
	add_to_group("CutsceneLauncher")
	
	body_entered.connect(on_body_entered)
	
func on_body_entered(body:Node2D) -> void:
	if (body as Player) && is_active:
		launch_cutscene.emit(cutscene_path)
		is_active = false
