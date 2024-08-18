extends Node2D

onready var username_input: LineEdit = $BackgroundPicture/BackgroundControl/UserNameLineEdit
onready var password_input: LineEdit = $BackgroundPicture/BackgroundControl/PasswordLineEdit
onready var school_input: LineEdit = $BackgroundPicture/BackgroundControl/SchoolLineEdit
onready var birthday_input: LineEdit = $BackgroundPicture/BackgroundControl/BirthdayLineEdit
onready var mail_input: LineEdit = $BackgroundPicture/BackgroundControl/MailLineEdit
onready var phone_input: LineEdit = $BackgroundPicture/BackgroundControl/PhoneLineEdit  # 修正拼寫錯誤

onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

# 註冊並進入遊戲
func _on_enter_pressed():
	# 獲取使用者輸入的資料
	var user_name = username_input.get_text()
	var password = password_input.get_text()
	var school = school_input.get_text()
	var birthday = birthday_input.get_text()
	var mail = mail_input.get_text()
	var phone = phone_input.get_text()

	# 構建API URL
	var url = "http://nccumisreading.ddnsking.com:5001/User/normal_register"
	
	# 建立 POST 請求的資料
	var data = {
		"user_name": user_name,
		"user_password": password,
		"user_school": school,
		"user_birthday": birthday,
		"user_email": mail,
		"user_phone": phone
	}
	
	# 將資料轉換為 JSON 格式
	var json_data = JSON.print(data)
	print(json_data)
	
	# 設置適當的標頭，表明我們正在發送 JSON 資料
	var headers = ["Content-Type: application/json"]

	# 發送HTTP POST請求
	http_request.request(url, headers, false, HTTPClient.METHOD_POST, json_data)

# 處理HTTP請求的結果
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 201:
		print("註冊成功")
		# 成功註冊後切換場景
		get_tree().change_scene("res://scene/1.2.3.tscn")
	else:
		print("註冊失敗，請檢查輸入資料")
		
#返回
func _on_back_pressed():
	get_tree().change_scene("res://scene/1.1.tscn")
