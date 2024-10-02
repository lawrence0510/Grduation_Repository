extends Node2D

onready var content: Button = $bg/content
onready var wave1: Button = $bg/wave1
onready var wave2: Button = $bg/wave2
onready var wave3: Button = $bg/wave3
onready var score: Button = $bg/score
onready var question3: RichTextLabel = $bg/Q
onready var answer3: RichTextLabel = $bg/A
onready var explanation3: RichTextLabel = $bg/details

func _ready() -> void:
	question3.text = GlobalVar.history_data["question3"]
	answer3.text = GlobalVar.history_data["q3_user_answer"]
	explanation3.text = "標準答案： " + GlobalVar.history_data["question3_answer"] + "\n答題評價： " + GlobalVar.history_data["q3_aicomment"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_content_pressed():
	get_tree().change_scene("res://scene/AnsRecord.0.tscn")


func _on_wave1_pressed():
	get_tree().change_scene("res://scene/AnsRecord.1.tscn")


func _on_wave2_pressed():
	get_tree().change_scene("res://scene/AnsRecord.2.tscn")


func _on_wave3_pressed():
	get_tree().change_scene("res://scene/AnsRecord.3.tscn")


func _on_cross_pressed():
	get_tree().change_scene("res://scene/MainPage.tscn")

func _on_score_pressed():
	get_tree().change_scene("res://scene/AnsRecord.4.tscn")
