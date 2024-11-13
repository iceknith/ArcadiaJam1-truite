extends Node

@export var FIRST_LEVEL:PackedScene

var level:Node2D
var level_packed_scene:PackedScene

func _ready() -> void:
	#Setup visible children
	$Menu.show()
	$GUI.hide()
	$Dialogue.hide()
	
	#Connect signals
	
	#GUI
	$GUI/Control/Cutscenes.finished.connect(exit_cutscene)
	$GUI.back_to_menu.connect(back_to_menu)
	#Dialogue
	$Dialogue/Control/DialogueBox.dialogue_ended.connect(exit_dialogue)
	#Menu
	$Menu/MainMenu/MarginContainer/VBoxContainer2/MarginContainerPlay/Play.pressed.connect(launch_first_level)
	$"Menu/PauseMenu/MarginContainer/VBoxContainer/MarginContainer2/Back to menu".pressed.connect(back_to_menu, CONNECT_DEFERRED)
	$"Menu/PauseMenu/MarginContainer/VBoxContainer/MarginContainer3/Back to game".pressed.connect(hide_pause_menu, CONNECT_DEFERRED)

func load_level(level_scene:PackedScene) -> void:
	if level:
		level.queue_free()
		level = null
	
	level_packed_scene = level_scene
	level = level_scene.instantiate()
	add_child(level)
	
	for child in get_tree().get_nodes_in_group("Player"):
		safe_connect(child.health_change, $GUI.change_life)
		safe_connect(child.death, restart_level)
		child.health_change.emit(1)
	
	for child in get_tree().get_nodes_in_group("DialogueLauncher"):
		safe_connect(child.launch_dialogue, $Dialogue.launch_dialogue)
		safe_connect(child.launch_dialogue, launch_dialogue, CONNECT_DEFERRED)
		
	for child in get_tree().get_nodes_in_group("CutsceneLauncher"):
		safe_connect(child.launch_cutscene, $GUI.play_cutscene)
		safe_connect(child.launch_cutscene, launch_cutscene, CONNECT_DEFERRED)
		
	for child in get_tree().get_nodes_in_group("LevelLauncher"):
		safe_connect(child.load_level,load_level, CONNECT_DEFERRED)

func _process(delta:float) -> void:
	if Input.is_action_just_pressed("pause") && level: 
		if $Menu.visible:
			call_deferred("hide_pause_menu")
		else: 
			call_deferred("show_pause_menu")

func safe_connect(s:Signal, c:Callable, flags:int=0):
	if !s.is_connected(c):
		s.connect(c, flags)

func launch_first_level():
	load_level(FIRST_LEVEL)
	$Menu.hide()
	$GUI.show()
	$Dialogue.show()
	$AudioStreamPlayer.stop()

func restart_level():
	load_level(level_packed_scene)
	$Menu.hide()
	$GUI.show()
	$Dialogue.show()
	$AudioStreamPlayer.stop()

func launch_dialogue(dialogue:DialogueData, dialogue_start:String = "START"):
	if level: level.process_mode = Node.PROCESS_MODE_DISABLED
	
func exit_dialogue():
	if level: level.process_mode = Node.PROCESS_MODE_INHERIT

func launch_cutscene(cutscene:String):
	if level: level.process_mode = Node.PROCESS_MODE_DISABLED

func exit_cutscene():
	if level: level.process_mode = Node.PROCESS_MODE_INHERIT

func show_pause_menu():
	level.process_mode = Node.PROCESS_MODE_DISABLED
	$Menu.show()
	$Menu.show_menu("PauseMenu")

func hide_pause_menu():
	level.process_mode = Node.PROCESS_MODE_INHERIT
	$Menu.hide()

func back_to_menu():
	$GUI.hide()
	$GUI.stop_cutscene()
	$Dialogue.hide()
	$Menu.show()
	$Menu.show_menu("MainMenu")
	$AudioStreamPlayer.play()
	level.queue_free()
	level = null
