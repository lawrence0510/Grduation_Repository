extends Node
onready var http_request: HTTPRequest = $"../HTTPRequest"

func process_command(input: String):
	var url = "http://140.119.19.145:5001/OpenAI/follow_up_question"
	
	# 建立 POST 請求的資料
	var data = {
		"user_id": 2,
		#之後要改成下面的
		#"user_id": GlobalVar.user_id,
		"user_input": input,
	}
	# 將資料轉換為 JSON 格式
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, true, HTTPClient.METHOD_POST, json_data)
	print("in the request")


#func _on_HTTPRequest_request_completed(result, response_code, headers, body):
#	print("after request")
#	print(response_code)
#	if response_code == 200:
#		var json = JSON.parse(body.get_string_from_utf8())
#		print(json.result.message)
#		GlobalVar.aiResponse = json.result.message
#	else:
#		print("error")
