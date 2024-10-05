extends Node

var time_to_change = 0.5
var request_sent = false  # 用於追蹤是否發送了POST請求
var continue_request = true  # 追蹤是否繼續發送請求

onready var ready = $TextureRect/Label2/ready
onready var ing = $TextureRect/Label2/ing
onready var http_request = $HTTPRequest

func _ready():
	# 初始化，當場景準備好後開始計時
	set_process(true)

func _process(delta):
	# 每幀減少倒數時間，並檢查是否要發送下一次請求
	time_to_change -= delta
	if time_to_change <= 0 and continue_request:
		send_post_request()
		time_to_change = 0.5

	if time_to_change <= 1:
		ing.hide()
		ready.show()

	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_cancel_pressed():
	get_tree().change_scene("res://Scene/MainPage.tscn")

# 發送 POST 請求
func send_post_request():
	# 構建 POST 請求
	var url = "http://nccumisreading.ddnsking.com:5001/Compete/match_user?user_id=" + str(GlobalVar.user_id)
	var request_body = ""
	var headers = ["Content-Type: application/json"]

	# 發送 POST 請求
	var error = http_request.request(url, headers, true, HTTPClient.METHOD_POST, request_body)
	if error != OK:
		print("Error sending request: ", error)

# 處理回應
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response = parse_json(body.get_string_from_utf8())
		if response.has("message") and response["message"] == "Match found":
			print("Match found!")
			print("Opponent ID: ", response["opponent_id"])
			continue_request = false
			
			GlobalVar.compete_id = response["compete_id"]
			
			GlobalVar.battle_question = {}  # 清空字典

			# 處理問題
			var questions = response["questions"]
			for i in range(questions.size()):
				var question = questions[i]
				GlobalVar.battle_question["short_question" + str(i + 1)] = question["shortquestion_content"]
				GlobalVar.battle_question["shortquestion" + str(i + 1) + "_option1"] = question["shortquestion_option1"]
				GlobalVar.battle_question["shortquestion" + str(i + 1) + "_option2"] = question["shortquestion_option2"]
				GlobalVar.battle_question["shortquestion" + str(i + 1) + "_option3"] = question["shortquestion_option3"]
				GlobalVar.battle_question["shortquestion" + str(i + 1) + "_option4"] = question["shortquestion_option4"]
				GlobalVar.battle_question["shortquestion" + str(i + 1) + "_answer"] = question["answer"]
			print(GlobalVar.battle_question)
			get_tree().change_scene("res://Scene/Battle_1.tscn")

	elif response_code == 201:
		print("Still Waiting...")
	else:
		print("Error: Response Code ", response_code)
