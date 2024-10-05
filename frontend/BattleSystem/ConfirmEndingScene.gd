extends ColorRect


## 取消button按下去
func _on_CancelButton_pressed() -> void:
	self.visible = false ## 隱藏確認離開的場景


func _on_ConfirmEndingButton_pressed():
	GlobalVar.global_player_health = 100 # 重置玩家血量
	get_tree().change_scene("res://Scene/MainPage.tscn")
