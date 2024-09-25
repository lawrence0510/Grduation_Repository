extends Button

onready var white_school: Button = $"../white_school"

func _process(delta):
	if self.is_hovered() or white_school.is_hovered():
		white_school.show()
		self.hide()
		white_school.rect_pivot_offset = white_school.rect_size / 2
		# 放大 1.5 倍
		white_school.rect_scale = Vector2(1.2, 1.2)
	else:
		white_school.hide()
		self.show()

func _ready():
	pass  # 如有需要初始化的程式碼，可以在此處加入
