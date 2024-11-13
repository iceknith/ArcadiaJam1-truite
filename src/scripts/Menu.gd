extends CanvasLayer

signal back_to_main_menu()

func _ready() -> void:
	connect_signals()
	show_menu("MainMenu")
	
func show_menu(menu_name:String):
	for child in get_children():
		if child.name == menu_name: child.show()
		else: child.hide()

func connect_signals():
	#Main Menu
	$MainMenu/MarginContainer/VBoxContainer2/HBoxContainer/MarginContainerQuit/Quit.pressed.connect(quit_game)
	$MainMenu/MarginContainer/VBoxContainer2/HBoxContainer/MarginContainerOptions/Options.pressed.connect(load_options_from_menu)
	#Option Menu
	$"OptionMenu/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/Back to menu".pressed.connect(load_menu)
	$OptionMenu/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/Back.pressed.connect(load_pause)
	#Pause Menu
	$PauseMenu/MarginContainer/VBoxContainer/MarginContainer/Settings.pressed.connect(load_options_from_pause)
	$"PauseMenu/MarginContainer/VBoxContainer/MarginContainer2/Back to menu".pressed.connect(load_menu)

func quit_game():
	get_tree().quit()

func load_options_from_menu():
	show_menu("OptionMenu")
	$"OptionMenu/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/Back to menu".show()
	$OptionMenu/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/Back.hide()
	
func load_options_from_pause():
	show_menu("OptionMenu")
	$"OptionMenu/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/Back to menu".hide()
	$OptionMenu/MarginContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/Back.show()

func load_menu():
	show_menu("MainMenu")
	back_to_main_menu.emit()

func load_pause():
	show_menu("PauseMenu")
