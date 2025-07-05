extends Control

@onready var panel = $Panel
@onready var label = $Label
@onready var vbox = $VBoxContainer
@onready var retry_button = vbox.get_node("Restart")
@onready var menu_button = vbox.get_node("Menu")

# Укажи путь к PauseMenu в твоей сцене
@onready var pause_menu = get_node("../PauseMenu")

func _ready():
	hide_menu()

	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_menu():
	self.visible = true
	pause_menu.hide_pause_button()  # Скрываем кнопку паузы при показе меню смерти
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

func hide_menu():
	self.visible = false

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Level/menu.tscn")
