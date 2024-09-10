extends WindowDialog

onready var s_enter: Button = $s_enter
onready var school: LineEdit = $SchoolLineEdit
onready var http_request: HTTPRequest = $HTTPRequest  # 新增的 HTTPRequest 節點

# 當按鈕被按下時執行
func _on_b_enter_pressed():
	# 從 GlobalVar 取得 user_id，並從輸入框取得學校名稱
	var user_id = GlobalVar.user_id
	var new_school = school.text

	# 構建 HTTP 請求 URL
	var url = "http://nccumisreading.ddnsking.com:5001/User/reset_school?user_id=%d&new_school=%s" % [user_id, new_school]

	# 發送 HTTP 請求
	var err = http_request.request(url)
	
	if err != OK:
		print("Error sending HTTP request: ", err)
	else:
		print("HTTP request sent successfully")

	# 隱藏視窗
	self.hide()

# HTTPRequest 完成後的回調函數
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("School updated successfully!")
		# 更新完成後重新載入場景
		get_tree().reload_current_scene()
	else:
		print("Failed to update school. Response code: ", response_code)
