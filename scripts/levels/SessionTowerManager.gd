extends Node2D
# SessionTowerManager.gd — Mengelola mekanik sesi berbatas waktu di Session Tower (L5)
class_name SessionTowerManager

signal session_started
signal session_ended(success: bool)

@export var session_duration   : float   = 60.0
@export var keep_alive_bonus   : float   = 10.0
@export var base_reset_pos     : Vector2 = Vector2(5500, 580)
@export var gate_l5_path       : NodePath

var is_session_active : bool  = false
var session_completed : bool  = false
var time_left         : float = 0.0

var _gate_l5  : Node   = null
var _player   : Node2D = null

func _ready() -> void:
	add_to_group("resettable")
	call_deferred("_bind_gate")

func _bind_gate() -> void:
	if has_node(gate_l5_path):
		_gate_l5 = get_node(gate_l5_path)
		if _gate_l5 and not GameState.gates_cleared.has("L5"):
			_gate_l5.set("locked", true)

func _process(delta: float) -> void:
	if not is_session_active:
		return
		
	time_left -= delta
	_update_hud_timer()
	
	if time_left <= 0.0:
		_on_timeout()

func start_session(player: Node2D) -> void:
	if session_completed:
		return
	_player = player
	is_session_active = true
	time_left = Config.SESSION_TOWER_DURATION
	_update_hud_timer()
	session_started.emit()
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/checkpoint.ogg")

func add_time(bonus: float = 10.0) -> void:
	if is_session_active:
		time_left += bonus
		_update_hud_timer()
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/pickup_coin.ogg")

func close_session() -> void:
	if not is_session_active:
		return
	is_session_active = false
	session_completed = true
	_hide_hud_timer()
	if _gate_l5 and _gate_l5.has_method("unlock_gate"):
		_gate_l5.unlock_gate()
	session_ended.emit(true)
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/gate_open.ogg")

func _on_timeout() -> void:
	is_session_active = false
	_hide_hud_timer()
	session_ended.emit(false)
	
	# Kembalikan pemain ke dasar menara tanpa kehilangan Integrity
	if _player and is_instance_valid(_player):
		_player.global_position = base_reset_pos
		_player.velocity = Vector2.ZERO
		
	# Reset token keep-alive
	get_tree().call_group("keep_alive_token", "reset_token")
	
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/player_hit.ogg")

func _update_hud_timer() -> void:
	var hud := _get_hud()
	if hud and hud.has_method("set_session_timer"):
		hud.set_session_timer(maxf(time_left, 0.0), true)

func _hide_hud_timer() -> void:
	var hud := _get_hud()
	if hud and hud.has_method("set_session_timer"):
		hud.set_session_timer(0.0, false)

func _get_hud() -> Node:
	if get_tree().current_scene:
		return get_tree().current_scene.get_node_or_null("UI_HUD")
	return null

func reset() -> void:
	if is_session_active:
		is_session_active = false
		_hide_hud_timer()
