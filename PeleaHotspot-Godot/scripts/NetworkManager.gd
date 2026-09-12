extends Node
## Autoload que centraliza ENet y evita que las escenas conozcan detalles de red.

signal connection_succeeded
signal connection_failed(message: String)
signal player_disconnected(peer_id: int)

const PORT := 7000
const MAX_CLIENTS := 1
var is_host := false
var local_mode := false

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func create_game() -> bool:
	close_connection()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(PORT, MAX_CLIENTS)
	if error != OK:
		connection_failed.emit("No se pudo abrir el puerto %d (error %d)." % [PORT, error])
		return false
	multiplayer.multiplayer_peer = peer
	is_host = true
	local_mode = false
	return true

func join_game(ip: String) -> bool:
	close_connection()
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(ip.strip_edges(), PORT)
	if error != OK:
		connection_failed.emit("IP no válida o error de red (%d)." % error)
		return false
	multiplayer.multiplayer_peer = peer
	is_host = false
	local_mode = false
	return true

func get_lan_addresses() -> PackedStringArray:
	# Puede haber varias interfaces; se muestran todas las IPv4 útiles al anfitrión.
	var addresses := PackedStringArray()
	for address in IP.get_local_addresses():
		if ":" not in address and not address.begins_with("127."):
			addresses.append(address)
	return addresses

func start_local_game() -> void:
	close_connection()
	local_mode = true
	is_host = true

func close_connection() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	is_host = false
	local_mode = false

func _on_connected() -> void:
	connection_succeeded.emit()

func _on_connection_failed() -> void:
	connection_failed.emit("No fue posible conectar con el host.")
	close_connection()

func _on_server_disconnected() -> void:
	connection_failed.emit("El host cerró la partida.")
	close_connection()

func _on_peer_disconnected(peer_id: int) -> void:
	player_disconnected.emit(peer_id)
