extends Node
## Música y efectos sintetizados: no se necesitan archivos binarios externos.

const SAMPLE_RATE := 22050.0
var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var phase := 0.0
var clock := 0.0
var hit_envelope := 0.0

func _ready() -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = 0.25
	player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -16.0
	add_child(player)
	player.play()
	playback = player.get_stream_playback()

func _process(delta: float) -> void:
	if playback == null:
		return
	clock += delta
	var frames := playback.get_frames_available()
	for frame in frames:
		var beat := int(clock * 2.0) % 4
		var notes := [110.0, 146.83, 164.81, 130.81]
		var frequency: float = notes[beat]
		var tone := sin(phase) * 0.08
		var hit := sin(phase * 4.0) * hit_envelope
		playback.push_frame(Vector2(tone + hit, tone + hit))
		phase = fmod(phase + TAU * frequency / SAMPLE_RATE, TAU)
		hit_envelope = move_toward(hit_envelope, 0.0, 0.0018)

func play_hit() -> void:
	hit_envelope = 0.28

func play_round() -> void:
	hit_envelope = 0.16
