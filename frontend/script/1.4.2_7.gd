extends Node2D

onready var button_r: Button = $"bg/框框/personal"
onready var button_l: Button = $"bg/框框/record"
onready var LoginDay: WindowDialog = $BackgroundPicture/LoginDay
onready var last: Button = $BackgroundPicture/last
onready var next: Button = $BackgroundPicture/next
onready var labels = [] # 用來存放日期label的列表
onready var Day: Label = LoginDay.get_node("TextureRect/Day")

func _ready() -> void:
	# 初始化30個Label節點，假設它們的命名是 label_1, label_2, ..., label_30
	for i in range(1, 32):
		var label = get_node("BackgroundPicture/DayPanel/" + str(i)) 
		labels.append(label)
	
	# 定義要變成按鈕的label號碼，假設是 3, 11 和 28
	var label_numbers = [7, 17, 27]
	
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

# 按鈕按下時觸發的函數
func _on_button_pressed(button_text):
	Day.text = button_text
	LoginDay.popup_centered()  # 顯示 WindowDialog

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
	get_tree().change_scene("res://scene/1.4.0.tscn")

func _on_cross2_pressed():
	LoginDay.hide()

func _on_last_pressed():
	get_tree().change_scene("res://scene/1.4.2_6.tscn")

func _on_next_pressed():
	get_tree().change_scene("res://scene/1.4.2_8.tscn")
