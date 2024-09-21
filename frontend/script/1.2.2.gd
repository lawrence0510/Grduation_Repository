extends Node2D

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()


func _on_already_pressed():
	get_tree().change_scene("res://scene/SignIn.tscn")

func _on_enter_pressed():
	get_tree().change_scene("res://scene/Choose.tscn")
