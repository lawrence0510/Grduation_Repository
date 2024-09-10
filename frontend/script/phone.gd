extends WindowDialog

onready var p_enter: Button = $p_enter
onready var phone: LineEdit = $PhoneLineEdit
onready var http_request: HTTPRequest = $HTTPRequest

# 當按鈕被按下時執行
func _on_p_enter_pressed():
	var user_id = GlobalVar.user_id
	var new_phone = phone.get_text()

	var url = "http://nccumisreading.ddnsking.com:5001/User/reset_phone"

	var data = {
		"user_id": user_id,
		"new_phone": new_phone
	}
	
	var json_data = JSON.print(data)

	var headers = ["Content-Type: application/json"]

	var err = http_request.request(url, headers, false, HTTPClient.METHOD_POST, json_data)
	
	if err != OK:
		print("Error sending HTTP request: ", err)
	else:
		print("HTTP request sent successfully")

	# 隱藏視窗
	self.hide()

# HTTPRequest 完成後的回調函數
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Phone updated successfully!")
		# 更新完成後重新載入場景
		get_tree().reload_current_scene()
	else:
		print("Update Phone Error Code: " + str(response_code))
		print("Failed to update phone. Response code: ", response_code)
