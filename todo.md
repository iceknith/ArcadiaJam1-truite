
Trucs à faire:

Code:
- [x] Système de platformer 2D
- [x] Entités
	- [x] Ennemis (bougent à l'envers)
	- [x] PNJ (lancent interraction)
- [x] Système de combat (hp, dégats, et tout le tralala)
- [x] Système de dialogue modulable
- [x] Système de cutscenes
- [x] Arbre de décision des persos
- [x] Faire un menu
- [x] Faire un système de niveau
	- [x] Faire des objets qui enlèvent les power-ups
	- [x] Faire des objets qui permettent de finir le jeu
- [x] Faire les portes fermées/ouvertes
- [ ] Mettre une interaction secondaire aux PNJs
- [x] Rendre le KB moins scuffed
Scénario:
	(acte 1 -> fin jeu, début histoire)
- [x] Définir les endroits des actes 1, 2, 3
	- Usine/Endroit steamphunk -> base du méchant steampunk
- [x] Définir la storyline de ces actes
	- acte 3 -> combat de "boss" (tuto système de combat)
			-> ajouter un power up de combat (fat épée, qui increase la reach et les dégats)
			-> Section de platforming (déposer le power up) & de dialogue où le perso as des options de dialogue "normale"
	- acte 2 -> On se bat contre des mobs & dépot 3ème dash & un peu platforming
			-> vue du corps de perso 2
	- acte 1 -> Collection de pleins de power ups 
			-> énigme de savoir lesquels déposer quand, récolte indice de l'ordre en parlant avec les compagnons
- Liste persos:
	- Perso principal
	- Proche
	- perso 1
	- Gontran
	- Méchant
- [ ] Définir les arbres de conversations des personages
Art:
- [ ] Chara design du perso principal
- [ ] Animations du perso principal
- [ ] Tileset des 3 actes
	- [ ] Acte 1
	- [ ] Acte 2
	- [ ] Acte 3
- [ ] Chara design des pnj
- [ ] Animations des pnj
- [ ] Chara design des ennemis
- [ ] Animations des ennemis
Musique
- [ ] Définir la todo list


Architechture prévisionelle du jeu:

Main
	Menu
	Cutscenes
		VideoPlayer
	Dialogue
		TextBox
		Pleins de fioritures jolies
	Level
		Player
		Ennemies
		PNJs
		Tilemap
