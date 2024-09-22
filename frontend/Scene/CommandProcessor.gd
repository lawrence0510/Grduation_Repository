extends Node
onready var http_request: HTTPRequest = $"../HTTPRequest"

func process_command(input: String):
	var url = "http://nccumisreading.ddnsking.com:5001/Article/get_random_article"
	
	# 建立 POST 請求的資料
	var data = {
	}
	# 將資料轉換為 JSON 格式
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, false, HTTPClient.METHOD_GET, json_data)
	print("in the request")


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("after request")

	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		print(json.result[0].article_title)
		GlobalVar.aiResponse = json.result[0].article_title
	else:
		print("error")
