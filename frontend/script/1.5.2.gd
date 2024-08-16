extends Node2D

onready var content: Button = $bg/content
onready var wave1: Button = $bg/wave1
onready var wave2: Button = $bg/wave2
onready var wave3: Button = $bg/wave3
onready var score: Button = $bg/score

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_content_pressed():
	get_tree().change_scene("res://scene/1.5.0.tscn")

func _on_wave1_pressed():
	get_tree().change_scene("res://scene/1.5.1.tscn")

func _on_wave2_pressed():
	get_tree().change_scene("res://scene/1.5.2.tscn")

func _on_wave3_pressed():
	get_tree().change_scene("res://scene/1.5.3.tscn")

func _on_cross_pressed():
	get_tree().change_scene("res://scene/1.4.0.tscn")

func _on_score_pressed():
	get_tree().change_scene("res://scene/1.5.4.tscn")
