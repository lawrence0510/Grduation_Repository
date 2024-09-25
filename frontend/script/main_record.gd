extends Button

onready var white_record: Button = $"../white_record"

func _process(delta):
	if self.is_hovered() or white_record.is_hovered():
		white_record.show()
		self.hide()
		white_record.rect_pivot_offset = white_record.rect_size / 2
		# 放大 1.5 倍
		white_record.rect_scale = Vector2(1.2, 1.2)
	else:
		white_record.hide()
		self.show()

func _ready():
	pass  # 如有需要初始化的程式碼，可以在此處加入
