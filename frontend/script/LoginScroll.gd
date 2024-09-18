extends ScrollContainer

# 這裡尋找名為 "VBox" 的 VBoxContainer 節點
onready var vbox = $VBoxContainer

# 定義包含多筆資料的列表
var data_list = [
	{"time_start": "18:30", "time_end": "19:30","correct": "9","play": "10", "score": "90%"},
	{"time_start": "12:45", "time_end": "20:30","correct": "1","play": "2", "score": "50%"},
	{"time_start": "18:30", "time_end": "19:30","correct": "9","play": "10", "score": "90%"}
]

func _ready():
	# 遍歷資料列表，生成每一行 Label
	for data in data_list:
		var correct = data["correct"]
		if correct.length() < 2:
			correct = "0" + correct
		
		var play = data["play"]
		if play.length() < 2:
			play = "0" + play
		var text = data["time_start"] + " ~ "+data["time_end"]+"             "+ correct +" / "+play + "                     " + data["score"]
		create_label_r(text)

func create_label_r(text):
	vbox.set("custom_constants/separation", 10)
	
	var new_label = Label.new()  # 建立新的 Label
	new_label.text = text  # 設定 Label 的文字
	
	# 設定字體樣式
	var custom_font = DynamicFont.new()  # 建立一個 DynamicFont
	var font_data = load("res://Fonts/NotoSansTC-VariableFont_wght.ttf")  # 使用正確的方式載入字體
	custom_font.font_data = font_data
	custom_font.size = 33  # 設定字體大小
	
	# 將字體應用到 Label
	new_label.add_font_override("font", custom_font)
	new_label.add_color_override("font_color", Color(0, 0, 0))  # 黑色
  
	
	vbox.add_child(new_label)  # 將 Label 加入 VBoxContainer
