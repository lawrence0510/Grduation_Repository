extends Control

const InputResponse = preload("res://Dialog/InputResponse.tscn")

var max_scroll_length := 0

onready var history_rows = $MarginContainer/VBoxContainer/textArea/MarginContainer/ScrollContainer/HistoryRows
onready var scroll = $MarginContainer/VBoxContainer/textArea/MarginContainer/ScrollContainer
onready var scrollbar = scroll.get_v_scrollbar()


func _ready():
	scrollbar.connect("changed", self, "handle_scrollbar_changed")
	max_scroll_length = scrollbar.max_value
	
func handle_scrollbar_changed():
	if max_scroll_length != scrollbar.max_value:
		max_scroll_length = scrollbar.max_value
		scroll.scroll_vertical = max_scroll_length


func _on_Input_text_entered(new_text):
	if new_text.empty():
		return
	var input_response = InputResponse.instance()
	input_response.set_text(new_text, "api_response_here")
	history_rows.add_child(input_response)
