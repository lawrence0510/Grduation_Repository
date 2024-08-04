extends Control

func _ready():
	pass # Replace with function body.



func _on_Timer_timeout():
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ProgressBar.value += 1

