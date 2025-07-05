extends CharacterBody2D

const JUMP_VELOCITY: float = -250.0
const BASE_SPEED   : float = 150.0
const CARRY_SPEED  : float = 100.0
const ATTACK_SPEED : float =  30.0

var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
var health  : int   = 100
var gold    : int   =   0
var alive   : bool  = true
var attacking                : bool = false
var is_jumping               : bool = false
var is_jumping_anim_played   : bool = false
var SPEED : float = BASE_SPEED
var game_completed : bool = false

@onready var anim_player : AnimationPlayer    = $AnimationPlayer
@onready var sprite      : Sprite2D           = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var attack_shape   : CollisionShape2D = $AttackArea/AttackShape
@onready var death_menu     : Control          = get_node("../../CanvasLayer/DeathMenu")

var door: Area2D = null
var grabbed_box: RigidBody2D = null
var joint: PinJoint2D = null

func _ready() -> void:
	anim_player.play("Idle")
	door = get_tree().get_current_scene().find_child("Door", true, false)
	if door == null:
		push_warning("⚠ Не удалось найти дверь!")
	attack_shape.disabled = true
	if not $AttackArea.is_connected("body_entered", Callable(self, "_on_attack_area_body_entered")):
		$AttackArea.connect("body_entered", Callable(self, "_on_attack_area_body_entered"))

func _physics_process(delta: float) -> void:
	if game_completed:
		return

	if not alive:
		move_and_slide()
		return

	if not is_on_floor():
		if is_jumping and Input.is_action_pressed("ui_accept") and velocity.y < 0:
			velocity.y += gravity * delta * 0.4
		else:
			velocity.y += gravity * delta
	else:
		is_jumping = false
		is_jumping_anim_played = false

	if grabbed_box != null and is_jumping:
		drop_box()

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and grabbed_box == null:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		is_jumping_anim_played = false

	if velocity.y < 0 and not attacking and not is_jumping_anim_played:
		anim_player.play("Jump")
		is_jumping_anim_played = true
	elif velocity.y > 0 and not attacking:
		anim_player.play("Fall")

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0.0:
		SPEED = CARRY_SPEED if grabbed_box != null else BASE_SPEED
		velocity.x = lerp(velocity.x, direction * SPEED, 0.2)
		update_facing(direction)
		if is_on_floor() and not attacking and velocity.y == 0:
			anim_player.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and not attacking and velocity.y == 0:
			anim_player.play("Idle")

	if Input.is_action_just_pressed("attack") and not attacking:
		start_attack()

	if health <= 0:
		death()

	check_box_interaction(delta)

	move_and_slide()

	if global_position.y > 650 and alive:
		apply_damage(9999)

func update_facing(direction: float) -> void:
	if grabbed_box:
		return
	var facing_left := direction < 0
	sprite.flip_h = facing_left
	var shape_pos := attack_shape.position
	shape_pos.x = abs(shape_pos.x) * (-1 if facing_left else 1)
	attack_shape.position = shape_pos

func start_attack() -> void:
	attacking = true
	SPEED = ATTACK_SPEED
	attack_shape.disabled = false
	anim_player.play("Attack")
	await anim_player.animation_finished
	attack_shape.disabled = true
	SPEED = BASE_SPEED
	attacking = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if attacking:
		if body.has_method("apply_damage"):
			body.apply_damage(10, self)

func apply_damage(amount: int, _source: Node2D = null) -> void:
	if not alive:
		return
	health = clamp(health - amount, 0, 100)
	if health <= 0:
		death()

func death() -> void:
	alive = false
	anim_player.play("Death")
	await anim_player.animation_finished
	queue_free()
	death_menu.show_menu()

func _on_door_body_entered(body: Node2D) -> void:
	if body == self and door != null and door.is_open:
		call_deferred("go_to_next_level")

var levels = [
	"res://Level/level1.tscn",
	"res://Level/level2.tscn",
	"res://Level/level3.tscn",
	"res://Level/level4.tscn",
	"res://Level/level5.tscn"
]

func go_to_next_level() -> void:
	var current = get_tree().current_scene.scene_file_path
	var index = levels.find(current)

	if index != -1 and index < levels.size() - 1:
		var next_scene = levels[index + 1]
		get_tree().change_scene_to_file(next_scene)
	else:
		show_complete_game_screen()

func show_complete_game_screen() -> void:
	game_completed = true
	set_physics_process(false)

	var complete_game_ui := get_tree().get_current_scene().find_child("CompleteGame", true, false)
	if complete_game_ui and complete_game_ui.has_method("on_game_complete"):
		complete_game_ui.on_game_complete()
	else:
		push_warning("⚠ Не удалось вызвать завершение игры!")

func add_gold() -> void:
	gold += 1
	if door != null and door.has_method("set_gold_collected"):
		door.set_gold_collected(gold >= 10)

func apply_knockback(from_position: Vector2) -> void:
	if not alive:
		return
	var direction = (global_position - from_position).normalized()
	velocity = direction * 500

func check_box_interaction(delta: float) -> void:
	if grabbed_box and not Input.is_action_pressed("pull"):
		drop_box()
		return

	var shape := collision_shape.shape
	if shape == null or grabbed_box:
		return

	var motion := velocity * delta
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = global_transform
	query.motion = motion
	query.margin = 0.1
	query.collision_mask = 1
	query.exclude = [self]

	for hit in get_world_2d().direct_space_state.intersect_shape(query):
		var rb := hit.collider as RigidBody2D
		if rb and rb.has_method("apply_push"):
			if Input.is_action_pressed("pull"):
				grab_box(rb)
			else:
				rb.apply_push(Vector2(velocity.x, 0).normalized())

func grab_box(box: RigidBody2D) -> void:
	if grabbed_box:
		return
	grabbed_box = box
	joint = PinJoint2D.new()
	joint.node_a = get_path()
	joint.node_b = box.get_path()
	joint.position = global_position
	get_parent().add_child(joint)

func drop_box() -> void:
	if joint:
		joint.queue_free()
	joint = null
	grabbed_box = null
