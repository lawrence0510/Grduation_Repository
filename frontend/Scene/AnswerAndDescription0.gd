extends Node2D

onready var content: Button = $bg/content
onready var wave1: Button = $bg/wave1
onready var wave2: Button = $bg/wave2
onready var wave3: Button = $bg/wave3
onready var score: Button = $bg/score
onready var http_request: HTTPRequest = $HTTPRequest

# 全域變數中的history_data字典將用來存放API回應
func _ready() -> void:
	# 改為使用GlobalVar中的history_id
	var history_id = str(GlobalVar.history_id)
	var url = "http://nccumisreading.ddnsking.com:5001/History/get_all_data_with_history_id?history_id=" + history_id
	
	# 設置請求的 headers
	var headers = ["Content-Type: application/json"]
	
	# 發送 HTTP GET 請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET)


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


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error == OK:
		# 將API回應的資料存入history_data字典
		GlobalVar.history_data = {
			"history_id": json.result.history_id,
			"user_id": json.result.user_id,
			"article_id": json.result.article_id,
			"question_id": json.result.question_id,
			"time": json.result.time,
			"q1_user_answer": json.result.q1_user_answer,
			"q1_correct_answer": json.result.q1_correct_answer,
			"q1_is_correct": json.result.q1_is_correct,
			"q2_user_answer": json.result.q2_user_answer,
			"q2_correct_answer": json.result.q2_correct_answer,
			"q2_is_correct": json.result.q2_is_correct,
			"q3_user_answer": json.result.q3_user_answer,
			"q3_correct_answer": json.result.q3_correct_answer,
			"q3_score_1": json.result.q3_score_1,
			"q3_score_2": json.result.q3_score_2,
			"q3_score_3": json.result.q3_score_3,
			"q3_total_score": json.result.q3_total_score,
			"q3_aicomment": json.result.q3_aicomment,
			"total_score": json.result.total_score,
			"article_title": json.result.article_title,
			"article_link": json.result.article_link,
			"article_category": json.result.article_category,
			"article_content": json.result.article_content,
			"article_grade": json.result.article_grade,
			"article_expired_day": json.result.article_expired_day,
			"article_pass": json.result.article_pass,
			"article_note": json.result.article_note,
			"check_time": json.result.check_time,
			"question_grade": json.result.question_grade,
			"question_1": json.result.question_1,
			"question1_choice1": json.result.question1_choice1,
			"question1_choice2": json.result.question1_choice2,
			"question1_choice3": json.result.question1_choice3,
			"question1_choice4": json.result.question1_choice4,
			"question1_answer": json.result.question1_answer,
			"question1_explanation": json.result.question1_explanation,
			"question_2": json.result.question_2,
			"question2_choice1": json.result.question2_choice1,
			"question2_choice2": json.result.question2_choice2,
			"question2_choice3": json.result.question2_choice3,
			"question2_choice4": json.result.question2_choice4,
			"question2_answer": json.result.question2_answer,
			"question2_explanation": json.result.question2_explanation,
			"question3": json.result.question3,
			"question3_answer": json.result.question3_answer,
			"q3_explanation1": json.result.q3_explanation1,
			"q3_explanation2": json.result.q3_explanation2,
			"q3_explanation3": json.result.q3_explanation3,
		}
		
		$bg/content2.text = GlobalVar.history_data["article_content"]
	else:
		print("Error parsing JSON: ", json.error_string)

