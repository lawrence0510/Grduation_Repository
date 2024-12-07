extends Node2D

# 使用者輸入的欄位
onready var username_input: LineEdit = $bg/BackgroundPicture/BackgroundControl/UserNameLineEdit
onready var password_input: LineEdit = $bg/BackgroundPicture/BackgroundControl/PasswordLineEdit
onready var school_input: LineEdit = $bg/BackgroundPicture/BackgroundControl/SchoolLineEdit
onready var birthday_input: LineEdit = $bg/BackgroundPicture/BackgroundControl/BirthdayLineEdit
onready var mail_input: LineEdit = $bg/BackgroundPicture/BackgroundControl/MailLineEdit
onready var phone_input: LineEdit = $bg/BackgroundPicture/BackgroundControl/PhoneLineEdit

# HTTP 請求節點
onready var get_http_request: HTTPRequest = $HTTPRequest
onready var update_http_request: HTTPRequest = $HTTPRequest2

func _ready() -> void:
	# 如果有 GlobalVar.user_id，則加載資料
	if GlobalVar.user_id != null:
		var url = "http://nccumisreading.ddnsking.com:5001/User/get_user_from_id?user_id=" + str(GlobalVar.user_id)
		get_http_request.request(url, [], false, HTTPClient.METHOD_GET)

# 處理資料抓取請求完成
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var body_string = body.get_string_from_utf8()
		var response = JSON.parse(body_string)
		if response.error == OK:
			var user_data = response.result
			
			# 姓名和郵件必定有值，直接更新
			username_input.text = user_data.get("user_name", "")
			mail_input.text = user_data.get("user_email", "")

			# 處理 school，若為 null 則保持默認值
			var user_school = user_data.get("user_school", null)
			if user_school != null:
				school_input.text = user_school

			# 處理其他可能為空的字段
			var user_birthday = user_data.get("user_birthday", null)
			if user_birthday != null:
				birthday_input.text = user_birthday
			
			var user_phone = user_data.get("user_phone", null)
			if user_phone != null:
				phone_input.text = user_phone

			print("User data loaded successfully")
		else:
			print("Failed to parse user data")
	else:
		print("Failed to load user data, HTTP Code:", response_code)

# 更新資料到資料庫
func _on_enter_pressed():
	# 構建更新資料的 URL 和內容
	var url = "http://nccumisreading.ddnsking.com:5001/User/update_user"
	var user_name = username_input.get_text()
	var password = password_input.get_text()
	var school = school_input.get_text()
	var birthday = birthday_input.get_text()
	var mail = mail_input.get_text()
	var phone = phone_input.get_text()
	
	# 準備要發送的資料
	var data = {
		"user_id": GlobalVar.user_id,
		"user_name": user_name,
		"user_password": password,
		"user_school": school,
		"user_birthday": birthday,
		"user_email": mail,
		"user_phone": phone
	}
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	update_http_request.request(url, headers, false, HTTPClient.METHOD_POST, json_data)

# 處理資料更新請求完成
func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("User data updated successfully")
		get_tree().change_scene("res://scene/Choose.tscn")
	else:
		print("Failed to update user data, HTTP Code:", response_code)
		print("Response body:", body.get_string_from_utf8())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.window_fullscreen:
			get_tree().quit()
