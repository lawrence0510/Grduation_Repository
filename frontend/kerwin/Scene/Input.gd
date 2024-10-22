extends LineEdit

func _ready():
	grab_focus()


func _on_Input_text_entered(new_text):
	clear()
