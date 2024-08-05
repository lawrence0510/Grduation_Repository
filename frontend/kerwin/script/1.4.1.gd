extends Node2D

onready var button_r: Button = $"bg/框框/personal"
onready var button_l: Button = $"bg/框框/record"
onready var edit_birth: Button = $"bg/edit_birth"
onready var edit_school: Button = $"bg/edit_school"
onready var edit_phone: Button = $"bg/edit_phone"
onready var birth: WindowDialog = $"bg/birth"
onready var school: WindowDialog = $"bg/school"
onready var phone: WindowDialog = $"bg/phone"

func _ready() -> void:
	edit_birth.connect("pressed", self, "_on_edit_birth_pressed")
	edit_school.connect("pressed", self, "_on_edit_school_pressed")
	edit_phone.connect("pressed", self, "_on_edit_phone_pressed")	

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_personal_pressed():
	get_tree().change_scene("res://scene/1.4.1.tscn")

func _on_record_pressed():
	get_tree().change_scene("res://scene/1.4.2.tscn")

func _on_edit_birth_pressed():
	birth.popup_centered()

func _on_edit_school_pressed():
	school.popup_centered()

func _on_edit_phone_pressed():
	phone.popup_centered()

func _on_cross_pressed():
	get_tree().change_scene("res://scene/1.4.0.tscn")
