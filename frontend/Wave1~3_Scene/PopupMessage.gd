extends Control

onready var anim_player = $Animation

func show_popup_message():
	self.visible = true
	anim_player.play("Popup")
