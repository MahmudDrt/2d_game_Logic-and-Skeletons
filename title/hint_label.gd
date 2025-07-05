extends Label

var hints = [
	"← / → или A / D — движение",
	"Пробел или W — прыжок",
	"ЛКМ или F — атака",
	"Соберите 10 монет",
	"Передвиньте ящик на нажимную плиту",
	"E — переключить",
	"Толкайте ящик, удерживая Ctrl — тяните"
]

func show_hint(index: int) -> void:
	if index >= 0 and index < hints.size():
		text = hints[index]
		show()
		$Timer.start()
	else:
		hide()

func _on_timer_timeout() -> void:
	hide()
