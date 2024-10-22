extends Control

onready var play: Button = $bg/player
onready var record: Button = $bg/record
onready var story: Button = $bg/story
onready var news: Button = $bg/news
onready var school: Button = $bg/school
onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	var url = "http://nccumisreading.ddnsking.com:5001/User/get_user_from_id?user_id=" + str(GlobalVar.user_id)
	print("Request URL: " + url)
	
	var headers = ["Content-Type: application/json"]
	# 發送HTTP GET請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET)

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
	Transition.change_scene(("res://Wave1~3_Scene/Wave1.tscn"))

func _on_white_news_pressed():
	GlobalVar.current_category = 'news'
	Transition.change_scene(("res://Wave1~3_Scene/Wave1.tscn"))

func _on_white_player_pressed():
	get_tree().change_scene("res://scene/1.4.1.tscn")

func _on_pk_hover_pressed():
	get_tree().change_scene("res://scene/Battle_0.tscn")


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	# 解析回傳的 JSON 資料
	var json = JSON.parse(body.get_string_from_utf8())
	
	# 根據回傳的狀態碼進行處理
	if response_code == 200:
		
		var character_id = json.result.character_id
		if character_id == 1:
			GlobalVar.player_character_name = "Graves"
		if character_id == 2:
			GlobalVar.player_character_name = "Harry"
		if character_id == 3:
			GlobalVar.player_character_name = "Olaf"
		if character_id == 4:
			GlobalVar.player_character_name = "Garen"
		if character_id == 5:
			GlobalVar.player_character_name = "Esther"
		if character_id == 6:
			GlobalVar.player_character_name = "Lux"
		if character_id == 7:
			GlobalVar.player_character_name = "Xayah"
		if character_id == 8:
			GlobalVar.player_character_name = "Mikasa"
	else:
		print("Request failed with response code: ", response_code)
