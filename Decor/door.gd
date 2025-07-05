extends Area2D

@onready var anim = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D

var is_open: bool = false
var gold_collected: bool = false
var button_pressed: bool = false

func _ready() -> void:
	anim.play("Idle")

func set_gold_collected(collected: bool) -> void:
	gold_collected = collected
	try_open_door()

func notify_button_pressed() -> void:
	button_pressed = true
	try_open_door()

func notify_button_released() -> void:
	button_pressed = false
	try_close_door()

func try_open_door() -> void:
	if gold_collected and button_pressed and not is_open:
		is_open = true
		if audio.stream:
			audio.play()
		anim.play("Open")

func try_close_door() -> void:
	if is_open and (not gold_collected or not button_pressed):
		is_open = false
		if audio.is_inside_tree() and audio.stream:
			audio.play()
		anim.play("Idle")
