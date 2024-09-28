extends Button

onready var pk_hover: Button = $"../pk_hover"

func _process(delta):
	if self.is_hovered() or pk_hover.is_hovered():
		pk_hover.show()
		self.hide()
		pk_hover.rect_pivot_offset = pk_hover.rect_size / 2
		# 放大 1.5 倍
		pk_hover.rect_scale = Vector2(1.4, 1.4)
	else:
		pk_hover.hide()
		self.show()

func _ready():
	pass  # 如有需要初始化的程式碼，可以在此處加入
