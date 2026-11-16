extends Node2D
class_name LaserKabel
# laser_kabel.gd — Laser kabel dua emitter + sinar aktif-padam (berkedip 0,5s sebelum aktif)

enum State { OFF, WARN, ON }

@export var on_time   : float = Config.LASER_DEFAULT_ON
@export var off_time  : float = Config.LASER_DEFAULT_OFF
@export var warn_time : float = Config.LASER_WARN_TIME
@export var length    : float = 200.0
@export var damage    : int   = Config.HAZARD_DAMAGE

var _state : State = State.OFF
var _timer : float = 0.0

@onready var emitter_a       : Node2D           = $EmitterA
@onready var emitter_b       : Node2D           = $EmitterB
@onready var beam_area       : Area2D           = $BeamArea
@onready var beam_collision  : CollisionShape2D = $BeamArea/CollisionShape2D
@onready var beam_visual     : ColorRect        = $BeamArea/BeamVisual
@onready var beam_core       : ColorRect        = $BeamArea/BeamVisual/BeamCore

func _ready() -> void:
	_setup_geometry()
	if beam_area:
		# Layer 4 = Hazard (bit 4 = 8)
		beam_area.collision_layer = 8
		# Mask 2 = Player (bit 2 = 2)
		beam_area.collision_mask = 2
		beam_area.body_entered.connect(_on_beam_body_entered)

	_enter_state(State.OFF)

func _setup_geometry() -> void:
	if emitter_b:
		emitter_b.position = Vector2(length, 0.0)

	if beam_collision and beam_collision.shape is RectangleShape2D:
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = Vector2(length, 8.0)
		beam_collision.shape = rect_shape
		beam_collision.position = Vector2(length / 2.0, 0.0)

	if beam_visual:
		beam_visual.position = Vector2(0.0, -4.0)
		beam_visual.size = Vector2(length, 8.0)

	if beam_core:
		beam_core.position = Vector2(0.0, 2.0)
		beam_core.size = Vector2(length, 4.0)

func _physics_process(delta: float) -> void:
	_timer += delta

	match _state:
		State.OFF:
			var wait_time: float = max(off_time - warn_time, 0.1)
			if _timer >= wait_time:
				_enter_state(State.WARN)

		State.WARN:
			# Efek berkedip cepat 0,5 detik sebelum aktif memberi telegraf visual jelas
			if beam_visual:
				beam_visual.visible = true
				beam_visual.color = Color(1.0, 0.25, 0.35, 0.8)
				var blink: bool = fmod(_timer, 0.1) < 0.05
				beam_visual.modulate.a = 0.85 if blink else 0.15

			if _timer >= warn_time:
				_enter_state(State.ON)

		State.ON:
			# Damage berkala jika pemain berdiri di jalur sinar laser
			if beam_area:
				for body in beam_area.get_overlapping_bodies():
					if body.is_in_group("player"):
						_apply_damage(body)

			if _timer >= on_time:
				_enter_state(State.OFF)

func _enter_state(new_state: State) -> void:
	_state = new_state
	_timer = 0.0

	match _state:
		State.OFF:
			if beam_collision:
				beam_collision.set_deferred("disabled", true)
			if beam_visual:
				beam_visual.visible = false
			_set_emitter_color(Color(0.2, 0.3, 0.45, 1.0))

		State.WARN:
			if beam_collision:
				beam_collision.set_deferred("disabled", true) # Belum memberi damage saat peringatan
			if beam_visual:
				beam_visual.visible = true
				beam_visual.color = Color(1.0, 0.3, 0.35, 0.75)
			_set_emitter_color(Color(1.0, 0.3, 0.3, 1.0))

		State.ON:
			if beam_collision:
				beam_collision.set_deferred("disabled", false)
			if beam_visual:
				beam_visual.visible = true
				beam_visual.color = Color(0.2, 0.85, 1.0, 0.95)
				beam_visual.modulate.a = 1.0
			_set_emitter_color(Color(0.3, 0.9, 1.0, 1.0))

			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/laser_active.ogg")

func _set_emitter_color(c: Color) -> void:
	if emitter_a and emitter_a.has_node("LED"):
		emitter_a.get_node("LED").modulate = c
	if emitter_b and emitter_b.has_node("LED"):
		emitter_b.get_node("LED").modulate = c

func _on_beam_body_entered(body: Node2D) -> void:
	if _state == State.ON and body.is_in_group("player"):
		_apply_damage(body)

func _apply_damage(body: Node2D) -> void:
	if body.has_method("take_hit"):
		body.take_hit(global_position)
	else:
		GameState.take_damage(damage)
