extends Node2D

onready var age_label = $BackgroundPicture/ageLabel
onready var birth_label = $BackgroundPicture/birthLabel
onready var school_label = $BackgroundPicture/schoolLabel
onready var phone_label = $BackgroundPicture/phoneLabel
onready var mail_label = $BackgroundPicture/mailLabel

onready var edit_birth = $BackgroundPicture/edit_birth_button
onready var edit_school = $BackgroundPicture/edit_school_button
onready var edit_phone = $BackgroundPicture/edit_phone_button

onready var birth: WindowDialog = $BackgroundPicture/birth
onready var school: WindowDialog = $BackgroundPicture/school
onready var phone: WindowDialog = $BackgroundPicture/phone

onready var B1 = $BackgroundPicture/BackgroundBoxPicture/B1
onready var B2 = $BackgroundPicture/BackgroundBoxPicture/B2
onready var B3 = $BackgroundPicture/BackgroundBoxPicture/B3
onready var B4 = $BackgroundPicture/BackgroundBoxPicture/B4
onready var G1 = $BackgroundPicture/BackgroundBoxPicture/G1
onready var G2 = $BackgroundPicture/BackgroundBoxPicture/G2
onready var G3 = $BackgroundPicture/BackgroundBoxPicture/G3
onready var G4 = $BackgroundPicture/BackgroundBoxPicture/G4

onready var character_name = $BackgroundPicture/Label

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
		
		var character_id = json.result.character_id
		if character_id == 1:
			B1.visible = true
			character_name.visible = true
			character_name.text = "Graves"
		if character_id == 2:
			B2.visible = true
			character_name.visible = true
			character_name.text = "Harry"
		if character_id == 3:
			B3.visible = true
			character_name.visible = true
			character_name.text = "Olaf"
		if character_id == 4:
			B4.visible = true
			character_name.visible = true
			character_name.text = "Garen"
		if character_id == 5:
			G1.visible = true
			character_name.visible = true
			character_name.text = "Esther"
		if character_id == 6:
			G2.visible = true
			character_name.visible = true
			character_name.text = "Lux"
		if character_id == 7:
			G3.visible = true
			character_name.visible = true
			character_name.text = "Xayah"
		if character_id == 8:
			G4.visible = true
			character_name.visible = true
			character_name.text = "Mikasa"
	else:
		print("Request failed with response code: ", response_code)

func _on_cross2_pressed():
	birth.hide()

func _on_cross3_pressed():
	school.hide()

func _on_cross4_pressed():
	phone.hide()
