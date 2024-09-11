extends ScrollContainer

# 這裡尋找名為 "VBox" 的 VBoxContainer 節點
onready var vbox = $VBoxContainer

func _ready():
	# 假設我們想要動態生成 10 條 Label
	for i in range(5):
		create_label("hello")

func create_label(text):
	var new_label = Label.new()  # 建立新的 Label
	new_label.text = text  # 設定 Label 的文字
	
	# 設定字體樣式
	var custom_font = DynamicFont.new()  # 建立一個 DynamicFont
	var font_data = DynamicFontData.new()  # 建立字體資料
	
	font_data.font_path = "res://Fonts/font911.tres"
	custom_font.font_data = font_data
	custom_font.size = 40  # 設定字體大小
	
	# 將字體應用到 Label
	new_label.add_font_override("font", custom_font)

	vbox.add_child(new_label)  # 將 Label 加入 VBoxContainer
