extends Control

onready var http_request = $HTTPRequest
onready var B1 = $"bg/底色2/B1"
onready var B2 = $"bg/底色2/B2"
onready var B3 = $"bg/底色2/B3"
onready var B4 = $"bg/底色2/B4"
onready var G1 = $"bg/底色2/G1"
onready var G2 = $"bg/底色2/G2"
onready var G3 = $"bg/底色2/G3"
onready var G4 = $"bg/底色2/G4"

func _ready():
	http_request.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	pass # 其他初始化代碼

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_enter_pressed():
	var user_id = GlobalVar.user_id
	var character_id = 8

	if(B1).visible:
		character_id = 1
	if(B2).visible:
		character_id = 2
	if(B3).visible:
		character_id = 3
	if(B4).visible:
		character_id = 4
	if(G1).visible:
		character_id = 5
	if(G2).visible:
		character_id = 6
	if(G3).visible:
		character_id = 7
	if(G4).visible:
		character_id = 8
	
	print("character_id: " + str(character_id))
	
	# 構建 URL 和參數
	var url = "http://nccumisreading.ddnsking.com:5001/User/image_register?user_id=%d&character_id=%d" % [user_id, character_id]
	var headers = ["Content-Type: application/json"] 
	var body = "{}"

	http_request.request(url, headers, false, HTTPClient.METHOD_POST, body)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200 or response_code == 201:

		get_tree().change_scene("res://scene/SignIn.tscn")
	else:
		print("Error Code: %d" % response_code)

