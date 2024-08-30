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
	get_tree().change_scene("res://scene/1.4.2.tscn")

func _on_edit_birth_pressed():
	birth_label.popup_centered()

func _on_edit_school_pressed():
	school_label.popup_centered()

func _on_edit_phone_pressed():
	phone_label.popup_centered()

func _on_cross_pressed():
	get_tree().change_scene("res://scene/1.4.0.tscn")


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
		# 檢查 user_birthday 是否為 null，並設定對應的文本
		if json.result.user_birthday != null:
			age_label.text = json.result.user_birthday
			birth_label.text = json.result.user_birthday
		else:
			age_label.text = "未提供生日"
			birth_label.text = "未提供生日"
		
		# 檢查 user_school 是否為 null，並設定對應的文本
		if json.result.user_school != null:
			school_label.text = json.result.user_school
		else:
			school_label.text = "未提供學校"
		
		# 檢查 user_phone 是否為 null，並設定對應的文本
		if json.result.user_phone != null:
			phone_label.text = json.result.user_phone
		else:
			phone_label.text = "未提供電話"
		
		# 檢查 user_email 是否為 null，並設定對應的文本
		if json.result.user_email != null:
			mail_label.text = json.result.user_email
		else:
			mail_label.text = "未提供郵件"
	else:
		print("Request failed with response code: ", response_code)
