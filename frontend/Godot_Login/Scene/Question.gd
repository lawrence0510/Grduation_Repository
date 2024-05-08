extends Control


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	var data = json.result
	#print(data.article_content)
	print(data.content)
	$NinePatchRect/VBoxContainer/Response.text = str(data.content)

func _on_Button2_button_up():
	var data = {
		"article_id": 1,
		"answer": $NinePatchRect/VBoxContainer/Answer.text,
	}
	$NinePatchRect/VBoxContainer/Response.text = "回復資料讀取中..."
	var query = JSON.print(data)
	var header = ["Content-Type: application/json"]
	$HTTPRequest.request("http://140.119.19.145:5001/OpenAI/get_rate_from_answers", header, true, HTTPClient.METHOD_POST, query)
	pass # Replace with function body.
