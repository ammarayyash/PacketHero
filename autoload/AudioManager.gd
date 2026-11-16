extends Node

var _music_player : AudioStreamPlayer
var _sfx_players  : Array[AudioStreamPlayer] = []
var _sfx_index    := 0
const SFX_POOL    := 6

var music_volume := 0.8
var sfx_volume   := 1.0

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	for i in SFX_POOL:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_players.append(p)

func play_music(path: String, fade_in := true) -> void:
	if _music_player.stream and _music_player.playing:
		if fade_in:
			var tw := create_tween()
			tw.tween_property(_music_player, "volume_db", -40.0, 0.5)
			await tw.finished
	var stream := load(path)
	if stream == null:
		return
	_music_player.stream = stream
	_music_player.volume_db = linear_to_db(music_volume)
	_music_player.play()
	if fade_in:
		_music_player.volume_db = -40.0
		var tw2 := create_tween()
		tw2.tween_property(_music_player, "volume_db", linear_to_db(music_volume), 1.0)

func stop_music() -> void:
	_music_player.stop()

func play_sfx(path: String) -> void:
	var stream := load(path)
	if stream == null:
		return
	var player := _sfx_players[_sfx_index % SFX_POOL]
	_sfx_index += 1
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume)
	player.play()

func set_music_volume(v: float) -> void:
	music_volume = clamp(v, 0.0, 1.0)
	_music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(v: float) -> void:
	sfx_volume = clamp(v, 0.0, 1.0)
