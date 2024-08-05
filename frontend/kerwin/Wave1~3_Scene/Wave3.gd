extends Node


onready var full_story_scene = $BattleBackground/FullStory
onready var pause_scene = $BattleBackground/PauseScene
onready var attack_animation
onready var line_edit = $BattleBackground/LineEdit


## 載入這個場景(Wave 3)後，馬上
func _ready() -> void:
	full_story_scene.set_visible(false) ## 隱藏全文
	pause_scene.set_visible(false) ## 隱藏暫停場景 
	attack_animation = $BattleBackground/AttackAnimation
	attack_animation.animation = "DarkBolt" ## 之後要根據使用者的角色匯入不同攻擊特效
	attack_animation.visible = false
	
	
## 查看全文button按下去
func _on_OpenStoryButton_pressed() -> void:
	full_story_scene.set_visible(true) ## 顯示全文


## 暫停button按下去
func _on_PauseButton_pressed() -> void:
	pause_scene.set_visible(true) ## 顯示暫停場景


## 玩家按下Enter送出答案
func _on_LineEdit_text_entered(new_text: String) -> void:
	attack_animation.visible = true
	attack_animation.play()
	line_edit.editable = false
