extends Node2D

onready var aicomment: RichTextLabel = $bg/details
onready var score1: Label = $bg/correct/correct_score
onready var score2: Label = $bg/Completeness/com_score
onready var score3: Label = $bg/clarity/clar_score
onready var explanation1: RichTextLabel = $bg/correct_detail
onready var explanation2: RichTextLabel = $bg/com_detail
onready var explanation3: RichTextLabel = $bg/clsr_detail
onready var total_score: Label = $"bg/XX score"

func _ready() -> void:
	aicomment.text = "總評： " + GlobalVar.history_data["q3_aicomment"]
	total_score.text = str(GlobalVar.history_data["total_score"]) + "/10"
	score1.text = str(GlobalVar.history_data["q3_score_1"]) + "/5"
	score2.text = str(GlobalVar.history_data["q3_score_2"]) + "/5"
	score3.text = str(GlobalVar.history_data["q3_score_3"]) + "/5"
	explanation1.text = GlobalVar.history_data["q3_explanation1"]
	explanation2.text = GlobalVar.history_data["q3_explanation2"]
	explanation3.text = GlobalVar.history_data["q3_explanation3"]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_content_pressed():
	get_tree().change_scene("res://Scene/AnswerAndDescription0.tscn")

func _on_wave1_pressed():
	get_tree().change_scene("res://Scene/AnswerAndDescription1.tscn")

func _on_wave2_pressed():
	get_tree().change_scene("res://Scene/AnswerAndDescription2.tscn")

func _on_wave3_pressed():
	get_tree().change_scene("res://Scene/AnswerAndDescription3.tscn")

func _on_cross_pressed():
	get_tree().change_scene("res://scene/MainPage.tscn")

func _on_score_pressed():
	get_tree().change_scene("res://Scene/AnswerAndDescription4.tscn")
