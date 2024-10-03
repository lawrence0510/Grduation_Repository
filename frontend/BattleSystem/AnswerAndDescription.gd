extends Control

func _ready() -> void:
	#問題1、回答1、結果分兩種（對的話，結果=回答正確恭喜你，錯的話，結果=回答錯誤！\n\n正確答案：正確選項+正確選項內文）
	var wave1 = "Wave1\n\n問題：\n%s\n\n您的回答：\n%s\n\n結果：\n%s"% [GlobalVar.question1["question1"], GlobalVar.question1["response"], GlobalVar.question1["consequence"]]
	var wave2 = ""
	var wave3 = ""
	var middle = "-------------------------------------------------------------------------------------------"
	$ScrollContainer/Label.text = wave1 + middle + wave2 + middle + wave3
func _on_AskButton_pressed() -> void:
	get_tree().change_scene("res://Scene/Dialog.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()


func _on_FinishButton_pressed():
	get_tree().change_scene("res://Scene/MainPage.tscn")
