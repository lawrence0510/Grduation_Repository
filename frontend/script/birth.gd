extends WindowDialog

onready var b_enter: Button = $b_enter

func _ready() -> void:
	pass

func _on_b_enter_pressed():
	self.hide()
	
