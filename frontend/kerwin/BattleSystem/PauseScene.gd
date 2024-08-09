extends ColorRect


onready var confirm_ending_scene = $ConfirmEndingScene


## 載入這個場景(PauseScene)後，馬上
func _ready() -> void:
	confirm_ending_scene.set_visible(false) ## 隱藏確認離開的場景


## 繼續遊戲button按下去
func _on_ResumeButton_pressed() -> void:
	self.visible = false ## 隱藏暫停場景


## 結束遊戲button按下去
func _on_EndinglButton_pressed() -> void:
	confirm_ending_scene.set_visible(true) ## 顯示確認離開的場景

