extends WindowDialog

onready var cross = $cross

func setStory(story: String):
	$RichTextLabel.bbcode_text = story

func _on_cross_pressed():
	self.hide()
	$ProgressBar.hide()

func set_cross_visible():
	cross.visible = true

func set_cross_hide():
	cross.hide()
