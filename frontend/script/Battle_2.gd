extends Node2D

# 倒數初始時間
var countdown_time = 10
var countdown_timer : Timer
var delay_timer : Timer  # 新增一個用於延遲跳題的 Timer
var button_paths = ["Background/Options1", "Background/Options2", "Background/Options3", "Background/Options4"]
var all_answered = false  # 用於追蹤兩個人是否已經答完題目

# 分數機制
var max_score = 100  # 最大分數
var current_score_1 = 0  # 玩家計分區塊的當前分數
var target_score_1 = 0  # 玩家計分區塊的目標分數（用來平滑過渡）
var current_score_2 = 0  # 對手計分區塊的當前分數
var target_score_2 = 0  # 對手計分區塊的目標分數（用來平滑過渡）
var base_score_per_question = 10  # 每題基本分數
var question_start_time = 0  # 記錄答題開始時間

# 第一組題目
var question_content = "電子帶有什麼電荷？"
var options = ["正電", "負電", "無電", "雙電"]
var correct_answer = options[1] 

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
	# 設置第一組題目文本
	load_question(question_content, options)
	# 連接按鈕的 pressed 信號
	connect_buttons()
	
	# 從 Globals 中讀取玩家和對手的分數
	var player_score = GlobalVar.player_score
	print(player_score)
	var opponent_score = GlobalVar.opponent_score

	# 直接設置分數條的當前分數，避免初始化時從0開始
	$Background/player_score/score.value = player_score
	$Background/oppo_score/score2.value = opponent_score
	
	# 顯示玩家和對手的分數
	$Background/player_score/word.text = str(player_score)
	$Background/oppo_score/word.text = str(opponent_score)

# 設置 Timer
func setup_timer():
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0  # 每秒更新一次
	countdown_timer.connect("timeout", self, "_on_timeout")
	add_child(countdown_timer)
	countdown_timer.start()
	update_countdown_label()

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
		get_tree().change_scene("res://Scene/Battle_3.tscn")

func _on_delay_timeout():
	# 當延遲的2秒結束後，跳到下一題
	get_tree().change_scene("res://Scene/Battle_3.tscn")

func _on_Timer_timeout():
	$Background/TextureProgress.value += 1
	
# 加載題目和選項
func load_question(content, options):
	$Background/Topic.text = content
	for i in range(button_paths.size()):
		get_node(button_paths[i] + "/content").text = options[i]

# 連接所有選項按鈕
func connect_buttons():
	for path in button_paths:
		get_node(path).connect("pressed", self, "_on_button_pressed", [path])

# 按下的按鈕行為
func _on_button_pressed(button_path: String):
	var selected_answer = get_node(button_path + "/content").text
	# 檢查選擇的答案是否正確
	if selected_answer == correct_answer:
		print("correct")  # 答案正確
		add_score()  # 加分
		apply_style(button_path, correct_stylebox, true)  # 顯示正確樣式
	else:
		print("incorrect")  # 答案錯誤
		apply_style(button_path, incorrect_stylebox, false)  # 顯示錯誤樣式
	
	# 禁用其他按鈕
	disable_other_buttons(button_path)

	# 檢查是否所有選項都已經被按下
	check_all_answered()

# 檢查是否所有選項已經被回答
func check_all_answered():
	all_answered = true
	# 所有人都回答完畢，啟動2秒延遲跳題
	delay_timer.start()
		
#	var all_disabled = true
#	for path in button_paths:
#		if not get_node(path).disabled:
#			all_disabled = false
#			break
#
#	if all_disabled:
#		all_answered = true
#		# 所有人都回答完畢，啟動2秒延遲跳題
#		delay_timer.start()	

# 根據基礎分數和剩餘時間加分
func add_score():
	# 讀取全域變數中的當前分數
	var previous_score_1 = GlobalVar.player_score
	var previous_score_2 = GlobalVar.opponent_score

	# 新題目分數計算
	var new_score_1 = base_score_per_question + countdown_time
	var new_score_2 = base_score_per_question + countdown_time

	# 累加分數
	target_score_1 = previous_score_1 + new_score_1
	target_score_2 = previous_score_2 + new_score_2

	# 確保分數不超過最大分數
	target_score_1 = clamp(target_score_1, 0, max_score)
	target_score_2 = clamp(target_score_2, 0, max_score)

	# 更新全域變數 GlobalVar
	GlobalVar.player_score = target_score_1
	GlobalVar.opponent_score = target_score_2

	# 更新目前分數到 current_score_1 和 current_score_2
	current_score_1 = target_score_1
	current_score_2 = target_score_2

	# 平滑更新分數條
	smooth_update_score()

func smooth_update_score():
	# 只在分數變動時啟用 Tween 來平滑過渡，而非初始化
	var tween_1 = $Background/player_score/Tween
	var tween_2 = $Background/oppo_score/Tween
	
	# 更新玩家分數條
	if tween_1.is_active():
		tween_1.stop_all()
	tween_1.interpolate_property($Background/player_score/score, "value", 
		$Background/player_score/score.value, target_score_1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_1.start()

	# 更新對手分數條
	if tween_2.is_active():
		tween_2.stop_all()
	tween_2.interpolate_property($Background/oppo_score/score2, "value", 
		$Background/oppo_score/score2.value, target_score_2, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween_2.start()

	# 更新分數顯示
	update_score_display()

# 更新分數顯示及紅色分數條B
func update_score_display():
	# 顯示玩家計分區塊的目前分數
	$Background/player_score/word.text = str(target_score_1)
	
	# 顯示對手計分區塊的目前分數
	$Background/oppo_score/word.text = str(target_score_2)

# 應用答案的按鈕樣式
func apply_style(button_path: String, stylebox, is_correct: bool):
	var button = get_node(button_path)
	# 更新按鈕樣式
	button.add_stylebox_override("normal", stylebox)
	button.add_stylebox_override("hover", stylebox)
	button.add_stylebox_override("pressed", stylebox)
	button.add_stylebox_override("focus", stylebox)
	# 顯示正確或錯誤圖案
	button.get_node("player_correct").visible = is_correct
	button.get_node("player_incorrect").visible = not is_correct

# 禁用其他選項按鈕
func disable_other_buttons(correct_path: String):
	for path in button_paths:
		if path != correct_path:
			get_node(path).disabled = true
