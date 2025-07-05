extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var interaction_area = $Area2D

@export var platform_group_path: NodePath = "../../Platform"

var player_in_area = false
var is_on = false
var platform_group: Node = null

func _ready():
	animation_player.play("Idle")
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

	if has_node(platform_group_path):
		platform_group = get_node(platform_group_path)
		hide_all_platforms()
	else:
		push_warning("⚠ Не удалось найти группу платформ")
		platform_group = null

func _on_body_entered(body):
	if body.name == "Player":
		player_in_area = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_area = false

func _input(event):
	if player_in_area and event.is_action_pressed("interact"):
		toggle()

func toggle():
	is_on = !is_on
	if is_on:
		animation_player.play("On")
		show_all_platforms()
	else:
		animation_player.play("Off")
		hide_all_platforms()

func show_all_platforms():
	if not platform_group:
		return
	for platform in platform_group.get_children():
		var collider = platform.get_node_or_null("CollisionShape2D")
		var sprite = platform.get_node_or_null("Sprite2D")
		if collider:
			collider.disabled = false
		if sprite:
			sprite.visible = true

func hide_all_platforms():
	if not platform_group:
		return
	for platform in platform_group.get_children():
		var collider = platform.get_node_or_null("CollisionShape2D")
		var sprite = platform.get_node_or_null("Sprite2D")
		if collider:
			collider.disabled = true
		if sprite:
			sprite.visible = false
