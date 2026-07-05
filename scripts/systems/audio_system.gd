extends Node

const AUDIO_SAMPLE_RATE := 22050

var bgm_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var audio_streams: Dictionary = {}
var enabled := true


func _ready() -> void:
	_setup_audio()


func set_enabled(value: bool) -> void:
	enabled = value
	_update_audio_state()


func play_sfx(sound_name: String) -> void:
	if not enabled or not audio_streams.has(sound_name):
		return
	var stream: AudioStream = audio_streams[sound_name]
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.play()
			return
	if sfx_players.is_empty():
		return
	var fallback_player := sfx_players[0]
	fallback_player.stop()
	fallback_player.stream = stream
	fallback_player.play()


func _setup_audio() -> void:
	audio_streams = {
		"feed": _make_tone_stream([620.0, 760.0], 0.08, 0.28, 0.08),
		"coin": _make_tone_stream([880.0, 1170.0, 1480.0], 0.14, 0.34, 0.07),
		"buy": _make_tone_stream([520.0, 700.0, 920.0], 0.18, 0.3, 0.06),
		"hit": _make_tone_stream([180.0, 120.0], 0.09, 0.42, 0.05),
		"defeat": _make_tone_stream([240.0, 360.0, 520.0], 0.18, 0.44, 0.09),
		"warning": _make_tone_stream([340.0, 220.0, 340.0], 0.28, 0.36, 0.1),
		"clear": _make_tone_stream([620.0, 820.0, 1040.0, 1320.0], 0.42, 0.34, 0.08),
		"fail": _make_tone_stream([300.0, 230.0, 160.0], 0.36, 0.34, 0.09),
	}

	for index in range(6):
		var player := AudioStreamPlayer.new()
		player.volume_db = -9.0
		sfx_players.append(player)
		add_child(player)

	bgm_player = AudioStreamPlayer.new()
	bgm_player.stream = _make_bgm_stream()
	bgm_player.volume_db = -24.0
	add_child(bgm_player)
	_update_audio_state()


func _make_tone_stream(notes: Array[float], duration: float, volume: float, decay_power: float) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	var sample_count: int = int(AUDIO_SAMPLE_RATE * duration)
	var data := PackedByteArray()
	var note_count: int = max(1, notes.size())
	for sample_index in range(sample_count):
		var progress: float = float(sample_index) / float(max(1, sample_count - 1))
		var note_index: int = min(note_count - 1, int(progress * note_count))
		var frequency: float = notes[note_index]
		var local_progress: float = fmod(progress * float(note_count), 1.0)
		var envelope: float = pow(1.0 - progress, decay_power) * min(1.0, local_progress * 14.0)
		var wave: float = sin(TAU * frequency * float(sample_index) / float(AUDIO_SAMPLE_RATE))
		var sample: int = int(clamp(wave * envelope * volume * 32767.0, -32768.0, 32767.0))
		_append_i16(data, sample)
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = AUDIO_SAMPLE_RATE
	stream.stereo = false
	stream.data = data
	return stream


func _make_bgm_stream() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	var duration := 4.0
	var sample_count: int = int(AUDIO_SAMPLE_RATE * duration)
	var data := PackedByteArray()
	var chord: Array[float] = [196.0, 246.94, 293.66, 392.0]
	for sample_index in range(sample_count):
		var time: float = float(sample_index) / float(AUDIO_SAMPLE_RATE)
		var bar_progress: float = fmod(time, 1.0)
		var pulse: float = 0.58 + 0.42 * sin(TAU * bar_progress)
		var wave := 0.0
		for note_index in range(chord.size()):
			var frequency: float = chord[note_index] * (1.0 + 0.005 * sin(time * 0.7 + float(note_index)))
			wave += sin(TAU * frequency * time) * 0.18
		wave += sin(TAU * 98.0 * time) * 0.12
		var sample: int = int(clamp(wave * pulse * 0.55 * 32767.0, -32768.0, 32767.0))
		_append_i16(data, sample)
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = AUDIO_SAMPLE_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = sample_count
	stream.data = data
	return stream


func _append_i16(data: PackedByteArray, sample: int) -> void:
	var value := sample
	if value < 0:
		value += 65536
	data.append(value & 0xff)
	data.append((value >> 8) & 0xff)


func _update_audio_state() -> void:
	if bgm_player == null:
		return
	if enabled:
		if not bgm_player.playing:
			bgm_player.play()
	else:
		bgm_player.stop()
