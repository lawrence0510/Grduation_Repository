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
	#拿題目
	var url = "http://140.119.19.145:5001/Article/get_random_unseen_article"
	
	# 建立 POST 請求的資料
	var data = {
#		"user_id": GlobalVar.user_id,
		"user_id": 15,
		"article_category": "story",
	}
	
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	# 發送HTTP GET請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET, json_data)
	
	var enemy_url = "http://nccumisreading.ddnsking.com:5001/Enemy/get_enemy_from_id"
	var random = RandomNumberGenerator.new()
	random.randomize()
	var category_id = str(random.randi_range(1, 200))  # 生成 1 到 200 的隨機數字作為 category
	print("category_id: " + str(category_id))
	http_request2.request(enemy_url + "?enemy_category=" + category_id)
	
	$BattleBackground/Question.add_child(health_bar) ## 因為畫面前後的關係，所以把節點放在Question的底下
	health_bar.init_health_value(health_bar.health_value) ## 設定玩家血量
	print(health_bar.health_value)
	full_story_scene.set_visible(true) ## 顯示全文，第一關先讓玩家讀文章再作答
	pause_scene.set_visible(false) ## 隱藏暫停場景
	attack_animation = $BattleBackground/AttackAnimation
	attack_animation.animation = "DarkBolt" ## 之後要根據使用者的角色匯入不同攻擊特效
	attack_animation.visible = false ## 隱藏敵人死亡特效
	

## 查看全文button按下去
func _on_OpenStoryButton_pressed() -> void:
	full_story_scene.set_visible(true) ## 顯示全文

## 暫停button按下去
func _on_PauseButton_pressed() -> void:
	pause_scene.set_visible(true) ## 顯示暫停場景
	
	
## 4個選項按下去
## 先複製StyleBox再用Override改顏色 才不會全部button都變色
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
	var new_stylebox = get_node(button_path).get_stylebox("normal").duplicate() ## 複製StyleBox
	
	if(right_button == button_pressed): ## 這裡的條件之後要改成"答案是否正確?"
		new_stylebox.bg_color = Color(0.16, 0.64, 0.25) ## 正確選項改成綠色
		attack_animation.visible = true ## 顯示攻擊特效
		attack_animation.play() ## 播放攻擊特效
		health_bar.damaged(30) ## 玩家扣血測試

	else:
		new_stylebox.bg_color = Color(0.71, 0.15, 0.15)
		
	get_node(button_path).add_stylebox_override("hover", new_stylebox) ## button變色
	get_node(button_path).add_stylebox_override("normal", new_stylebox) ## button變色
	disable_other_buttons(button_path)
		
	$BattleBackground/ChangeLevelTimer.start() ## 開始倒數 準備到下一關


## Timer倒數結束
func _on_ChangeLevelTimer_timeout() -> void:
	get_tree().change_scene("res://Wave1~3_Scene/Wave2.tscn") ## 跳到Wave 2


## Disable其他button 
## 防止玩家按到2個以上
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
	

## 攻擊特效結束後 讓敵人消失
func _on_AttackAnimation_animation_finished() -> void:
	$BattleBackground/Question/Enemy.queue_free() ## 敵人消失
	var effect = enemy_death_effect.instance() ## 生成敵人死亡動畫
	get_tree().current_scene.add_child(effect) ## 播放敵人死亡動畫


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())

	var story = json.result[0].article_content

	#設定文章
	GlobalVar.story = json.result[0].article_content
	
	#修改文章格式
	#跑過每個字元看有沒有句號
	var i = 0
	#用來記錄句號數量
	var pExist = 0
	#紀錄距離上一次換行過了幾個字元
	var distance = 0
	#設定左邊的留白
	story = story.insert(0, "      ")
	while story.length() > i:
		distance = distance + 1
		if story[i] == "。":
			pExist = pExist + 1
		
		#如果有三個句號，要換段落
		if pExist == 3:
			story = story.insert(i + 1, "\n\n      ||")
			pExist = 0
			distance = 0
		
		#經過了55個字元要換行
		if distance == 55:
			story = story.insert(i + 1, "\n      --")
			pExist = 0
			distance = 0
		i = i + 1
	
	print("字元數", i)
	

	full_story_scene.setStory(story)
	
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
func decode_base64(data: String) -> PoolByteArray:
	return Marshalls.base64_to_raw(data)
