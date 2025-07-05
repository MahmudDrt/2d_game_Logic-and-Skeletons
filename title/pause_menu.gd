extends Control

@onready var panel = $Panel
@onready var label = $Label
@onready var vbox = $VBoxContainer
@onready var continue_button = vbox.get_node("Continue")
@onready var retry_button = vbox.get_node("Restart")
@onready var menu_button = vbox.get_node("Menu")
@onready var pause_button = $PauseButton

func _ready() -> void:
	hide_menu()

	continue_button.pressed.connect(_on_continue_pressed)
	menu_button.pressed.connect(_on_main_menu_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)
	retry_button.pressed.connect(_on_retry_pressed)

func _input(event):
	if event.is_action_pressed("esc"):
		toggle_pause()

func toggle_pause():
	if get_tree().paused:
		resume_game()
	else:
		show_pause()

func show_pause():
	panel.visible = true
	label.visible = true
	vbox.visible = true
	pause_button.visible = false  # Скрываем кнопку паузы при открытии меню паузы
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func resume_game():
	hide_menu()
	get_tree().paused = false

func hide_menu():
	panel.visible = false
	label.visible = false
	vbox.visible = false
	pause_button.visible = true  # Показываем кнопку паузы при закрытии меню

func hide_pause_button():
	pause_button.visible = false

func _on_continue_pressed() -> void:
	resume_game()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Level/menu.tscn")

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_pause_button_pressed() -> void:
	toggle_pause()
