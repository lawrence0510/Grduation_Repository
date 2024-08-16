extends WindowDialog

onready var p_enter: Button = $"bg/birth/p_enter"

func _ready() -> void:
	pass

func _on_p_enter_pressed():
	self.hide()
