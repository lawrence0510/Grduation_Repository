extends ProgressBar


onready var timer = $Timer
onready var damage_bar = $DamageBar
var health_value = GlobalVar.global_player_health


func init_health_value(health : int):
	value = health
	damage_bar.value = health

	
func damaged(damage : int):
	GlobalVar.global_player_health -= damage
	health_value = GlobalVar.global_player_health
	print(health_value)
	value = health_value
	timer.start()


func _on_Timer_timeout() -> void:
	print(health_value)
	damage_bar.value = health_value
