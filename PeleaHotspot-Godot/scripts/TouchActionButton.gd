extends Button
## Botón táctil multitáctil. Mantiene la acción de Input mientras haya un dedo encima.

@export var input_action := ""
var touch_ids: Dictionary = {}

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
		# Permite probar la interfaz táctil con ratón desde el editor.
		if event.pressed:
			Input.action_press(input_action)
		else:
			Input.action_release(input_action)

func _exit_tree() -> void:
	if not input_action.is_empty():
		Input.action_release(input_action)
