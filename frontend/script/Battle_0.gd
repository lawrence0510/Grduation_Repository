extends Node

var time_to_change = 0.5
var request_sent = false  # 用於追蹤是否發送了POST請求
var continue_request = true  # 追蹤是否繼續發送請求
var countdown_time = 3.0  # 倒數時間設為3秒
var countdown_active = false  # 用於啟動倒數計時
var timer = null

onready var ready = $TextureRect/Label2/ready
onready var ing = $TextureRect/Label2/ing
onready var http_request = $HTTPRequest
onready var http_request2 = $HTTPRequest2
onready var time_label = $TextureRect/Label2/time
onready var ready_time = $TextureRect/Label2/ready_time
func _ready():
	# 初始化，當場景準備好後開始計時
	set_process(true)
	# 確保 Timer 節點已存在
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1  # 每秒觸發一次
	timer.connect("timeout", self, "_on_Timer_timeout")

func _process(delta):
	# 每幀減少倒數時間，並檢查是否要發送下一次請求
	time_to_change -= delta
	if time_to_change <= 0 and continue_request:
		send_post_request()
		time_to_change = 0.5

	if countdown_active:
		countdown_time -= delta
		time_label.visible = false
		if countdown_time <= 0:
			countdown_active = false
			get_tree().change_scene("res://Scene/Battle_1.tscn")  # 切換場景

	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_cancel_pressed():
	continue_request = false
	var url = "http://nccumisreading.ddnsking.com:5001/Compete/cancel_queue"
	# 建立 DELETE 請求的資料
	var data = {
		"user_id": GlobalVar.user_id,
	}
	# 將資料轉換為 JSON 格式
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	http_request2.request(url, headers, true, HTTPClient.METHOD_DELETE, json_data)

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
			GlobalVar.opponent_id = response["opponent_id"]
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
			
			# 隱藏ing，顯示ready，開始倒數計時
			ing.hide()
			ready.show()
			start_countdown()
			ready_time.text = "3"  # 初始化顯示的秒數
			ready_time.show()
			timer.start()  # 開始計時

	elif response_code == 201:
		print("Still Waiting...")
	else:
		print("Error: Response Code ", response_code)

# 啟動倒數計時的函數
func start_countdown():
	countdown_time = 3.0  # 重置倒數計時
	countdown_active = true  # 啟動倒數計時

func _on_Timer_timeout():
	# 倒數計時的邏輯
	var current_time = int(ready_time.text)
	if current_time > 1:
		current_time -= 1
		ready_time.text = str(current_time)  # 更新顯示的秒數
	else:
		timer.stop()  # 停止計時
		ready.text = ""  # 可以選擇在這裡清空 "ready" 的顯示


func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	print("cancel matching response: ", response)
	get_tree().change_scene("res://Scene/MainPage.tscn")
