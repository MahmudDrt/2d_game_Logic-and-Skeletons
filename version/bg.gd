extends ParallaxBackground
var speed = 5

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	scroll_offset.x -= speed + delta
