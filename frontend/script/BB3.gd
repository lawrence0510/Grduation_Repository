extends Button

var character_name = "B3"

func _on_BB3_pressed():
	var characters = ["B1", "B2", "B3", "G1", "G2", "G3", "G4", "B4"]
	for character in characters:
		get_parent().get_node(character).visible = false
	get_parent().get_node(character_name).visible = true

func _ready():
	connect("pressed", self, "_on_Button_pressed")
