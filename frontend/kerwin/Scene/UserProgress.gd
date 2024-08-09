extends KinematicBody2D

var move = Vector2(3, 0)

func _physics_process(delta):
	var collision = move_and_collide(move)

