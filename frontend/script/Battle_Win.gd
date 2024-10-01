extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_cancel_pressed():
	get_tree().change_scene("res://scene/Battle_0.tscn")

func _on_main_pressed():
	get_tree().change_scene("res://scene/MainPage.tscn")
