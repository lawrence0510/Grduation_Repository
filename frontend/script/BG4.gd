extends Button

var character_name = "G4"

func _on_BG4_pressed():
	var characters = ["B1", "B2", "B3", "G1", "G2", "G3", "G4", "G5", "G6"]
	for character in characters:
		get_parent().get_node(character).visible = false
	get_parent().get_node(character_name).visible = true

func _ready():
	connect("pressed", self, "_on_Button_pressed")