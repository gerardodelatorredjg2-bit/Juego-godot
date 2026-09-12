extends Node3D
## Controla creación de luchadores, mejor de tres y final de partida.

const FIGHTER_SCENE := preload("res://escenas/Jugador.tscn")
var fighters: Dictionary = {}
var rounds_won := [0, 0]
var round_active := true

@onready var hud: Control = $UIJuego
@onready var announcement: Label = $UIJuego/Announcement
@onready var round_label: Label = $UIJuego/RoundLabel

func _ready() -> void:
	NetworkManager.player_disconnected.connect(_on_player_disconnected)
	if NetworkManager.local_mode:
		spawn_fighter(1)
		spawn_fighter(2)
	elif NetworkManager.is_host:
		spawn_fighter(1)
		# Si el cliente se conectó mientras el host mostraba su IP, ya está listo.
		if multiplayer.get_peers().has(2):
			spawn_fighter.rpc(2)
	else:
		# El cliente confirma que su escena ya existe antes de que el host lo cree.
		request_match_setup.rpc_id(1)
	_update_round_label()

@rpc("any_peer", "reliable")
func request_match_setup() -> void:
	if multiplayer.is_server():
		spawn_fighter.rpc(1)
		spawn_fighter.rpc(2)

@rpc("authority", "call_local", "reliable")
func spawn_fighter(number: int) -> void:
	if fighters.has(number):
		return
	var fighter := FIGHTER_SCENE.instantiate() as Fighter
	fighter.player_number = number
	fighter.body_color = Color("3b9cff") if number == 1 else Color("ef4b5d")
	fighter.position = Vector3(-4.0 if number == 1 else 4.0, 1.2, 0.0)
	fighter.local_offline = NetworkManager.local_mode
	fighter.add_to_group("fighter_%d" % number)
	fighter.health_changed.connect(_on_health_changed)
	fighter.knocked_out.connect(_on_knocked_out)
	$Fighters.add_child(fighter)
	fighters[number] = fighter
	_on_health_changed(number, fighter.health)

func _on_health_changed(number: int, health: int) -> void:
	var bar: ProgressBar = hud.get_node("HealthP%d" % number)
	bar.value = health
	bar.get_node("Value").text = "%d / 100" % health

func _on_knocked_out(loser: int) -> void:
	if NetworkManager.local_mode:
		finish_round(2 if loser == 1 else 1)
	elif multiplayer.is_server():
		finish_round.rpc(2 if loser == 1 else 1)

@rpc("authority", "call_local", "reliable")
func finish_round(winner: int) -> void:
	if not round_active:
		return
	round_active = false
	rounds_won[winner - 1] += 1
	_update_round_label()
	announcement.text = "¡Jugador %d gana la ronda!" % winner
	announcement.visible = true
	if rounds_won[winner - 1] >= 2:
		$UIJuego/EndPanel.visible = true
		$UIJuego/EndPanel/Result.text = "¡Jugador %d gana el combate!" % winner
	else:
		$NextRoundTimer.start()

func _on_next_round_timer_timeout() -> void:
	if NetworkManager.local_mode:
		start_next_round()
	elif multiplayer.is_server():
		start_next_round.rpc()

@rpc("authority", "call_local", "reliable")
func start_next_round() -> void:
	for number in fighters:
		var fighter: Fighter = fighters[number]
		fighter.health = fighter.MAX_HEALTH
		fighter.defeated = false
		fighter.is_attacking = false
		fighter.global_position = Vector3(-4.0 if number == 1 else 4.0, 1.2, 0.0)
		_on_health_changed(number, fighter.health)
	round_active = true
	announcement.visible = false

func _update_round_label() -> void:
	round_label.text = "MEJOR DE 3   J1: %d  —  %d :J2" % [rounds_won[0], rounds_won[1]]

func _on_return_button_pressed() -> void:
	NetworkManager.close_connection()
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")

func _on_player_disconnected(_peer_id: int) -> void:
	announcement.text = "El otro jugador se desconectó."
	announcement.visible = true
	$DisconnectTimer.start()

func _on_disconnect_timer_timeout() -> void:
	NetworkManager.close_connection()
	get_tree().change_scene_to_file("res://escenas/MenuPrincipal.tscn")
