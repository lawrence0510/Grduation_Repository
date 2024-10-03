extends Control

const InputResponse = preload("res://Dialog/InputResponse.tscn")
const Response = preload("res://Dialog/Response.tscn")
const AIResponse = preload("res://Dialog/AIResponse.tscn")

var max_scroll_length := 0

onready var command_processor = $CommandProcessor
onready var history_rows = $MarginContainer/VBoxContainer/textArea/MarginContainer/ScrollContainer/HistoryRows
onready var scroll = $MarginContainer/VBoxContainer/textArea/MarginContainer/ScrollContainer
onready var scrollbar = scroll.get_v_scrollbar()

#用以確認用戶是否已經輸入, 不能連續發問，要等到回復之後才能問下一句
var checkUserInput = 0

func _ready():
	scrollbar.connect("changed", self, "handle_scrollbar_changed")
	max_scroll_length = scrollbar.max_value
	var starting_message = Response.instance()
	starting_message.text = "冒險者您好, 關於這些問題有沒有什麼要問我的阿~"
	add_response_to_game(starting_message)
	
	#設定我等待ai回應時間
	#$Timer.wait_time = 0.5
	#只等一次
	#$Timer.one_shot = true

#追蹤新輸入文字，自動下拉對話視窗
func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll.scroll_vertical = max_scroll_length

func _on_Input_text_entered(new_text):
	if checkUserInput == 1:
		return
	if new_text.empty():
		return

	var input_response = InputResponse.instance()
	#每30個char去換行一次
	var index = 35
	if new_text.length() <= 35:
		new_text = new_text.insert(new_text.length(), "        ")
	else:
		while new_text.length() > index:
			new_text = new_text.insert(index, "        \n")
			
			#因為前面有增加空格, 所以index加的長度需要比index原本的長度再+6
			index  = index + 44
		new_text = new_text.insert(new_text.length(), "        ")
		
	input_response.set_text(new_text)
	add_response_to_game(input_response)
	checkUserInput = 1
	#控制回復
	var ai_response_text = command_processor.process_command(new_text)
	#$Timer.start()


func add_response_to_game(response: Control):
	history_rows.add_child(response)

#在等待兩秒之後, 把ai的回應設給ai_response這個node的文字, 再把那個node加到history_rows裡面
#func _on_Timer_timeout():
#	print("timeout")
#	var ai_response = AIResponse.instance()
#	ai_response.set_text(GlobalVar.aiResponse)
#	add_response_to_game(ai_response)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	checkUserInput = checkUserInput - 1
	print(response_code)
	if(response_code == 200):
		var json = JSON.parse(body.get_string_from_utf8())
		print(json.result.message)
		var ai_response = AIResponse.instance()
		
		#responseLength: 回傳內容的長度
		var responseLength = json.result.message.length()
		#response: 回傳內容
		var response = json.result.message
			
		#每40個char去換行一次
		var index = 40
		response = response.insert(0, "      ")
		
		while responseLength > index:
			response = response.insert(index, "\n      ")
			index  = index + 40

		ai_response.set_text(response)
		add_response_to_game(ai_response)
	else:
		print("error")
	


func _on_cross_pressed():
	get_tree().change_scene("res://Scene/AnswerAndDescription4.tscn")
