extends Control

@onready var pause_menu = get_node("../PauseMenu")
@onready var restart_button := $VBoxContainer/Restart
@onready var menu_button := $VBoxContainer/Menu

func _ready() -> void:
	self.visible = false  # Изначально скрываем экран завершения игры

func on_game_complete() -> void:
	# Скрыть кнопку паузы, если она есть
	if pause_menu and pause_menu.has_method("hide_pause_button"):
		pause_menu.hide_pause_button()
	else:
		push_warning("⚠ Узел паузы не найден или не содержит метод hide_pause_button")

	# Ставим игру на паузу
	get_tree().paused = true

	# Показываем экран завершения игры
	self.visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false  # Снимаем паузу перед переходом
	get_tree().change_scene_to_file("res://Level/level1.tscn")

func _on_menu_pressed() -> void:
	get_tree().paused = false  # Снимаем паузу перед переходом
	get_tree().change_scene_to_file("res://Level/menu.tscn")
