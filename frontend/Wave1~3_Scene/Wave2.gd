extends Node


onready var full_story_scene = $BattleBackground/WindowDialog
onready var pause_scene = $BattleBackground/PauseScene
onready var attack_animation
onready var http_request: HTTPRequest = $HTTPRequest
onready var enemy_image = $BattleBackground/Question/Enemy

var button_path_array = ["BattleBackground/Option_A", 
						 "BattleBackground/Option_B",
						 "BattleBackground/Option_C", 
						 "BattleBackground/Option_D"]
var enemy_death_effect = preload("res://Enemy/EnemyDeathEffect.tscn")
var health_bar = load("res://UserSystem/HealthBar.tscn").instance()
var button_pressed = ""
var right_button = ""

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		# 如果遊戲當前是全螢幕模式，則退出全螢幕
		if OS.window_fullscreen:
			get_tree().quit()

## 載入這個場景(Wave 2)後，馬上
func _ready() -> void:	
	enemy_image.texture = GlobalVar.images[1]
	full_story_scene.setStory(GlobalVar.story)
	$BattleBackground/Question.add_child(health_bar) ## 因為畫面前後的關係，所以把節點放在Question的底下
	health_bar.init_health_value(GlobalVar.global_player_health) ## 設定玩家血量
	full_story_scene.set_visible(false) ## 隱藏全文
	pause_scene.set_visible(false) ## 隱藏暫停場景
	attack_animation = $BattleBackground/AttackAnimation
	attack_animation.animation = "DarkBolt" ## 之後要根據使用者的角色匯入不同攻擊特效
	attack_animation.visible = false ## 隱藏敵人死亡特效
	
	#設定問題、選項及答案
	$BattleBackground/Question.text = GlobalVar.question2["question2"]
	$BattleBackground/Option_A.text = "A. " + GlobalVar.question2["choice1"]
	$BattleBackground/Option_A.adjust_text_size() # 縮放文字至符合button大小
	$BattleBackground/Option_B.text = "B. " + GlobalVar.question2["choice2"]
	$BattleBackground/Option_B.adjust_text_size() # 縮放文字至符合button大小
	$BattleBackground/Option_C.text = "C. " + GlobalVar.question2["choice3"]
	$BattleBackground/Option_C.adjust_text_size() # 縮放文字至符合button大小
	$BattleBackground/Option_D.text = "D. " + GlobalVar.question2["choice4"]
	$BattleBackground/Option_D.adjust_text_size() # 縮放文字至符合button大小
	var question2_answer = GlobalVar.question2["answer"]

	if question2_answer == GlobalVar.question2["choice1"]:
		right_button = "A"
	elif question2_answer == GlobalVar.question2["choice2"]:
		right_button = "B"
	elif question2_answer == GlobalVar.question2["choice3"]:
		right_button = "C"
	elif question2_answer == GlobalVar.question2["choice4"]:
		right_button = "D"
	GlobalVar.question2["answer"] = right_button + ". " + question2_answer

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
	GlobalVar.question2["response"] = $BattleBackground/Option_A.text
	GlobalVar.wave_data["q2_user_answer"]=($BattleBackground/Option_A.text.substr(3, $BattleBackground/Option_A.text.length() - 3))
	change_button_color("BattleBackground/Option_A")

func _on_Option_B_pressed() -> void:
	button_pressed = "B"
	GlobalVar.question2["response"] = $BattleBackground/Option_B.text
	GlobalVar.wave_data["q2_user_answer"]=($BattleBackground/Option_B.text.substr(3, $BattleBackground/Option_B.text.length() - 3))
	change_button_color("BattleBackground/Option_B")

func _on_Option_C_pressed() -> void:
	button_pressed = "C"
	GlobalVar.question2["response"] = $BattleBackground/Option_C.text
	GlobalVar.wave_data["q2_user_answer"]=($BattleBackground/Option_C.text.substr(3, $BattleBackground/Option_C.text.length() - 3))
	change_button_color("BattleBackground/Option_C")

func _on_Option_D_pressed() -> void:
	button_pressed = "D"
	GlobalVar.question2["response"] = $BattleBackground/Option_D.text
	GlobalVar.wave_data["q2_user_answer"]=($BattleBackground/Option_D.text.substr(3, $BattleBackground/Option_D.text.length() - 3))
	change_button_color("BattleBackground/Option_D")


## 根據答案改成不同顏色
func change_button_color(button_path: String) -> void:
	var new_stylebox = get_node(button_path).get_stylebox("normal").duplicate() ## 複製StyleBox
	
	if(right_button == button_pressed):
		GlobalVar.question2["consequence"] = "回答正確，恭喜你！"
		new_stylebox.bg_color = Color(0.16, 0.64, 0.25)
		attack_animation.visible = true ## 顯示攻擊特效
		attack_animation.play() ## 播放攻擊特效

	else:
		new_stylebox.bg_color = Color(0.71, 0.15, 0.15)
		health_bar.damaged(30) ## 玩家扣血測試
		GlobalVar.question2["consequence"] = "回答錯誤！\n\n正確答案：\n" + GlobalVar.question2["answer"]
		
	get_node(button_path).add_stylebox_override("hover", new_stylebox) ## button變色
	get_node(button_path).add_stylebox_override("normal", new_stylebox) ## button變色
	disable_other_buttons(button_path)
	
	$BattleBackground/ChangeLevelTimer.start() ## 開始倒數 準備到下一關


## Timer倒數結束
func _on_ChangeLevelTimer_timeout() -> void:
	get_tree().change_scene("res://Wave1~3_Scene/Wave3.tscn") ## 跳到Wave 3


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
