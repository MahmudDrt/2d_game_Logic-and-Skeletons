extends Area2D

@export var target_teleport: NodePath = "../TeleportB"
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var exit_point: Marker2D = $Marker2D
@onready var audio = $AudioStreamPlayer2D

var can_teleport = true

func _ready():
	visible = false           # изначально не видно
	monitoring = false        # не реагирует на вход
	sprite.play("Idle")

func activate_teleport():
	visible = true
	monitoring = true

func _on_body_entered(body: Node2D):
	if not can_teleport or body.name != "Player":
		return

	can_teleport = false

	if audio.is_inside_tree() and audio.stream:
		audio.play()

	sprite.play("teleport_out")
	await sprite.animation_finished

	var target_node = get_node(target_teleport)
	var target_exit = target_node.get_node("Marker2D")
	body.global_position = target_exit.global_position

	target_node.call_deferred("play_arrival_animation")
	sprite.play("Idle")

func play_arrival_animation():
	can_teleport = false
	sprite.play("teleport_in")
	await sprite.animation_finished
	sprite.play("Idle")
	can_teleport = true

func _on_body_exited(_body: Node2D):
	can_teleport = true
