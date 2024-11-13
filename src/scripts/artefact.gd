extends LevelExit


func interact_text_set_text():
	#Fonction à changer si on veux mettre d'autre texte de "interact with"
	var action_event:InputEvent = InputMap.action_get_events("interact")[0]
	interact_text_position.get_node("MarginContainer/Label").text = \
		"Appuyez sur " + action_event.as_text().replace("(Physical)", "") +\
		" pour utiliser l'artéfact !"
