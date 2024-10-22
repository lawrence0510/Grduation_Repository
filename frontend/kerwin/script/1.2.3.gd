extends Control

var c_name1 = "B1"
var c_name2 = "B2"


func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()
			
func _on_enter_pressed():
	get_tree().change_scene("res://scene/1.2.2.tscn")
