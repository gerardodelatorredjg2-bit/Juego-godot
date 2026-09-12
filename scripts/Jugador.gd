extends CharacterBody3D
class_name Fighter
## La simulación de movimiento y daño ocurre en el host; los clientes envían entrada.

signal health_changed(player_number: int, value: int)
signal knocked_out(player_number: int)

@export var player_number := 1
@export var body_color := Color(0.2, 0.55, 1.0)
const SPEED := 6.0
const JUMP_VELOCITY := 9.0
const GRAVITY := 25.0
const MAX_HEALTH := 100
const ATTACK_TIME := 0.32
const ATTACK_RANGE := 2.25
const ATTACK_DAMAGE := 12

var health := MAX_HEALTH
var is_attacking := false
var is_blocking := false
var attack_timer := 0.0
var input_axis := 0.0
var input_jump := false
var input_attack := false
var input_block := false
var defeated := false
var local_offline := false

@onready var mesh: MeshInstance3D = $BodyMesh

func _ready() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = body_color
	mesh.material_override = material
	# Todos los nodos pertenecen al host: impide que un cliente altere vida o posición.
	set_multiplayer_authority(1)
	health_changed.emit(player_number, health)

func _physics_process(delta: float) -> void:
	if defeated:
		return
	if multiplayer.is_server() or local_offline:
		_read_local_input_if_needed()
		_simulate(delta)
		if not local_offline:
			sync_state.rpc(global_position, rotation.y, health, is_attacking, is_blocking)
	else:
		_send_client_input()

func _read_local_input_if_needed() -> void:
	var should_read := NetworkManager.local_mode or (NetworkManager.is_host and player_number == 1)
	if not should_read:
		return
	var prefix := "" if player_number == 1 else "p2_"
	input_axis = Input.get_axis(prefix + "move_left", prefix + "move_right")
	input_jump = Input.is_action_just_pressed(prefix + "jump")
	input_attack = Input.is_action_just_pressed(prefix + "attack")
	input_block = Input.is_action_pressed(prefix + "block")

func _send_client_input() -> void:
	# Sólo el jugador 2 remoto puede enviar su entrada al servidor.
	if player_number != 2:
		return
	var axis := Input.get_axis("move_left", "move_right")
	submit_input.rpc_id(1, axis, Input.is_action_just_pressed("jump"), Input.is_action_just_pressed("attack"), Input.is_action_pressed("block"))

@rpc("any_peer", "unreliable")
func submit_input(axis: float, jump: bool, attack: bool, block: bool) -> void:
	if multiplayer.is_server() and multiplayer.get_remote_sender_id() == 2 and player_number == 2:
		input_axis = clampf(axis, -1.0, 1.0)
		input_jump = input_jump or jump
		input_attack = input_attack or attack
		input_block = block

func _simulate(delta: float) -> void:
	velocity.x = move_toward(velocity.x, input_axis * SPEED, SPEED * 12.0 * delta)
	velocity.z = 0.0
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	if input_jump and is_on_floor():
		velocity.y = JUMP_VELOCITY
	input_jump = false
	is_blocking = input_block and not is_attacking
	if input_attack and not is_attacking:
		is_attacking = true
		attack_timer = ATTACK_TIME
		_try_hit_opponent()
	input_attack = false
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0.0:
			is_attacking = false
	move_and_slide()
	global_position.x = clampf(global_position.x, -10.0, 10.0)

func _try_hit_opponent() -> void:
	var opponent := get_tree().get_first_node_in_group("fighter_%d" % (2 if player_number == 1 else 1)) as Fighter
	if opponent and not opponent.defeated and absf(opponent.global_position.x - global_position.x) <= ATTACK_RANGE:
		if local_offline:
			opponent.receive_damage(ATTACK_DAMAGE, player_number)
		else:
			opponent.receive_damage.rpc(ATTACK_DAMAGE, player_number)

@rpc("authority", "call_local", "reliable")
func receive_damage(amount: int, _attacker: int) -> void:
	if defeated:
		return
	var final_damage := amount if not is_blocking else maxi(1, amount >> 2)
	health = maxi(0, health - final_damage)
	health_changed.emit(player_number, health)
	if health == 0:
		defeated = true
		knocked_out.emit(player_number)

@rpc("authority", "unreliable")
func sync_state(new_position: Vector3, new_rotation_y: float, new_health: int, attacking: bool, blocking: bool) -> void:
	if multiplayer.is_server():
		return
	global_position = new_position
	rotation.y = new_rotation_y
	health = new_health
	is_attacking = attacking
	is_blocking = blocking
	health_changed.emit(player_number, health)
