extends CanvasLayer

func _ready() -> void:
	$Control/Cutscenes.finished.connect(cutscene_end)

func change_life(life_percent:float):
	var life_node:Control = $Control/MarginContainer/Life
	
	for i:float in range(3):
		if life_percent >= (i+1)/3:
			life_node.get_node(str(i)).animation = "2"
		elif life_percent >= (i+.5)/3:
			life_node.get_node(str(i)).animation = "1"
		else:
			life_node.get_node(str(i)).animation = "0"

func play_cutscene(file_name:String):
	$Control/Cutscenes.stream.file = file_name
	$Control/Cutscenes.show()
	$Control/Cutscenes.play()
	
func stop_cutscene():
	cutscene_end()

func cutscene_end():
	$Control/Cutscenes.hide()
