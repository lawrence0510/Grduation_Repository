extends Node2D

onready var username_input: LineEdit = $BackgroundPicture/BackGroundControl/UserNameLineEdit
onready var password_input: LineEdit = $BackgroundPicture/BackGroundControl/PasswordLineEdit

onready var google_button: Button = $BackgroundPicture/BackGroundControl/GoogleButton

onready var http_request: HTTPRequest = $HTTPRequest
onready var http_request2: HTTPRequest = $HTTPRequest2

func _ready() -> void:
	pass





func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

# 註冊ok
func _on_register_pressed():
	get_tree().change_scene("res://scene/1.2.1.tscn")

# 登入ok
func _on_enter_pressed():
	# 獲取使用者輸入的帳號與密碼
	var username = username_input.get_text()
	var password = password_input.get_text()
	
	var url = "http://nccumisreading.ddnsking.com:5001/User/normal_login"
	
	# 建立 POST 請求的資料
	var data = {
		"user_name": username,
		"user_password": password
	}
	
	# 將資料轉換為 JSON 格式
	var json_data = JSON.print(data)
	
	# 設置適當的標頭，表明我們正在發送 JSON 資料
	var headers = ["Content-Type: application/json"]

	# 發送HTTP POST請求
	http_request.request(url, headers, false, HTTPClient.METHOD_POST, json_data)

# 處理HTTP請求的結果
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("登入成功")
		# 成功登入後切換場景
		get_tree().change_scene("res://scene/1.4.0.tscn")
	else:
		print("登入失敗，請檢查使用者名稱與密碼")

# 忘記密碼
func _on_forget_pressed():
	get_tree().change_scene("res://scene/1.3.1.tscn")


func _on_google_pressed():
	print("Google login button pressed")
	var url = "http://nccumisreading.ddnsking.com:5001/User/google_login"
	var headers = ["Content-Type: application/json"]
	http_request2.request(url, headers, false, HTTPClient.METHOD_GET)



func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	if response_code == 302: 
		var redirect_url = headers.filter("Location")[0].split(": ")[1]
		OS.shell_open(redirect_url)
	elif response_code == 200:
		print("登入成功")
		get_tree().change_scene("res://scene/1.4.0.tscn")
	else:
		print("Google登入失敗")
