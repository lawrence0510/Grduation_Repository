extends Control


func _on_AskButton_pressed() -> void:
	get_tree().change_scene("res://Scene/Dialog.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()
