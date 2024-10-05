extends Node2D

# 倒數初始時間
var countdown_time = 10
var countdown_timer : Timer
var delay_timer : Timer  # 用於延遲跳題的 Timer
var opponent_timer : Timer  # 用於對手答題的 Timer
var button_paths = ["Background/Options1", "Background/Options2", "Background/Options3", "Background/Options4"]
var opponent_button_paths = ["Background/op_Options1", "Background/op_Options2", "Background/op_Options3", "Background/op_Options4"]
var all_answered = false  # 用於追蹤兩個人是否已經答完題目
var opponent_answered = false  # 用來追蹤對手是否答題
var player_answered = false  # 用來追蹤玩家是否答題
var opponent_pending_answer = null  # 儲存對手的答案但不立即呈現（只在對手比玩家早答題時使用）

# 分數機制
var max_score = 100  # 最大分數
var current_score_1 = 0  # 玩家計分區塊的當前分數
var target_score_1 = 0  # 玩家計分區塊的目標分數（用來平滑過渡）
var current_score_2 = 0  # 對手計分區塊的當前分數
var target_score_2 = 0  # 對手計分區塊的目標分數（用來平滑過渡）
var base_score_per_question = 10  # 每題基本分數
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
	setup_opponent_timer()  # 設置對手答題 Timer
	
	# 設置第一組題目文本
	load_question(question_content, options)
	# 連接按鈕的 pressed 信號
	connect_buttons()

	# 設置玩家計分區塊的分數條
	$Background/player_score/score.max_value = max_score  # 設置最大分數
	$Background/player_score/score.value = current_score_1  # 初始化分數條為0
	
	# 設置對手計分區塊的分數條
	$Background/oppo_score/score2.max_value = max_score  # 設置最大分數
	$Background/oppo_score/score2.value = current_score_2  # 初始化分數條為0
	
	# 顯示當前分數
	update_score_display()

# 設置 Timer
func setup_timer():
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0  # 每秒更新一次
	countdown_timer.connect("timeout", self, "_on_timeout")
	add_child(countdown_timer)
	countdown_timer.start()
	update_countdown_label()

func _on_Timer_timeout():
	$Background/TextureProgress.value += 1

# 設置對手答題的 Timer
func setup_opponent_timer():
	opponent_timer = Timer.new()
	opponent_timer.wait_time = rand_range(1.0, 3.0)  # 隨機時間為 1 到 5 秒
	opponent_timer.one_shot = true  # 只啟動一次
	opponent_timer.connect("timeout", self, "_on_opponent_answer")
	add_child(opponent_timer)
	opponent_timer.start()  # 啟動對手答題 Timer
	print("Opponent will answer in " + str(opponent_timer.wait_time) + " seconds.")  # 調試訊息

# 設置延遲跳題的 Timer
func setup_delay_timer():
	delay_timer = Timer.new()
	delay_timer.wait_time = 3.0  # 設置為3秒
	delay_timer.connect("timeout", self, "_on_delay_timeout")
	add_child(delay_timer)

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

		# 跳轉到下一個場景
		get_tree().change_scene("res://Scene/Battle_2.tscn")

func _on_delay_timeout():
	get_tree().set_meta("player_score", current_score_1)
	get_tree().set_meta("opponent_score", current_score_2)
	
	get_tree().change_scene("res://Scene/Battle_2.tscn")

# 玩家按下的按鈕行為
func _on_button_pressed(button_path: String):
	if player_answered:
		return  # 如果玩家已經答題，則忽略

	player_answered = true  # 玩家已經答題

	var selected_answer = button_path[button_path.length() - 1]
	print("correct_answer: " + str(correct_answer))
	print("selected answer: " + str(selected_answer))
	# 檢查選擇的答案是否正確
	if str(selected_answer) == str(correct_answer):
		print("Player chose correct answer")  # 答案正確
		add_score()  # 加分
		apply_player_style(button_path, correct_stylebox, true)  # 顯示玩家正確樣式
		$Background/Player/correct.show()
	else:
		print("Player chose incorrect answer")  # 答案錯誤
		apply_player_style(button_path, incorrect_stylebox, false)  # 顯示玩家錯誤樣式
		$Background/Player/incorrect.show()
	
	# 如果對手比玩家先答題，現在顯示對手的按鈕效果
	if opponent_pending_answer != null:
		apply_opponent_style(opponent_pending_answer["button_path"], correct_stylebox if opponent_pending_answer["is_correct"] else incorrect_stylebox, opponent_pending_answer["is_correct"])
		opponent_pending_answer = null  # 清除對手的暫存狀態

	# 禁用其他按鈕
	disable_other_buttons(button_path, button_paths)

	# 檢查是否所有選項都已經被按下
	check_all_answered()

	var question_number = 1
	var selected_option= str(selected_answer)

	update_compete_request(question_number, selected_option) 

# 發送 POST 請求的函數
func update_compete_request(question_number: int, selected_option: String) -> void:
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
	pass
	# if opponent_answered:
	# 	return  # 避免重複答題
	# opponent_answered = true  # 設定對手已經答題
	# print("Opponent is answering...")  # 調試訊息
	
	# # 隨機選擇一個答案
	# var random_index = randi() % opponent_button_paths.size()
	# var selected_answer = opponent_button_paths[opponent_button_paths.length() - 1]
	
	# # 檢查選擇的答案是否正確
	# if str(selected_answer) == str(correct_answer):
	# 	print("Opponent chose correct answer")  # 調試訊息
	# 	add_opponent_score()
	# 	$Background/opponent/correct.show()  # 對手答對顯示
	# else:
	# 	print("Opponent chose incorrect answer")  # 調試訊息
	# 	$Background/opponent/incorrect.show()  # 對手答錯顯示

	# # 如果玩家已經答題，立即顯示對手的按鈕效果
	# if player_answered:
	# 	apply_opponent_style(opponent_button_paths[random_index], correct_stylebox if selected_answer == correct_answer else incorrect_stylebox, selected_answer == correct_answer)
	# else:
	# 	# 玩家還沒答題，暫存對手的答案
	# 	opponent_pending_answer = {
	# 		"button_path": opponent_button_paths[random_index],
	# 		"is_correct": selected_answer == correct_answer
	# 	}

	# # 禁用其他對手按鈕
	# disable_other_buttons(opponent_button_paths[random_index], opponent_button_paths)

	# # 檢查是否所有選項都已經被按下
	# check_all_answered()

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
	if player_answered and opponent_answered:
		# 玩家和對手都已經答題，啟動3秒延遲跳題
		if delay_timer.is_stopped():
			delay_timer.start()

# 根據基礎分數和剩餘時間加分
func add_opponent_score():
	target_score_2 += base_score_per_question
	target_score_2 += countdown_time  # 對手計分區塊加上剩餘時間
	target_score_2 = clamp(target_score_2, 0, max_score)
	GlobalVar.opponent_score = target_score_2
	smooth_update_score()

func add_score():
	target_score_1 += base_score_per_question
	target_score_1 += countdown_time  # 玩家計分區塊加上剩餘時間
	target_score_1 = clamp(target_score_1, 0, max_score)
	print(target_score_1)
	GlobalVar.player_score += target_score_1
	smooth_update_score()

func smooth_update_score():
	# 使用Tween來平滑更新玩家分數條
	var tween_1 =  $Background/player_score/Tween
	if tween_1.is_active():
		tween_1.stop_all()
	tween_1.interpolate_property($Background/player_score/score, "value", current_score_1, target_score_1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_1.start()
	current_score_1 = target_score_1

	# 使用Tween來平滑更新對手分數條
	var tween_2 =  $Background/oppo_score/Tween
	if tween_2.is_active():
		tween_2.stop_all()
	tween_2.interpolate_property($Background/oppo_score/score2, "value", current_score_2, target_score_2, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_2.start()
	current_score_2 = target_score_2
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

