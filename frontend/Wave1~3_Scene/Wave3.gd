extends Node

onready var full_story_scene = $BattleBackground/WindowDialog
onready var pause_scene = $BattleBackground/PauseScene
onready var attack_animation
onready var line_edit = $BattleBackground/LineEdit
onready var http_request: HTTPRequest = $HTTPRequest
onready var http_request2: HTTPRequest = $HTTPRequest2
var enemy_death_effect = preload("res://Enemy/EnemyDeathEffect.tscn")
var health_bar = load("res://UserSystem/HealthBar.tscn").instance()
onready var enemy_image = $BattleBackground/Question/Enemy

## 載入這個場景(Wave 3)後，馬上
func _ready() -> void:
	full_story_scene.setStory(GlobalVar.story)
	enemy_image.texture = GlobalVar.images[2]
	$BattleBackground/Question.add_child(health_bar) ## 因為畫面前後的關係，所以把節點放在Question的底下
	health_bar.init_health_value(GlobalVar.global_player_health) ## 設定玩家血量
	full_story_scene.set_visible(false) ## 隱藏全文
	pause_scene.set_visible(false) ## 隱藏暫停場景 
	attack_animation = $BattleBackground/AttackAnimation
	attack_animation.animation = "DarkBolt" ## 之後要根據使用者的角色匯入不同攻擊特效
	attack_animation.visible = false ## 隱藏敵人死亡特效
	
	#設定題目
	$BattleBackground/Question.text = GlobalVar.question3["question3"]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

## 查看全文button按下去
func _on_OpenStoryButton_pressed() -> void:
	full_story_scene.set_visible(true) ## 顯示全文


## 暫停button按下去
func _on_PauseButton_pressed() -> void:
	pause_scene.set_visible(true) ## 顯示暫停場景


## 玩家按下Enter送出答案
func _on_LineEdit_text_entered(new_text: String) -> void:
	GlobalVar.wave_data["q3_user_answer"] = new_text  # 將玩家的答案儲存在 GlobalVar 中

	var article_id = GlobalVar.wave_data["article_id"]
	var answer = GlobalVar.wave_data["q3_user_answer"]
	
	# 發送 HTTP POST 請求
	send_post_request(article_id, answer)
	
	if(true): ## 這裡的條件之後要改成"答案是否正確?"
		attack_animation.visible = true
		attack_animation.play()
		line_edit.editable = false

# 發送POST請求的函數
func send_post_request(article_id: int, answer: String) -> void:
	var url = "http://nccumisreading.ddnsking.com:5001/OpenAI/get_rate_from_answers"
	
	# 準備資料，對article_id 和 answer 進行http_escape處理
	var query_string = "?article_id=" + str(article_id).http_escape() + "&answer=" + answer.http_escape()
	url += query_string
	
	# 準備HTTP headers
	var headers = ["accept: application/json", "Content-Type: application/json"]
	
	# 發送POST請求
	http_request.request(url, headers, true, HTTPClient.METHOD_POST, "{}")

var retry_count = 0
var max_retries = 3  # 最多重試次數

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var response_body = body.get_string_from_utf8()
		var json_result = JSON.parse(response_body)
		if json_result.error == OK:
			var rate_result = json_result.result
			
			# 將評分結果存入 GlobalVar.wave_data
			GlobalVar.wave_data["q3_aicomment"] = rate_result["總評"]
			GlobalVar.wave_data["q3_score_1"] = rate_result["語意得分"]
			GlobalVar.wave_data["q3_explanation1"] = rate_result["語意評分理由"]
			GlobalVar.wave_data["q3_score_2"] = rate_result["語用得分"]
			GlobalVar.wave_data["q3_explanation2"] = rate_result["語用評分理由"]
			GlobalVar.wave_data["q3_score_3"] = rate_result["語法得分"]
			GlobalVar.wave_data["q3_explanation3"] = rate_result["語法評分理由"]
			
			print("評分完畢: ", GlobalVar.wave_data)
			
			# 成功後，重置重試計數器並發送新的 API 請求保存到 History
			retry_count = 0
			send_history_post_request()
		else:
			print("無法解析 API 回應")
			handle_retry()  # 處理重試
	else:
		print("詢問OpenAI api時 HTTP 請求失敗，狀態碼: ", response_code)
		handle_retry()

# 處理重試邏輯的函數
func handle_retry() -> void:
	if retry_count < max_retries:
		retry_count += 1
		print("重試第 %d 次..." % retry_count)
		# 重新發送POST請求
		send_post_request(GlobalVar.wave_data["article_id"], GlobalVar.wave_data["q3_user_answer"])
	else:
		print("已達到最大重試次數，請求失敗。")
		retry_count = 0  # 重置重試計數器

# 發送保存 History 的POST請求
func send_history_post_request() -> void:
	var url = "http://nccumisreading.ddnsking.com:5001/History/record_new_history"

	# 準備資料，從 wave_data 中提取值
	var query_string = "?user_id=" + str(GlobalVar.wave_data["user_id"]).http_escape()
	query_string += "&article_id=" + str(GlobalVar.wave_data["article_id"]).http_escape()
	query_string += "&q1_user_answer=" + str(GlobalVar.wave_data["q1_user_answer"]).http_escape()
	query_string += "&q2_user_answer=" + str(GlobalVar.wave_data["q2_user_answer"]).http_escape()
	query_string += "&q3_user_answer=" + str(GlobalVar.wave_data["q3_user_answer"]).http_escape()
	query_string += "&q3_aicomment=" + str(GlobalVar.wave_data["q3_aicomment"]).http_escape()
	query_string += "&q3_score_1=" + str(GlobalVar.wave_data["q3_score_1"]).http_escape()
	query_string += "&q3_explanation1=" + str(GlobalVar.wave_data["q3_explanation1"]).http_escape()
	query_string += "&q3_score_2=" + str(GlobalVar.wave_data["q3_score_2"]).http_escape()
	query_string += "&q3_explanation2=" + str(GlobalVar.wave_data["q3_explanation2"]).http_escape()
	query_string += "&q3_score_3=" + str(GlobalVar.wave_data["q3_score_3"]).http_escape()
	query_string += "&q3_explanation3=" + str(GlobalVar.wave_data["q3_explanation3"]).http_escape()

	url += query_string

	# 發送第二個 POST 請求
	http_request2.request(url, [], true, HTTPClient.METHOD_POST, "{}")

## 攻擊特效結束後 讓敵人消失
func _on_AttackAnimation_animation_finished() -> void:
	$BattleBackground/Question/Enemy.queue_free() ## 敵人消失
	var effect = enemy_death_effect.instance() ## 生成敵人死亡動畫
	get_tree().current_scene.add_child(effect) ## 播放敵人死亡動畫

func _on_HTTPRequest2_request_completed(result, response_code, headers, body):
	if response_code == 201:
		var response_body = body.get_string_from_utf8()
		var json_result = JSON.parse(response_body)

		if json_result.error == OK:
			var history_id = json_result.result["history_id"]
			GlobalVar.history_id = history_id
			print("歷史紀錄已儲存，history_id: ", GlobalVar.history_id)
			get_tree().change_scene("res://Scene/AnswerAndDescription0.tscn")
		else:
			print("無法解析 API 回應")
	else:
		print("儲存歷史紀錄時 HTTP 請求失敗，狀態碼: ", response_code)
