extends Control

const InputResponse = preload("res://Dialog/InputResponse.tscn")
const Response = preload("res://Dialog/Response.tscn")
const AIResponse = preload("res://Dialog/AIResponse.tscn")

var max_scroll_length := 0

onready var command_processor = $CommandProcessor
onready var history_rows = $MarginContainer/VBoxContainer/textArea/MarginContainer/ScrollContainer/HistoryRows
onready var scroll = $MarginContainer/VBoxContainer/textArea/MarginContainer/ScrollContainer
onready var scrollbar = scroll.get_v_scrollbar()


func _ready():
	scrollbar.connect("changed", self, "handle_scrollbar_changed")
	max_scroll_length = scrollbar.max_value
	var starting_message = Response.instance()
	starting_message.text = "Hello challenger, if there's anything you want to ask me?"
	add_response_to_game(starting_message)

#追蹤新輸入文字，自動下拉對話視窗
func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll.scroll_vertical = max_scroll_length

func _on_Input_text_entered(new_text):
	if new_text.empty():
		return
	var input_response = InputResponse.instance()
	var ai_response = AIResponse.instance()
	input_response.set_text(new_text)
	add_response_to_game(input_response)
	#控制回復
	var ai_response_text = command_processor.process_command(new_text)
#	ai_response.set_text(ai_response_text)
#	add_response_to_game(ai_response)


func add_response_to_game(response: Control):
	history_rows.add_child(response)
