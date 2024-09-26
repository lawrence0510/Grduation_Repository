extends Node2D

# 倒數初始時間
var countdown_time = 10
var countdown_timer : Timer
var button_path_array = ["Background/Options1", 
						 "Background/Options2", 
						 "Background/Options3", 
						 "Background/Options4"]

# 第一組題目
var shortquestion_content = "電子帶有什麼電荷？"
var shortquestion_option1 = "正電"
var shortquestion_option2 = "負電"
var shortquestion_option3 = "無電"
var shortquestion_option4 = "雙電"
var answer = shortquestion_option2  # 正確答案是"負電"

# 第二組題目
var new_question_content = "哪一個是地球最長的山脈？"
var new_question_option1 = "喜馬拉雅山"
var new_question_option2 = "洛磯山"
var new_question_option3 = "安第斯山"
var new_question_option4 = "阿爾卑斯山"
var new_answer = new_question_option3  # 正確答案是"安第斯山"

# 預載入正確的 StyleBox 資源
var default_stylebox = preload("res://Fonts/battle_hover.tres")
var a_stylebox = preload("res://Fonts/123.tres")
var correct_stylebox = preload("res://Fonts/correct.tres")
var incorrect_stylebox = preload("res://Fonts/incorrect.tres")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _ready():
	# 創建一個 Timer 並設置為每秒倒數一次
	countdown_timer = Timer.new()
	countdown_timer.wait_time = 1.0  # 每秒更新一次
	countdown_timer.connect("timeout", self, "_on_timeout")
	add_child(countdown_timer)
	countdown_timer.start()
	update_countdown_label()

	# 設置第一組題目文本
	load_question(shortquestion_content, shortquestion_option1, shortquestion_option2, shortquestion_option3, shortquestion_option4)

	# 連接按鈕的 pressed 信號
	$Background/Options1.connect("pressed", self, "_on_Option1_pressed")
	$Background/Options2.connect("pressed", self, "_on_Option2_pressed")
	$Background/Options3.connect("pressed", self, "_on_Option3_pressed")
	$Background/Options4.connect("pressed", self, "_on_Option4_pressed")

# 更新倒數 Label
func update_countdown_label():
	var label = $Background/countdown_label
	label.text = str(countdown_time)

# 每秒更新倒數邏輯
func _on_timeout():
	if countdown_time > 0:
		countdown_time -= 1
		update_countdown_label()
	else:
		# 當倒數結束時，清空題目並載入新題目
		load_new_question()

func _on_Timer_timeout():
	$Background/TextureProgress.value +=1

## 按下的按鈕行為
func _on_Option1_pressed() -> void:
	check_answer("Background/Options1", "content")

func _on_Option2_pressed() -> void:
	check_answer("Background/Options2", "content")

func _on_Option3_pressed() -> void:
	check_answer("Background/Options3", "content")

func _on_Option4_pressed() -> void:
	check_answer("Background/Options4", "content")

## 檢查答案
func check_answer(button_path: String, label_name: String) -> void:
	var button = get_node(button_path)
	var button_label = button.get_node(label_name)  # 根據傳入的 label_name 找到按鈕下的 Label

	if button_label == null:
		print("Label not found under path:", button_path, "/", label_name)
		return

	var selected_answer = button_label.text

	# 檢查選擇的答案是否正確
	if selected_answer == answer:
		print("correct")  # 答案正確時回傳 "correct"
		apply_correct_button_style(button_path)  # 顯示正確圖案
	else:
		print("incorrect")  # 答案錯誤時回傳 "incorrect"
		apply_incorrect_button_style(button_path)  # 顯示錯誤圖案

	# 禁用其他按鈕
	disable_other_buttons(button_path)

## 應用正確答案的按鈕樣式，顯示 correct 圖案
func apply_correct_button_style(button_path: String) -> void:
	var button = get_node(button_path)
	
	# 獲取按鈕中的正確與錯誤圖案
	var player_correct = button.get_node("player_correct")  # 假設 player_correct 是正確圖案的節點
	var player_incorrect = button.get_node("player_incorrect")  # 假設 player_incorrect 是錯誤圖案的節點
	
	# 顯示正確圖案並隱藏錯誤圖案
	if player_correct != null:
		player_correct.visible = true
	if player_incorrect != null:
		player_incorrect.visible = false
	
	# 更新按鈕樣式
	button.add_stylebox_override("normal", correct_stylebox)
	button.add_stylebox_override("hover", correct_stylebox)
	button.add_stylebox_override("pressed", correct_stylebox)
	button.add_stylebox_override("focus", correct_stylebox)

## 應用錯誤答案的按鈕樣式，顯示 incorrect 圖案
func apply_incorrect_button_style(button_path: String) -> void:
	var button = get_node(button_path)
	
	# 獲取按鈕中的正確與錯誤圖案
	var player_correct = button.get_node("player_correct")
	var player_incorrect = button.get_node("player_incorrect")
	
	# 顯示錯誤圖案並隱藏正確圖案
	if player_correct != null:
		player_correct.visible = false
	if player_incorrect != null:
		player_incorrect.visible = true
	
	# 更新按鈕樣式
	button.add_stylebox_override("normal", incorrect_stylebox)
	button.add_stylebox_override("hover", incorrect_stylebox)
	button.add_stylebox_override("pressed", incorrect_stylebox)
	button.add_stylebox_override("focus", incorrect_stylebox)

## Disable其他button 
## 防止玩家按到2個以上
func disable_other_buttons(button_path: String) -> void:
	match button_path:
		"Background/Options1":
			button_path_array.remove(0)
		"Background/Options2":
			button_path_array.remove(1)
		"Background/Options3":
			button_path_array.remove(2)
		"Background/Options4":
			button_path_array.remove(3)
	
	for button_path in button_path_array:
		get_node(button_path).disabled = true

## 加載題目和選項
func load_question(content, option1, option2, option3, option4):
	$Background/Topic.text = content
	$Background/Options1/content.text = option1
	$Background/Options2/content.text = option2
	$Background/Options3/content.text = option3
	$Background/Options4/content.text = option4

## 重置所有按鈕狀態
func reset_buttons():
	for path in button_path_array:
		var button = get_node(path)
		var player_correct = button.get_node("player_correct")
		var player_incorrect = button.get_node("player_incorrect")
		player_correct.hide()
		

		# 重置按鈕樣式
		button.add_stylebox_override("normal", default_stylebox)
		button.add_stylebox_override("hover", a_stylebox)
		button.add_stylebox_override("pressed", a_stylebox)

		# 允許再次點擊按鈕
		button.disabled = false

## 加載新題目，並重新開始倒數計時
func load_new_question():
	# 重置按鈕狀態
	reset_buttons()

	# 重設新題目和選項
	shortquestion_content = new_question_content
	shortquestion_option1 = new_question_option1
	shortquestion_option2 = new_question_option2
	shortquestion_option3 = new_question_option3
	shortquestion_option4 = new_question_option4
	answer = new_answer

	# 加載新的題目和選項
	load_question(shortquestion_content, shortquestion_option1, shortquestion_option2, shortquestion_option3, shortquestion_option4)
	
	# 重置倒數計時
	countdown_time = 10
	update_countdown_label()
	countdown_timer.start()
