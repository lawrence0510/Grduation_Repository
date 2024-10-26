extends ProgressBar


onready var timer = $Timer
onready var damage_bar = $DamageBar
var health_value = 100


func init_health_value(health: int):
	value = health
	damage_bar.value = health
		
func damaged(damage: int):
	health_value = 0
	print(health_value)
	value = health_value
	timer.start()

func _on_Timer_timeout() ->void:
	print(health_value)
	damage_bar.value = health_value
