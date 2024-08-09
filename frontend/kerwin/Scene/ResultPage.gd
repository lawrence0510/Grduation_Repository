extends Control

func _ready():
	pass

func _on_Timer_timeout():
	$MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/ProgressBar.value += 1
