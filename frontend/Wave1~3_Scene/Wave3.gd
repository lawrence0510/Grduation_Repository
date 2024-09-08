extends Node


onready var full_story_scene = $BattleBackground/FullStory
onready var pause_scene = $BattleBackground/PauseScene
onready var attack_animation
onready var line_edit = $BattleBackground/LineEdit
onready var http_request: HTTPRequest = $HTTPRequest
var enemy_death_effect = preload("res://Enemy/EnemyDeathEffect.tscn")
var health_bar = load("res://UserSystem/HealthBar.tscn").instance()


## 載入這個場景(Wave 3)後，馬上
func _ready() -> void:
	#拿題目
	var url = "http://140.119.19.145:5001/Article/get_random_unseen_article"
	
	# 建立 POST 請求的資料
	var data = {
		"user_id": GlobalVar.user_id,
		"article_category": "story",
	}
	
	var json_data = JSON.print(data)
	var headers = ["Content-Type: application/json"]
	# 發送HTTP GET請求
	http_request.request(url, headers, true, HTTPClient.METHOD_GET, json_data)
	
	
	$BattleBackground/Question.add_child(health_bar) ## 因為畫面前後的關係，所以把節點放在Question的底下
	health_bar.init_health_value(GlobalVar.global_player_health) ## 設定玩家血量
	full_story_scene.set_visible(false) ## 隱藏全文
	pause_scene.set_visible(false) ## 隱藏暫停場景 
	attack_animation = $BattleBackground/AttackAnimation
	attack_animation.animation = "DarkBolt" ## 之後要根據使用者的角色匯入不同攻擊特效
	attack_animation.visible = false ## 隱藏敵人死亡特效
	
	#設定題目
	$BattleBackground/Question.text = GlobalVar.question3[0]
	
## 查看全文button按下去
func _on_OpenStoryButton_pressed() -> void:
	full_story_scene.set_visible(true) ## 顯示全文


## 暫停button按下去
func _on_PauseButton_pressed() -> void:
	pause_scene.set_visible(true) ## 顯示暫停場景


## 玩家按下Enter送出答案
func _on_LineEdit_text_entered(new_text: String) -> void:
	if(true): ## 這裡的條件之後要改成"答案是否正確?"
		attack_animation.visible = true
		attack_animation.play()
		health_bar.damaged(30) ## 玩家扣血測試
	line_edit.editable = false


## 攻擊特效結束後 讓敵人消失
func _on_AttackAnimation_animation_finished() -> void:
	$BattleBackground/Question/Enemy.queue_free() ## 敵人消失
	var effect = enemy_death_effect.instance() ## 生成敵人死亡動畫
	get_tree().current_scene.add_child(effect) ## 播放敵人死亡動畫
	


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	print(json.result[0].article_content)
	full_story_scene.setStory(json.result[0].article_content)
