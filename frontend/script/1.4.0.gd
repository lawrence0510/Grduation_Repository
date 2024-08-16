extends Control

onready var play: Button = $bg/player
onready var record: Button = $bg/record
onready var story: Button = $bg/story
onready var news: Button = $bg/news
onready var school: Button = $bg/school

func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_player_pressed():
	get_tree().change_scene("res://scene/1.4.1.tscn")

func _on_record_pressed():
	get_tree().change_scene("res://scene/1.5.0.tscn")

func _on_story_pressed():
	pass # Replace with function body.


func _on_news_pressed():
	pass # Replace with function body.


func _on_school_pressed():
	pass # Replace with function body.
