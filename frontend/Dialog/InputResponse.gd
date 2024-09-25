extends VBoxContainer


#user輸入的位置
func set_text(input: String):
	$InputHistory.text = "冒險者 : \n" + input

