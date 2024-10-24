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


func _on_white_record_pressed():
	get_tree().change_scene("res://scene/1.4.3.tscn")

func _on_white_school_pressed():
	get_tree().change_scene("res://Scene/textbook_selection.tscn")

func _on_white_story_pressed():
	GlobalVar.current_category = 'story'
	get_tree().change_scene(("res://Wave1~3_Scene/Wave1.tscn"))

func _on_white_news_pressed():
	GlobalVar.current_category = 'news'
	get_tree().change_scene(("res://Wave1~3_Scene/Wave1.tscn"))

func _on_white_player_pressed():
	get_tree().change_scene("res://scene/1.4.1.tscn")

func _on_pk_hover_pressed():
	get_tree().change_scene("res://scene/Battle_0.tscn")
