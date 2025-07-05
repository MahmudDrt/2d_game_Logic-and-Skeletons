extends Area2D

@onready var audio = $AudioStreamPlayer2D  # Ссылка на аудиоплеер в дочернем узле

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		# Проигрываем звук сбора
		if audio.is_inside_tree() and audio.stream:
			audio.play()

		# Анимация: подлет вверх
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", position - Vector2(0, 25), 0.3)

		# Анимация: исчезновение
		tween.tween_property(self, "modulate:a", 0.0, 0.3)

		# Удаление после анимации
		tween.tween_callback(queue_free)

		# Увеличить золото игрока
		if body.has_method("add_gold"):
			body.add_gold()
