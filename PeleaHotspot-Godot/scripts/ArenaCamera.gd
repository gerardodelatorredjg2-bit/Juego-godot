extends Camera3D
## Mantiene toda la pista visible en cualquier relación de aspecto.

@export var arena_width := 24.0
@export var minimum_vertical_size := 15.0

func _ready() -> void:
	get_viewport().size_changed.connect(_fit_arena)
	_fit_arena()

func _fit_arena() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.y <= 0.0:
		return
	var aspect := viewport_size.x / viewport_size.y
	size = maxf(minimum_vertical_size, arena_width / aspect)
