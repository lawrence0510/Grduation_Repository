extends Node2D

onready var useremail_input: LineEdit = $BackgroundPicture/BackGroundControl/UserEmailLineEdit
onready var password_input: LineEdit = $BackgroundPicture/BackGroundControl/PasswordLineEdit

onready var google_button: Button = $BackgroundPicture/BackGroundControl/GoogleButton

onready var Failed: WindowDialog = $BackgroundPicture/Failed

onready var http_request: HTTPRequest = $HTTPRequest
onready var http_request2: HTTPRequest = $HTTPRequest2


func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			$BackgroundPicture/BackGroundControl/EnterButton.emit_signal("pressed")  # 觸發按鈕的按下信號

# 註冊ok
func _on_register_pressed():
	get_tree().change_scene("res://scene/Regist.tscn")

# 登入ok
func _on_enter_pressed():
	# 獲取使用者輸入的帳號與密碼
	var useremail = useremail_input.get_text()
	var password = password_input.get_text()
	
	var url = "http://nccumisreading.ddnsking.com:5001/User/normal_login"
	
	# 建立 POST 請求的資料
	var data = {
		"user_email": useremail,
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
		var body_string = body.get_string_from_utf8()
		print(body_string)
		var response = JSON.parse(body_string)
		if response.error == OK:
			var user_id = response.result["user_id"]
			GlobalVar.login_record_id = response.result["login_record_id"]
			
			# 將 user_id 存入 GlobalVar
			GlobalVar.user_id = user_id
			
			print("登入成功")
			# 成功登入後切換場景
			get_tree().change_scene("res://Scene/MainPage.tscn")
		else:
			print("解析 JSON 失敗")
	else:
		Failed.popup_centered()
		print("登入失敗，請檢查使用者名稱與密碼")

# 忘記密碼
func _on_forget_pressed():
	get_tree().change_scene("res://scene/Password.1.tscn")


func _on_GoogleButton_pressed():
	var url = "http://nccumisreading.ddnsking.com:5001/User/google_login"
	var headers = ["Content-Type: application/json"]
	http_request2.request(url, headers, false, HTTPClient.METHOD_GET)
	OS.shell_open(url)


func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	print('response_code: ' + str(response_code))
	if response_code == 302: 
		var redirect_url = headers.filter("Location")[0].split(": ")[1]
		OS.shell_open(redirect_url)
	elif response_code == 200:
		var body_string = body.get_string_from_utf8()
		print("================")
		#print(body_string)
		print("================")

		var response = JSON.parse(body_string)
		print(response)
		if response.error == OK:
			# 提取 user_id
			var user_id = response.result["user_id"]
			print("User ID: ", user_id)
			
			# 將 user_id 存入 GlobalVar
			GlobalVar.user_id = user_id
			
			print("登入成功")
			# 成功登入後切換場景
			get_tree().change_scene("res://scene/MainPage.tscn")
	else:
		print("Google登入失敗")

func _on_OKButton_pressed():
	Failed.hide()
