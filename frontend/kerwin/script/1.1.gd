extends Node2D

onready var Button_p: Button = $Button_p
onready var Button_r: Button = $Button_r
onready var Button_e: Button = $Button_e

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_reregister_pressed():
	get_tree().change_scene("res://scene/1.2.1.tscn")

func _on_enter_pressed():
	get_tree().change_scene("res://scene/1.4.0.tscn")

func _on_forget_pressed():
	get_tree().change_scene("res://scene/1.3.1.tscn")
