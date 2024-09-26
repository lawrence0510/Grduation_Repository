extends Node

onready var full_story_scene = $BattleBackground/FullStory
onready var pause_scene = $BattleBackground/PauseScene
onready var attack_animation
onready var http_request: HTTPRequest = $HTTPRequest
onready var http_request2: HTTPRequest = $HTTPRequest2
onready var enemy_image = $BattleBackground/Question/Enemy

var button_path_array = ["BattleBackground/Option_A", 
						 "BattleBackground/Option_B",
						 "BattleBackground/Option_C", 
						 "BattleBackground/Option_D"]
var enemy_death_effect = preload("res://Enemy/EnemyDeathEffect.tscn")
var health_bar = load("res://UserSystem/HealthBar.tscn").instance()
var button_pressed = ""
var right_button = ""
var enemy_images = []

## 載入這個場景(Wave 1)後，馬上
func _ready() -> void:
	# 發送請求拿取題目
	var url = "http://140.119.19.145:5001/Article/get_random_unseen_article"
	var data = {"user_id": GlobalVar.user_id, "article_category": "story"}
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	http_request.request(url, headers, true, HTTPClient.METHOD_GET, json_data)

	# 發送請求取得敵人的圖片，使用 http_request2
	var enemy_url = "http://nccumisreading.ddnsking.com:5001/Enemy/get_enemy_from_id"
	var random = RandomNumberGenerator.new()
	random.randomize()
	var category_id = str(random.randi_range(1, 200))  # 生成 1 到 200 的隨機數字作為 category
	print("category_id: " + str(category_id))
	http_request2.request(enemy_url + "?enemy_category=" + category_id)

	$BattleBackground/Question.add_child(health_bar)
	health_bar.init_health_value(health_bar.health_value)
	print(health_bar.health_value)
	full_story_scene.set_visible(true)
	pause_scene.set_visible(false)
	attack_animation = $BattleBackground/AttackAnimation
	attack_animation.animation = "DarkBolt"
	attack_animation.visible = false


## 查看全文 button 按下去
func _on_OpenStoryButton_pressed() -> void:
	full_story_scene.set_visible(true)

## 暫停 button 按下去
func _on_PauseButton_pressed() -> void:
	pause_scene.set_visible(true)

## 4個選項按下去
func _on_Option_A_pressed() -> void:
	button_pressed = "A"
	change_button_color("BattleBackground/Option_A")

func _on_Option_B_pressed() -> void:
	button_pressed = "B"
	change_button_color("BattleBackground/Option_B")

func _on_Option_C_pressed() -> void:
	button_pressed = "C"
	change_button_color("BattleBackground/Option_C")

func _on_Option_D_pressed() -> void:
	button_pressed = "D"
	change_button_color("BattleBackground/Option_D")

## 根據答案改成不同顏色
func change_button_color(button_path: String) -> void:
	var new_stylebox = get_node(button_path).get_stylebox("normal").duplicate()
	print(right_button)
	print(button_pressed)
	if right_button == button_pressed:
		new_stylebox.bg_color = Color(0.16, 0.64, 0.25)
		attack_animation.visible = true
		attack_animation.play()
		health_bar.damaged(30)
	else:
		new_stylebox.bg_color = Color(0.71, 0.15, 0.15)

	get_node(button_path).add_stylebox_override("hover", new_stylebox)
	get_node(button_path).add_stylebox_override("normal", new_stylebox)
	disable_other_buttons(button_path)
	$BattleBackground/ChangeLevelTimer.start()

## Timer倒數結束
func _on_ChangeLevelTimer_timeout() -> void:
	get_tree().change_scene("res://Wave1~3_Scene/Wave2.tscn")

## Disable其他button
func disable_other_buttons(button_path: String) -> void:
	match button_path:
		"BattleBackground/Option_A":
			button_path_array.remove(0)
		"BattleBackground/Option_B":
			button_path_array.remove(1)
		"BattleBackground/Option_C":
			button_path_array.remove(2)
		"BattleBackground/Option_D":
			button_path_array.remove(3)
	
	for button_path in button_path_array:
		get_node(button_path).disabled = true

## 攻擊特效結束後讓敵人消失
func _on_AttackAnimation_animation_finished() -> void:
	$BattleBackground/Question/Enemy.queue_free()
	var effect = enemy_death_effect.instance()
	get_tree().current_scene.add_child(effect)

## 處理問題的 HTTP response
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())

	if json.result[0].has("article_content"):
		# 處理文章和問題
		full_story_scene.setStory(json.result[0].article_content)
		GlobalVar.story = json.result[0].article_content
		$BattleBackground/Question.text = json.result[0].question_1
		$BattleBackground/Option_A.text = "A. " + json.result[0].question1_choice1
		$BattleBackground/Option_B.text = "B. " + json.result[0].question1_choice2
		$BattleBackground/Option_C.text = "C. " + json.result[0].question1_choice3
		$BattleBackground/Option_D.text = "D. " + json.result[0].question1_choice4

		var question1_answer = json.result[0].question1_answer
		if question1_answer == json.result[0].question1_choice1:
			right_button = "A"
		elif question1_answer == json.result[0].question1_choice2:
			right_button = "B"
		elif question1_answer == json.result[0].question1_choice3:
			right_button = "C"
		elif question1_answer == json.result[0].question1_choice4:
			right_button = "D"
		#先記錄wave2, 3的問題、答案
		GlobalVar.question2.append(json.result[0].question_2)
		GlobalVar.question2.append(json.result[0].question2_answer)
		GlobalVar.question2.append(json.result[0].question2_choice1)
		GlobalVar.question2.append(json.result[0].question2_choice2)
		GlobalVar.question2.append(json.result[0].question2_choice3)
		GlobalVar.question2.append(json.result[0].question2_choice4)
		
		GlobalVar.question3.append(json.result[0].question3)
	#	GlobalVar.question3.append(json.result[0].question3_answer)
	#	GlobalVar.question3.append(json.result[0].question3_choice1)
	#	GlobalVar.question3.append(json.result[0].question3_choice2)
	#	GlobalVar.question3.append(json.result[0].question3_choice3)
	#	GlobalVar.question3.append(json.result[0].question3_choice4)
		print(GlobalVar.question2)
		print(GlobalVar.question3)

## 處理敵人圖片的 HTTP response
func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	# 檢查 HTTP 回應碼是否為 200
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		for enemy_data in json.result:
			var base64_string = enemy_data.enemy_image
			var image_texture = decode_base64_image(base64_string)
			enemy_images.append(image_texture)
			print("appended")

			enemy_image.texture = enemy_images[0]  # 顯示第一張圖片
			GlobalVar.images = enemy_images  # 保存圖片到 GlobalVar 中
	else:
		# 如果回應碼不是 200，重新發送請求
		print("Response not 200, retrying...")
		request_enemy_image()


func request_enemy_image() -> void:
	var random = RandomNumberGenerator.new()
	random.randomize()
	var category_id = str(random.randi_range(1, 200))  # 生成 1 到 200 的隨機數字作為 category
	print("category_id: " + category_id)
	var enemy_url = "http://nccumisreading.ddnsking.com:5001/Enemy/get_enemy_from_id"
	http_request2.request(enemy_url + "?enemy_category=" + category_id)


## 將 Base64 字串解碼並轉換為 ImageTexture
func decode_base64_image(base64_string: String) -> ImageTexture:
	var image = Image.new()
	var byte_data = decode_base64(base64_string)
	var error = image.load_png_from_buffer(byte_data)

	if error == OK:
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		return texture
	else:
		return null

## 解碼 Base64 字串
func decode_base64(data: String) -> PoolByteArray:
	return Marshalls.base64_to_raw(data)
