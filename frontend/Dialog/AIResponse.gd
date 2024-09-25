extends VBoxContainer

func set_text(input: String):
	$responseHistory.text = "AI助手 :  \n" + input


#func _on_responseHistory_resized():

	#while 
	#if $responseHistory.text.length() > 44:
	#	print($responseHistory.text)
	#	$responseHistory.text = $responseHistory.text.substr(0, 30) + "\n" + $responseHistory.text.substr(30, len($responseHistory.text))

