extends Node2D

# 倒數初始時間
var countdown_time = 10
var countdown_timer : Timer
onready var delay_timer : Timer = $"Background/Timer2"  # 用於延遲跳題的 Timer
var opponent_check_timer : Timer  # 用於檢查對手答題的 Timer
var button_paths = ["Background/Options1", "Background/Options2", "Background/Options3", "Background/Options4"]
var opponent_button_paths = ["Background/op_Options1", "Background/op_Options2", "Background/op_Options3", "Background/op_Options4"]
var all_answered = false  # 用於追蹤兩個人是否已經答完題目
var opponent_answered = false  # 用來追蹤對手是否答題
var player_answered = false  # 用來追蹤玩家是否答題
var opponent_pending_answer = null  # 儲存對手的答案但不立即呈現（只在對手比玩家早答題時使用）

# 分數機制
var max_score = 1000  # 最大分數
var current_score_1 = 0  # 玩家計分區塊的當前分數
var target_score_1 = 0  # 玩家計分區塊的目標分數（用來平滑過渡）
var current_score_2 = 0  # 對手計分區塊的當前分數
var target_score_2 = 0  # 對手計分區塊的目標分數（用來平滑過渡）
var base_score_per_question = 120  # 每題基本分數
var question_start_time = 0  # 記錄答題開始時間

# 第一組題目
var question_content = GlobalVar.battle_question["short_question1"]
var options = [GlobalVar.battle_question["shortquestion1_option1"], GlobalVar.battle_question["shortquestion1_option2"], GlobalVar.battle_question["shortquestion1_option3"], GlobalVar.battle_question["shortquestion1_option4"]]
var correct_answer = GlobalVar.battle_question["shortquestion1_answer"]

# 預載入正確的 StyleBox 資源
var default_stylebox = preload("res://Fonts/battle_hover.tres")
var correct_stylebox = preload("res://Fonts/correct.tres")
var incorrect_stylebox = preload("res://Fonts/incorrect.tres")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _ready():
	# 創建 Timer 並開始倒數
	setup_timer()
	setup_delay_timer()  # 設置延遲跳題的 Timer
	setup_opponent_check_timer()  # 設置檢查對手答題的 Timer
	
	# 發送GET請求，獲取玩家資料
	get_player_data()
	# 發送GET請求，獲取對手資料
	get_opponent_data()

	# 設置第一組題目文本
	load_question(question_content, options)
	# 連接按鈕的 pressed 信號
	connect_buttons()

	# 設置玩家計分區塊的分數條
	$Background/player_score/score2.max_value = max_score  # 設置最大分數
	$Background/player_score/score2.value = current_score_1  # 初始化分數條為0
	
	# 設置對手計分區塊的分數條
	$Background/oppo_score/score.max_value = max_score  # 設置最大分數
	$Background/oppo_score/score.value = current_score_2  # 初始化分數條為0
	
	# 顯示當前分數
	update_score_display()

# 發送GET請求，獲取玩家資料
func get_player_data():
	var url = "http://nccumisreading.ddnsking.com:5001/User/get_user_from_id?user_id=" + str(GlobalVar.user_id)
	var headers = ["accept: application/json", "Content-Type: application/json"]
	$HTTPRequest3.request(url, headers, false, HTTPClient.METHOD_GET)

func _on_Timer_timeout():
	$Background/TextureProgress.value += 1

# 處理從API接收到的玩家資料
func _on_HTTPRequest3_request_completed(result, response_code, headers, body):
	if response_code == 200:  # 成功接收回應
		var json_data = JSON.parse(body.get_string_from_utf8()).result
		var profile_picture = json_data["profile_picture"]
		$Background/Player/name.text = json_data["user_name"]
		var character_id = json_data["character_id"]

		if profile_picture != null and profile_picture != "":
			load_profile_picture_from_url(profile_picture)
		else:
			if character_id == 1:
				$Background/Player/pic.texture = load("res://Pic/battle_B1.png")
			elif character_id == 2:
				$Background/Player/pic.texture = load("res://Pic/battle_B2.png")
			elif character_id == 3:
				$Background/Player/pic.texture = load("res://Pic/battle_B3.png")
			elif character_id == 4:
				$Background/Player/pic.texture = load("res://Pic/battle_B4.png")
			elif character_id == 5:
				$Background/Player/pic.texture = load("res://Pic/battle_G1.png")
			elif character_id == 6:
				$Background/Player/pic.texture = load("res://Pic/battle_G2.png")
			elif character_id == 7:
				$Background/Player/pic.texture = load("res://Pic/battle_G3.png")
			elif character_id == 8:
				$Background/Player/pic.texture = load("res://Pic/battle_G4.png")

# 使用 HTTP 請求下載並加載圖片
func load_profile_picture_from_url(url: String):
	var image_request = $HTTPRequest4
	image_request.connect("request_completed", self, "_on_profile_picture_request_completed")
	image_request.request(url)

# 當圖片下載完成時處理圖片
func _on_HTTPRequest4_request_completed(result, response_code, headers, body):
	if response_code == 200:
		# 嘗試將body轉換為Image
		var image = Image.new()
		var load_result = image.load_jpg_from_buffer(body)
		if load_result == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			$Background/Player/pic.texture = texture

func get_opponent_data():
	var url = "http://nccumisreading.ddnsking.com:5001/User/get_user_from_id?user_id=" + str(GlobalVar.opponent_id)
	var headers = ["accept: application/json", "Content-Type: application/json"]
	$HTTPRequest5.request(url, headers, false, HTTPClient.METHOD_GET)

# 處理從API接收到的對手資料
func _on_HTTPRequest5_request_completed(result, response_code, headers, body):
	if response_code == 200:  # 成功接收回應
		var json_data = JSON.parse(body.get_string_from_utf8()).result
		var profile_picture = json_data["profile_picture"]
		$Background/opponent/name.text = json_data["user_name"]
		var character_id = json_data["character_id"]

		if profile_picture != null and profile_picture != "":
			load_opponent_picture_from_url(profile_picture)
		else:
			if character_id == 1:
				$Background/opponent/pic.texture = load("res://Pic/battle_B1.png")
			elif character_id == 2:
				$Background/opponent/pic.texture = load("res://Pic/battle_B2.png")
			elif character_id == 3:
				$Background/opponent/pic.texture = load("res://Pic/battle_B3.png")
			elif character_id == 4:
				$Background/opponent/pic.texture = load("res://Pic/battle_B4.png")
			elif character_id == 5:
				$Background/opponent/pic.texture = load("res://Pic/battle_G1.png")
			elif character_id == 6:
				$Background/opponent/pic.texture = load("res://Pic/battle_G2.png")
			elif character_id == 7:
				$Background/opponent/pic.texture = load("res://Pic/battle_G3.png")
			elif character_id == 8:
				$Background/opponent/pic.texture = load("res://Pic/battle_G4.png")

# 使用 HTTP 請求下載並加載對手的圖片
func load_opponent_picture_from_url(url: String):
	var image_request = $HTTPRequest6
	image_request.connect("request_completed", self, "_on_opponent_picture_request_completed")
	image_request.request(url)

# 當對手圖片下載完成時處理圖片
func _on_opponent_picture_request_completed(result, response_code, headers, body):
	if response_code == 200:
		# 嘗試將body轉換為Image
		var image = Image.new()
		var load_result = image.load_jpg_from_buffer(body)
		if load_result == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			$Background/opponent/pic.texture = texture

# 設置 Timer
func setup_timer():
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0  # 每秒更新一次
	countdown_timer.connect("timeout", self, "_on_timeout")
	add_child(countdown_timer)
	countdown_timer.start()
	update_countdown_label()

# 設置檢查對手答題的 Timer
func setup_opponent_check_timer():
	opponent_check_timer = Timer.new()
	opponent_check_timer.wait_time = 0.5  # 每0.5秒發送一次請求
	opponent_check_timer.connect("timeout", self, "_on_opponent_answer")
	add_child(opponent_check_timer)
	opponent_check_timer.start()

# 設置延遲跳題的 Timer
func setup_delay_timer():
	delay_timer.wait_time = 2
	delay_timer.connect("timeout", self, "_on_delay_timeout")

# 更新倒數 Label
func update_countdown_label():
	$Background/countdown_label.text = str(countdown_time)

# 每秒更新倒數邏輯
func _on_timeout():
	if countdown_time > 0:
		countdown_time -= 1
		update_countdown_label()
	else:
		# 當倒數時間為 0，跳轉到下一題
		get_tree().change_scene("res://Scene/Battle_2.tscn")
		# 確保在場景切換前，存儲當前分數到全局變數
		GlobalVar.player_score = current_score_1
		GlobalVar.opponent_score = current_score_2

func _on_delay_timeout():
	get_tree().change_scene("res://Scene/Battle_2.tscn")
	get_tree().set_meta("player_score", current_score_1)
	get_tree().set_meta("opponent_score", current_score_2)

# 玩家按下的按鈕行為
func _on_button_pressed(button_path: String):
	if player_answered:
		return  # 如果玩家已經答題，則忽略

	player_answered = true  # 玩家已經答題

	var selected_answer = button_path[button_path.length() - 1]
	GlobalVar.player_selected_answer = selected_answer  # 存儲玩家選擇
	# 檢查選擇的答案是否正確
	if str(selected_answer) == str(correct_answer):
		print("使用者作答正確")  # 答案正確
		add_score()  # 加分
		apply_player_style(button_path, correct_stylebox, true)  # 顯示玩家正確樣式
		$Background/Player/correct.show()
	else:
		print("使用者作答錯誤")  # 答案錯誤
		apply_player_style(button_path, incorrect_stylebox, false)  # 顯示玩家錯誤樣式
		$Background/Player/incorrect.show()

	update_compete_request(1, str(selected_answer))
	# 禁用其他按鈕
	disable_other_buttons(button_path, button_paths)

	# 檢查是否所有選項都已經被按下
	check_all_answered()

	# 檢查是否有 pending 的對手答案，如果有，立即應用
	if opponent_pending_answer != null:
		apply_opponent_style(opponent_pending_answer["button_path"], correct_stylebox if opponent_pending_answer["is_correct"] else incorrect_stylebox, opponent_pending_answer["is_correct"])
		opponent_pending_answer = null  # 清除對手的暫存狀態
	
# 發送 POST 請求的函數
func update_compete_request(question_number: int, selected_option: String) -> void:
	print("Trying to update...")
	var url = "http://nccumisreading.ddnsking.com:5001/Compete/update_answer"
	
	# 構建 query_string，對 user_id 和 compete_id 進行 http_escape
	var query_string = "?user_id=" + str(GlobalVar.user_id).http_escape() + "&compete_id=" + str(GlobalVar.compete_id).http_escape() + "&question_number=" + str(question_number).http_escape() + "&selected_option=" + selected_option.http_escape() + "&score=" + str(GlobalVar.player_score).http_escape()
	url += query_string
		
	# 準備 HTTP headers
	var headers = ["accept: application/json", "Content-Type: application/json"]
	
	# 發送 POST 請求
	$HTTPRequest.request(url, headers, true, HTTPClient.METHOD_POST, "{}")



# 對手答題邏輯
func _on_opponent_answer():
	var url = "http://nccumisreading.ddnsking.com:5001/Compete/get_compete_from_id?compete_id=" + str(GlobalVar.compete_id)
	var headers = ["accept: application/json", "Content-Type: application/json"]
	
	# 發送 GET 請求
	$HTTPRequest2.request(url, headers, false, HTTPClient.METHOD_GET)

# 處理從API接收到的對手答題
func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	if response_code == 200:  # 成功接收回應
		var json_data = JSON.parse(body.get_string_from_utf8()).result
		var opponent_answer = null
		var opponent_score = 0

		# 確定玩家是 user1 還是 user2
		if GlobalVar.user_id == json_data["user1_id"]:
			opponent_answer = json_data["user2_question1"]
			opponent_score = json_data["user2_score"]
		elif GlobalVar.user_id == json_data["user2_id"]:
			opponent_answer = json_data["user1_question1"]
			opponent_score = json_data["user1_score"]
		
		# 檢查對手是否已經回答
		if opponent_answer != null:
			var selected_answer = str(opponent_answer)
			GlobalVar.opponent_selected_answer = selected_answer  # 存儲對手選擇
			
			# 根據對手的答案更新樣式
			if str(selected_answer) == str(correct_answer):
				$Background/opponent/correct.show()  # 對手答對
			else:
				$Background/opponent/incorrect.show()  # 對手答錯

			# 更新對手的分數
			GlobalVar.opponent_score = opponent_score
			smooth_update_score()

			# 對手已經回答，停止檢查
			opponent_check_timer.stop()
			opponent_pending_answer = {
				"button_path": opponent_button_paths[opponent_answer - 1],
				"is_correct": str(selected_answer) == str(correct_answer)
			}

			# 如果玩家已經回答，立即應用對手的樣式
			if player_answered:
				apply_opponent_style(opponent_pending_answer["button_path"], correct_stylebox if opponent_pending_answer["is_correct"] else incorrect_stylebox, opponent_pending_answer["is_correct"])
				opponent_pending_answer = null
			
			check_all_answered()
			print("對手已回答、分數已更新")

# 加載題目和選項
func load_question(content, options):
	$Background/Topic.text = content
	for i in range(button_paths.size()):
		get_node(button_paths[i] + "/content").text = options[i]

	for i in range(opponent_button_paths.size()):
		get_node(opponent_button_paths[i] + "/content").text = options[i]

# 連接所有選項按鈕
func connect_buttons():
	for path in button_paths:
		get_node(path).connect("pressed", self, "_on_button_pressed", [path])


# 檢查是否所有選項已經被回答
func check_all_answered():
	# 檢查玩家的正確或錯誤圖標是否可見
	var player_answered_correctly = $Background/Player/correct.visible
	var player_answered_incorrectly = $Background/Player/incorrect.visible
	
	# 檢查對手的正確或錯誤圖標是否可見
	var opponent_answered_correctly = $Background/opponent/correct.visible
	var opponent_answered_incorrectly = $Background/opponent/incorrect.visible
	if (player_answered_correctly or player_answered_incorrectly) and (opponent_answered_correctly or opponent_answered_incorrectly):
		# 玩家和對手都已經答題，啟動3秒延遲跳題
		print("雙方都已答題")
		print("我方回答： " + str(GlobalVar.player_selected_answer))
		print("敵方回答： " + str(GlobalVar.opponent_selected_answer))
		if delay_timer.is_stopped():
			delay_timer.start()
		var correct_button_path = button_paths[int(correct_answer) - 1]
		apply_AllIncorrect_style(correct_button_path, correct_stylebox)
		GlobalVar.player_selected_answer = ""
		GlobalVar.opponent_selected_answer = ""
		print("雙方都答錯，正確答案已顯示")
	#許馨文救我 他只會出現O不會出現綠色

func add_score():
	var score_for_current_question = base_score_per_question + countdown_time * 8
	GlobalVar.player_score += score_for_current_question
	target_score_1 = GlobalVar.player_score
	smooth_update_score()

func smooth_update_score():
	# 使用Tween來平滑更新玩家分數條
	var tween_1 =  $Background/player_score/Tween
	if tween_1.is_active():
		tween_1.stop_all()
	tween_1.interpolate_property($Background/player_score/score2, "value", current_score_1, target_score_1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_1.start()
	current_score_1 = target_score_1

	# 使用Tween來平滑更新對手分數條
	var tween_2 = $Background/oppo_score/Tween
	if tween_2.is_active():
		tween_2.stop_all()
	tween_2.interpolate_property($Background/oppo_score/score, "value", current_score_2, GlobalVar.opponent_score, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_2.start()
	current_score_2 = GlobalVar.opponent_score
	update_score_display()

# 更新分數顯示
func update_score_display():
	$Background/player_score/word.text = str(current_score_1)
	$Background/oppo_score/word.text = str(current_score_2)

# 禁用其他選項按鈕
func disable_other_buttons(correct_path: String, paths: Array):
	for path in paths:
		if path != correct_path:
			get_node(path).disabled = true

# 適用於玩家的按鈕樣式應用
func apply_player_style(button_path: String, stylebox, is_correct: bool):
	var button = get_node(button_path)
	# 更新玩家的按鈕樣式
	button.add_stylebox_override("normal", stylebox)
	button.add_stylebox_override("hover", stylebox)
	button.add_stylebox_override("pressed", stylebox)
	button.add_stylebox_override("focus", stylebox)
	# 顯示玩家的正確或錯誤圖標
	button.get_node("player_correct").visible = is_correct
	button.get_node("player_incorrect").visible = not is_correct

# 適用於對手的按鈕樣式應用
# 如果玩家已經答題，對手按鈕樣式會有變化
func apply_opponent_style(button_path: String, stylebox, is_correct: bool):
	var button = get_node(button_path)
	# 更新對手的按鈕樣式
	button.add_stylebox_override("normal", stylebox)
	button.add_stylebox_override("hover", stylebox)
	button.add_stylebox_override("pressed", stylebox)
	button.add_stylebox_override("focus", stylebox)
	# 顯示對手的正確或錯誤圖標
	button.get_node("oppo_correct").visible = is_correct
	button.get_node("oppo_incorrect").visible = not is_correct

# 只應用正確答案樣式的函數
func apply_AllIncorrect_style(button_path: String, stylebox):
	var button = get_node(button_path)
	# 更新按鈕的樣式為正確答案樣式
	button.add_stylebox_override("normal", stylebox)
	button.add_stylebox_override("hover", stylebox)
	button.add_stylebox_override("pressed", stylebox)
	button.add_stylebox_override("focus", stylebox)
	# 強制刷新按鈕狀態
	button.release_focus()
	button.grab_focus()
	

func _on_HTTPRequest6_request_completed(result, response_code, headers, body):
	pass # Replace with function body.


func _on_HTTPRequest_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray):
	print("UPDATE STATUS: " + str(response_code))
