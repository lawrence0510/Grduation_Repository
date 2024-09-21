extends Node2D

onready var age_label = $BackgroundPicture/BackgroundBoxPicture/ageLabel
onready var birth_label = $BackgroundPicture/BackgroundBoxPicture/birthLabel
onready var school_label = $BackgroundPicture/BackgroundBoxPicture/schoolLabel
onready var phone_label = $BackgroundPicture/BackgroundBoxPicture/phoneLabel
onready var mail_label = $BackgroundPicture/BackgroundBoxPicture/mailLabel

onready var edit_birth = $BackgroundPicture/edit_birth_button
onready var edit_school = $BackgroundPicture/edit_school_button
onready var edit_phone = $BackgroundPicture/edit_phone_button

onready var birth: WindowDialog = $BackgroundPicture/birth
onready var school: WindowDialog = $BackgroundPicture/school
onready var phone: WindowDialog = $BackgroundPicture/phone

onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	# 用user_id找尋對應的user資料
	var url = "http://nccumisreading.ddnsking.com:5001/User/get_user_from_id?user_id=" + str(GlobalVar.user_id)
	print("Request URL: " + url)
	
	var headers = ["Content-Type: application/json"]
	# 發送HTTP GET請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_personal_pressed():
	get_tree().change_scene("res://scene/1.4.1.tscn")

func _on_record_pressed():
	get_tree().change_scene("res://scene/1.4.2_9.tscn")

func _on_edit_birth_pressed():
	birth.popup_centered()

func _on_edit_school_pressed():
	school.popup_centered()

func _on_edit_phone_pressed():
	phone.popup_centered()

func _on_cross_pressed():
	get_tree().change_scene("res://scene/MainPage.tscn")


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	# 打印回傳的狀態碼
	print("Response Code: ", response_code)
	
	# 解析回傳的 JSON 資料
	var json = JSON.parse(body.get_string_from_utf8())
	
	# 打印解析出的 JSON 資料
	print(json)
	print(json.result)
	
	# 根據回傳的狀態碼進行處理
	if response_code == 200:
		if json.result.user_birthday != null:
			# 解析生日並計算年齡
			var user_birthday = json.result.user_birthday.split("-")
			var birth_year = int(user_birthday[0])
			var birth_month = int(user_birthday[1])
			var birth_day = int(user_birthday[2])
			
			# 取得目前的日期
			var current_date = OS.get_datetime()
			var current_year = current_date.year
			var current_month = current_date.month
			var current_day = current_date.day

			# 計算年齡
			var age = current_year - birth_year

			# 檢查今年的生日是否已過，如果還沒過則年齡要減一歲
			if current_month < birth_month or (current_month == birth_month and current_day < birth_day):
				age -= 1

			# 更新 UI
			age_label.text = str(age)
			birth_label.text = json.result.user_birthday
		else:
			age_label.text = "未提供生日"
			birth_label.text = "未提供生日"
		
		if json.result.user_school != null:
			school_label.text = json.result.user_school
		else:
			school_label.text = "未提供學校"
		
		if json.result.user_phone != null:
			phone_label.text = json.result.user_phone
		else:
			phone_label.text = "未提供電話"
		
		if json.result.user_email != null:
			mail_label.text = json.result.user_email
		else:
			mail_label.text = "未提供郵件"
	else:
		print("Request failed with response code: ", response_code)
