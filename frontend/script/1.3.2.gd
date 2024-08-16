extends Node2D

onready var verification_input: LineEdit = $BackgroundPicture/BackgroundControl/VerificationLineEdit
onready var next_button: Button = $BackgroundPicture/BackgroundControl/NextButton
onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	next_button.connect("pressed", self, "_on_next_pressed")
	http_request.connect("request_completed", self, "_on_HTTPRequest_request_completed")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_next_pressed():
	# 禁用按鈕以避免重複請求
	next_button.disabled = true
	
	# 獲取使用者輸入的驗證碼
	var verification_code = verification_input.get_text()
	
	var user_email = GlobalVar.user_email
	
	# 構建 API 的 URL，並附帶使用者 email 和驗證碼參數
	var url = "http://nccumisreading.ddnsking.com:5001/User/check_verification_code"
	var query = "?user_email=%s&verification_code=%s" % [user_email, verification_code]
	url += query
	
	http_request.request(url)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		get_tree().change_scene("res://scene/1.3.3.tscn")
	elif response_code == 400:
		show_error_message("驗證碼已過期，請重新請求一個新的驗證碼。")
	elif response_code == 401:
		show_error_message("驗證碼錯誤，請檢查並重新輸入。")
	elif response_code == 404:
		show_error_message("找不到該電子郵件地址，請檢查並重試。")
	else:
		show_error_message("發生未知錯誤，請稍後重試。")
	
	# 恢復按鈕
	next_button.disabled = false

func show_error_message(message: String) -> void:
	# 顯示錯誤訊息給使用者，例如透過一個標籤或彈出視窗
	var error_label = $BackgroundPicture/BackgroundControl/ErrorLabel
	error_label.text = message
	error_label.visible = true
