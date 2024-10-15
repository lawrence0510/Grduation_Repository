extends Node2D

onready var button_r: Button = $"bg/框框/personal"
onready var button_l: Button = $"bg/框框/record"
onready var LoginDay: WindowDialog = $BackgroundPicture/LoginDay
onready var last: Button = $BackgroundPicture/last
onready var next: Button = $BackgroundPicture/next
onready var labels = [] # 用來存放日期label的列表
onready var Day: Label = LoginDay.get_node("TextureRect/Day")
onready var login_scroll = $BackgroundPicture/LoginDay/TextureRect/ScrollContainer

func _ready() -> void:
	var current_month = 2
	var days_in_current_month = 28
	for i in range(1, days_in_current_month + 1):
		var label = get_node("BackgroundPicture/DayPanel/" + str(i)) 
		labels.append(label)
	
	# 檢查 GlobalVar.login_record 是否存在，並且有 data 欄位
	if GlobalVar.login_record != null and GlobalVar.login_record.has("data"):
		var login_record = GlobalVar.login_record["data"]
		var unique_days = []

		for record in login_record:
			var login_time = record["login_time"]
			# 將字串按照 '-' 和 'T' 進行切割來取得年月日
			var date_parts = login_time.split("T")[0].split("-")
			var year = int(date_parts[0])
			var month = int(date_parts[1])
			var day = int(date_parts[2])

			# 檢查月份是否為 10 月（October）
			if month == current_month:
				# 如果這個日還沒被添加到 unique_days，則將其加入
				if not day in unique_days:
					unique_days.append(day)

		var label_numbers = unique_days
		
		# 將這些指定的label變成button
		for number in label_numbers:
			var label_index = number - 1  # Label對應的索引值（數組從0開始）
			if label_index >= 0 and label_index < labels.size():
				var selected_label = labels[label_index]
				# 創建新的 Button 並替換對應的 Label
				var new_button = Button.new()
				new_button.text = str(number)  # 設定按鈕文字只顯示數字
				
				# 建立一個 DynamicFont
				var custom_font = DynamicFont.new()  
				var font_data = DynamicFontData.new()
				font_data.font_path = "res://Fonts/NotoSansTC-VariableFont_wght.ttf"
				custom_font.font_data = font_data
				
				# 設定字體樣式 + 細節
				new_button.add_font_override("font", custom_font)	
				new_button.add_color_override("font_color", Color(0, 0, 0)) 
				new_button.add_color_override("font_color_hover", Color(0, 0, 0))
				new_button.add_color_override("font_color_disabled", Color(0, 0, 0))
				new_button.add_color_override("font_color_focus", Color(0, 0, 0))
				new_button.add_color_override("font_color_pressed", Color(0, 0, 0))
				custom_font.outline_size = 1
				custom_font.outline_color = Color(0, 0, 0)
				custom_font.size = 20	# 設定字體大小為 20
					
				 # 設定按鈕樣式
				new_button.add_stylebox_override("normal", preload("res://Fonts/日期按鈕.tres"))
				new_button.add_stylebox_override("pressed", preload("res://Fonts/日期按鈕.tres"))  
				new_button.add_stylebox_override("focus", preload("res://Fonts/日期按鈕.tres"))  
				new_button.add_stylebox_override("disable", preload("res://Fonts/日期按鈕.tres"))  
				new_button.add_stylebox_override("hover", preload("res://Fonts/日期按鈕.tres"))
				new_button.rect_size = Vector2(88, 40)	# 設定按鈕大小  
				
				# 替換選定的 Label 為 Button
				replace_label_with_button(selected_label, new_button)
	else:
		# 如果 GlobalVar.login_record 是空的，顯示提示或執行其他邏輯
		print("沒有找到任何登入紀錄")
			
func replace_label_with_button(label, button):	# Button 取代 Label 並在原本的位置
	var parent = label.get_parent()

	# 獲取原 label 的位置和大小
	var original_position = label.rect_position
	var original_size = label.rect_size

	# 刪除 Label
	label.queue_free()

	# 將 Button 加入父節點
	parent.add_child(button)

	# 設定 Button 的位置和大小
	button.rect_position = original_position
	button.rect_size = original_size

	# 獲取所有子節點
	var children = parent.get_children()
	
	# 獲取 label 的索引
	var label_index = -1
	for i in range(children.size()):
		if children[i] == button:  # 尋找新按鈕的索引
			label_index = i
			break

	# 將 Button 移動到原 Label 的位置
	if label_index != -1:
		parent.move_child(button, label_index)
	
		
	button.connect("pressed", self, "_on_button_pressed", [button.text])  # 將按鈕文字作為參數傳遞	

func _on_button_pressed(button_text):
	Day.text = button_text
	var selected_day = int(button_text)
	var filtered_records = []

	# 檢查 GlobalVar.login_record 是否存在且有資料
	if GlobalVar.login_record != null and GlobalVar.login_record.has("data"):
		var login_record = GlobalVar.login_record["data"]
		for record in login_record:
			if record.has("offline_time") and record["offline_time"] != null:
				var login_time = record["login_time"]
				var date_parts = login_time.split("T")[0].split("-")
				var year = int(date_parts[0])
				var month = int(date_parts[1])
				var day = int(date_parts[2])

				# 檢查是否是指定的月份（10 月）且日期符合按鈕文字
				if month == 2 and day == selected_day:
					# 格式化時間範圍
					var time_start = record["login_time"].split("T")[1].substr(0, 5)  # 抓取登入時間的 HH:MM
					var time_end = record["offline_time"].split("T")[1].substr(0, 5)  # 抓取登出時間的 HH:MM

					# 獲取答題數 (play)
					var play = str(record["questions_answered"])
					if play.length() < 2:
						play = "0" + play  # 補 0

					# 獲取分數 (score)
					var score = record["average_score"]
					if score == null:
						score = "N/A"
					else:
						score = String("%.2f" % score.to_float())

					# 將資料添加至 filtered_records
					filtered_records.append({
						"time_start": time_start,
						"time_end": time_end,
						"play": play,
						"score": score
					})
	else:
		print("沒有可用的登入紀錄")

	login_scroll.set_login_day_data(filtered_records)

	# 顯示 WindowDialog
	LoginDay.popup_centered()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_personal_pressed():
	get_tree().change_scene("res://scene/1.4.1.tscn")

func _on_record_pressed():
	get_tree().change_scene("res://scene/1.4.2.tscn")

func _on_cross_pressed():
	get_tree().change_scene("res://scene/MainPage.tscn")

func _on_cross2_pressed():
	LoginDay.hide()

func _on_last_pressed():
	get_tree().change_scene("res://scene/1.4.2_1.tscn")

func _on_next_pressed():
	get_tree().change_scene("res://scene/1.4.2_3.tscn")
