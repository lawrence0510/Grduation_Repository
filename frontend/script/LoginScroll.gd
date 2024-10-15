extends ScrollContainer

# 這裡尋找名為 "VBox" 的 VBoxContainer 節點
onready var vbox = $VBoxContainer

# 定義一個空的資料列表
var data_list = []

func _ready():
	# 初始狀態不顯示任何資料
	# 按下日期按鈕後，會動態更新資料
	pass

# 用來更新 LoginDay 的資料
func set_login_day_data(new_data):
	for child in vbox.get_children():
		child.queue_free()
	
	data_list.clear()

	# 將新的資料加入 data_list
	for data in new_data:
		data_list.append(data)

	# 重新建立所有的 Label
	for data in data_list:
		var play = data["play"]
		var text = data["time_start"] + " ~ " + data["time_end"] + "                " + play + "                        " + data["score"]
		create_label_r(text)

# 創建 Label 並添加到 VBoxContainer
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
	new_label.add_color_override("font_color", Color(0, 0, 0))  # 設定字體顏色為黑色
  
	vbox.add_child(new_label)  # 將 Label 加入 VBoxContainer
