extends ScrollContainer

# 這裡尋找名為 "VBox" 的 VBoxContainer 節點
onready var vbox = $VBoxContainer
onready var http_request = $HTTPRequest

# 變數
var data_list = []

func _ready():
	# 用user_id找尋對應的history資料
	var url = "http://nccumisreading.ddnsking.com:5001/History/get_history_from_user?user_id=" + str(2)
	print("Request URL: " + url)
	
	var headers = ["Content-Type: application/json"]
	# 發送HTTP GET請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("Response Code: ", response_code)
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error == OK:
		var response_data = json.result  # 解析回傳資料
		data_list.clear()  # 清空 data_list 以重新填入新資料
		for entry in response_data:
			# 抓取時間的月、日、時、分
			var time = entry["time"].substr(5, 11)  # 只取 "MM-DD HH:MM" 部分
			var title = entry.get("article_title", "未知標題")  # 使用 article_title，如果無則顯示“未知標題”
			
			# 處理標題：限制在12個中文字，超過則補「...」，少於則補空格
			var title_length = title.length()
			if title_length > 12:
				title = title.substr(0, 11) + "..."  # 截斷到11字並補上「...」
			elif title_length < 12:
				title = title.ljust(12)  # 如果不足12字，則補滿空格

			var score = str(entry["total_score"])  # 抓取 total_score
			
			# 將資料加入 data_list
			data_list.append({
				"time": time,
				"title": title,
				"score": score
			})
			
		# 刷新 UI，動態生成 Label
		for data in data_list:
			var text = data["time"] + "             " + data["title"] + "                  " + data["score"]
			create_button_r(text)
	else:
		print("Error parsing JSON: ", json.error_string)

func create_button_r(text):
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
	custom_font.outline_size = 1
	custom_font.outline_color = Color(0, 0, 0)
	
	# 將字體應用到 Button
	new_button.add_font_override("font", custom_font)
	new_button.add_color_override("font_color", Color(0, 0, 0))  # 黑色
	
	# 設定按鈕的背景為透明並移除邊框
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0)  # 完全透明的背景色
	style_box.border_width_top = 0
	style_box.border_width_bottom = 0
	style_box.border_width_left = 0
	style_box.border_width_right = 0
	new_button.add_style_override("normal", style_box)
	new_button.add_style_override("hover", style_box)
	new_button.add_style_override("pressed", style_box)
	
	# 設定 Button 的按下事件
	new_button.connect("pressed", self, "_on_button_pressed", [text])
	vbox.add_child(new_button)  # 將 Button 加入 VBoxContainer

# 按鈕被按下時的處理函數
func _on_button_pressed(text):
	print("Button pressed with text: " + text)
