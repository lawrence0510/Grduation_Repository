extends Node2D

onready var useremail_input: LineEdit = $BackgroundPicture/BackGroundControl/UserEmailLineEdit
onready var password_input: LineEdit = $BackgroundPicture/BackGroundControl/PasswordLineEdit

onready var google_button: Button = $BackgroundPicture/BackGroundControl/GoogleButton

onready var Failed: WindowDialog = $BackgroundPicture/Failed

onready var http_request: HTTPRequest = $HTTPRequest
onready var http_request2: HTTPRequest = $HTTPRequest2
onready var http_request3: HTTPRequest = $HTTPRequest3
onready var http_request4: HTTPRequest = $HTTPRequest4  # 新增的 HTTPRequest

# 新增檢測定時器
onready var check_timer: Timer = $Timer
var last_login_record_id: int = -1  # 用於記錄最新的 login_record_id
var initial_check_done: bool = false  # 用於確保初始檢測完成後再處理不同的 login_id
var max_user_id: int = -1  # 用於記錄最大 user_id

func _ready() -> void:
	OfflineUpdater.update_enabled = true

	# 確保定時器與檢測函數連接
	if not check_timer.is_connected("timeout", self, "_check_latest_login"):
		check_timer.connect("timeout", self, "_check_latest_login")
	check_timer.set_wait_time(1.0)  # 每秒檢測一次
	check_timer.set_one_shot(false)
	check_timer.start()  # 在遊戲啟動時立即啟動定時器檢測最新登入紀錄
	_check_max_user_id()

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

# Google登入按鈕
func _on_GoogleButton_pressed():
	var url = "http://nccumisreading.ddnsking.com:5001/User/google_login"
	OS.shell_open(url)  # 打開瀏覽器進行Google登入

# 定時檢測最新登入紀錄
func _check_latest_login():
	print("Checking latest login info...")
	var url = "http://nccumisreading.ddnsking.com:5001/User/latest_login_record"
	var headers = ["Content-Type: application/json"]
	http_request3.request(url, headers, false, HTTPClient.METHOD_GET)

# 處理最新LoginRecord的HTTP回應
func _on_HTTPRequest3_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var body_string = body.get_string_from_utf8()
		var response = JSON.parse(body_string)
		if response.error == OK:
			print(response.result)
			var login_record_id = response.result["login_id"]
			var user_id = response.result["user_id"]
			
			# 初次檢測完成，更新初始 login_id，不觸發登入
			if not initial_check_done:
				last_login_record_id = login_record_id
				initial_check_done = true
				print("初始檢測完成，記錄 ID:", last_login_record_id)
				return

			# 檢測是否有新紀錄
			if login_record_id != last_login_record_id:
				last_login_record_id = login_record_id
				GlobalVar.login_record_id = login_record_id
				GlobalVar.user_id = user_id
				
				print("成功登入，User ID:", user_id, "Login Record ID:", login_record_id)
				check_timer.stop()  # 停止定時器
				if GlobalVar.user_id > max_user_id:
					get_tree().change_scene("res://Scene/1.2.2.tscn")
				else:
					get_tree().change_scene("res://Scene/MainPage.tscn")
	else:
		print("檢測最新的登入紀錄失敗，HTTP狀態碼:", response_code)

# 檢測最大 user_id
func _check_max_user_id():
	var url = "http://nccumisreading.ddnsking.com:5001/User/get_max_user_id"
	var headers = ["Content-Type: application/json"]
	http_request4.request(url, headers, false, HTTPClient.METHOD_GET)

# 處理最大 user_id 的 HTTP 回應
func _on_HTTPRequest4_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var body_string = body.get_string_from_utf8()
		var response = JSON.parse(body_string)
		if response.error == OK:
			max_user_id = response.result["max_user_id"]
			print("Max User ID:", max_user_id)
		else:
			print("解析 JSON 失敗")
	else:
		print("獲取最大 User ID 失敗，HTTP狀態碼:", response_code)

# 處理錯誤窗口的關閉
func _on_OKButton_pressed():
	Failed.hide()
