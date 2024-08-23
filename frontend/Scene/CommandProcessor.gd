extends Node
onready var http_request: HTTPRequest = $"../HTTPRequest"

func process_command(input: String):
	var url = "http://nccumisreading.ddnsking.com:5001/OpenAI/get_rate_from_answers"
	
	# 建立 POST 請求的資料
	var data = {
		"article_id": 30,
		"answer": input
	}
	
	# 將資料轉換為 JSON 格式
	var json_data = JSON.print(data)
	
	# 設置適當的標頭，表明我們正在發送 JSON 資料
	var headers = ["Content-Type: application/json"]

	# 發送HTTP POST請求
	http_request.request(url, headers, false, HTTPClient.METHOD_POST, json_data)

#	var words = input.split(" ", false)
#	if words.size() == 0:
#		return "ERRor: no words parsed"
#	
#	var first_word = words[0].to_lower()
#	var second_word = ""
#	if words.size() > 1:
#		second_word = words[1].to_lower()
#	
#	match first_word:
#		"go":
#			return go(second_word)
#		_:
#			return "Unreconginzed"

func go(second_word: String) -> String:
	if second_word == "":
		return "go where?"
	return "you go to %s" % second_word


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		print(json.result)
	else:
		print("error")
