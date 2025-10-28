extends Area2D


func _physics_process(_delta):
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			var dir = (body.global_position - global_position).normalized()
			body.apply_central_force(dir * 40)
