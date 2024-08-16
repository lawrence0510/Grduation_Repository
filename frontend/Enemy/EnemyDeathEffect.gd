extends CPUParticles2D


func _ready() -> void:
	emitting = true
	

func _process(delta) -> void:
	if !emitting:
		queue_free()
