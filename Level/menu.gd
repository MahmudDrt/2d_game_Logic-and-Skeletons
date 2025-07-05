extends Node2D

@onready var audio = $AudioStreamPlayer
@onready var settings_panel = $SettingsPanel
@onready var volume_slider = $SettingsPanel/VBoxContainer/HBoxContainer/MusicVolumeSlider
@onready var fullscreen_check = $SettingsPanel/VBoxContainer/FullscreenCheck
@onready var main_buttons = $MainButtons
@onready var credits_panel = $CreditsPanel

func _ready() -> void:
	settings_panel.visible = false
	credits_panel.visible = false
	volume_slider.value = audio.volume_db

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/level1.tscn")

func _on_settings_pressed() -> void:
	settings_panel.visible = true
	main_buttons.visible = false

func _on_back_button_pressed() -> void:
	settings_panel.visible = false
	credits_panel.visible = false
	main_buttons.visible = true

func _on_fullscreen_check_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 648))

func _on_credits_pressed() -> void:
	credits_panel.visible = true
	main_buttons.visible = false
