extends RigidBody2D

@export var push_strength := 20.0

func apply_push(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	apply_central_impulse(direction.normalized() * push_strength)
