extends WindowDialog

onready var s_enter: Button = $s_enter

func _ready() -> void:
	pass

func _on_s_enter_pressed():
	self.hide()
