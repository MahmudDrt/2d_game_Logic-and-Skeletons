extends Area2D

@export var target_door_path: NodePath
@onready var target_door = get_node("../../Decor/Door")
@onready var anim = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D

var is_pressed = false
var pressing_bodies: Array = []

func _ready() -> void:
	anim.play("Idle")

func _on_Button_body_entered(body: Node2D) -> void:
	if body.name == "Box":
		if body not in pressing_bodies:
			pressing_bodies.append(body)

		if not is_pressed:
			is_pressed = true
			if audio.is_inside_tree() and audio.stream:
				audio.play()
			anim.play("Press")
			if target_door and target_door.has_method("notify_button_pressed"):
				target_door.notify_button_pressed()

func _on_Button_body_exited(body: Node2D) -> void:
	if body.name == "Box":
		pressing_bodies.erase(body)

		if pressing_bodies.is_empty():
			is_pressed = false
			if audio.is_inside_tree() and audio.stream:
				audio.play()
			anim.play("Idle")
			if target_door and target_door.has_method("notify_button_released"):
				target_door.notify_button_released()
