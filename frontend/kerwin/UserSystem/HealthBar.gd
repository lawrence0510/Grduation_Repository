extends ProgressBar


onready var timer = $Timer
onready var damage_bar = $DamageBar
	
	
var health = 0 setget _set_health


func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if health <= 0:
		pass ## 這裡之後要改成結束對戰

	if health < prev_health:
		timer.start()
		

## 初始化玩家血量
func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _on_Timer_timeout() -> void:
	damage_bar.value = health
