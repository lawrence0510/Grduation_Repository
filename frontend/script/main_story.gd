extends Button

onready var white_story: Button = $"../white_story"

func _process(delta):
	if self.is_hovered() or white_story.is_hovered():
		white_story.show()
		self.hide()
		white_story.rect_pivot_offset = white_story.rect_size / 2
		# 放大 1.5 倍
		white_story.rect_scale = Vector2(1.2, 1.2)
	else:
		white_story.hide()
		self.show()

func _ready():
	pass  # 如有需要初始化的程式碼，可以在此處加入
