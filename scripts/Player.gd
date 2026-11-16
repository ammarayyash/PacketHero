extends CharacterBody2D
# Player.gd — Karakter Utama Pak E (Platformer 2D)

# ── Variabel state ─────────────────────────────────────────
var air_jump_used   : bool  = false
var is_invulnerable : bool  = false
var dash_t          : float = 0.0
var dash_cd_t       : float = 0.0
var invulnerable_t  : float = 0.0
var carried_item    : Node2D = null

var coyote_t         : float = 0.0
var buffer_t         : float = 0.0
var facing           : int   = 1
var speed_mult       : float = 1.0
var jump_mult        : float = 1.0
var booster_t        : float = 0.0
var _hurt_t          : float = 0.0
var _is_dead         : bool  = false

# ── Node refs ──────────────────────────────────────────────
@onready var anim        : AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox     : Area2D           = $Hurtbox
@onready var cam         : Camera2D         = $Camera2D
@onready var magnet_area : Area2D           = get_node_or_null("MagnetArea")
@onready var magnet_col  : CollisionShape2D = get_node_or_null("MagnetArea/CollisionShape2D")

func _ready() -> void:
	add_to_group("player")
	GameState.player_died.connect(_on_player_died)
	GameState.stats_changed.connect(_on_stats_changed)

	# Pastikan default checkpoint mengarah ke posisi awal level aktif jika belum diset
	if get_tree().current_scene:
		var cur_scene_path: String = get_tree().current_scene.scene_file_path
		if GameState.checkpoint.get("level") != cur_scene_path:
			GameState.checkpoint = {
				"level": cur_scene_path,
				"pos":   [global_position.x, global_position.y]
			}

	if hurtbox:
		hurtbox.collision_layer = 0
		hurtbox.set_collision_mask_value(1, false)
		hurtbox.set_collision_mask_value(2, false)
		hurtbox.set_collision_mask_value(3, true) # Layer 3 = Enemy
		hurtbox.set_collision_mask_value(4, true) # Layer 4 = Hazard
		hurtbox.area_entered.connect(_on_hurtbox_area_entered)
		hurtbox.body_entered.connect(_on_hurtbox_body_entered)

	if magnet_area:
		magnet_area.collision_layer = 0
		magnet_area.set_collision_mask_value(1, false)
		magnet_area.set_collision_mask_value(2, false)
		magnet_area.set_collision_mask_value(5, true) # Layer 5 = Pickup
		magnet_area.area_entered.connect(_on_magnet_area_entered)
		_update_magnet_radius()

func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	# Arah gerak horizontal
	var dir : float = Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		facing = int(sign(dir))

	# ── Timer Cooldown Dash & Kebal ──
	if dash_cd_t > 0.0:
		dash_cd_t = max(dash_cd_t - delta, 0.0)

	if invulnerable_t > 0.0:
		invulnerable_t = max(invulnerable_t - delta, 0.0)
		is_invulnerable = true
	else:
		is_invulnerable = false

	# ── Timer Booster (Speed & Jump Multiplier) ──
	if booster_t > 0.0:
		booster_t = max(booster_t - delta, 0.0)
		if booster_t == 0.0:
			speed_mult = 1.0
			jump_mult  = 1.0

	# ── Input & Eksekusi Dash (Memakai 20 Energy) ──
	if GameState.has_dash and dash_cd_t == 0.0 and Input.is_action_just_pressed("dash"):
		if GameState.use_energy(Config.ENERGY_COST_DASH):
			dash_t          = Config.DASH_TIME
			dash_cd_t       = Config.DASH_COOLDOWN
			invulnerable_t  = Config.DASH_IFRAME
			is_invulnerable = true
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/laser_active.ogg")

	# ── Gerakan Dash Aktif ──
	if dash_t > 0.0:
		dash_t = max(dash_t - delta, 0.0)
		velocity = Vector2(facing * Config.DASH_SPEED, 0.0)
		if anim:
			anim.scale = Vector2(1.35, 0.8) # Sprite sedikit memanjang selama dash
		move_and_slide()
		_update_animation()
		if dash_t == 0.0 and anim:
			anim.scale = Vector2(1.0, 1.0)
		return
	elif anim and anim.scale.x != 1.0 and scale == Vector2(1.0, 1.0):
		anim.scale = Vector2(1.0, 1.0)

	# ── Gravitasi & Coyote Time ──
	if is_on_floor():
		coyote_t      = Config.COYOTE
		air_jump_used = false
		if velocity.y > 10.0:
			_squash_land()
	else:
		coyote_t = max(coyote_t - delta, 0.0)
		velocity.y = min(velocity.y + Config.GRAVITY * delta, 1200.0)

	# ── Jump Buffer ──
	if Input.is_action_just_pressed("jump"):
		buffer_t = Config.JUMP_BUFFER
	else:
		buffer_t = max(buffer_t - delta, 0.0)

	# ── Eksekusi Lompat (Buffer + Coyote) ──
	if buffer_t > 0.0 and coyote_t > 0.0:
		velocity.y = Config.JUMP_V * jump_mult
		buffer_t   = 0.0
		coyote_t   = 0.0
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	# ── Eksekusi Double Jump di Udara (Maks 1x, Memakai 15 Energy) ──
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and GameState.has_double_jump and not air_jump_used:
		if GameState.use_energy(Config.ENERGY_COST_DJ):
			velocity.y    = Config.DOUBLE_JUMP_V * jump_mult
			air_jump_used = true
			buffer_t      = 0.0
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

	# ── Lompat Variabel (Tombol dilepas saat naik memotong kecepatan vertikal 50%) ──
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

	# Gerak horizontal
	velocity.x = dir * Config.SPEED * speed_mult
	move_and_slide()

	# ── Hurt cooldown ──
	if _hurt_t > 0.0:
		_hurt_t = max(_hurt_t - delta, 0.0)
		anim.modulate.a = 0.4 if fmod(_hurt_t, 0.1) < 0.05 else 1.0
	else:
		anim.modulate.a = 1.0

	_update_animation()

# ── Booster ────────────────────────────────────────────────
func apply_booster(duration: float = Config.BOOSTER_DURATION) -> void:
	speed_mult = Config.BOOSTER_SPEED_MULT
	jump_mult  = Config.BOOSTER_JUMP_MULT
	booster_t  = duration # Refresh durasi, tidak menumpuk multiplier

# ── Animasi ────────────────────────────────────────────────
func _update_animation() -> void:
	if not anim:
		return
	anim.flip_h = (facing == -1)
	if _hurt_t > 0.0 and dash_t <= 0.0:
		anim.play("hurt")
	elif dash_t > 0.0:
		anim.play("run")
	elif not is_on_floor():
		anim.play("jump" if velocity.y < 0.0 else "fall")
	elif abs(velocity.x) > 10.0:
		anim.play("run")
	else:
		anim.play("idle")

func _squash_land() -> void:
	var tw : Tween = create_tween()
	tw.tween_property(self, "scale", Vector2(1.2, 0.7), 0.05)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

# ── Magnet Koin ────────────────────────────────────────────
func _on_magnet_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin") and area.has_method("attract_to"):
		area.attract_to(self)

func _update_magnet_radius() -> void:
	if magnet_col and magnet_col.shape is CircleShape2D:
		(magnet_col.shape as CircleShape2D).radius = GameState.magnet_radius

# ── Damage & Respawn ───────────────────────────────────────
func apply_stomp_iframe(duration: float = 0.35) -> void:
	invulnerable_t = max(invulnerable_t, duration)
	is_invulnerable = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Abaikan jika ini trigger, pickup, koin, checkpoint, gate, atau portal
	if area.is_in_group("pickup") or area.is_in_group("coin") or area.is_in_group("trigger") or area.is_in_group("checkpoint") or area.is_in_group("gate") or area.is_in_group("portal"):
		return
	var area_parent := area.get_parent()
	if area_parent and (area_parent.is_in_group("pickup") or area_parent.is_in_group("trigger") or area_parent.is_in_group("checkpoint") or area_parent.is_in_group("coin")):
		return

	# Jika musuh: jika pemain sedang bergerak jatuh/menginjak dari atas atau sedang i-frame stomp, abaikan damage!
	if area.is_in_group("enemy") or (area_parent and area_parent.is_in_group("enemy")):
		if (velocity.y >= 0.0 and global_position.y < area.global_position.y) or is_invulnerable or invulnerable_t > 0.0:
			return # Stomp sedang berlangsung / kebal, abaikan damage!

	take_hit(area.global_position)

func _on_hurtbox_body_entered(body: Node2D) -> void:
	# Abaikan jika bukan enemy atau hazard
	if not body.is_in_group("enemy") and not body.is_in_group("hazard"):
		return

	# Jika musuh: jika pemain sedang bergerak jatuh/menginjak dari atas atau sedang i-frame stomp, abaikan damage!
	if body.is_in_group("enemy"):
		if (velocity.y >= 0.0 and global_position.y < body.global_position.y) or is_invulnerable or invulnerable_t > 0.0:
			return # Stomp sedang berlangsung / kebal, abaikan damage!

	take_hit(body.global_position)

func take_hit(source_pos: Vector2 = Vector2.ZERO) -> void:
	# Abaikan damage saat mati, sedang dalam i-frame hurt (1 detik), atau dalam dash i-frame
	if _is_dead or _hurt_t > 0.0 or is_invulnerable:
		return
	GameState.take_damage(1)
	_hurt_t = Config.HURT_COOLDOWN # 1.0 detik kebal & kedip
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/player_hit.ogg")

	# Knockback singkat
	var kb_dir : float = -facing
	if source_pos != Vector2.ZERO:
		kb_dir = -1.0 if source_pos.x > global_position.x else 1.0
	velocity = Vector2(kb_dir * 180.0, -220.0)

	if anim:
		anim.play("hurt")

func _on_player_died() -> void:
	_is_dead = true
	velocity = Vector2.ZERO
	if carried_item and is_instance_valid(carried_item):
		if carried_item.has_method("return_to_spawn"):
			carried_item.return_to_spawn()
		carried_item = null
	if anim:
		anim.play("hurt")
	await get_tree().create_timer(Config.DEATH_OVERLAY_DURATION).timeout
	_respawn()

func _respawn() -> void:
	_is_dead      = false
	_hurt_t       = 0.0
	air_jump_used = false
	booster_t     = 0.0
	speed_mult    = 1.0
	jump_mult     = 1.0
	velocity      = Vector2.ZERO
	if carried_item and is_instance_valid(carried_item):
		if carried_item.has_method("return_to_spawn"):
			carried_item.return_to_spawn()
		carried_item = null
	GameState.reset_for_respawn()
	
	var cp       : Dictionary = GameState.checkpoint
	var lvl      : String     = cp.get("level", "")
	var pos      : Array      = cp.get("pos", [global_position.x, global_position.y])
	var cur_path : String     = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""

	if lvl == "" or lvl == cur_path or not ResourceLoader.exists(lvl):
		if pos.size() >= 2:
			global_position = Vector2(pos[0], pos[1])
		get_tree().call_group("resettable", "reset")
	else:
		SceneTransition.change_scene(lvl)

func _on_stats_changed() -> void:
	_update_magnet_radius()
