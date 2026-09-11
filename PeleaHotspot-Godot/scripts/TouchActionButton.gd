extends Button
## Botón táctil multitáctil con estilos y animación generados por código.

@export var input_action := ""
var touch_ids: Dictionary = {}

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	_add_style("normal", Color(0.08, 0.14, 0.25, 0.78), Color(0.48, 0.78, 1.0, 0.9))
	_add_style("hover", Color(0.12, 0.25, 0.42, 0.92), Color(0.82, 0.94, 1.0, 1.0))
	_add_style("pressed", Color(0.03, 0.07, 0.14, 0.96), Color(1.0, 0.82, 0.3, 1.0))
	button_down.connect(_animate_pressed.bind(true))
	button_up.connect(_animate_pressed.bind(false))

func _add_style(state: StringName, background: Color, border: Color) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(3)
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 6
	add_theme_stylebox_override(state, style)

func _animate_pressed(pressed: bool) -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(0.9, 0.9) if pressed else Vector2.ONE, 0.08)
	tween.parallel().tween_property(self, "modulate:a", 1.0 if pressed else 0.78, 0.08)

func _gui_input(event: InputEvent) -> void:
	if input_action.is_empty():
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_ids[event.index] = true
			Input.action_press(input_action)
		else:
			touch_ids.erase(event.index)
			if touch_ids.is_empty():
				Input.action_release(input_action)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Input.action_press(input_action)
		else:
			Input.action_release(input_action)

func _exit_tree() -> void:
	if not input_action.is_empty():
		Input.action_release(input_action)
