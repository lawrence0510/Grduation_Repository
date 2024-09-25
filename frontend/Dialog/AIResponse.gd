extends VBoxContainer

func set_text(input: String):
	$responseHistory.text = "AI助手 :  \n" + input


func _on_responseHistory_resized():
	var responseLength = $responseHistory.text.length()
	print("長度", responseLength)
	while responseLength > 30:
		responseLength - 30
		print("計算過的長度")
		print(responseLength)
	#while 
	#if $responseHistory.text.length() > 44:
	#	print($responseHistory.text)
	#	$responseHistory.text = $responseHistory.text.substr(0, 30) + "\n" + $responseHistory.text.substr(30, len($responseHistory.text))

