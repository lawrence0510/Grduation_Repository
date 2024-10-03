extends Node


onready var full_story_scene = $BattleBackground/FullStory
onready var pause_scene = $BattleBackground/PauseScene
onready var attack_animation
onready var line_edit = $BattleBackground/LineEdit
onready var http_request: HTTPRequest = $HTTPRequest
var enemy_death_effect = preload("res://Enemy/EnemyDeathEffect.tscn")
var health_bar = load("res://UserSystem/HealthBar.tscn").instance()
onready var enemy_image = $BattleBackground/Question/Enemy


## 載入這個場景(Wave 3)後，馬上
func _ready() -> void:
	enemy_image.texture = GlobalVar.images[2]
	full_story_scene.setStory(GlobalVar.story)
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
	GlobalVar.wave_data.append($BattleBackground/LineEdit.text)
	print(GlobalVar.wave_data)
	if(true): ## 這裡的條件之後要改成"答案是否正確?"
		attack_animation.visible = true
		attack_animation.play()
		$BattleBackground/ChangeLevelTimer.start()
#		health_bar.damaged(30) ## 玩家正確率太低時要扣血
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


func _on_ChangeLevelTimer_timeout() -> void:
	get_tree().change_scene("res://Scene/AnswerAndDescription4.tscn")
