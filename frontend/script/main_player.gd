extends Button

onready var white_player: Button = $"../white_player"

# 當滑鼠進入按鈕時
func _on_Button_mouse_entered():
	white_player.show()
	self.hide()
	white_player.rect_pivot_offset = white_player.rect_size / 2
	# 放大 1.5 倍
	white_player.rect_scale = Vector2(1.2, 1.2)

# 當滑鼠離開按鈕時
func _on_Button_mouse_exited():
	# 恢復正常大小
	white_player.hide()
	self.show()

func _ready():
	# 連接滑鼠進入與離開事件
	connect("mouse_entered", self, "_on_Button_mouse_entered")
	connect("mouse_exited", self, "_on_Button_mouse_exited")