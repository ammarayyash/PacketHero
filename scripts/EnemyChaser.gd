extends CharacterBody2D
class_name EnemyChaser
# EnemyChaser.gd — AI Musuh: Patroli, Kejar Pemain, Animasi Spritesheet, dan Stomp Bounce

enum EnemyMode { GROUND_WALKER, FLYING }

@export var mode           : EnemyMode = EnemyMode.GROUND_WALKER
@export var hp             : int       = 1
@export var patrol_range   : float     = 160.0
@export var patrol_speed   : float     = 65.0
@export var chase_speed    : float     = 130.0
@export var detect_radius  : float     = 280.0
@export var attack_radius  : float     = 45.0
@export var exp_reward     : int       = 15
@export var damage         : int       = 1

@export var walk_anim      : String    = "walk"
@export var attack_anim    : String    = "attack"
@export var idle_anim      : String    = "idle"

const GRAVITY : float = 980.0

var _spawn_pos    : Vector2 = Vector2.ZERO
var _hp_current   : int     = 1
var _patrol_dir   : float   = 1.0
var _is_chasing   : bool    = false
var _is_dead      : bool    = false
var _attack_timer : float   = 0.0

@onready var anim   : AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox : Area2D           = $Hitbox

func _ready() -> void:
	_spawn_pos  = global_position
	_hp_current = hp
	add_to_group("resettable")
	add_to_group("enemy")

	# Layer 3 = Enemy, Mask 1 = World
	set_collision_layer_value(3, true)
	set_collision_mask_value(1, true)

	if hitbox:
		hitbox.add_to_group("enemy")
		hitbox.set_collision_layer_value(3, true)
		hitbox.set_collision_layer_value(4, true)
		hitbox.set_collision_mask_value(2, true)
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		hitbox.area_entered.connect(_on_hitbox_area_entered)

	_play_anim(walk_anim)

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_attack_timer = max(_attack_timer - delta, 0.0)
	var player : Node2D = _get_player()

	if player != null:
		var dist : float = global_position.distance_to(player.global_position)
		if dist <= detect_radius:
			_is_chasing = true
		elif dist > detect_radius * 1.5:
			_is_chasing = false

	if _is_chasing and player != null:
		_process_chase(player, delta)
	else:
		_process_patrol(delta)

	move_and_slide()
	_update_animation_and_facing()
	_check_continuous_contact()

func _process_patrol(delta: float) -> void:
	if mode == EnemyMode.GROUND_WALKER:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0.0

		if global_position.x > _spawn_pos.x + patrol_range:
			_patrol_dir = -1.0
		elif global_position.x < _spawn_pos.x - patrol_range:
			_patrol_dir = 1.0

		if is_on_wall():
			_patrol_dir *= -1.0

		velocity.x = _patrol_dir * patrol_speed

	elif mode == EnemyMode.FLYING:
		if global_position.x > _spawn_pos.x + patrol_range:
			_patrol_dir = -1.0
		elif global_position.x < _spawn_pos.x - patrol_range:
			_patrol_dir = 1.0

		velocity.x = _patrol_dir * patrol_speed
		velocity.y = sin(float(Time.get_ticks_msec()) * 0.003) * 35.0

func _process_chase(player: Node2D, delta: float) -> void:
	var to_player : Vector2 = (player.global_position - global_position)
	var dist : float = to_player.length()

	if mode == EnemyMode.GROUND_WALKER:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0.0

		var dir_x : float = 1.0 if to_player.x >= 0.0 else -1.0
		velocity.x = dir_x * chase_speed

		if dist <= attack_radius and _attack_timer <= 0.0:
			_attack_timer = 0.8
			_play_anim(attack_anim)

	elif mode == EnemyMode.FLYING:
		var dir : Vector2 = to_player.normalized()
		velocity = dir * chase_speed

		if dist <= attack_radius and _attack_timer <= 0.0:
			_attack_timer = 0.8
			_play_anim(attack_anim)

func _update_animation_and_facing() -> void:
	if _attack_timer > 0.4 and anim.sprite_frames.has_animation(attack_anim):
		_play_anim(attack_anim)
	else:
		_play_anim(walk_anim)

	if abs(velocity.x) > 5.0:
		anim.flip_h = (velocity.x < 0)

func _play_anim(anim_name: String) -> void:
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation(anim_name):
		if anim.animation != anim_name:
			anim.play(anim_name)

func _get_player() -> Node2D:
	var players : Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		return players[0] as Node2D
	return null

func _on_hitbox_body_entered(body: Node) -> void:
	_handle_player_contact(body)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		_handle_player_contact(area)
	elif area.get_parent() and area.get_parent().is_in_group("player"):
		_handle_player_contact(area.get_parent())

func _check_continuous_contact() -> void:
	if _is_dead or hitbox == null:
		return
	var overlapping : Array[Node2D] = hitbox.get_overlapping_bodies()
	for b in overlapping:
		if b.is_in_group("player"):
			_handle_player_contact(b)
			return

func _handle_player_contact(node: Node) -> void:
	if _is_dead:
		return
	var player_node : CharacterBody2D = node as CharacterBody2D
	if player_node != null and player_node.is_in_group("player"):
		# Injak musuh dari atas (stomp): pemain sedang bergerak jatuh atau posisi pemain di atas musuh
		var is_stomp : bool = (player_node.velocity.y >= 0.0 and player_node.global_position.y < global_position.y) or (player_node.global_position.y < global_position.y - 8.0)
		if is_stomp:
			if player_node.has_method("apply_stomp_iframe"):
				player_node.apply_stomp_iframe(0.35)
			if hitbox:
				hitbox.set_deferred("monitoring", false)
				hitbox.set_deferred("monitorable", false)
			player_node.velocity.y = -380.0
			take_hit(1)
		else:
			if player_node.has_method("take_hit"):
				player_node.take_hit(global_position)

func take_hit(dmg: int = 1) -> void:
	if _is_dead:
		return
	_hp_current -= dmg

	var tw : Tween = create_tween()
	tw.tween_property(anim, "modulate", Color(2.5, 0.4, 0.4, 1.0), 0.06)
	tw.tween_property(anim, "modulate", Color.WHITE, 0.1)

	if _hp_current <= 0:
		_die()

func _die() -> void:
	_is_dead = true
	if hitbox:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	AudioManager.play_sfx("res://assets/audio/sfx/explosion.ogg")
	GameState.add_exp(exp_reward)
	GameState.add_bandwidth(3)
	GameState.record_enemy_defeated()

	var tw : Tween = create_tween()
	tw.tween_property(self, "scale", Vector2(0.1, 0.1), 0.18)
	tw.tween_callback(func() -> void:
		visible = false
		set_physics_process(false)
	)

func reset() -> void:
	_is_dead = false
	_hp_current = hp
	_is_chasing = false
	_patrol_dir = 1.0
	_attack_timer = 0.0
	global_position = _spawn_pos
	scale = Vector2.ONE
	visible = true
	set_physics_process(true)
	if hitbox:
		hitbox.set_deferred("monitoring", true)
		hitbox.set_deferred("monitorable", true)
	_play_anim(walk_anim)
