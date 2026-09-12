extends Control

@onready var ip_input: LineEdit = %IPInput
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	NetworkManager.connection_succeeded.connect(_on_connected)
	NetworkManager.connection_failed.connect(_on_error)
	status_label.text = "Puerto LAN: %d. Conéctate a la IP Wi-Fi/hotspot del anfitrión." % NetworkManager.PORT

func _on_create_pressed() -> void:
	if NetworkManager.create_game():
		get_tree().change_scene_to_file("res://escenas/Juego.tscn")

func _on_join_pressed() -> void:
	if ip_input.text.strip_edges().is_empty():
		status_label.text = "Escribe la IP del anfitrión."
		return
	status_label.text = "Conectando a %s..." % ip_input.text
	NetworkManager.join_game(ip_input.text)

func _on_local_pressed() -> void:
	NetworkManager.start_local_game()
	get_tree().change_scene_to_file("res://escenas/Juego.tscn")

func _on_connected() -> void:
	get_tree().change_scene_to_file("res://escenas/Juego.tscn")

func _on_error(message: String) -> void:
	status_label.text = message

func _on_quit_pressed() -> void:
	get_tree().quit()
