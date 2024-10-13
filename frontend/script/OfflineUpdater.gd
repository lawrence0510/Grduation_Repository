# OfflineUpdater.gd
extends Node

onready var http_request: HTTPRequest = HTTPRequest.new()
var update_enabled = false  # 默認為禁用，登入後啟用

func _ready() -> void:
	# 將 HTTPRequest 添加到場景樹
	add_child(http_request)
	# 連接 request_completed 信號，以便處理請求完成後的邏輯
	http_request.connect("request_completed", self, "_on_HTTPRequest_request_completed")
	# 設置計時器，每 30 秒更新一次 offline_time
	var timer = Timer.new()
	timer.set_wait_time(3)  # 每5秒觸發一次
	timer.set_one_shot(false)  # 重複觸發
	add_child(timer)  # 將計時器添加到場景樹
	timer.connect("timeout", self, "_update_offline_time")  # 連接 timeout 信號
	timer.start()

func _update_offline_time() -> void:
	if not update_enabled:
		return  # 如果更新被禁用，跳過更新

	print("Updating offline time...")
	var current_time = OS.get_datetime()
	var offline_time = str(current_time.year) + "-" + str(current_time.month) + "-" + str(current_time.day) + " " + str(current_time.hour) + ":" + str(current_time.minute) + ":" + str(current_time.second)
	upload_offline_time(offline_time)

func upload_offline_time(time):
	var url = "http://nccumisreading.ddnsking.com:5001/User/update_offline"
	var data = {
		"login_id": GlobalVar.login_record_id,
		"offline_time": time
	}

	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	var err = http_request.request(url, headers, false, HTTPClient.METHOD_POST, json_data)

# 處理 HTTP 請求完成後的邏輯
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("HTTP request completed with response code:", response_code)
