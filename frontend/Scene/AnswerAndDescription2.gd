extends Node2D

onready var content: Button = $bg/content
onready var wave1: Button = $bg/wave1
onready var wave2: Button = $bg/wave2
onready var wave3: Button = $bg/wave3
onready var score: Button = $bg/score
onready var question2: RichTextLabel = $bg/Q
onready var optiona: RichTextLabel = $bg/A
onready var optionb: RichTextLabel = $bg/B
onready var optionc: RichTextLabel = $bg/C
onready var optiond: RichTextLabel = $bg/D
onready var detail: RichTextLabel = $bg/details
onready var iscorrect: Label = $"bg/(in)correct"

func _ready() -> void:
	# 設定字體樣式
	var custom_font = DynamicFont.new()  # 建立一個 DynamicFont
	var font_data = DynamicFontData.new()  # 建立字體資料
	
	font_data.font_path = "res://Fonts/NotoSansTC-SemiBold.ttf"
	custom_font.font_data = font_data
	custom_font.size = 50  # 設定字體大小
	
	question2.text = GlobalVar.history_data["question_2"]
	optiona.text = "A. " + GlobalVar.history_data["question2_choice1"]
	optionb.text = "B. " + GlobalVar.history_data["question2_choice2"]
	optionc.text = "C. " + GlobalVar.history_data["question2_choice3"]
	optiond.text = "D. " + GlobalVar.history_data["question2_choice4"]
	detail.text = GlobalVar.history_data["question2_explanation"]
	
	if GlobalVar.history_data["q2_is_correct"] == 1:
		iscorrect.text = "正確 ✓"
		iscorrect.add_font_override("font", custom_font)
		iscorrect.add_color_override("font_color", Color8(93, 234, 85))
		iscorrect.add_color_override("shadow_color", Color8(93, 234, 85))
		iscorrect.add_color_override("outline_color", Color8(93, 234, 85))
	else:
		iscorrect.text = "不正確 X"
		iscorrect.add_font_override("font", custom_font)
		iscorrect.add_color_override("font_color", Color8(255, 113, 113))
		iscorrect.add_color_override("shadow_color", Color8(255, 113, 113))
		iscorrect.add_color_override("outline_color", Color8(255, 113, 113))
	
	var right_answer = GlobalVar.history_data["question2_answer"]

	if(GlobalVar.history_data["question2_choice1"] == right_answer):
		#正確答案是A
		optiona.add_stylebox_override("normal", preload("res://Fonts/104correct.tres"))
		
	if(GlobalVar.history_data["question2_choice2"] == right_answer):
		#正確答案是B
		optionb.add_stylebox_override("normal", preload("res://Fonts/104correct.tres"))
		
	if(GlobalVar.history_data["question2_choice3"] == right_answer):
		#正確答案是C
		optionc.add_stylebox_override("normal", preload("res://Fonts/104correct.tres"))
		
	if(GlobalVar.history_data["question2_choice4"] == right_answer):
		#正確答案是D
		optiond.add_stylebox_override("normal", preload("res://Fonts/104correct.tres"))
	
	#使用者有選錯的情況（變紅色格子）	
	if GlobalVar.history_data["q2_is_correct"] == 0:
		if(GlobalVar.history_data["q2_user_answer"] == GlobalVar.history_data["question2_choice1"]):
			#使用者選擇A且A是錯的
			optiona.add_stylebox_override("normal", preload("res://Fonts/104incorrect.tres"))
		elif(GlobalVar.history_data["q2_user_answer"] == GlobalVar.history_data["question2_choice2"]):
			#使用者選擇B且B是錯的
			optionb.add_stylebox_override("normal", preload("res://Fonts/104incorrect.tres"))
		elif(GlobalVar.history_data["q2_user_answer"] == GlobalVar.history_data["question2_choice3"]):
			#使用者選擇C且C是錯的
			optionc.add_stylebox_override("normal", preload("res://Fonts/104incorrect.tres"))
		elif(GlobalVar.history_data["q2_user_answer"] == GlobalVar.history_data["question2_choice4"]):
			#使用者選擇D且D是錯的
			optiond.add_stylebox_override("normal", preload("res://Fonts/104incorrect.tres"))

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
