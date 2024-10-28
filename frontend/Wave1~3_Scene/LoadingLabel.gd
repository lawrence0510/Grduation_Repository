extends Label


var full_text: String = "AI小幫手計算分數中，請稍後..."
var current_text: String = ""
var typing_speed: float = 0.05  # Delay between each character

func _ready():
	current_text = ""
	set_text(current_text)  # Clear the label at the start
	start_typing_effect()

func start_typing_effect():
	# Start a coroutine to update the text incrementally
	current_text = ""  # Reset displayed text
	set_process(true)  # Start calling _process for the effect

func _process(delta):
	# Gradually add one character at a time
	if len(current_text) < len(full_text):
		current_text += full_text[len(current_text)]
		text = current_text
		yield(get_tree().create_timer(typing_speed), "timeout")  # Wait before adding the next character
	else:
		set_process(false)  # Stop when the full text is displayed
