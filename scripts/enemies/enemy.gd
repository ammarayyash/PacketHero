extends CharacterBody2D
class_name EnemyBase
# enemy.gd — Basis Musuh (Layer 3 Enemy, Stomp Mechanic, Drop Koin, Group Resettable)

signal died

@export var hp              : int   = 1
@export var move_speed      : float = 60.0
@export var exp_reward      : int   = Config.ENEMY_KILL_EXP
@export var damage          : int   = 1
@export var can_patrol      : bool  = true
@export var is_flying       : bool  = false
@export var jarak           : float = 120.0:
	set(val):
		jarak = val
		if patrol_distance != val:
			patrol_distance = val
@export var patrol_distance : float = 120.0:
	set(val):
		patrol_distance = val
		if jarak != val:
			jarak = val

var _hp_current  : int     = 1
var _is_alive    : bool    = true
var _start_pos   : Vector2 = Vector2.ZERO
var _facing      : int     = -1
var _left_bound  : float   = 0.0
var _right_bound : float   = 0.0

@onready var anim            : AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var sprite          : Sprite2D         = get_node_or_null("Sprite2D")
@onready var collision_shape : CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var hitbox          : Area2D           = get_node_or_null("Hitbox")
@onready var stomp_area      : Area2D           = get_node_or_null("StompArea")

func _ready() -> void:
	# Group wajib
	add_to_group("enemy")
	add_to_group("resettable")

	# Layer 3 = Enemy (bit 3 = 4)
	collision_layer = 4
	# Mask 1 = World (bit 1 = 1)
	collision_mask = 1

	_start_pos   = global_position
	var d        : float = jarak if jarak > 0.0 else patrol_distance
	_left_bound  = _start_pos.x - d
	_right_bound = _start_pos.x + d
	_hp_current  = hp

	if hitbox:
		# Layer 3 = Enemy, Mask 2 = Player
		hitbox.collision_layer = 4
		hitbox.collision_mask = 2
		hitbox.body_entered.connect(_on_hitbox_body_entered)

	if stomp_area:
		# Mask 2 = Player
		stomp_area.collision_layer = 0
		stomp_area.collision_mask = 2
		stomp_area.body_entered.connect(_on_stomp_area_body_entered)

	if anim and anim.sprite_frames:
		if is_flying and anim.sprite_frames.has_animation("fly"):
			anim.play("fly")
		elif anim.sprite_frames.has_animation("walk"):
			anim.play("walk")

func _physics_process(delta: float) -> void:
	if not _is_alive:
		return

	# Gravitasi jika bukan musuh terbang
	if not is_flying:
		if not is_on_floor():
			velocity.y = min(velocity.y + Config.GRAVITY * delta, 1200.0)
		else:
			velocity.y = 0.0
	else:
		velocity.y = 0.0

	# Gerak patroli horizontal antara dua titik
	if can_patrol:
		velocity.x = _facing * move_speed
		if global_position.x <= _left_bound:
			global_position.x = _left_bound
			_facing = 1
		elif global_position.x >= _right_bound:
			global_position.x = _right_bound
			_facing = -1

		# Balik arah jika menabrak dinding
		if is_on_wall():
			_facing = -_facing
			velocity.x = _facing * move_speed

		if anim:
			anim.flip_h = (_facing == 1)
		elif sprite:
			sprite.flip_h = (_facing == 1)
	else:
		velocity.x = 0.0

	move_and_slide()

# ── Deteksi Injakan (Stomp) ─────────────────────────────────
func _on_stomp_area_body_entered(body: Node2D) -> void:
	if not _is_alive or not body.is_in_group("player"):
		return
	# Syarat injak: pemain berada di atas musuh
	if body.global_position.y <= global_position.y + 4.0:
		_stomp(body)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if not _is_alive or not body.is_in_group("player"):
		return
	# Jika pemain bergerak ke bawah dan berada di atas musuh, prioritaskan sebagai injakan
	if "velocity" in body and body.velocity.y > 0.0 and body.global_position.y < global_position.y:
		_stomp(body)
		return
	# Kontak samping atau bawah -> damage pemain
	_damage_player(body)

func _stomp(body: Node2D) -> void:
	if not _is_alive:
		return
	_is_alive = false

	# Langsung nonaktifkan hitbox musuh seketika agar tidak melukai pemain
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		hitbox.collision_layer = 0
		hitbox.collision_mask = 0

	# Beri pemain sedikit i-frame agar kebal dari kontak sekunder frame ini
	if body.has_method("apply_stomp_iframe"):
		body.apply_stomp_iframe(0.35)
	elif "invulnerable_t" in body:
		body.invulnerable_t = max(body.invulnerable_t, 0.35)
		body.is_invulnerable = true

	# Pemain memantul mantap ke atas
	if "velocity" in body:
		body.velocity.y = Config.ENEMY_STOMP_BOUNCE
	if "air_jump_used" in body:
		body.air_jump_used = false
	if "coyote_t" in body:
		body.coyote_t = Config.COYOTE

	_die()

func _damage_player(body: Node2D) -> void:
	if not _is_alive:
		return
	# Cek apakah pemain sedang menginjak dari atas
	if "velocity" in body and ((body.velocity.y >= 0.0 and body.global_position.y < global_position.y + 4.0) or body.global_position.y < global_position.y - 6.0):
		_stomp(body)
		return
	if body.has_method("take_hit"):
		body.take_hit(global_position)
	else:
		GameState.take_damage(damage)

func take_hit(dmg: int = 1) -> void:
	if not _is_alive:
		return
	_hp_current -= dmg
	if _hp_current <= 0:
		_is_alive = false
		_die()
	else:
		if anim:
			var tw := create_tween()
			tw.tween_property(anim, "modulate", Color(2.0, 0.4, 0.4, 1.0), 0.05)
			tw.tween_property(anim, "modulate", Color.WHITE, 0.1)

# ── Kematian & Drop Koin ────────────────────────────────────
func _die() -> void:
	GameState.add_exp(exp_reward)
	if GameState.has_method("record_enemy_defeated"):
		GameState.record_enemy_defeated()

	_spawn_coin()
	died.emit()

	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/explosion.ogg")

	if anim:
		var tw := create_tween()
		tw.tween_property(anim, "modulate", Color(2.0, 0.3, 0.3, 1.0), 0.06)
		tw.tween_property(anim, "modulate:a", 0.0, 0.12)
		tw.tween_callback(_deactivate_for_reset)
	else:
		_deactivate_for_reset()

func _spawn_coin() -> void:
	var pickup_scene: PackedScene = load("res://scenes/pickups/Pickup.tscn") as PackedScene
	if pickup_scene:
		var coin: Node2D = pickup_scene.instantiate() as Node2D
		if coin:
			coin.set("jenis", 0) # Jenis.COIN
			coin.global_position = global_position + Vector2(0.0, -10.0)
			get_parent().add_child(coin)

func _deactivate_for_reset() -> void:
	hide()
	set_physics_process(false)
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	if stomp_area:
		stomp_area.set_deferred("monitoring", false)
		stomp_area.set_deferred("monitorable", false)

# ── Reset Level (Menghidupkan lagi) ─────────────────────────
func reset() -> void:
	_is_alive       = true
	_hp_current     = hp
	global_position = _start_pos
	velocity        = Vector2.ZERO
	_facing         = -1
	var d           : float = jarak if jarak > 0.0 else patrol_distance
	_left_bound     = _start_pos.x - d
	_right_bound    = _start_pos.x + d
	show()
	set_physics_process(true)

	if anim:
		anim.modulate = Color.WHITE
		if anim.sprite_frames:
			if is_flying and anim.sprite_frames.has_animation("fly"):
				anim.play("fly")
			elif anim.sprite_frames.has_animation("walk"):
				anim.play("walk")

	if collision_shape:
		collision_shape.set_deferred("disabled", false)
	if hitbox:
		hitbox.set_deferred("monitoring", true)
		hitbox.set_deferred("monitorable", true)
	if stomp_area:
		stomp_area.set_deferred("monitoring", true)
		stomp_area.set_deferred("monitorable", true)
