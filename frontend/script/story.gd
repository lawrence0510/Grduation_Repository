extends WindowDialog

func setStory(story: String):
	$RichTextLabel.bbcode_text += story

func _on_cross_pressed():
	self.hide()
