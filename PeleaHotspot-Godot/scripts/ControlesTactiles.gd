extends Control
## Los controles sólo se muestran en Android/iOS para no cubrir el juego en escritorio.

func _ready() -> void:
	visible = OS.has_feature("mobile")
