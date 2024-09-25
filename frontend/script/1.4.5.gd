extends Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_cross_pressed():
	get_tree().change_scene("res://scene/1.4.3.tscn")
