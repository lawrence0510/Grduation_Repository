extends ColorRect


## 取消button按下去
func _on_CancelButton_pressed() -> void:
	self.visible = false ## 隱藏確認離開的場景
