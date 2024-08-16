extends Node2D

# 獲取 UI 中的節點
onready var mail_input: LineEdit = $BackgroundPicture/BackgroundControl/MailLineEdit
onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

# 當按下 "下一步" 按鈕時
func _on_next_pressed():
	# 獲取使用者輸入的郵件地址
	var user_email = mail_input.get_text()
	
	# 保存 user_email 到全局變數中
	GlobalVar.user_email = user_email
	
	# 定義 API 的 URL
	var url = "http://nccumisreading.ddnsking.com:5001/User/send_verification_code"
	
	# 構建 POST 請求的資料
	var data = {
		"user_email": user_email
	}
	
	# 將資料轉換為 JSON 格式
	var json_data = JSON.print(data)
	
	# 設置適當的標頭，表明我們正在發送 JSON 資料
	var headers = ["Content-Type: application/json"]
	
	# 發送 HTTP POST 請求
	http_request.request(url, headers, false, HTTPClient.METHOD_POST, json_data)
	
	get_tree().change_scene("res://scene/1.3.2.tscn")
	
# 處理 HTTP 請求的結果
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	get_tree().change_scene("res://scene/1.3.2.tscn")
