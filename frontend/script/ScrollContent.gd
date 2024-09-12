extends ScrollContainer

# 這裡尋找名為 "VBox" 的 VBoxContainer 節點
onready var vbox = $VBoxContainer

# 變數
var data_list = [
	{"time": "09-01 10:30", "title": "這裡標題總共會有十二個字...", "score": "90"},
	{"time": "09-02 11:00", "title": "這裡標題總共會有十二個字...", "score": "91"},
	{"time": "09-03 11:30", "title": "這裡標題總共會有十二個字...", "score": "92"},
	{"time": "09-04 12:00", "title": "這裡標題總共會有十二個字...", "score": "93"},
	{"time": "09-05 12:30", "title": "這裡標題總共會有十二個字...", "score": "94"},
	{"time": "09-06 13:00", "title": "這裡標題總共會有十二個字...", "score": "95"},
	{"time": "09-07 13:30", "title": "這裡標題總共會有十二個字...", "score": "96"},
	{"time": "09-08 14:00", "title": "這裡標題總共會有十二個字...", "score": "97"},
	{"time": "09-09 14:30", "title": "這裡標題總共會有十二個字...", "score": "98"}
]

func _ready():
	# 假設我們想要動態生成 5 條 Label
	for data in data_list:
		var text = data["time"] + "              " + data["title"] + "              " + data["score"]
		create_label_r(text)
		
func create_label_r(text):
	vbox.set("custom_constants/separation", 10)
	
	var new_label = Label.new()  # 建立新的 Label
	new_label.text = text  # 設定 Label 的文字
	
	# 設定字體樣式
	var custom_font = DynamicFont.new()  # 建立一個 DynamicFont
	var font_data = DynamicFontData.new()  # 建立字體資料
	
	font_data.font_path = "res://Fonts/NotoSansTC-VariableFont_wght.ttf"
	custom_font.font_data = font_data
	custom_font.size = 45  # 設定字體大小
	custom_font.outline_size = 1
	custom_font.outline_color = Color(0, 0, 0)
	
	# 將字體應用到 Label
	new_label.add_font_override("font", custom_font)
	new_label.add_color_override("font_color", Color(0, 0, 0))  # 黑色
	
	 # 設定 Label 的位置，向右移動 100 單位
	new_label.rect_min_size = Vector2(200, 73)  # 設定 Label 的大小
	new_label.rect_position = Vector2(500, 100)  # 設定位置，X=100 讓它向右移動 100 單位

	vbox.add_child(new_label)  # 將 Label 加入 VBoxContainer



