extends Area2D

@export var hint_index: int = 6

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var hint_label = get_node("/root/Level/CanvasLayer/HintLabel")
		hint_label.show_hint(hint_index)
