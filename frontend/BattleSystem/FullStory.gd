extends Control


## 關閉button按下去之後
func _on_CloseStoryButton_pressed() -> void:
	set_visible(false) ## 隱藏全文

func setStory(story: String):
	$RichTextLabel.text = story
