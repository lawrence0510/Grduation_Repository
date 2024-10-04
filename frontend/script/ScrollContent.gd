extends ScrollContainer

# 這裡尋找名為 "VBox" 的 VBoxContainer 節點
onready var vbox = $VBoxContainer
onready var http_request = $HTTPRequest
onready var fixed_title_length = 20

# 變數
var data_list = []

func _ready():
	# 用user_id找尋對應的history資料
	var url = "http://nccumisreading.ddnsking.com:5001/History/get_history_from_user?user_id=" + str(GlobalVar.user_id) + "&article_category=" + GlobalVar.current_category
	print("Request URL: " + url)
	
	var headers = ["Content-Type: application/json"]
	# 發送HTTP GET請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("Response Code: ", response_code)

	# 檢查 HTTP 狀態碼
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		if json.error == OK:
			var response_data = json.result  # 解析回傳資料
			data_list.clear()  # 清空 data_list 以重新填入新資料
			if response_data.size() == 0:
				return

			for entry in response_data:
				# 處理每一筆資料
				var time = entry["time"].substr(5, 11)  # 只取 "MM-DD HH:MM" 部分
				var title = entry.get("article_title", "未知標題")  # 使用 article_title，如果無則顯示“未知標題”
				var id = entry["history_id"]
				
				# 處理標題：限制在13個中文字，超過則補「...」，少於則補空格
				var title_length = title.length()
				if title_length > 13:
					title = title.substr(0, 12) + "..."  # 截斷到11字並補上「...」
				
						
				var score = str(entry["total_score"])  # 抓取 total_score
				
				# 將資料加入 data_list
				data_list.append({
					"time": time,
					"title": title,
					"score": score,
					"id": id
				})
				
			# 刷新 UI，動態生成 Label
			for data in data_list:
				var text = "                                    " + data["title"]
				create_button_r(text, data["id"], data["score"], data["time"]) 
		else:
			print("Error parsing JSON: ", json.error_string)
	elif response_code == 404:
		var text = "在此類別中未找到任何作答紀錄"
		var id = 1
		create_label_r(text,id)
	else:
		print("Request failed with response code: ", response_code)


func create_button_r(text, id, score, time):
	vbox.set("custom_constants/separation", 10)
	
	var new_button = Button.new()  # 建立新的 Button
	new_button.text = text  # 設定 Button 的文字
	new_button.align = Button.ALIGN_LEFT
	
	# 設定字體樣式
	var custom_font = DynamicFont.new()  # 建立一個 DynamicFont
	var font_data = DynamicFontData.new()  # 建立字體資料
	
	font_data.font_path = "res://Fonts/NotoSansTC-VariableFont_wght.ttf"
	custom_font.font_data = font_data
	custom_font.size = 45  # 設定字體大小
	
	# 將字體應用到 Button
	new_button.add_font_override("font", custom_font)
	new_button.add_color_override("font_color", Color(0, 0, 0))  # 黑色
	new_button.add_color_override("font_color_hover", Color(0, 0, 205))
	new_button.add_color_override("font_color_disabled", Color(0, 0, 0))
	new_button.add_color_override("font_color_focus", Color(0, 0, 0))
	new_button.add_color_override("font_color_pressed", Color(0, 0, 205))
	
	# 設定按鈕的背景為透明並移除邊框
	new_button.add_stylebox_override("normal", preload("res://Fonts/record_line.tres"))
	new_button.add_stylebox_override("pressed", preload("res://Fonts/record_line.tres"))  
	new_button.add_stylebox_override("focus", preload("res://Fonts/record_line.tres"))  
	new_button.add_stylebox_override("disable", preload("res://Fonts/record_line.tres"))  
	new_button.add_stylebox_override("hover", preload("res://Fonts/record_line.tres"))

	# 設定 Button 的按下事件
	new_button.connect("pressed", self, "_on_button_pressed", [id])
	vbox.add_child(new_button)  # 將 Button 加入 VBoxContainer
	if(id == 0):
		new_button.disabled = true

	# 在 VBoxContainer2 中創建一個新的 Label 來顯示 score
	var new_score_label = Label.new()  # 建立新的 Label
	new_score_label.text = "                                                                                                          "+score  # 設定 Label 的文字
	new_score_label.align = Label.ALIGN_LEFT
	new_score_label.add_font_override("font", custom_font)  # 使用同樣的字體樣式
	new_score_label.add_color_override("font_color", Color(0, 0, 0))  # 黑色
	$VBoxContainer2.add_child(new_score_label)
	
	# 在 VBoxContainer3 中創建一個新的 Label 來顯示時間
	var new_time_label = Label.new()  # 建立新的 Label
	new_time_label.text = time  # 設定 Label 的文字
	new_time_label.align = Label.ALIGN_LEFT
	new_time_label.add_font_override("font", custom_font)  # 使用同樣的字體樣式
	new_time_label.add_color_override("font_color", Color(0, 0, 0))  # 黑色
	$VBoxContainer3.add_child(new_time_label)  # 將時間 Label 加入 VBoxContainer3

func create_label_r(text, id):
	vbox.set("custom_constants/separation", 10)
	
	var new_label = Label.new()  # 建立新的 Label
	new_label.text = text  # 設定 Label 的文字
	new_label.align = Label.ALIGN_LEFT
	
	# 設定字體樣式
	var custom_font = DynamicFont.new()  # 建立一個 DynamicFont
	var font_data = DynamicFontData.new()  # 建立字體資料
	
	font_data.font_path = "res://Fonts/NotoSansTC-VariableFont_wght.ttf"
	custom_font.font_data = font_data
	custom_font.size = 45  # 設定字體大小
	
	# 將字體應用到 Label
	new_label.add_font_override("font", custom_font)
	new_label.add_color_override("font_color", Color(0, 0, 0))  # 黑色
	new_label.add_color_override("font_color_disabled", Color(0, 0, 0))
	
	# 設定 Label 的背景為透明
	new_label.add_stylebox_override("normal", preload("res://Fonts/record_line.tres"))
	new_label.add_stylebox_override("disabled", preload("res://Fonts/record_line.tres"))

	# 將 Label 加入 VBoxContainer
	vbox.add_child(new_label)  # 將 Label 加入 VBoxContainer
	if(id == 0):
		new_label.disabled = true


# 按鈕被按下時的處理函數
func _on_button_pressed(text):
	GlobalVar.history_id = text
	print("History_id: " + str(GlobalVar.history_id))
	get_tree().change_scene("res://scene/AnsRecord.0.tscn")
