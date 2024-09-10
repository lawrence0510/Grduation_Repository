extends WindowDialog

onready var b_enter: Button = $b_enter
onready var year: LineEdit = $YearLineEdit
onready var month: LineEdit = $MonthLineEdit
onready var day: LineEdit = $DayLineEdit
onready var http_request: HTTPRequest = $HTTPRequest

func _on_b_enter_pressed():
	var user_id = GlobalVar.user_id
	var new_year = year.get_text()
	var new_month = month.get_text()
	var new_day = day.get_text()

	# 構建生日字串（API需要'YYYY-MM-DD'格式）
	var new_birthday = "%s-%02d-%02d" % [new_year, new_month.to_int(), new_day.to_int()]

	var url = "http://nccumisreading.ddnsking.com:5001/User/reset_birthday"

	var data = {
		"user_id": user_id,
		"new_birthday": new_birthday
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

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Birthday updated successfully!")
		# 更新完成後重新載入場景
		get_tree().reload_current_scene()
	else:
		print("Update Birthday Error Code: " + str(response_code))
		print("Failed to update birthday. Response code: ", response_code)
