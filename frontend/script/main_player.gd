extends Button

onready var white_player: Button = $"../white_player"

func _process(delta):
	if self.is_hovered() or white_player.is_hovered():
		white_player.show()
		self.hide()
		white_player.rect_pivot_offset = white_player.rect_size / 2
		# 放大 1.5 倍
		white_player.rect_scale = Vector2(1.2, 1.2)
	else:
		white_player.hide()
		self.show()

func _ready():
	pass  # 如有需要初始化的程式碼，可以在此處加入
