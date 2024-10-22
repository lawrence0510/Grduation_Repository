extends Node


onready var full_story_scene = $BattleBackground/WindowDialog
onready var pause_scene = $BattleBackground/PauseScene

onready var http_request: HTTPRequest = $HTTPRequest
onready var http_request2: HTTPRequest = $HTTPRequest2
onready var enemy_image = $BattleBackground/Question/Enemy
var attack_animation

var button_path_array = ["BattleBackground/Option_A", 
						 "BattleBackground/Option_B",
						 "BattleBackground/Option_C", 
						 "BattleBackground/Option_D"]
var enemy_death_effect = preload("res://Enemy/EnemyDeathEffect.tscn")
var health_bar = load("res://UserSystem/HealthBar.tscn").instance()
var button_pressed = ""
var right_button = ""
var enemy_images = []

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

## 載入這個場景(Wave 1)後，馬上
func _ready() -> void:
	#根據題目類別設定關卡背景
	change_category_background()
	
	#先隱藏所有攻擊特效
	$BattleBackground/BalrogAttackAnimation.visible = false
	$BattleBackground/DarkBoltAttackAnimation.visible = false
	$BattleBackground/BombAttackAnimation.visible = false
	$BattleBackground/AxeAttackAnimation.visible = false
	
	#拿題目
	var url = "http://140.119.19.145:5001/Article/get_random_unseen_article"
	
	# 建立 POST 請求的資料
	var data = {
		"user_id": GlobalVar.user_id,
		"article_category": GlobalVar.current_category,
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
	health_bar.init_health_value(100) ## 設定玩家血量
	print(health_bar.health_value)
	full_story_scene.set_visible(true) ## 顯示全文，第一關先讓玩家讀文章再作答
	pause_scene.set_visible(false) ## 隱藏暫停場景
	
#	attack_animation = $BattleBackground/BalrogAttackAnimation ## 之後要根據使用者的角色匯入不同攻擊特效

	#先讓用戶讀文章, 不給按叉叉
	full_story_scene.set_cross_hide()
	$BattleBackground/readTheStory.start() #等待三秒

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
	GlobalVar.question1["response"] = $BattleBackground/Option_A.text
	GlobalVar.wave_data["q1_user_answer"]=($BattleBackground/Option_A.text.substr(3, $BattleBackground/Option_A.text.length() - 3))
	change_button_color("BattleBackground/Option_A")

func _on_Option_B_pressed() -> void:
	button_pressed = "B"
	GlobalVar.question1["response"] = $BattleBackground/Option_B.text
	GlobalVar.wave_data["q1_user_answer"]=($BattleBackground/Option_B.text.substr(3, $BattleBackground/Option_B.text.length() - 3))
	change_button_color("BattleBackground/Option_B")

func _on_Option_C_pressed() -> void:
	button_pressed = "C"
	GlobalVar.question1["response"] = $BattleBackground/Option_C.text
	GlobalVar.wave_data["q1_user_answer"]=($BattleBackground/Option_C.text.substr(3, $BattleBackground/Option_C.text.length() - 3))
	change_button_color("BattleBackground/Option_C")

func _on_Option_D_pressed() -> void:
	button_pressed = "D"
	GlobalVar.question1["response"] = $BattleBackground/Option_D.text
	GlobalVar.wave_data["q1_user_answer"]=($BattleBackground/Option_D.text.substr(3, $BattleBackground/Option_D.text.length() - 3))
	change_button_color("BattleBackground/Option_D")
	

## 根據答案改成不同顏色
func change_button_color(button_path: String) -> void:
	var new_stylebox = get_node(button_path).get_stylebox("normal").duplicate() ## 複製StyleBox
	
	if(right_button == button_pressed):
		GlobalVar.question1["consequence"] = "回答正確，恭喜你！"
		disable_all_buttons()
		new_stylebox.bg_color = Color(0.16, 0.64, 0.25) ## 正確選項改成綠色
		change_attack_animation() ## 更改攻擊特效
		attack_animation.visible = true ## 顯示攻擊特效
		attack_animation.play() ## 播放攻擊特效

	else:
		disable_all_buttons()
		new_stylebox.bg_color = Color(0.71, 0.15, 0.15)
		health_bar.damaged(30) ## 玩家扣血測試
		GlobalVar.question1["consequence"] = "回答錯誤！\n\n正確答案：\n" + GlobalVar.question1["answer"]
	
	get_node(button_path).add_stylebox_override("disabled", new_stylebox) ## button變色
	get_node(button_path).add_stylebox_override("hover", new_stylebox) ## button變色
	get_node(button_path).add_stylebox_override("normal", new_stylebox) ## button變色
		
	$BattleBackground/ChangeLevelTimer.start() ## 開始倒數 準備到下一關


## Timer倒數結束
func _on_ChangeLevelTimer_timeout() -> void:
	Transition.change_scene("res://Wave1~3_Scene/Wave2.tscn") ## 跳到Wave 2
	print(GlobalVar.question1)



## Disable所有button 
## 防止玩家重複點選
func disable_all_buttons() -> void:
	for button_path in button_path_array:
		get_node(button_path).disabled = true


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())

	var story = json.result[0].article_content
	story = story.replace("\n", "\n\n")  # 在每個段落後添加一個空行

	GlobalVar.wave_data["user_id"] = (GlobalVar.user_id)
	GlobalVar.wave_data["article_id"] = (json.result[0].article_id)

	# 設定文章
	GlobalVar.story = story
	full_story_scene.setStory(story)  # 使用處理過的故事

	$BattleBackground/Question.text = json.result[0].question_1
	GlobalVar.question1["question1"] = json.result[0].question_1
	$BattleBackground/Option_A.text = "A. " + json.result[0].question1_choice1
	$BattleBackground/Option_A.adjust_text_size() # 縮放文字至符合button大小
	$BattleBackground/Option_B.text = "B. " + json.result[0].question1_choice2
	$BattleBackground/Option_B.adjust_text_size() # 縮放文字至符合button大小
	$BattleBackground/Option_C.text = "C. " + json.result[0].question1_choice3
	$BattleBackground/Option_C.adjust_text_size() # 縮放文字至符合button大小
	$BattleBackground/Option_D.text = "D. " + json.result[0].question1_choice4
	$BattleBackground/Option_D.adjust_text_size() # 縮放文字至符合button大小

	var question1_answer = json.result[0].question1_answer
	if question1_answer == json.result[0].question1_choice1:
		right_button = "A"
	elif question1_answer == json.result[0].question1_choice2:
		right_button = "B"
	elif question1_answer == json.result[0].question1_choice3:
		right_button = "C"
	elif question1_answer == json.result[0].question1_choice4:
		right_button = "D"

	GlobalVar.question1["answer"] = right_button + ". " + json.result[0].question1_answer

	GlobalVar.question2 = {
		"question2": json.result[0].question_2,
		"answer": json.result[0].question2_answer,
		"choice1": json.result[0].question2_choice1,
		"choice2": json.result[0].question2_choice2,
		"choice3": json.result[0].question2_choice3,
		"choice4": json.result[0].question2_choice4
	}

	GlobalVar.question3 = {
		"question3": json.result[0].question3,
		"question3_answer": json.result[0].question3_answer
	}

	
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


## 攻擊特效結束後 讓敵人消失
func _on_BalrogAttackAnimation_animation_finished() -> void:
	if $BattleBackground/Question/Enemy != null:
		print("Enemy exists, queuing free.")
		$BattleBackground/Question/Enemy.queue_free() ## 敵人消失
	else:
		print("Enemy node is null, cannot queue_free.")

	var effect = enemy_death_effect.instance() ## 生成敵人死亡動畫
	get_tree().current_scene.add_child(effect) ## 播放敵人死亡動畫


func _on_DarkBoltAttackAnimation_animation_finished() -> void:
	if $BattleBackground/Question/Enemy != null:
		print("Enemy exists, queuing free.")
		$BattleBackground/Question/Enemy.queue_free() ## 敵人消失
	else:
		print("Enemy node is null, cannot queue_free.")

	var effect = enemy_death_effect.instance() ## 生成敵人死亡動畫
	get_tree().current_scene.add_child(effect) ## 播放敵人死亡動畫


func _on_BombAttackAnimation_animation_finished() -> void:
	if $BattleBackground/Question/Enemy != null:
		print("Enemy exists, queuing free.")
		$BattleBackground/Question/Enemy.queue_free() ## 敵人消失
	else:
		print("Enemy node is null, cannot queue_free.")

	var effect = enemy_death_effect.instance() ## 生成敵人死亡動畫
	get_tree().current_scene.add_child(effect) ## 播放敵人死亡動畫


func _on_AxeAttackAnimation_animation_finished() -> void:
	if $BattleBackground/Question/Enemy != null:
		print("Enemy exists, queuing free.")
		$BattleBackground/Question/Enemy.queue_free() ## 敵人消失
	else:
		print("Enemy node is null, cannot queue_free.")

	var effect = enemy_death_effect.instance() ## 生成敵人死亡動畫
	get_tree().current_scene.add_child(effect) ## 播放敵人死亡動畫


#在時間倒數完之後才允許用戶關閉文章
func _on_readTheStory_timeout():
	full_story_scene.set_cross_visible()


func _on_Timer_timeout():
	$BattleBackground/WindowDialog/ProgressBar.value += 1

	
#根據不同題目類別更換背景
func change_category_background():
	if(GlobalVar.current_category == "Chinese"):
		$BattleBackground.texture = load("res://Textures/ChineseWave1.png")
	elif(GlobalVar.current_category == "Social"):
		$BattleBackground.texture = load("res://Textures/SocietyWave1.png")
	elif(GlobalVar.current_category == "Science"):
		$BattleBackground.texture = load("res://Textures/ScienceWave1.png")
	elif(GlobalVar.current_category == "story"):
		$BattleBackground.texture = load("res://Textures/StoryWave1.png")
	elif(GlobalVar.current_category == "news"):
		$BattleBackground.texture = load("res://Textures/NewsWave1.png")


#根據不同角色選擇攻擊特效
func change_attack_animation():
	print(GlobalVar.player_character_name)
	if(GlobalVar.player_character_name == "Graves" or GlobalVar.player_character_name == "Esther"):
		attack_animation = $BattleBackground/BalrogAttackAnimation
	elif(GlobalVar.player_character_name == "Harry" or GlobalVar.player_character_name == "Lux"):
		attack_animation = $BattleBackground/DarkBoltAttackAnimation
	elif(GlobalVar.player_character_name == "Olaf" or GlobalVar.player_character_name == "Xayah"):
		attack_animation = $BattleBackground/AxeAttackAnimation
	elif(GlobalVar.player_character_name == "Garen" or GlobalVar.player_character_name == "Mikasa"):
		attack_animation = $BattleBackground/BombAttackAnimation
	
	
