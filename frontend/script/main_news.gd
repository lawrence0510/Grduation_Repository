extends Button

onready var white_news: Button = $"../white_news"

func _process(delta):
	if self.is_hovered() or white_news.is_hovered():
		white_news.show()
		self.hide()
		white_news.rect_pivot_offset = white_news.rect_size / 2
		# 放大 1.5 倍
		white_news.rect_scale = Vector2(1.2, 1.2)
	else:
		white_news.hide()
		self.show()

func _ready():
	pass  # 如有需要初始化的程式碼，可以在此處加入
