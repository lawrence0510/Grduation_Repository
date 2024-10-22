extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("123")
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result)
	var data = json.result
	_jumpToQuestion(data)
	pass # Replace with function body.

func _jumpToQuestion(data):
	if(data.message == "Login successful"):
		get_tree().change_scene("res://Scene/Question.tscn")

func _login():
	var data = {
		"user_name": $NinePatchRect/VBoxContainer/UserName.text,
		"user_password": $NinePatchRect/VBoxContainer/Password.text,
#		"user_school": $school.text,
#		"user_age": $age.text.to_int(),
#		"user_email": $email.text,
#		"user_phone": $phone.text
	}
	var query = JSON.print(data)
	var header = ["Content-Type: application/json"]
	$HTTPRequest.request("http://140.119.19.145:5001/User/login", header, true, HTTPClient.METHOD_POST, query)
	pass # Replace with function body.



func _goBackToStartPage():
	get_tree().change_scene("res://Scene/StartPage.tscn")
