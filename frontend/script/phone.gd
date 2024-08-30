extends WindowDialog

onready var p_enter: Button = $p_enter

func _ready() -> void:
	pass

func _on_p_enter_pressed():
	self.hide()
