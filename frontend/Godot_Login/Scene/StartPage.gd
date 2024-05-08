extends Node

func _on_Login_button_up():
	pass # Replace with function body.


func _Login():
	get_tree().change_scene("res://Scene/LoginPage.tscn")


func _Register():
	get_tree().change_scene("res://Scene/Register.tscn")
