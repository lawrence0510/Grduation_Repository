extends VBoxContainer

func set_text(input: String, response:String):
	$InputHistory.text = "User:  " + input
	$Response.text = response
