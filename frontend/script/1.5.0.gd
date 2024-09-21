extends Node2D

onready var content: Button = $bg/content
onready var wave1: Button = $bg/wave1
onready var wave2: Button = $bg/wave2
onready var wave3: Button = $bg/wave3
onready var score: Button = $bg/score
onready var http_request: HTTPRequest = $HTTPRequest

func _ready() -> void:
	var url = "http://140.119.19.145:5001/Article/get_random_article"
	
	# 建立 POST 請求的資料
	var data = {
		"article_id": 30,
		"answer": 20,
	}
	
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	# 發送HTTP GET請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

func _on_content_pressed():
	get_tree().change_scene("res://scene/AnsRecord.0.tscn")

func _on_wave1_pressed():
	get_tree().change_scene("res://scene/AnsRecord.1.tscn")

func _on_wave2_pressed():
	get_tree().change_scene("res://scene/AnsRecord.2.tscn")

func _on_wave3_pressed():
	get_tree().change_scene("res://scene/AnsRecord.3.tscn")

func _on_cross_pressed():
	get_tree().change_scene("res://scene/1.4.0.tscn")

func _on_score_pressed():
	get_tree().change_scene("res://scene/AnsRecord.4.tscn")



func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	#print(json.result[0].article_content)
	$bg/content2.text = json.result[0].article_content
