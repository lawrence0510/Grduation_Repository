extends Node2D

onready var button_r: Button = $"bg/框框/personal"
onready var button_l: Button = $"bg/框框/record"
onready var b16: Button = $"bg/框框/DayPanel/b16"
onready var LogDay: WindowDialog = $"bg/LogDay"

func _ready() -> void:
	b16.connect("pressed", self, "_on_16_pressed")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_personal_pressed():
	get_tree().change_scene("res://scene/1.4.1.tscn")

func _on_record_pressed():
	get_tree().change_scene("res://scene/1.4.2.tscn")

func _on_16_pressed():
	LogDay.popup_centered()

func _on_cross_pressed():
	get_tree().change_scene("res://scene/1.4.0.tscn")
