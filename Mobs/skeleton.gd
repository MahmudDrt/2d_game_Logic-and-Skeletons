extends CharacterBody2D

var chase: bool = false
var alive: bool = true
var speed: float = 100
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var health: int = 50
var attacking: bool = false
var player_in_zone: CharacterBody2D = null
var knocked_back: bool = false

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var damage_timer: Timer = $Death2/DamageTimer
@onready var knockback_timer: Timer = $KnockbackTimer
@onready var progress_bar: ProgressBar = $HealthBar/ProgressBar
@onready var health_bar: Node2D = $HealthBar

func _ready():
	progress_bar.max_value = health
	progress_bar.value = health

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if alive and not knocked_back:
		var player: CharacterBody2D = $"../../Player/Player"
		if player:
			var direction: Vector2 = (player.global_position - global_position).normalized()

			if chase and not attacking:
				velocity.x = direction.x * speed
				if velocity.y == 0:
					anim.play("Run")
			else:
				velocity.x = 0
				if velocity.y == 0 and not attacking:
					anim.play("Idle")

			$Sprite2D.flip_h = direction.x < 0
			$Death2.scale.x = -1 if direction.x < 0 else 1

	move_and_slide()

	if global_position.y > 650 and alive:
		apply_damage(9999)

	# Обновляем позицию и значение полоски здоровья всегда
	health_bar.position = Vector2(0, 0)
	progress_bar.value = clamp(health, 0, progress_bar.max_value)

# Агрессия
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		chase = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		chase = false

# Зона урона ближнего боя
func _on_death_2_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = body
		attack_player()

func _on_death_2_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_zone = null
		damage_timer.stop()

func _on_DamageTimer_timeout() -> void:
	if player_in_zone and player_in_zone.alive:
		attack_player()
	else:
		damage_timer.stop()

func attack_player() -> void:
	if not alive or attacking or player_in_zone == null:
		return

	attacking = true
	anim.play("Attack")
	await anim.animation_finished

	if player_in_zone and player_in_zone.alive and $Death2.get_overlapping_bodies().has(player_in_zone):
		player_in_zone.apply_damage(25)
		player_in_zone.apply_knockback(global_position)
		damage_timer.start()
	else:
		damage_timer.stop()

	attacking = false

# Урон сверху (прыжок по врагу)
func _on_death_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.velocity.y = -300
		apply_damage(999, body)

# Получение урона
func apply_damage(amount: int, source: Node2D = null) -> void:
	if not alive:
		return

	health = clamp(health - amount, 0, 100)  # 100 — это максимум HP
	print("Скелет получил урон: ", amount, ", осталось HP: ", health)

	progress_bar.value = clamp(health, 0, progress_bar.max_value)  # Обновляем шкалу

	# Отталкивание от источника урона
	if source and source is Node2D:
		var knockback_dir := (global_position - source.global_position).normalized()
		velocity.x = knockback_dir.x * 75
		knocked_back = true
		knockback_timer.start()

	if health > 0:
		anim.play("Hit")
	else:
		death()

# Сброс отталкивания
func _on_KnockbackTimer_timeout() -> void:
	knocked_back = false

# Смерть
func death() -> void:
	if not alive:
		return

	alive = false
	damage_timer.stop()
	anim.play("Death")
	await anim.animation_finished
	queue_free()
