extends Node

var time_to_change = 10.0  # 設置倒數計時為 5 秒
var target_scene_path = "res://Scene/Battle_1.tscn" # 目標場景 A 的路徑
onready var ready = $TextureRect/Label2/ready
onready var ing = $TextureRect/Label2/ing

func _ready():
	# 初始化，當場景準備好後開始計時
	set_process(true)

func _process(delta):
	# 每幀減少倒數時間
	time_to_change -= delta
	if time_to_change <= 0:
		change_scene()
	if 	time_to_change <= 3:
		ing.hide()
		ready.show()	
		
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func change_scene():
	# 加載並切換到目標場景
	get_tree().change_scene(target_scene_path)

func _on_cancel_pressed():
	get_tree().change_scene("res://Scene/MainPage.tscn")
