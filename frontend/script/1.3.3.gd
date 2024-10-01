extends Node2D

# 獲取 UI 中的節點
onready var finish_button: Button = $BackgroundPicture/BackgroundControl/FinishButton
onready var password_lineedit: LineEdit = $BackgroundPicture/BackgroundControl/PasswordLineEdit
onready var http_request: HTTPRequest = $HTTPRequest
onready var error: Label = $BackgroundPicture/BackgroundControl/error

# 假設 user_email 從全局變數傳遞過來
var user_email: String = GlobalVar.user_email  # 全局變數中保存的使用者電子郵件

func _ready() -> void:
	http_request.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	finish_button.connect("pressed", self, "_on_finish_pressed")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if OS.window_fullscreen:
			get_tree().quit()

func _on_finish_pressed():
	# 獲取使用者輸入的新密碼
	var new_password = password_lineedit.get_text().strip_edges()

	# 定義 API 的 URL，並添加查詢參數
	var url = "http://nccumisreading.ddnsking.com:5001/User/reset_password" + "?user_email=" + user_email + "&new_password=" + new_password
	
	print("API URL: ", url)  # 打印 API URL 來確認是否正確

	# 設置適當的標頭
	var headers = ["accept: application/json"]

	# 發送 HTTP POST 請求
	var error_code = http_request.request(url, headers, false, HTTPClient.METHOD_POST)
	if error_code != OK:
		print("Failed to send request, error code: ", error_code)

# 處理 HTTP 請求的結果
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("HTTP Request Completed")
	print("Response Code: ", response_code)
	print("Response Body: ", body)

	if response_code == 200:
		print("Password reset successful.")
		get_tree().change_scene("res://scene/SignIn.tscn")
	else:
		print("Failed to reset password, response code: ", response_code)
		error.show()


func _on_Back_pressed():
	get_tree().change_scene("res://Scene/SignIn.tscn")
